FROM centos:7

RUN mkdir /etc/yum.repos.d/bak
RUN mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak || true
ADD aliyun.repo /etc/yum.repos.d/aliyun.repo
ADD mariadb.repo /etc/yum.repos.d/mariadb.repo
ADD kubernetes.repo /etc/yum.repos.d/kubernetes.repo
RUN yum makecache
RUN yum -y install gcc pcre-devel openssl-devel bind-utils


RUN useradd nginx
ADD ./nginx-1.22.0.tar.gz /
RUN /nginx-1.22.0/configure --prefix=/usr/local/nginx --user=nginx --group=nginx --with-http_ssl_module --with-http_stub_status_module
RUN cd /nginx-1.22.0 && make && make install

#RUN rm -f /usr/local/nginx/conf/nginx.conf  # configmap使用测试,使用cm挂载该文件
RUN ln -s /dev/stdout /usr/local/nginx/logs/access.log  # 将应用日志打印到容器输出
RUN ln -s /dev/stderr /usr/local/nginx/logs/error.log

ADD src/* /usr/local/nginx/html/

EXPOSE 80
#ENTRYPOINT ["nginx"]    #为了在workload配置启动命令，不使用ENTRYPOINT
#CMD ["-g", "daemon off;"]
CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
