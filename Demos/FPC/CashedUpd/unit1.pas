unit Unit1; 

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, FileUtil, LResources, Forms, Controls, Graphics,
  Dialogs, DBGrids, StdCtrls, uib, fbcustomdataset, mydbunit;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    Datasource1: TDatasource;
    DBGrid1: TDBGrid;
    FBDataSet1: TFBDataSet;
    FBDataSet1ADDRESS_LINE1: TFBAnsiField;
    FBDataSet1ADDRESS_LINE2: TFBAnsiField;
    FBDataSet1CITY: TFBAnsiField;
    FBDataSet1CONTACT_FIRST: TFBAnsiField;
    FBDataSet1CONTACT_LAST: TFBAnsiField;
    FBDataSet1COUNTRY: TFBAnsiField;
    FBDataSet1CUSTOMER: TFBAnsiField;
    FBDataSet1CUST_NO: TLongintField;
    FBDataSet1ON_HOLD: TStringField;
    FBDataSet1PHONE_NO: TFBAnsiField;
    FBDataSet1POSTAL_CODE: TFBAnsiField;
    FBDataSet1REC_STATUS1: TStringField;
    FBDataSet1STATE_PROVINCE: TFBAnsiField;
    MainDB: TUIBDataBase;
    trRead: TUIBTransaction;
    trWrite: TUIBTransaction;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure FBDataSet1CalcFields(DataSet: TDataSet);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form1: TForm1; 

implementation

{ TForm1 }

procedure TForm1.CheckBox1Change(Sender: TObject);
begin
  if not CheckBox1.Checked then
  begin
    FBDataSet1.Close;
    trRead.Commit;
  end;
  MainDB.Connected:=CheckBox1.Checked;

  if CheckBox1.Checked then
  begin
    trRead.StartTransaction;
    CheckBox2Click(nil);
    FBDataSet1.Open;
  end;
end;

procedure TForm1.CheckBox2Click(Sender: TObject);
begin
  if FBDataSet1.Active then
    if CheckBox2.Checked then
      FBDataSet1.UpdateRecordTypes := FBDataSet1.UpdateRecordTypes + [cusDeleted, cusUninserted, cusDeletedApplied]
    else
      FBDataSet1.UpdateRecordTypes := FBDataSet1.UpdateRecordTypes - [cusDeleted, cusUninserted, cusDeletedApplied];
end;

procedure TForm1.FBDataSet1CalcFields(DataSet: TDataSet);
const
   UpdStrStat:array [TCachedUpdateStatus] of string[5] =
     ('', 'M', 'I', 'D', 'UI', 'DA');
//   (cusUnmodified, cusModified, cusInserted, cusDeleted, cusUninserted, cusDeletedApplied);
begin
  FBDataSet1REC_STATUS1.AsString:=UpdStrStat[FBDataSet1.CurRecordCachedUpdateStatus];
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  trWrite.StartTransaction;
  try
    FBDataSet1.ApplyUpdates;
    trWrite.Commit;
  except
    on E:Exception do
    begin
      ShowMessage(E.Message);
      trWrite.RollBack;
    end;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  FBDataSet1.Refresh;
end;

initialization
  {$I unit1.lrs}

end.

