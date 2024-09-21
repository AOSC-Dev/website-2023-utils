website-2023 实用工具及守护程序
===

[英文自述文件 >>](README.md)

本仓库存放部署 [website-2023](https://github.com/AOSC-Dev/website-2023) 所需的实用工具及守护程序。

部署指南
---

首先，安装 Go >= 1.19 工具链。安同 OS 用户可使用如下命令安装：

```
oma install go
```

构建实用工具及守护程序：

```
make
```

以 root 用户安装上述文件：

```
make install
```

以 root 用户配置服务：

```
systemd-sysusers aosc-portal-paste-server.conf
systemd-tmpfiles --create aosc-portal-paste-server.conf
```

最后，以 root 用户启动服务：

```
systemctl enable --now aosc-portal-paste-server
```
