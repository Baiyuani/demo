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


RUN apt update -y && apt -y install ca-certificates && update-ca-certificates && \
    apt -y update && apt-get -y upgrade && \
    apt-get -y -f install iproute2 curl bash-completion gnupg tcpdump telnet ca-certificates iputils-ping bind9-utils dnsutils netcat && \
    curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add - && \
    echo 'deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main' >> /etc/apt/sources.list.d/kubernetes.list && \
    apt -y update && \
    apt -y install kubectl=1.23.15-00 && \
    apt-get clean all && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/*

ADD sources.list /etc/apt/
RUN apt -y update

EXPOSE 80
#ENTRYPOINT ["nginx"]    #为了在workload配置启动命令，不使用ENTRYPOINT
#CMD ["-g", "daemon off;"]
CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
