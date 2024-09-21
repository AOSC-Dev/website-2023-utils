website-2023: utilities and daemons
===

[简体中文自述文件 >>](README.zh-cn.md)

This repository contains utilities and daemons used in conjunction with
[website-2023](https://github.com/AOSC-Dev/website-2023).

Deployment
---

First, install Go >= 1.19. To install Go on AOSC OS:

```
oma install go
```

Build the utilities and daemons:

```
make
```

As root, install the utilities and daemons:

```
make install
```

As root, configure the services:

```
systemd-sysusers aosc-portal-paste-server.conf
systemd-tmpfiles --create aosc-portal-paste-server.conf
```

As root, start the paste service:

```
systemctl enable --now aosc-portal-paste-server
```
