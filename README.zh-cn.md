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

以 root 用户安装上述文件（安装过程中会自动配置各实用工具及守护程序）：

```
make install
```

最后，以 root 用户启动服务：

```
systemctl enable --now aosc-portal-paste-server
```

### 手动部署配置

如果您在安装时使用了 `DESTDIR=` 参数将文件临时安装到某处，最终部署时，您还需要使用 root 用户运行如下命令：

```
systemd-sysusers ${PROGPREFIX}paste-server.conf
systemd-tmpfiles --create ${PROGPREFIX}paste-server.conf
chmod -v 740 ${LIBEXECDIR}/${PROGPREFIX}paste-server
chown -Rv aosc-portal-paste:www-data ${LIBEXECDIR}/${PROGPREFIX}paste-server
```

注意，如上的 `${LIBEXEC}` 及 `${PROGPREFIX}` 为编译 (`make`) 时指定，默认值如下：

- `${LIBEXECDIR}`: `/usr/local/libexec`
- `${PROGPREFIX}`: `aosc-portal-`