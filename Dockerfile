FROM ubuntu:20.04

ADD sources.list /etc/apt/
RUN apt update -y && apt -y upgrade && sleep 1
RUN apt -y install gcc pcre-devel openssl-devel bind-utils make vim-enhanced iproute bash-completion nmap tcpdump telnet curl

RUN curl https://mirrors.aliyun.com/kubernetes/apt/doc/apt-key.gpg | apt-key add - && echo "deb https://mirrors.aliyun.com/kubernetes/apt/ kubernetes-xenial main" >/etc/apt/sources.list.d/kubernetes.list
RUN apt -y install apt-transport-https ca-certificates software-properties-common
RUN curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | apt-key add - && add-apt-repository -y "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable" && apt -y update

ADD ./nginx-1.22.0.tar.gz /

WORKDIR /nginx-1.22.0
RUN ./configure --prefix=/usr/local/nginx --user=nobody --group=nobody --with-http_ssl_module --with-http_stub_status_module
RUN make && make install

#RUN rm -f /usr/local/nginx/conf/nginx.conf  # configmap使用测试,使用cm挂载该文件
RUN ln -s /dev/stdout /usr/local/nginx/logs/access.log  # 将应用日志打印到容器输出
RUN ln -s /dev/stderr /usr/local/nginx/logs/error.log

WORKDIR /usr/local/nginx/html/
ADD src .

EXPOSE 80
#ENTRYPOINT ["nginx"]    #为了在workload配置启动命令，不使用ENTRYPOINT
#CMD ["-g", "daemon off;"]
CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]
