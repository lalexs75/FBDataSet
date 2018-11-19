program Employee;

{$mode objfpc}{$H+}

uses
  Interfaces, // this includes the LCL widgetset
  Forms,
  MainUnit,
  sprCustomerEditUnit,
  sprCustomerFilterUnit,
  hlpAboutUnit,
  lngResourcesUnit,
  ConfigUnit,
  ConfigFormUnit,
  uTranslator;

{$R *.res}

begin
  Application.Initialize;
  InitConfig;
  LoadConfig;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

