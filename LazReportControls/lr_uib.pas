{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit lr_uib;

{$warn 5023 off : no warning about unused units}
interface

uses
  lrUIBData, LR_UEditVariables, lrUIBDataConst, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('lrUIBData', @lrUIBData.Register);
end;

initialization
  RegisterPackage('lr_uib', @Register);
end.
