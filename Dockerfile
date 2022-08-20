FROM centos:7

RUN mkdir /etc/yum.repos.d/bak
RUN mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak || true
ADD aliyun.repo /etc/yum.repos.d/aliyun.repo
ADD mariadb.repo /etc/yum.repos.d/mariadb.repo
ADD kubernetes.repo /etc/yum.repos.d/kubernetes.repo

RUN yum makecache
RUN yum -y install nginx bind-utils

RUN rm -f /etc/nginx/nginx.conf  # configmap使用测试,使用cm挂载该文件
RUN ln -s /dev/stdout /var/log/nginx/access.log  # 将应用日志打印到容器输出
RUN ln -s /dev/stderr /var/log/nginx/error.log

ADD src/* /usr/share/nginx/html/

EXPOSE 80
#ENTRYPOINT ["nginx"]    #为了在workload配置启动命令，不使用ENTRYPOINT
#CMD ["-g", "daemon off;"]
CMD ["nginx", "-g", "daemon off;"]
