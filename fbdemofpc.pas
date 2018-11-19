{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit fbdemofpc;

{$warn 5023 off : no warning about unused units}
interface

uses
  fbcustomdataset, mydbunit, metadatasqlgenerator, uibstoredproc, fbmisc, 
  FBDataSetRegister, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('FBDataSetRegister', @FBDataSetRegister.Register);
end;

initialization
  RegisterPackage('fbdemofpc', @Register);
end.
