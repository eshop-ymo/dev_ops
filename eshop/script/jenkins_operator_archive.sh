#!/bin/sh

PACKAGE_FOLDER="dist"
PROFILE_NAME="loadExtendFile.js"
PROFILE_PATH="js"

# --参数--
PROFILE=$1

# 删除之前打包产生的文件
rm -fr ${PACKAGE_FOLDER}

# 用fis3进行html打包
# fis3 release -d ${PACKAGE_FOLDER}
mkdir ${PACKAGE_FOLDER}
cp -fr $(find ./ -maxdepth 1 ! -name "dist" ! -name ".*" ! -name "README.md") ${PACKAGE_FOLDER}

# 修改多环境配置
function edit_profile_file() {
    # 指定的当前环境
    local profile=$1
    local profile_name=`echo "${PROFILE_NAME}"|cut -d . -f 1`
    
    echo "current profile ${profile}"
    
    local profile_path=`find ${PACKAGE_FOLDER}/${PROFILE_PATH} -name "${profile_name}*.js"`
    
    echo "edit ${profile_path}"
    
    # 转义特殊字符
    local config_info=`cat ${PACKAGE_FOLDER}/profile-${profile}.js | sed ":a;N;s/\n//g;$!ba" | sed -r "s:([\/\"]):\\\\\&:g"`
    
    local file_fingerprint=`date "+%s"`
    # 插入文件指纹
    sed -i "1i const v=$file_fingerprint;" ${profile_path}
    
    # 修改多环境配置开关
    sed -i "1i $config_info" ${profile_path}
}

if [ ${PROFILE} ]
then
    # 修改多环境配置
    edit_profile_file ${PROFILE}
else
    echo "profile not empty"
fi

# 进入打包好的文件夹
cd ${PACKAGE_FOLDER}

# 删除多环境配置文件
rm -fr profile-*.js

# 进行文件打包和压缩
tar -czf html-operator.tar.gz *