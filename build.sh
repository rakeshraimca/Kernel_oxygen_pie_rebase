#!/bin/bash
kernel_dir=$PWD
export V="$(date +'%d%m%Y-%H%M%S')"
#export CONFIG_FILE="oxygen_user_defconfig"
export CONFIG_FILE="miui_oxygen_defconfig"
export ARCH=arm64
export SUBARCH=arm64
export LOCALVERSION="_${V}"
export CROSS_COMPILE="${kernel_dir}/../../GCC/bin/aarch64-linux-android-"
export PATH=$PATH:${TOOL_CHAIN_PATH}
export out_dir="${kernel_dir}/out/"
export builddir="${kernel_dir}/Builds"
export ANY_KERNEL2_DIR="${kernel_dir}/AnyKernel2"
export ZIP_NAME="Hardrock-miui_OCv18beast.zip"
export IMAGE="${out_dir}arch/arm64/boot/Image.gz-dtb";
export STRIP_KO="${kernel_dir}/../../GCC/aarch64-linux-android/bin/strip"
JOBS="-j$(nproc --all)"
cd $kernel_dir

make_defconfig() {
	make O=${out_dir} $CONFIG_FILE
}

compile() {
	make \
	O=${out_dir} \
	$JOBS
}

zipit () {
    if [[ ! -f "${IMAGE}" ]]; then
        echo -e "Build failed :P";
        exit 1;
    else
        echo -e "Build Succesful!";
    fi
    echo "**** Copying Image ****"
    cp ${out_dir}arch/arm64/boot/Image.gz-dtb ${ANY_KERNEL2_DIR}/
    find ${out_dir} -name '*.ko' -exec ${STRIP_KO} --strip-unneeded {} &> /dev/null  \;
    find ${out_dir} -name '*.ko' -exec cp {} ${ANY_KERNEL2_DIR}/modules/system/lib/modules/ \; 
    cp ${out_dir}drivers/staging/prima/wlan.ko ${ANY_KERNEL2_DIR}/modules/system/lib/modules/pronto/pronto_wlan.ko
    cd ${ANY_KERNEL2_DIR}/
    zip -r9 ${ZIP_NAME} * -x README ${ZIP_NAME}
    rm -rf ${kernel_dir}/Builds/${ZIP_NAME}
    cp ${ANY_KERNEL2_DIR}/${ZIP_NAME} ${kernel_dir}/Builds/${ZIP_NAME}
}

make_defconfig
compile
zipit
cd ${kernel_dir}
