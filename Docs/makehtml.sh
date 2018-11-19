#!/bin/bash

#Копируем инклуды в текущий каталог - иначе не соберём (глюк FPDoc)
cp ../lazarus/fb_define_compiler.inc fb_define_compiler.inc
cp ../fb_define.inc fb_define.inc
cp ../fbmisc.inc fbmisc.inc
cp ../jedi.inc jedi.inc

fpdoc --package=FBDataSet --hide-protected --format=html --output=./FBDataSet/ \
  --input=../fbcustomdataset.pas --descr=FBDataSet.xml \
  --input=../mydbunit.pas --descr=FBDataSet.xml \
  --input=../fbmisc.pas --descr=FBDataSet.xml \
  --input=../fbparams.pas --descr=FBDataSet.xml

fpdoc --package=dcl_fb_id_dataset --hide-protected --index-colcount=4 --format=html --output=./FBDataSet_Editor/ \
  --input=../fbcustomdatasetautoupdateoptionseditorl.pas --descr=FBDataSet.xml \
  --input=../dcl_fb_id_strconsts.pas --descr=FBDataSet.xml
  