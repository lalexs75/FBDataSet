{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit UIBEditors;

{$warn 5023 off : no warning about unused units}
interface

uses
  jvuibdatabaseedit, jvuibtransactionedit, laz_editors_register, 
  uibeditorsconsts, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('laz_editors_register', @laz_editors_register.Register);
end;

initialization
  RegisterPackage('UIBEditors', @Register);
end.
