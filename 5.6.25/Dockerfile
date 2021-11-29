FROM centos:latest

EXPOSE 3306

ENV MYSQL_VERSION      5.6.25
ENV MYSQL_PACKAGE_NAME mysql-${MYSQL_VERSION}
ENV MYSQL_RPM_URL_BASE http://downloads.mysql.com/archives/get/p/23/file
ENV SOURCE_TAR         ${MYSQL_PACKAGE_NAME}.tar.gz
ENV DEBUG_DIR          /export/home/pb2/build/sb_0-15205200-1430827758.79/rpm/BUILD/${MYSQL_PACKAGE_NAME}/${MYSQL_PACKAGE_NAME}

RUN mkdir -p $(dirname ${DEBUG_DIR})

RUN yum install -y gdb tar gzip perl-Data-Dumper && \
    yum install -y ${MYSQL_RPM_URL_BASE}/MySQL-server-${MYSQL_VERSION}-1.linux_glibc2.5.x86_64.rpm \
    ${MYSQL_RPM_URL_BASE}/MySQL-client-${MYSQL_VERSION}-1.linux_glibc2.5.x86_64.rpm && \
    yum clean all

RUN curl -LO ${MYSQL_RPM_URL_BASE}/${SOURCE_TAR} && \
    tar -C /home -zxf ${SOURCE_TAR} && \
    rm -f ${SOURCE_TAR} && \
    ln -s /home/${MYSQL_PACKAGE_NAME} ${DEBUG_DIR} && \
    rm -rf /home/${MYSQL_PACKAGE_NAME}/mysql-test

ADD start_mysql.sh /start_mysql.sh
ADD my.cnf /etc/my.cnf

RUN chown -R mysql:mysql /var/lib/mysql
RUN rm -rf /var/lib/mysql
RUN mysql_install_db
    
ENTRYPOINT bash /start_mysql.sh

# Install debuginfo
RUN sed -i 's/enabled=0/enable=1/g' /etc/yum.repos.d/CentOS-Linux-Debuginfo.repo
RUN yum -y debuginfo-install MySQL-server-5.6.25-1.linux_glibc2.5.x86_64

# Set workdir
WORKDIR /home/