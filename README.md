
#### docker-compose.yml
```shell
version: '3'

services:
  mysql:
    image: ipking/mysql-gdb:5.6.25
    container_name: mysql-gdb
    init: true
    user: root
    ports:
      - '3306:3306'
    # volumes:
      # - ./my.cnf:/etc/my.cnf
      # - ./docker-entrypoint.sh:/work/docker-entrypoint.sh
    environment:
      - TZ=Asia/Shanghai
      - LANG=C.UTF-8
      # - MYSQL_ROOT_PASSWORD=pass
    deploy:
      resources:
        limits:
          cpus: '0.8'
          memory: 1024m
    privileged: true
    cap_add:
      - SYS_PTRACE
    security_opt:
      - seccomp:unconfined
```

#### 启动容器

```shell
> docker-compose up -d
> docker exec -it mysql-gdb bash
[root@10c1bbb7fa2d home]#
```


#### 启动 gdb

```shell
# 启动 gdb 并调试 mysqld 进程269
[root@10c1bbb7fa2d home]# gdb -p 269
GNU gdb (GDB) Red Hat Enterprise Linux 8.2-16.el8

Attaching to process 269
[New LWP 270]
...
[New LWP 294]
[Thread debugging using libthread_db enabled]
Using host libthread_db library "/lib64/libthread_db.so.1".
0x00007fc5d6bc8a41 in poll () from /lib64/libc.so.6
Missing separate debuginfos, use: yum debuginfo-install MySQL-server-5.6.25-1.linux_glibc2.5.x86_64
(gdb)
```

#### 设置 breakpoint

```shell
(gdb) b do_select
Breakpoint 1 at 0x6d505b: file /export/home/pb2/build/sb_0-15205200-1430827758.79/rpm/BUILD/mysql-5.6.25/mysql-5.6.25/sql/sql_optimizer.h, line 473.
(gdb) b do_command
Breakpoint 2 at 0x702d2c: file /export/home/pb2/build/sb_0-15205200-1430827758.79/rpm/BUILD/mysql-5.6.25/mysql-5.6.25/sql/sql_parse.cc, line 914.
(gdb) b JOIN::exec
Breakpoint 3 at 0x6d4d92: file /export/home/pb2/build/sb_0-15205200-1430827758.79/rpm/BUILD/mysql-5.6.25/mysql-5.6.25/sql/sql_executor.cc, line 99.
```

#### 保存 breakpoint

```shell
(gdb) save breakpoints /home/mysql-breakpoints.txt
Saved to file '/home/mysql-breakpoints.txt'.
```

#### 加载 breakpoint

```shell
(gdb) source /home/mysql-breakpoints.txt
Breakpoint 4 at 0x6d505b: file /export/home/pb2/build/sb_0-15205200-1430827758.79/rpm/BUILD/mysql-5.6.25/mysql-5.6.25/sql/sql_optimizer.h, line 473.
Breakpoint 5 at 0x702d2c: file /export/home/pb2/build/sb_0-15205200-1430827758.79/rpm/BUILD/mysql-5.6.25/mysql-5.6.25/sql/sql_parse.cc, line 914.
Breakpoint 6 at 0x6d4d92: file /export/home/pb2/build/sb_0-15205200-1430827758.79/rpm/BUILD/mysql-5.6.25/mysql-5.6.25/sql/sql_executor.cc, line 99.
```

#### mysql 客户端发起查询

```mysql
mysql> select Host from mysql.user;
# 此处查询挂起，等待gdb执行
```

#### 进入gdb调试

```shell
(gdb) c
Continuing.
[Switching to Thread 0x7fc5ace53700 (LWP 343)]

Thread 23 "mysqld" hit Breakpoint 3, JOIN::exec (this=0x7fc598005680) at /export/home/pb2/build/sb_0-15205200-1430827758.79/rpm/BUILD/mysql-5.6.25/mysql-5.6.25/sql/sql_executor.cc:99
99        Opt_trace_context * const trace= &thd->opt_trace;
(gdb) bt
#0  JOIN::exec (this=0x7fc598005680) at /export/home/pb2/build/sb_0-15205200-1430827758.79/rpm/BUILD/mysql-5.6.25/mysql-5.6.25/sql/sql_executor.cc:99
#1  0x000000000071cb79 in mysql_execute_select (thd=0x1af0f20, select_lex=0x1af33c8, free_join=true) at /export/home/pb2/build/sb_0-15205200-1430827758.79/rpm/BUILD/mysql-5.6.25/mysql-5.6.25/sql/sql_select.cc:1100
#2  0x000000000071d63c in mysql_select (thd=0x1af0f20, tables=<optimized out>, wild_num=<optimized out>, fields=..., conds=<optimized out>, order=<optimized out>, group=0x1af34c8, having=0x0, select_options=2147748608,
    result=0x7fc598005658, unit=0x1af2d80, select_lex=0x1af33c8) at /export/home/pb2/build/sb_0-15205200-1430827758.79/rpm/BUILD/mysql-5.6.25/mysql-5.6.25/sql/sql_select.cc:1221
#3  0x000000000071d845 in handle_select (thd=0x1af0f20, result=0x7fc598005658, setup_tables_done_option=0) at /export/home/pb2/build/sb_0-15205200-1430827758.79/rpm/BUILD/mysql-5.6.25/mysql-5.6.25/sql/sql_select.cc:110
#4  0x00000000006f7669 in execute_sqlcom_select (thd=0x1af0f20, all_tables=0x7fc598005048) at /export/home/pb2/build/sb_0-15205200-1430827758.79/rpm/BUILD/mysql-5.6.25/mysql-5.6.25/sql/sql_parse.cc:5134
#5  0x00000000006fbdce in mysql_execute_command (thd=0x1af0f20) at /export/home/pb2/build/sb_0-15205200-1430827758.79/rpm/BUILD/mysql-5.6.25/mysql-5.6.25/sql/sql_parse.cc:2656
#6  0x00000000006ffaf8 in mysql_parse (thd=0x1af0f20, rawbuf=0x1af0f88 "", length=<optimized out>, parser_state=<optimized out>)
    at /export/home/pb2/build/sb_0-15205200-1430827758.79/rpm/BUILD/mysql-5.6.25/mysql-5.6.25/sql/sql_parse.cc:6386
#7  0x0000000000701518 in dispatch_command (command=COM_QUERY, thd=0x1af0f20, packet=0x1afd021 "select Host from mysql.user", packet_length=27)
    at /export/home/pb2/build/sb_0-15205200-1430827758.79/rpm/BUILD/mysql-5.6.25/mysql-5.6.25/sql/sql_parse.cc:1340
#8  0x0000000000702df7 in do_command (thd=0x1af0f20) at /export/home/pb2/build/sb_0-15205200-1430827758.79/rpm/BUILD/mysql-5.6.25/mysql-5.6.25/sql/sql_parse.cc:1037
#9  0x00000000006c9f76 in do_handle_one_connection (thd_arg=0x1af0f20) at /export/home/pb2/build/sb_0-15205200-1430827758.79/rpm/BUILD/mysql-5.6.25/mysql-5.6.25/sql/sql_connect.cc:982
#10 0x00000000006ca055 in handle_one_connection (arg=0x1af0f20) at /export/home/pb2/build/sb_0-15205200-1430827758.79/rpm/BUILD/mysql-5.6.25/mysql-5.6.25/sql/sql_connect.cc:898
#11 0x0000000000997976 in pfs_spawn_thread (arg=<optimized out>) at /export/home/pb2/build/sb_0-15205200-1430827758.79/rpm/BUILD/mysql-5.6.25/mysql-5.6.25/storage/perfschema/pfs.cc:1860
#12 0x00007fc5d800b14a in start_thread () from /lib64/libpthread.so.0
#13 0x00007fc5d6bd3dc3 in clone () from /lib64/libc.so.6
```

#### mysql返回执行结果

```mysql
mysql> select Host from mysql.user;
+-----------------+
| Host            |
+-----------------+
| %               |
| 127.0.0.1       |
| ::1             |
| buildkitsandbox |
| buildkitsandbox |
| localhost       |
| localhost       |
+-----------------+
7 rows in set (1 min 37.97 sec)
```