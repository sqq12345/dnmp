ycpai——DNMP（Docker + Nginx + MySQL + PHP7/5 + Redis）是一款全功能的**LNMP一键安装程序**。

# 目录
- [1.快速使用](#2快速使用)
- [2.切换PHP版本](#3切换php版本)
- [3.使用Log](#5使用log)
    - [3.1 Nginx日志](#31-nginx日志)
    - [3.2 PHP-FPM日志](#32-php-fpm日志)
    - [3.3 MySQL日志](#33-mysql日志)
- [4.php怎么安装扩展](#4php怎么安装扩展)
- [5nginx站点的配置](#5nginx站点的配置)
- [6.可视化界面管理](#7可视化界面管理)
    - [6.1 phpMyAdmin](#61-phpmyadmin)
    - [6.2 phpRedisAdmin](#62-phpredisadmin)
    - [6.3 docker可视化界面管理](6.3 docker可视化界面管理)
- [7在正式环境中安全使用](#7在正式环境中安全使用)
- [8.docker常用命令](http://www.runoob.com/docker/docker-command-manual.html) 
- [9.docker的mysql的隐患](#9.docker的mysql的隐患)
    -  [navicate无法连接mysql](# navicate无法连接mysql)
    - [php无法连接mysql](#php无法连接mysql)

## 1.快速使用
1. **本地安装vagrant   和  oracle vm virtualBox** 

     注意事项：vagrant下载新版本 2.2.2  （如何查看版本 vagrant  -v）

​      下载地址:  https://www.vagrantup.com/downloads.html

​                    oracle vm virtualBox  下载版本 5.2.22  （如何查看版本 打开virtualbox软件，点击帮助，查看virtualBox）

​       下载地址:  https://www.virtualbox.org



2：**下载centos7.2box镜像文件，使用vagrant up进行安装和启动**

安装使用过程中可能出现的问题：

​        执行vagrant up  提示powershell的版本太低，需要升级

​      如何升级： 从以下地址中下载management framework5.1的版本 

​            <https://www.microsoft.com/en-us/download/details.aspx?id=54616>

​      同时必须安装net framework4.5以上的版本（请先在卸载程序面板中查看对应的net framework的版本，如果太低，请在以上地址中 找到System Requirements进行下载安装）



3： **通过脚本一键安装   docker  和docker-compose，并通过docker安装lnmp**

- 从git 地址 http://gl.ycpai.com/service/lnmp-docker.git 中获取其中的docker_install.sh脚本

- 将docker_install.sh脚本文件上传到虚拟机中

- 使用su -切换到root用户，密码是vagrant

- 执行chmod a+x docker_install.sh  给脚本添加可执行的权限

- sh  docker_install.sh  执行脚本 等待安装完毕即可  

  ​      （默认的lnmp安装在/www下面，所有在vagrant中可以设置/www的共享目录）

​     



**4：测试是否安装成功**

访问在浏览器中访问：

 - [http://虚拟机的ip地址](http://虚拟机的ip地址t)： 默认*http*站点
 - [https://虚拟机的ip地址](https:/虚拟机的ip地址)：自定义证书*https*站点，访问时浏览器会有安全提示，忽略提示访问即可
 - http://虚拟机的ip地址:8080  可以打开phpMysAdmin的面板操作数据库
 - http://虚拟机的ip地址:8081  可以打开phpRedisAdmin
 - http://虚拟机的ip地址:9000   可以打开docker的图形化管理工具，可以查看镜像 容器 安装等

默认情况下该虚拟机指向的项目根目录：在/www/lnmp-docker/www/base/public

要修改端口、日志文件位置、以及是否替换source.list文件等，请修改.env文件，然后重新构建：
```bash
$ docker-compose build php56    # 重建单个服务
$ docker-compose build          # 重建全部服务

```




## 2.切换PHP版本
默认情况下，我们同时创建 **PHP5.6和PHP7.2** 三个PHP版本的容器，

切换PHP仅需修改相应站点 Nginx 配置的`fastcgi_pass`选项，

例如，示例的 [http://localhost](http://localhost) 用的是PHP5.6，Nginx 配置：
```
    fastcgi_pass   php56:9000;
```
要改用PHP7.2，修改为：
```
    fastcgi_pass   php72:9000;
```
再**重启 Nginx** 生效。




## 3.使用Log

Log文件生成的位置依赖于conf下各log配置的值。

### 3.1 Nginx日志
Nginx日志是我们用得最多的日志，所以我们放在lnmp的安装目录/www/lnmp-docker/目录`log`下。

`log`会目录映射Nginx容器的`/var/log/nginx`目录，所以在Nginx配置文件中，需要输出log的位置，我们需要配置到`/var/log/nginx`目录，如：

```
error_log  /var/log/nginx/nginx.localhost.error.log  warn;
```


### 3.2 PHP-FPM日志
大部分情况下，PHP-FPM的日志都会输出到Nginx的日志中，所以不需要额外配置。

另外，建议直接在PHP中打开错误日志：
```php
error_reporting(E_ALL);
ini_set('error_reporting', 'on');
ini_set('display_errors', 'on');
```

如果确实需要，可按一下步骤开启（在容器中）。

1. 进入容器，创建日志文件并修改权限：
    ```bash
    $ docker exec -it dnmp_php_1 /bin/bash
    $ mkdir /var/log/php
    $ cd /var/log/php
    $ touch php-fpm.error.log
    $ chmod a+w php-fpm.error.log
    ```
2. 主机上打开并修改PHP-FPM的配置文件`conf/php-fpm.conf`，找到如下一行，删除注释，并改值为：
    ```
    php_admin_value[error_log] = /var/log/php/php-fpm.error.log
    ```
3. 重启PHP-FPM容器。

### 3.3 MySQL日志
因为MySQL容器中的MySQL使用的是`mysql`用户启动，它无法自行在`/var/log`下的增加日志文件。所以，我们把MySQL的日志放在与data一样的目录，即项目的`mysql`目录下，对应容器中的`/var/lib/mysql/`目录。
```bash
slow-query-log-file     = /var/lib/mysql/mysql.slow.log
log-error               = /var/lib/mysql/mysql.error.log
```
以上是mysql.conf中的日志文件的配置。

## 4.php怎么安装扩展

​    安装扩展的命令，boss已经在http://gl.ycpai.com/service/lnmp-docker的dockerfile文件全部声明: 

​    例如: 我们需要安装memcached的扩展：

-    先进入php对应的容器：

​       docker  exec -it  lnmp-docker_php72_1 /bin/bash

- 然后输入以下三行安装的命令   （该命令在dockerfile中） ：

​           apt install -y libmemcached-dev zlib1g-dev 

​           pecl install memcached

​          docker-php-ext-enable memcached

​     安装的时候提示：libmemcached directory [no] :  输入yes ，按enter键继续安装

​     注意事项：如果php7的版本 ：pecl install memcached

​                   如果php56的版本： pecl install memcached-2.2.0    

​     

## 5.nginx站点的配置   

- 复制  /www/lnmp-docker/conf/conf.d/localhost.conf文件  在同一个目录下，自定义名称（例如anfo.conf）

- 更改其中的域名地址 和站点目录

  ​          server_name  站点的域名;
  ​           root   站点的目录;

- 在虚拟机中创建对应的站点目录文件夹，将代码放在此文件夹中

- 在本机的host文件中添加ip 和域名地址绑定




## 6.数据库管理
本项目默认在`docker-compose.yml`中开启了用于MySQL在线管理的*phpMyAdmin*，以及用于redis在线管理的*phpRedisAdmin*，可以根据需要修改或删除。

### 6.1 phpMyAdmin
phpMyAdmin容器映射到主机的端口地址是：`8080`，所以主机上访问phpMyAdmin的地址是：
```
http://localhost:8080
```

MySQL连接信息：
- username：root
- password：123456

### 6.2 phpRedisAdmin
phpRedisAdmin容器映射到主机的端口地址是：`8081`，所以主机上访问phpMyAdmin的地址是：
```
http://localhost:8081
```



### 6.3 docker可视化界面管理 portainer

 portainer容器映射到主机的端口地址是：9000,所以主机上访问phpMyAdmin的地址是：

```
http://localhost:8888
```

containers菜单： 可对各个容器进行启动 /停止/删除等操作

images菜单：显示安装的所有容器




## 7.在正式环境中安全使用
要在正式环境中使用，请：
1. 在php.ini中关闭XDebug调试
2. 增强MySQL数据库访问的安全策略
3. 增强redis访问的安全策略



## 8: docker常用命令

docker-compose up  [-d] 启动并运行整个应用程序   -d代表在后天运行

##### 8.1 查看docker基本相关信息

docker version    # 查看docker的版本号，包括客户端、服务端、依赖的Go等

docker -v  #仅仅只是查看docker版本号 

docker info #查看系统(docker)层面信息，包括管理的images, containers数等

docker  ps  #查看启动的容器



##### 8.2 docker的启动  暂停  重启

service docker start  # 启动docker服务  （stop  restart  status）

systemctl start docker # 启动docker服务   （stop  restart  status）



##### 8.3 docker的镜像操作命令

docker images  # 查看所有镜像

docker images    <image>   #查看指定的镜像

docker search <image> # 在docker 资源库中搜索image

docker pull <image>  #下载镜像

 docker rmi  <image ID> #删除镜像



##### 8.4 docker的容器操作命令：

#创建容器

docker create 容器的名称      #创建一个新的容器但不启动它

docker run -i -t  -d  容器的名称   #创建容器

docker run -i -t   容器的名称    /bin/bash # 创建一个容器，让其中运行



\# 再次启动容器

​    docker start/stop/restart <container_id> #：开启/停止/重启container

​    docker start [container_id] #：再次运行某个container （包括历史container）

​    docker start -i <container> #：启动一个container并进入交互模式（相当于先

​         start，在attach）



#进入容器

  docker exec 容器的name  /bin/bash

  docker exec 容器的name  /bin/sh



\# 删除容器

​    docker rm <container...> #：删除一个或多个container

​    docker rm `docker ps -a -q` #：删除所有的container

​    docker ps -a -q | xargs docker rm #：同上, 删除所有的container





### 9: docker的mysql的隐患

#### 9.1 navicate无法连接docker的mysql

   问题:   navicate连接docker的mysql提示如下错误

   Authentication plugin ‘caching_sha2_password’ cannot be loaded: 

  解决方案： 则重置root用户的密码：

   首选进入到mysql的容器：docker exec -it   lnmp-docker_mysql_1 /bin/bash

   进入mysql数据 ：use  mysql

   重置root用户的密码：ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY '123456';





#### 9.2 php中无法连接docker的mysql

问题:mysql数据库的连接失败

原因:连接的域名不能写成localhost.  可以改成服务器端的ip地址 ，或者使用应用对应的ip address(可以在docker的可视化界面查看)

