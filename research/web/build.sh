#!/bin/bash

WEB_ROOT=http://winlinvip.github.io/srs.release

# calc the dir
echo "argv[0]=$0"
if [[ ! -f $0 ]]; then 
    echo "directly execute the scripts on shell.";
    work_dir=`pwd`
else 
    echo "execute scripts in file: $0";
    work_dir=`dirname $0`; work_dir=`(cd ${work_dir} && pwd)`
fi &&

workdir=$work_dir &&
objs=${workdir}/objs &&
release=$objs/_release &&
mkdir -p $objs &&
echo "objs: $objs" &&
echo "release: $release" &&

if [[ ! -f $release/nginx/sbin/nginx ]]; then
    echo "build ngx_openresty-1.7.0.1" &&
    cd $objs &&
    rm -rf ngx_openresty-1.7.0.1 &&
    wget $WEB_ROOT/3rdparty/ngx_openresty-1.7.0.1.tar.gz -O ngx_openresty-1.7.0.1.tar.gz
    tar xf ngx_openresty-1.7.0.1.tar.gz && 
    cd ngx_openresty-1.7.0.1 &&
    ./configure --prefix=$release \
        --with-luajit --with-http_stub_status_module --without-http_redis2_module \
        --with-http_iconv_module --with-http_mp4_module --with-http_flv_module --with-http_realip_module &&
    echo "dynamic link lua" &&
    make && make install &&
    echo "static link lua" &&
    rm -f build/nginx-1.7.0/objs/nginx &&
    sed -i "s|-lluajit-5.1|$release/luajit/lib/libluajit-5.1.a|g" build/nginx-1.7.0/objs/Makefile &&
    make && make install &&
    echo "ngx_openresty-1.7.0.1 ok"
else
    echo "ngx_openresty-1.7.0.1 ok"
fi &&

# lua api
# @see bravoserver/trunk/src/p2p/api
echo "build lua api" &&
cd $objs/_release/nginx &&
rm -f api && ln -sf $workdir/api &&

# nginx conf
# @see bravoserver/trunk/src/p2p/api/nginx.conf
echo "build nginx conf" &&
cd $objs/_release/nginx/conf &&
rm -f nginx.conf && cp $workdir/conf/nginx.conf . &&
sed -i "s/nobody/`whoami`/g" nginx.conf &&
sed -i "s|ROOT_DIR|$objs/_release/nginx|g" nginx.conf &&

# about
echo "about nginx-lua(v2):" &&
echo "      sudo killall nginx; sudo ./objs/_release/nginx/sbin/nginx" &&
echo "      sudo killall -1 nginx" &&
echo "      tailf objs/_release/nginx/logs/error.log"
echo "      http://dev:8080/api/v3/json"
