#!/bin/sh

rm -Rf build/*
cp -R haxelib.json haxedoc.xml src demo LICENSE.txt README.md build-detox.hxml build-jquery.hxml build

cd build
zip -r package.zip haxelib.json haxedoc.xml src demo LICENSE.txt README.md build-detox.hxml build-jquery.hxml
cd ..
