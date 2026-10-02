#!/bin/sh
# 无框架测试: sh tests/void-rootfs-url.sh
# 从 reinstall.sh 抠出纯函数 parse_void_rootfs_filename 单独跑
cd "$(dirname "$0")/.." || exit 1

func=$(sed -n '/^parse_void_rootfs_filename()/,/^}/p' reinstall.sh)
if [ -z "$func" ]; then
    echo "FAIL: reinstall.sh 里找不到 parse_void_rootfs_filename" >&2
    exit 1
fi
eval "$func"

fail() {
    echo "FAIL: $1" >&2
    exit 1
}

assert_eq() {
    [ "$1" = "$2" ] || fail "$3: got '$1', want '$2'"
}

# 真实目录列表的形态, nju 的 HTML 里下划线被转义成 \_
listing='<tr><td colspan="2" class="link"><a href="void-aarch64-ROOTFS-20250202.tar.xz" title="void-aarch64-ROOTFS-20250202.tar.xz">void-aarch64-ROOTFS-20250202.tar.xz</a></td></tr>
<tr><td colspan="2" class="link"><a href="void-aarch64-musl-ROOTFS-20250202.tar.xz" title="void-aarch64-musl-ROOTFS-20250202.tar.xz">void-aarch64-musl-ROOTFS-20250202.tar.xz</a></td></tr>
<tr><td colspan="2" class="link"><a href="void-x86_64-ROOTFS-20250202.tar.xz" title="void-x86_64-ROOTFS-20250202.tar.xz">void-x86_64-ROOTFS-20250202.tar.xz</a></td></tr>
<tr><td colspan="2" class="link"><a href="void-x86_64-musl-ROOTFS-20250202.tar.xz" title="void-x86_64-musl-ROOTFS-20250202.tar.xz">void-x86_64-musl-ROOTFS-20250202.tar.xz</a></td></tr>
<tr><td colspan="2" class="link"><a href="void-live-x86_64-20250202-base.iso">void-live-x86_64-20250202-base.iso</a></td></tr>'

assert_eq "$(printf '%s\n' "$listing" | parse_void_rootfs_filename x86_64)" \
    "void-x86_64-ROOTFS-20250202.tar.xz" "x86_64 转义下划线"

assert_eq "$(printf '%s\n' "$listing" | parse_void_rootfs_filename aarch64)" \
    "void-aarch64-ROOTFS-20250202.tar.xz" "aarch64"

# 多日期取最新: version sort 认 20250101 > 2025101, 字典序相反
dates='<a href="void-x86_64-ROOTFS-2025101.tar.xz">void-x86_64-ROOTFS-2025101.tar.xz</a>
<a href="void-x86_64-ROOTFS-20250101.tar.xz">void-x86_64-ROOTFS-20250101.tar.xz</a>'
assert_eq "$(printf '%s\n' "$dates" | parse_void_rootfs_filename x86_64)" \
    "void-x86_64-ROOTFS-20250101.tar.xz" "多日期取最新"

# 只有 musl 条目时输出为空
musl='<a href="void-x86_64-musl-ROOTFS-20250202.tar.xz">void-x86_64-musl-ROOTFS-20250202.tar.xz</a>'
assert_eq "$(printf '%s\n' "$musl" | parse_void_rootfs_filename x86_64 || true)" \
    "" "只有 musl 时为空"

echo "PASS"
