{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit dcl_fb_id_dataset;

{$warn 5023 off : no warning about unused units}
interface

uses
  fb_ib_edt_ins_master_field_unit, fbcustomdatasetpropeditorl, 
  fbcustomdatasetautoupdateoptionseditorl, fbcustomdatasetsqleditorl, 
  FBCustomDataSetSQLEditorTestL, dcl_fb_id_StrConsts, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('fbcustomdatasetpropeditorl', 
    @fbcustomdatasetpropeditorl.Register);
end;

initialization
  RegisterPackage('dcl_fb_id_dataset', @Register);
end.
