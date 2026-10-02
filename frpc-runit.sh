#!/bin/sh
# frpc 的 runit run 脚本，安装到 /etc/sv/frpc/run
# chpst 来自 runit，Void 自带
exec chpst -u frpc /usr/local/bin/frpc -c /usr/local/etc/frpc/frpc.toml
