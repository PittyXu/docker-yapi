# 基于 alpine镜像构建
FROM alpine:latest
# 镜像维护者的信息
LABEL MAINTAINER = 'crper@outlook.com(https://github.com/crper)'
# 基础环境构建
# - 更新源
# - 安装基础环境包
# - 不用更改默认shell了,只要进入的镜像的时候指定shell即可
# - 最后是删除一些缓存
# - 克隆项目
# - 采用自动化构建不考虑国内npm源了 , 可以降低初始化失败的概率
# !! yapi 官方的内网部署教程: https://yapi.ymfe.org/devops/index.html
RUN apk update \
  && apk add --no-cache python2 python2-dev gcc libcurl make git nodejs npm bash vim \
  && rm -rf /var/cache/apk/* \
  && npm i -g node-gyp ykit yapi-cli npm@latest --registry https://registry.npm.taobao.org \
  && mkdir /yapi

COPY vendors /yapi/vendors/
# 配置yapi的配置文件
COPY config.json /yapi/
# 复制执行脚本到容器的执行目录
COPY entrypoint.sh /usr/local/bin/
# 写好的vim配置文件复制进去
COPY .vimrc /root/

# 工作目录
WORKDIR /yapi/vendors

RUN cd /yapi/vendors && npm install --production --registry https://registry.npm.taobao.org \
  && cd .. 
#  && yapi plugin --name yapi-plugin-add-user \
#  && yapi plugin --name yapi-plugin-auto-test \
#  && yapi plugin --name yapi-plugin-import-swagger-customize \
#  && yapi plugin --name yapi-plugin-notifier \
#  && yapi plugin --name yapi-plugin-gitlab

# 向外暴露的端口
EXPOSE 3000

# 配置入口为bash shell
ENTRYPOINT ["entrypoint.sh"]


# `vim` : 编辑神器
# `tar` : 解压缩
# `make`: 编译依赖的
# `gcc`:  GNU编译器套装
# `python`: `python python-dev py-pip`这三个包包括了基本开发环境
# `curl` 可以测试连接也能下载内容的命令行工具
# `git` : 不用说了
# `nodejs` : node
# `nodejs-current-npm` : `alpine`Linux版本需要依赖这个版本,才能让`npm`识别到