FROM registry.cn-shanghai.aliyuncs.com/baiyuani/web1:0.0.1

ADD web/index.html /usr/share/nginx/html/
RUN mkdir -p /usr/share/nginx/html/web
ADD web/web1/* /usr/share/nginx/html/web/
