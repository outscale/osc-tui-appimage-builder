#!/bin/sh

PY_MAJ="3.9"
PY_NAME="python$PY_MAJ"
APPIMAGETOOL=appimagetool

for arg in $@; do
    print $arg
    if [ "--help" = $arg ]; then
	echo "./configure:"
	echo "--helplike seriously ?"
	echo "--py3_ver=X.X choose python3 version (example 3.9)"
	echo "--wget-appimagetool: download appimagetool"
	exit 0
    fi
    if [ "--py3_ver" = $( echo "$arg" | cut -d '=' -f 1) ]; then
	PY_MAJ=$( echo $arg | cut -f 2 -d '=' )
	echo "python versio to use: " $PY_MAJ
    fi
    if [ "--wget-appimagetool" = $arg ]; then
	rm -vf appimagetool-x86_64.AppImage
	wget https://github.com/AppImage/AppImageKit/releases/download/13/appimagetool-x86_64.AppImage
	chmod +x appimagetool-x86_64.AppImage
	APPIMAGETOOL=./appimagetool-x86_64.AppImage
    fi

done

./clean.sh

TARGET=$(curl --silent "https://api.github.com/repos/niess/python-appimage/releases" | grep AppImage | grep $PY_MAJ | grep manylinux1_x86_64 | grep name | cut -d '"' -f 4)

wget https://github.com/niess/python-appimage/releases/download/$PY_NAME/$TARGET

chmod +x ./$TARGET
./$TARGET --appimage-extract
mv squashfs-root/ osc-tui.AppDir

cp ./AppRun-py osc-tui.AppDir/AppRun-py
cp ./AppRun osc-tui.AppDir/

git clone https://github.com/outscale/osc-sdk-python.git
cd osc-sdk-python
git submodule update --init
../osc-tui.AppDir/AppRun-py setup.py install --prefix=../osc-tui.AppDir/opt/$PY_NAME/ --optimize=1
cd ../

git clone https://github.com/asweigart/pyperclip.git
cd pyperclip
../osc-tui.AppDir/AppRun-py setup.py install --prefix=../osc-tui.AppDir/opt/$PY_NAME/ --optimize=1
cd ../

git clone https://github.com/outscale-mgo/npyscreen
cd npyscreen
../osc-tui.AppDir/AppRun-py setup.py install --prefix=../osc-tui.AppDir/opt/$PY_NAME/ --optimize=1
cd ../

git clone https://github.com/outscale-dev/osc-tui.git
cd osc-tui
./configure.sh --release
../osc-tui.AppDir/AppRun-py setup.py install --prefix=../osc-tui.AppDir/opt/$PY_NAME/ --optimize=1
cd ../

cd ./osc-tui.AppDir
PIP_CONFIG_FILE=/dev/null usr/bin/pip$PY_MAJ install --isolated --root="" --ignore-installed --no-deps urllib3
PIP_CONFIG_FILE=/dev/null usr/bin/pip$PY_MAJ install --isolated --root="" --ignore-installed --no-deps requests
PIP_CONFIG_FILE=/dev/null usr/bin/pip$PY_MAJ install --isolated --root="" --ignore-installed --no-deps chardet
PIP_CONFIG_FILE=/dev/null usr/bin/pip$PY_MAJ install --isolated --root="" --ignore-installed --no-deps idna==2.9
cd ..

rm  osc-tui.AppDir/$PY_NAME*desktop
cp osc-tui.desktop osc-tui.AppDir
cp libncursesw.so.5 osc-tui.AppDir/usr/lib
cp libtinfo.so.5 osc-tui.AppDir/usr/lib
cp libtic.so.5 osc-tui.AppDir/usr/lib
cp infocmp osc-tui.AppDir/usr/bin
cp -rvf x osc-tui.AppDir/
$APPIMAGETOOL osc-tui.AppDir/
