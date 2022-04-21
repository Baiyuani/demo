FROM registry.cn-shanghai.aliyuncs.com/baiyuani/web1:0.0.1

ADD web/index.html /usr/share/nginx/html/
RUN mkdir -p /usr/share/nginx/html/web
ADD web/web1/* /usr/share/nginx/html/web/

RUN rm -f /etc/yum.repos.d/CentOS-Linux-*
ADD Centos-vault-8.5.2111.repo /etc/yum.repos.d/aliyun.repo
RUN yum makecache