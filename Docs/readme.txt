TABLE OF CONTENTS
----------------------------
1. Installation 
  1.1. Installation in Lazarus
  1.2. Installation in Delphi
2. Demonstration Programs
3. Source Files
4. License

1. Installation
----------------------------
  1.1. Installation in Lazarus
  ----------------------------
Use "Components\Open package file (.lpk)..." menu item to open FBDataSet
run-time package fbdemofpc.lpk
In "Package..." window click "Compile" button to compile the package
and then click "Install" button to register FBDataSet Library components on
the component palette. Repeat that for design-time package
dcl_fb_id_dataset.lpk.

  1.2. Installation in Delphi

Use "File\Open" menu item to open FBDataSet run-time package:
  for delphi7 use delphi\d7\FB_IB_DataSets.dpk 
     (NOTE: this package actual for version wich DB.TField haveno AsLargeInt method - upto Delphi ver7 )
  for delphi2005 or above use delphi\d200x\FB_IB_DataSets.dpk
     (NOTE: since Delphi2005 not allowed mixed objects and classes usage)
In "Package..." window click "Compile" button to compile the package
and then click "Install" button to register FBDataSet Library components on
the component palette. Repeat that for design-time package
dcl_fb_id_dataset.dpk.

2. Demonstration Programs
----------------------------
Demonstration programs included in FBDataSet Library in FBDataSet\Demos 
directory.

3. Source Files
----------------------------
All sources (100%) of FBDataSet Library are available in FBDataSet directory.
All language specific string constants used in FBDataSet are
collected in resource files. There are sources for all string resource
files in English and Russian. 

4. License
----------------------------
See file "license.txt"