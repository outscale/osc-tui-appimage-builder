#!/bin/sh

./clean.sh

TARGET="python3.9.6-cp39-cp39-manylinux1_x86_64.AppImage"

wget https://github.com/niess/python-appimage/releases/download/python3.9/$TARGET

chmod +x ./$TARGET
./$TARGET --appimage-extract
mv squashfs-root/ osc-tui.AppDir

cp ./AppRun-py osc-tui.AppDir/AppRun-py
cp ./AppRun osc-tui.AppDir/

git clone https://github.com/outscale/osc-sdk-python.git
cd osc-sdk-python
git submodule update --init
../osc-tui.AppDir/AppRun-py setup.py install --prefix=../osc-tui.AppDir/opt/python3.9/ --optimize=1
cd ../

git clone https://github.com/asweigart/pyperclip.git
cd pyperclip
../osc-tui.AppDir/AppRun-py setup.py install --prefix=../osc-tui.AppDir/opt/python3.9/ --optimize=1
cd ../

git clone https://github.com/npcole/npyscreen
cd npyscreen
../osc-tui.AppDir/AppRun-py setup.py install --prefix=../osc-tui.AppDir/opt/python3.9/ --optimize=1
cd ../

git clone https://github.com/outscale-dev/osc-tui.git
cd osc-tui
./configure.sh --release
../osc-tui.AppDir/AppRun-py setup.py install --prefix=../osc-tui.AppDir/opt/python3.9/ --optimize=1
cd ../

rm  osc-tui.AppDir/python3.9.5.desktop
cp osc-tui.desktop osc-tui.AppDir
cp libncursesw.so.5 osc-tui.AppDir/usr/lib
cp libtinfo.so.5 osc-tui.AppDir/usr/lib
cp libtic.so.5 osc-tui.AppDir/usr/lib
cp infocmp osc-tui.AppDir/usr/bin
cp -rvf x osc-tui.AppDir/
appimagetool osc-tui.AppDir/
