FROM centos

RUN rm -f /etc/yum.repos.d/CentOS-Linux-* || true
ADD Centos-vault-8.5.2111.repo /etc/yum.repos.d/aliyun.repo
RUN yum makecache || true
RUN yum -y install nginx bind-utils

RUN rm -f /etc/nginx/nginx.conf  # configmap使用测试,使用cm挂载该文件
RUN ln -s /dev/stdout /var/log/nginx/access.log  # 将应用日志打印到容器输出
RUN ln -s /dev/stderr /var/log/nginx/error.log

ADD src/index.html /usr/share/nginx/html/
RUN mkdir -p /usr/share/nginx/html/web
ADD src/web/* /usr/share/nginx/html/web/

EXPOSE 80
#ENTRYPOINT ["nginx"]    #为了在workload配置启动命令，不使用ENTRYPOINT
#CMD ["-g", "daemon off;"]
CMD ["nginx", "-g", "daemon off;"]
