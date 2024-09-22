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

As root, install the utilities and daemons (Makefile will automatically
configure all utilities and daemons for you during installation):

```
make install
```

Finally, start the paste service as root:

```
systemctl enable --now aosc-portal-paste-server
```

### Manual configuration

If you specified the `DESTDIR=` during `make install` to install the files to
a temporary directory, during final deployment, you would need to execute the
following extra steps **before** starting the relevant services:

```
systemd-sysusers ${PROGPREFIX}paste-server.conf
systemd-tmpfiles --create ${PROGPREFIX}paste-server.conf
chmod -v 740 ${LIBEXECDIR}/${PROGPREFIX}paste-server
chown -Rv aosc-portal-paste:www-data ${LIBEXECDIR}/${PROGPREFIX}paste-server
```

Note: The aforementioned `${LIBEXEC}` and `${PROGPREFIX}` variables were
specified during build time (`make`), with the following default values:

- `${LIBEXECDIR}`: `/usr/local/libexec`
- `${PROGPREFIX}`: `aosc-portal-`