unit ConfigUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils; 

var
  lngFolder    : string = '';
  lngFileName  : string = '';
  configFolder :  string = '';

procedure LoadConfig;
procedure SaveConfig;
procedure InitConfig;
implementation
uses Translations, LResources, uTranslator, IniFiles;

function ConfigFile:TIniFile;
begin
  Result:=TIniFile.Create(configFolder + ChangeFileExt(ExtractFileName(ParamStr(0)), '.ini'));
end;

procedure LoadConfig;
var
  AFileName:string;
  Ini:TIniFile;
begin
  Ini:=ConfigFile;
  lngFileName:=Ini.ReadString('System', 'Language', lngFileName);
  Ini.Free;

  if lngFileName<>'' then
  begin
    AFileName:=lngFolder +DirectorySeparator + lngFileName;

    if FileExists(AFileName) then
    begin
      Translations.TranslateUnitResourceStrings('lngResourcesUnit', AFileName);
      LRSTranslator := TTranslator.Create(AFileName);
    end;
  end;
end;

procedure SaveConfig;
var
  Ini:TIniFile;
begin
  Ini:=ConfigFile;
  Ini.WriteString('System', 'Language', lngFileName);
  Ini.Free;
end;

procedure InitConfig;
begin
  lngFolder:=IncludeTrailingPathDelimiter(ExtractFileDir(ParamStr(0))) + 'languages';
  configFolder:=GetAppConfigDir(false);
  if not DirectoryExists(configFolder) then
    mkdir(configFolder);
  configFolder:=IncludeTrailingPathDelimiter(configFolder);
end;


end.

