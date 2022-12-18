FROM ubuntu:20.04 AS build-source
WORKDIR /usr/local

RUN apt update -y && apt -y install ca-certificates gcc libpcre3-dev zlib1g-dev bind9-utils make

ADD ./nginx-1.22.0.tar.gz /
WORKDIR /nginx-1.22.0
RUN ./configure --prefix=/usr/local/nginx --user=nobody
# RUN ./configure --prefix=/usr/local/nginx --user=nobody --group=nobody --with-http_ssl_module --with-http_stub_status_module
RUN make && make install

#RUN rm -f /usr/local/nginx/conf/nginx.conf  # configmap使用测试,使用cm挂载该文件
RUN ln -s /dev/stdout /usr/local/nginx/logs/access.log  # 将应用日志打印到容器输出
RUN ln -s /dev/stderr /usr/local/nginx/logs/error.log



FROM ubuntu:20.04

COPY --from=build-source /usr/local/nginx /usr/local/nginx
WORKDIR /usr/local/nginx/html/
ADD src .

RUN apt -y update && apt -y install curl vim iproute2 bash-completion netcat-traditional tcpdump telnet ca-certificates iputils-ping
ADD sources.list /etc/apt/
#RUN apt -y install apt-transport-https software-properties-common
#RUN curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add - && echo "deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main" >/etc/apt/sources.list.d/kubernetes.list
#RUN curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | apt-key add - && add-apt-repository -y "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu focal stable"
#RUN curl -o /etc/apt/trusted.gpg.d/mariadb_release_signing_key.asc 'https://mariadb.org/mariadb_release_signing_key.asc' && sh -c "echo '\ndeb [arch=amd64] https://mirrors.aliyun.com/mariadb/repo/10.5/ubuntu focal main' >>/etc/apt/sources.list"
RUN apt -y update

EXPOSE 80
#ENTRYPOINT ["nginx"]    #为了在workload配置启动命令，不使用ENTRYPOINT
#CMD ["-g", "daemon off;"]
CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
