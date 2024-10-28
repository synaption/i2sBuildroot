#!/usr/bin/env bash

#
# dtb_list extracts the list of DTB files from BR2_LINUX_KERNEL_INTREE_DTS_NAME
# in ${BR_CONFIG}, then prints the corresponding list of file names for the
# genimage configuration file
#
dtb_list()
{
	local DTB_LIST="$(sed -n 's/^BR2_LINUX_KERNEL_INTREE_DTS_NAME="\([\/a-z0-9 \-]*\)"$/\1/p' ${BR2_CONFIG})"

	for dt in $DTB_LIST; do
		echo -n "\"`basename $dt`.dtb\", "
	done
}

#
# linux_image extracts the Linux image format from BR2_LINUX_KERNEL_UIMAGE in
# ${BR_CONFIG}, then prints the corresponding file name for the genimage
# configuration file
#
linux_image()
{
	if grep -Eq "^BR2_LINUX_KERNEL_UIMAGE=y$" ${BR2_CONFIG}; then
		echo "\"uImage\""
	elif grep -Eq "^BR2_LINUX_KERNEL_IMAGE=y$" ${BR2_CONFIG}; then
		echo "\"Image\""
	elif grep -Eq "^BR2_LINUX_KERNEL_IMAGEGZ=y$" ${BR2_CONFIG}; then
		echo "\"Image.gz\""
	else
		echo "\"zImage\""
	fi
}

genimage_type()
{
	if grep -Eq "^BR2_PACKAGE_FREESCALE_IMX_PLATFORM_IMX8=y$" ${BR2_CONFIG}; then
		echo "genimage.cfg.template_imx8"
	elif grep -Eq "^BR2_PACKAGE_FREESCALE_IMX_PLATFORM_IMX8M=y$" ${BR2_CONFIG}; then
		echo "genimage.cfg.template_imx8"
	elif grep -Eq "^BR2_PACKAGE_FREESCALE_IMX_PLATFORM_IMX8MM=y$" ${BR2_CONFIG}; then
		echo "genimage.cfg.template_imx8"
	elif grep -Eq "^BR2_PACKAGE_FREESCALE_IMX_PLATFORM_IMX8MN=y$" ${BR2_CONFIG}; then
		echo "genimage.cfg.template_imx8"
	elif grep -Eq "^BR2_PACKAGE_FREESCALE_IMX_PLATFORM_IMX8MP=y$" ${BR2_CONFIG}; then
		echo "genimage.cfg.template_imx8"
	elif grep -Eq "^BR2_PACKAGE_FREESCALE_IMX_PLATFORM_IMX8X=y$" ${BR2_CONFIG}; then
		echo "genimage.cfg.template_imx8"
	elif grep -Eq "^BR2_LINUX_KERNEL_INSTALL_TARGET=y$" ${BR2_CONFIG}; then
		if grep -Eq "^BR2_TARGET_UBOOT_SPL=y$" ${BR2_CONFIG}; then
		    echo "genimage.cfg.template_no_boot_part_spl"
		else
		    echo "genimage.cfg.template_no_boot_part"
		fi
	elif grep -Eq "^BR2_TARGET_UBOOT_SPL=y$" ${BR2_CONFIG}; then
		echo "genimage.cfg.template_spl"
	else
		echo "genimage.cfg.template"
	fi
}

imx_offset()
{
	if grep -Eq "^BR2_PACKAGE_FREESCALE_IMX_PLATFORM_IMX8M=y$" ${BR2_CONFIG}; then
		echo "33K"
	elif grep -Eq "^BR2_PACKAGE_FREESCALE_IMX_PLATFORM_IMX8MM=y$" ${BR2_CONFIG}; then
		echo "33K"
	else
		echo "32K"
	fi
}

uboot_image()
{
	if grep -Eq "^BR2_TARGET_UBOOT_FORMAT_DTB_IMX=y$" ${BR2_CONFIG}; then
		echo "u-boot-dtb.imx"
	elif grep -Eq "^BR2_TARGET_UBOOT_FORMAT_IMX=y$" ${BR2_CONFIG}; then
		echo "u-boot.imx"
	elif grep -Eq "^BR2_TARGET_UBOOT_FORMAT_DTB_IMG=y$" ${BR2_CONFIG}; then
	    echo "u-boot-dtb.img"
	elif grep -Eq "^BR2_TARGET_UBOOT_FORMAT_IMG=y$" ${BR2_CONFIG}; then
	    echo "u-boot.img"
	fi
}

main()
{   
	local FILES="$(dtb_list) $(linux_image)"
	local IMXOFFSET="$(imx_offset)"
	local UBOOTBIN="$(uboot_image)"
	local GENIMAGE_CFG=${BR2_EXTERNAL_BR2RAUC_PATH}/board/coral/genimage.cfg.template_imx8 #"$(mktemp --suffix genimage.cfg)"
	local GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"
	GENBOOTFS_CFG=${BR2_EXTERNAL_BR2RAUC_PATH}/board/coral/genbootfs-coral.cfg
	RAUC_COMPATIBLE="br2rauc-rpi4-64"
	 
    trap 'rm -rf "${ROOTPATH_TMP}"' EXIT
    ROOTPATH_TMP="$(mktemp -d)"

    rm -rf "${GENIMAGE_TMP}"
	
# Generate the boot filesystem image
genimage \
	--rootpath "${ROOTPATH_TMP}"   \
	--tmppath "${GENIMAGE_TMP}"    \
	--inputpath "${BINARIES_DIR}"  \
	--outputpath "${BINARIES_DIR}" \
	--config "${GENBOOTFS_CFG}"

echo x 

# Generate a RAUC update bundle for the full system (bootfs + rootfs)
[ -e ${BINARIES_DIR}/update.raucb ] && rm -rf ${BINARIES_DIR}/update.raucb
[ -e ${BINARIES_DIR}/temp-update ] && rm -rf ${BINARIES_DIR}/temp-update
mkdir -p ${BINARIES_DIR}/temp-update

cat >> ${BINARIES_DIR}/temp-update/manifest.raucm << EOF
[update]
compatible=${RAUC_COMPATIBLE}
version=${VERSION}
[bundle]
format=verity
[image.bootloader]
filename=boot.vfat
[image.rootfs]
filename=rootfs.ext4
EOF

ln -L ${BINARIES_DIR}/boot.vfat ${BINARIES_DIR}/temp-update/
ln -L ${BINARIES_DIR}/rootfs.ext4 ${BINARIES_DIR}/temp-update/

${HOST_DIR}/bin/rauc bundle \
	--cert ${BR2_EXTERNAL_BR2RAUC_PATH}/openssl-ca/dev/development-1.cert.pem \
	--key ${BR2_EXTERNAL_BR2RAUC_PATH}/openssl-ca/dev/private/development-1.key.pem \
	--keyring ${BR2_EXTERNAL_BR2RAUC_PATH}/openssl-ca/dev/ca.cert.pem \
	${BINARIES_DIR}/temp-update/ \
	${BINARIES_DIR}/update.raucb
echo x 
# Generate a RAUC update bundle for just the root filesystem
[ -e ${BINARIES_DIR}/rootfs.raucb ] && rm -rf ${BINARIES_DIR}/rootfs.raucb
[ -e ${BINARIES_DIR}/temp-rootfs ] && rm -rf ${BINARIES_DIR}/temp-rootfs
mkdir -p ${BINARIES_DIR}/temp-rootfs

cat >> ${BINARIES_DIR}/temp-rootfs/manifest.raucm << EOF
[update]
compatible=${RAUC_COMPATIBLE}
version=${VERSION}
[bundle]
format=verity
[image.rootfs]
filename=rootfs.ext4
EOF

ln -L ${BINARIES_DIR}/rootfs.ext4 ${BINARIES_DIR}/temp-rootfs/

${HOST_DIR}/bin/rauc bundle \
	--cert ${BR2_EXTERNAL_BR2RAUC_PATH}/openssl-ca/dev/development-1.cert.pem \
	--key ${BR2_EXTERNAL_BR2RAUC_PATH}/openssl-ca/dev/private/development-1.key.pem \
	--keyring ${BR2_EXTERNAL_BR2RAUC_PATH}/openssl-ca/dev/ca.cert.pem \
	${BINARIES_DIR}/temp-rootfs/ \
	${BINARIES_DIR}/rootfs.raucb
echo x 
# Parse update.raucb and generate initial rauc.status file
# FIXME: There is probably a MUCH better way to do this,
#        suggestions welcome!
eval $(rauc --keyring ${BR2_EXTERNAL_BR2RAUC_PATH}/openssl-ca/dev/ca.cert.pem --output-format=shell info ${BINARIES_DIR}/update.raucb)

cat > ${BINARIES_DIR}/rauc.status << EOF
[slot.${RAUC_IMAGE_CLASS_0}.0]
bundle.compatible=${RAUC_MF_COMPATIBLE}
status=ok
sha256=${RAUC_IMAGE_DIGEST_0}
size=${RAUC_IMAGE_SIZE_0}

[slot.${RAUC_IMAGE_CLASS_1}.0]
bundle.compatible=${RAUC_MF_COMPATIBLE}
status=ok
sha256=${RAUC_IMAGE_DIGEST_1}
size=${RAUC_IMAGE_SIZE_1}

[slot.${RAUC_IMAGE_CLASS_1}.1]
bundle.compatible=${RAUC_MF_COMPATIBLE}
status=ok
sha256=${RAUC_IMAGE_DIGEST_1}
size=${RAUC_IMAGE_SIZE_1}
EOF

# Install rauc.status to genimage rootpath
install -D -m 0644 ${BINARIES_DIR}/rauc.status ${ROOTPATH_TMP}/data/rauc.status

rm -rf "${GENIMAGE_TMP}"

	genimage \
		--rootpath "${ROOTPATH_TMP}" \
		--tmppath "${GENIMAGE_TMP}" \
		--inputpath "${BINARIES_DIR}" \
		--outputpath "${BINARIES_DIR}" \
		--config "${GENIMAGE_CFG}"

	# Create a bmap file for the sdcard image
	cp "${BINARIES_DIR}/sdcard.img" "${BINARIES_DIR}/full.img"
    bmaptool create "${BINARIES_DIR}/sdcard.img" -o "${BINARIES_DIR}/sdcard.img.bmap"
    
    # Compress the sdcard image
    [ -e "${BINARIES_DIR}/sdcard.img.xz" ] && rm "${BINARIES_DIR}/sdcard.img.xz"
    xz -T 0 "${BINARIES_DIR}/sdcard.img"

	#rm -f ${GENIMAGE_CFG}

	exit $?
}

main $@