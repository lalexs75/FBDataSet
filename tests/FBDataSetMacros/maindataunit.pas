unit MainDataUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, fbcustomdataset, uib;

type

  { TMainData }

  TMainData = class(TDataModule)
    FBDataSet_WithMacro: TFBDataSet;
    FBDataSet_WithParam: TFBDataSet;
    MainDB: TUIBDataBase;
    MainTr: TUIBTransaction;
    procedure DataModuleCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  MainData: TMainData;

implementation

{$R *.lfm}

{ TMainData }

procedure TMainData.DataModuleCreate(Sender: TObject);
begin
  MainDB.Connected:=true;
  MainTr.StartTransaction;
end;

end.

