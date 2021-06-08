#!/bin/bash

source ~/.cargo/env
cargo build --target=x86_64-pc-windows-gnu --release

if [ -d package ]
then
	echo "'package' directory already exists. Aborting." 1>&2
    exit 1
fi

mkdir -p package
cp target/x86_64-pc-windows-gnu/release/*.exe package

export DLLS=`peldd package/*.exe -t --ignore-errors`
for DLL in $DLLS
    do cp "$DLL" package
done

find package -maxdepth 1 -type f -exec mingw-strip {} +

zip -qr package.zip package/*
rm -rf package
