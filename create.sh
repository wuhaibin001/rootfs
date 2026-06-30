#!/bin/bash
ROOT_DIR=`pwd`/root
OUTPUT_DIR=/tmp/rootfs_output/

rm -rf ${OUTPUT_DIR}
mkdir ${OUTPUT_DIR}

# 1. 直接将根文件系统目录打包为 squashfs 镜像
#    -comp xz 可换成 gzip / lz4 / lzo，需与内核 CONFIG_SQUASHFS_* 一致
#    -noappend 生成全新镜像
#    -all-root 强制所有文件属主为 root（避免权限问题）
mksquashfs ${ROOT_DIR} ${OUTPUT_DIR}/rootfs.squashfs \
    -comp xz \
    -noappend \
    -all-root

# 2. 用 mkimage 添加 U-Boot 头部，注意 -C none
#    因为 squashfs 内部已压缩，内核将直接挂载，不再需要外部解压
mkimage -A mips -O linux -T ramdisk -C none \
    -n "SquashFS RootFS" \
    -d ${OUTPUT_DIR}/rootfs.squashfs \
    ${OUTPUT_DIR}/uramdisk.image.gz

# 3. 清理临时 squashfs 镜像（可选）
rm -f ${OUTPUT_DIR}/rootfs.squashfs

echo "uramdisk 已生成：${OUTPUT_DIR}/uramdisk.image.gz"
