{ lrUIBData unit

  Copyright (C) 2005-2016 Lagunov Aleksey alexs75@yandex.ru

  This library is free software; you can redistribute it and/or modify it
  under the terms of the GNU Library General Public License as published by
  the Free Software Foundation; either version 2 of the License, or (at your
  option) any later version with the following modification:

  As a special exception, the copyright holders of this library give you
  permission to link this library with independent modules to produce an
  executable, regardless of the license terms of these independent modules,and
  to copy and distribute the resulting executable under terms of your choice,
  provided that you also meet, for each linked independent module, the terms
  and conditions of the license of that module. An independent module is a
  module which is not derived from or based on this library. If you modify
  this library, you may extend this exception to your version of the library,
  but you are not obligated to do so. If you do not wish to do so, delete this
  exception statement from your version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  FITNESS FOR A PARTICULAR PURPOSE. See the GNU Library General Public License
  for more details.

  You should have received a copy of the GNU Library General Public License
  along with this library; if not, write to the Free Software Foundation,
  Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
}

unit lrUIBData;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Graphics, UIB, DB, LR_Class, LR_DBComponent,
  contnrs, LR_Intrp, uiblib, fbcustomdataset;

type

  TQueryParam = class
    ParamType:TFieldType;
    ParamName:string;
    ParamValue:string;
  end;

  { TQueryParamList }

  TQueryParamList = class(TFPObjectList)
    function ParamByName(AParamName:string):TQueryParam;
    function Add(AParamType:TFieldType; const AParamName, AParamValue:string):TQueryParam;
  end;

  { TlrUIBData }

  TlrUIBData = class(TComponent)
  private
    FDefaultTransaction: TUIBTransaction;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property DefaultTransaction:TUIBTransaction read FDefaultTransaction write FDefaultTransaction;
  end;


  { TlrFBDataSet }

  TlrFBDataSet = class(TLRDataSetControl)
  private
    FDatabase: string;
    FMacros:TQueryParamList;
    FParams:TQueryParamList;
    procedure SetDatabase(AValue: string);
    procedure FBDataSetBeforeOpen(ADataSet: TDataSet);
    procedure DoMakeParams;
    function DoEditParams(ParOrMacro:boolean):boolean;
    procedure DoSetTransaction;
  protected
    function GetSQL: string;
    procedure SetSQL(AValue: string);
    procedure SetDataSource(AValue: string); override;
    procedure AfterLoad;override;
  public
    constructor Create(AOwnerPage:TfrPage); override;
    destructor Destroy; override;

    procedure LoadFromXML(XML: TLrXMLConfig; const Path: String); override;
    procedure SaveToXML(XML: TLrXMLConfig; const Path: String); override;
  published
    property SQL:string read GetSQL write SetSQL;
    property Database:string read FDatabase write SetDatabase;
    property Params:TQueryParamList read FParams write FParams;
    property Macros:TQueryParamList read FMacros write FMacros;
  end;

  { TLRUIBDatabase }

  TLRUIBDatabase = class(TfrNonVisualControl)
  private
    FUIBDataBase:TUIBDataBase;
    FUIBTransaction:TUIBTransaction;
    FConnected:Boolean;

    function GetCharacterSet: TCharacterSet;
    function GetConnected: Boolean;
    function GetDatabaseName: string;
    function GetPassword: string;
    function GetRole: string;
    function GetUserName: string;
    procedure SetCharacterSet(AValue: TCharacterSet);
    procedure SetConnected(AValue: Boolean);
    procedure SetDatabaseName(AValue: string);
    procedure SetPassword(AValue: string);
    procedure SetRole(AValue: string);
    procedure SetUserName(AValue: string);
  protected
    procedure SetName(const AValue: string); override;
    procedure AfterLoad;override;
  public
    constructor Create(AOwnerPage:TfrPage); override;
    destructor Destroy; override;

    procedure LoadFromXML(XML: TLrXMLConfig; const Path: String); override;
    procedure SaveToXML(XML: TLrXMLConfig; const Path: String); override;
  published
    property CharacterSet: TCharacterSet read GetCharacterSet write SetCharacterSet;
    property Connected: Boolean read GetConnected write SetConnected;
    property DatabaseName: string read GetDatabaseName write SetDatabaseName;
    property UserName: string read GetUserName write SetUserName;
    property Role: string read GetRole write SetRole;
    property Password: string read GetPassword write SetPassword;

  end;

procedure Register;

implementation
uses LR_Utils, DBPropEdits, PropEdits, LazarusPackageIntf, types, Forms,
  Controls, variants, LR_UEditVariables, fbmisc;

{$R lruibdata_img.res}

procedure Register;
begin
  RegisterComponents('LazReport',[TlrUIBData]);
end;

function StrToFieldType(AStrTypeName:string):TFieldType;
var
  i:TFieldType;
begin
  Result:=ftUnknown;
  AStrTypeName:=UpperCase(AStrTypeName);
  for i in TFieldType do
  begin
    if UpperCase(Fieldtypenames[i]) = AStrTypeName then
    begin
      Result:=i;
      exit;
    end;
  end;
end;


procedure DoRegsiterControl(var cmpBMP:TBitmap; lrClass:TfrViewClass);
begin
  if not assigned(cmpBMP) then
  begin
    cmpBMP := TBitmap.Create;
    cmpBMP.LoadFromResourceName(HInstance, lrClass.ClassName);
    frRegisterObject(lrClass, cmpBMP, lrClass.ClassName, nil, otlUIControl, nil);
  end;
end;

var
  lrBMP_FBDataSet:TBitmap = nil;
  lrBMP_UIBDatabase:TBitmap = nil;
  lrUIBCmp:TlrUIBData = nil;

procedure InitLRComp;
begin
  DoRegsiterControl(lrBMP_FBDataSet, TlrFBDataSet);
  DoRegsiterControl(lrBMP_UIBDatabase, TLRUIBDatabase);
end;

{ TQueryParamList }

function TQueryParamList.ParamByName(AParamName: string): TQueryParam;
var
  i:integer;
begin
  Result:=nil;
  AParamName:=UpperCase(AParamName);
  for i:=0 to Count - 1 do
  begin
    if UpperCase(TQueryParam(Items[i]).ParamName) = AParamName then
    begin
      Result:=TQueryParam(Items[i]);
      exit;
    end;
  end;
end;

function TQueryParamList.Add(AParamType: TFieldType; const AParamName,
  AParamValue: string): TQueryParam;
begin
  Result:=TQueryParam.Create;
  inherited Add(Result);
  Result.ParamType:=AParamType;
  Result.ParamName:=AParamName;
  Result.ParamValue:=AParamValue;
end;

{ TlrUIBData }

constructor TlrUIBData.Create(AOwner: TComponent);
begin
  if Assigned(lrUIBCmp) then
    raise Exception.Create('Only one instance of TlrUIBData allowed.');
  inherited Create(AOwner);
  lrUIBCmp:=Self;
end;

destructor TlrUIBData.Destroy;
begin
  if lrUIBCmp = Self then
    lrUIBCmp:=nil;
  inherited Destroy;
end;

{ TLRUIBDatabase }

function TLRUIBDatabase.GetConnected: Boolean;
begin
  Result:=FUIBDataBase.Connected;
end;

function TLRUIBDatabase.GetCharacterSet: TCharacterSet;
begin
  Result:=FUIBDataBase.CharacterSet;
end;

function TLRUIBDatabase.GetDatabaseName: string;
begin
  Result:=FUIBDataBase.DatabaseName;
end;

function TLRUIBDatabase.GetPassword: string;
begin
  Result:=FUIBDataBase.PassWord;
end;

function TLRUIBDatabase.GetRole: string;
begin
  Result:=FUIBDataBase.Role;
end;

function TLRUIBDatabase.GetUserName: string;
begin
  Result:=FUIBDataBase.UserName;
end;

procedure TLRUIBDatabase.SetCharacterSet(AValue: TCharacterSet);
begin
  FUIBDataBase.CharacterSet:=AValue;
end;

procedure TLRUIBDatabase.SetConnected(AValue: Boolean);
begin
  FUIBDataBase.Connected:=AValue;
  if AValue then
    FUIBTransaction.StartTransaction;
end;

procedure TLRUIBDatabase.SetDatabaseName(AValue: string);
begin
  FUIBDataBase.DatabaseName:=AValue;
end;

procedure TLRUIBDatabase.SetPassword(AValue: string);
begin
  FUIBDataBase.PassWord:=AValue;
end;

procedure TLRUIBDatabase.SetRole(AValue: string);
begin
  FUIBDataBase.Role:=AValue;
end;

procedure TLRUIBDatabase.SetUserName(AValue: string);
begin
  FUIBDataBase.UserName:=AValue;
end;

procedure TLRUIBDatabase.SetName(const AValue: string);
begin
  inherited SetName(AValue);
  FUIBDataBase.Name:=Name;
  FUIBTransaction.Name:='tr'+Name;
end;

procedure TLRUIBDatabase.AfterLoad;
begin
  inherited AfterLoad;
  FUIBDataBase.Connected:=FConnected;
  if FConnected then
    FUIBTransaction.StartTransaction;
end;

constructor TLRUIBDatabase.Create(AOwnerPage: TfrPage);
begin
  inherited Create(AOwnerPage);
  BaseName := 'LRUIBDatabase';
  FUIBDataBase:=TUIBDataBase.Create(OwnerForm);
  FUIBTransaction:=TUIBTransaction.Create(OwnerForm);
  FUIBTransaction.DataBase:=FUIBDataBase;
end;

destructor TLRUIBDatabase.Destroy;
begin
{  if not Assigned(OwnerForm) then
  begin
    FreeAndNil(FUIBDataBase);
    FreeAndNil(FUIBTransaction);
  end;}
  inherited Destroy;
end;

procedure TLRUIBDatabase.LoadFromXML(XML: TLrXMLConfig; const Path: String);
begin
  inherited LoadFromXML(XML, Path);
  FConnected:=XML.GetValue(Path + 'Connected/Value'{%H-}, false);
  DatabaseName:=XML.GetValue(Path + 'DatabaseName/Value'{%H-}, '');
  UserName:=XML.GetValue(Path + 'UserName/Value'{%H-}, '');
  Role:=XML.GetValue(Path + 'Role/Value'{%H-}, '');
  Password:=XML.GetValue(Path + 'Password/Value'{%H-}, '');
  RestoreProperty('CharacterSet',XML.GetValue(Path+'CharacterSet/Value','csNONE'));
end;

procedure TLRUIBDatabase.SaveToXML(XML: TLrXMLConfig; const Path: String);
begin
  inherited SaveToXML(XML, Path);
  XML.SetValue(Path + 'Connected/Value'{%H-}, Connected);
  XML.SetValue(Path + 'DatabaseName/Value'{%H-}, DatabaseName);
  XML.SetValue(Path + 'UserName/Value'{%H-}, UserName);
  XML.SetValue(Path + 'Role/Value'{%H-}, Role);
  XML.SetValue(Path + 'Password/Value'{%H-}, Password);
  XML.SetValue(Path + 'CharacterSet/Value'{%H-}, GetSaveProperty('CharacterSet'));
end;

{ TlrFBDataSet }

procedure TlrFBDataSet.SetDatabase(AValue: string);
var
  D:TComponent;
  i:integer;
  TD: TUIBTransaction;
begin
  if FDatabase=AValue then Exit;
  FDatabase:=AValue;

  DataSet.Active:=false;
  D:=frFindComponent(OwnerForm, FDatabase);
  if Assigned(D) and (D is TUIBDataBase)then
  begin
    TFBDataSet(DataSet).DataBase:=TUIBDataBase(D);
    DoSetTransaction;
  end;
end;

procedure TlrFBDataSet.FBDataSetBeforeOpen(ADataSet: TDataSet);
var
  i: Integer;
  s: String;
  SaveView: TfrView;
  SavePage: TfrPage;
  SaveBand: TfrBand;
  Q:TFBDataSet;
  P: TQueryParam;
  V:Variant;
begin
  Q:=TFBDataSet(DataSet);
  SaveView := CurView;
  SavePage := CurPage;
  SaveBand := CurBand;

  CurView := nil;
  CurPage := OwnerPage;
  CurBand := nil;

  for i := 0 to Q.Macros.Count - 1 do
  begin
    V:=frParser.Calc(FMacros.ParamByName(Q.Macros[i].Name).ParamValue);
    if V = null then
      Q.MacroByName(Q.Macros[i].Name).Value:=''
    else
      Q.MacroByName(Q.Macros[i].Name).Value:=V;
  end;

  for i := 0 to Q.Params.FieldCount - 1 do
  begin
    S:=Q.Params.FieldName[i];
    P:=TQueryParam(FParams.ParamByName(S));
    if Assigned(P) and (P.ParamValue <> '') {and (DocMode = dmPrinting) }then
    begin
      V:=frParser.Calc(P.ParamValue);
      if V = null then
        Q.Params.IsNull[i]:=true
      else
      case P.ParamType of
        ftDate,
        ftDateTime:Q.Params.AsDateTime[i] := V;//frParser.Calc(P.ParamValue);
        ftInteger:Q.Params.AsInteger[i] := V;//frParser.Calc(P.ParamValue);
        ftFloat:Q.Params.AsDouble[i] := V;//frParser.Calc(P.ParamValue);
        ftString:Q.Params.AsString[i] := V;//frParser.Calc(P.ParamValue);
      else
        Q.Params.AsVariant[i] := V;//frParser.Calc(P.ParamValue);
      end;
    end;
  end;

  if Assigned(Q.DataBase) then
    if not Q.DataBase.Connected then Q.DataBase.Connected:=true;

  if Assigned(Q.Transaction) then
  begin
    if not Q.Transaction.InTransaction then
      Q.Transaction.StartTransaction
  end
  else
  ;

  CurView := SaveView;
  CurPage := SavePage;
  CurBand := SaveBand;
end;

procedure TlrFBDataSet.DoMakeParams;
var
  Q:TFBDataSet;
  i:integer;
  P: TQueryParam;

  function FindParam(ParName:string):boolean;
  var
    k: Word;
  begin
    Result:=Q.Params.TryGetFieldIndex(UpperCase(ParName), k);
  end;

begin
  Q:=TFBDataSet(DataSet);
  if Q.Params.FieldCount > 0 then
  begin
    //Add new params...
    for i:=0 to Q.Params.FieldCount - 1 do
    begin
      if not Assigned(FParams.ParamByName(Q.Params.FieldName[i])) then
        FParams.Add(ftUnknown, Q.Params.FieldName[i], '');
    end;

    //Delete not exists params
    for i:=FParams.Count-1 downto 0 do
    begin
      P:=TQueryParam(FParams[i]);
      if not FindParam(P.ParamName) then
        FParams.Delete(i);
    end;
  end
  else
    FParams.Clear;

  if Q.MacroCount > 0 then
  begin
    //Add new params...
    for i:=0 to Q.MacroCount-1 do
      if not Assigned(FMacros.ParamByName(Q.Macros.Items[i].Name))  then
        FMacros.Add(ftUnknown, Q.Macros.Items[i].Name, ''''+Q.Macros.Items[i].Value+'''');

    //Delete not exists params
    for i:=FMacros.Count-1 downto 0 do
    begin
      P:=TQueryParam(FMacros[i]);
      if not Assigned(Q.Macros.FindParam(P.ParamName)) then
        FMacros.Delete(i);
    end;
  end
  else
    FMacros.Clear;
end;

function TlrFBDataSet.DoEditParams(ParOrMacro: boolean): boolean;
begin
  lrEditUVariablesForm:=TlrEditUVariablesForm.Create(Application);

  if not ParOrMacro then
    lrEditUVariablesForm.HideType;

  if ParOrMacro then
    lrEditUVariablesForm.LoadParamList(FParams)
  else
    lrEditUVariablesForm.LoadParamList(FMacros);
  Result:=false;
  if lrEditUVariablesForm.ShowModal = mrOk then
  begin
    Result:=true;
    if ParOrMacro then
      lrEditUVariablesForm.SaveParamList(FParams)
    else
      lrEditUVariablesForm.SaveParamList(FMacros);
    if Assigned(frDesigner) then
      frDesigner.Modified:=true;
  end;
  lrEditUVariablesForm.Free;
end;

procedure TlrFBDataSet.DoSetTransaction;
var
  D: TUIBDataBase;
  i: Integer;
  TD: TUIBTransaction;
begin
  D:=TFBDataSet(DataSet).DataBase;
  if D.TransactionsCount>0 then
  begin
    if Assigned(lrUIBCmp) and Assigned(lrUIBCmp.FDefaultTransaction) then
    begin
      for i:=0 to D.TransactionsCount - 1 do
      begin
        if D.Transactions[i] = lrUIBCmp.FDefaultTransaction then
        begin
          TFBDataSet(DataSet).Transaction:=lrUIBCmp.FDefaultTransaction;
          break;
        end;
      end;
    end;

    if not Assigned(TFBDataSet(DataSet).Transaction) then
    begin
      TD:=nil;
      for i:=0 to D.TransactionsCount - 1 do
      begin
        if D.Transactions[I].InTransaction then
        begin
          TD:=D.Transactions[I];
          break;
        end;
      end;
      if (not Assigned(TD)) and (D.TransactionsCount>0) then
        TD:=D.Transactions[0];
      TFBDataSet(DataSet).Transaction:=TD;
    end;
  end;
end;

function TlrFBDataSet.GetSQL: string;
begin
  Result:=TFBDataSet(DataSet).SQLSelect.Text;
end;

procedure TlrFBDataSet.SetSQL(AValue: string);
begin
  DataSet.Active:=false;
  TFBDataSet(DataSet).SQLSelect.Text:=AValue;
  DoMakeParams;
  if Assigned(frDesigner) then
    frDesigner.Modified:=true;
end;

procedure TlrFBDataSet.SetDataSource(AValue: string);
var
  D:TComponent;
begin
  inherited SetDataSource(AValue);
  D:=frFindComponent(OwnerForm, AValue);
  if Assigned(D) and (D is TDataSource)then
    TFBDataSet(DataSet).DataSource:=TDataSource(D);
end;

procedure TlrFBDataSet.AfterLoad;
var
  D:TComponent;
  i: Integer;
begin
  D:=frFindComponent(OwnerForm, DataSource);
  if Assigned(D) and (D is TDataSource)then
    TFBDataSet(DataSet).DataSource:=TDataSource(D);

  D:=frFindComponent(OwnerForm, FDatabase);
  if Assigned(D) and (D is TUIBDataBase)then
  begin
    TFBDataSet(DataSet).DataBase:=TUIBDataBase(D);
    DoSetTransaction;
    DataSet.Active:=FActive;
  end;
end;

constructor TlrFBDataSet.Create(AOwnerPage: TfrPage);
begin
  inherited Create(AOwnerPage);
  FMacros:=TQueryParamList.Create;
  FParams:=TQueryParamList.Create;

  BaseName := 'lrFBDataSet';
  DataSet:=TFBDataSet.Create(OwnerForm);
  DataSet.BeforeOpen:=@FBDataSetBeforeOpen;
end;

destructor TlrFBDataSet.Destroy;
begin
  FreeAndNil(FMacros);
  FreeAndNil(FParams);
  inherited Destroy;
end;

procedure TlrFBDataSet.LoadFromXML(XML: TLrXMLConfig; const Path: String);
var
  C, I:integer;
  S:string;
begin
  inherited LoadFromXML(XML, Path);
  TFBDataSet(DataSet).SQLSelect.Text:=XML.GetValue(Path+'SQL/Value'{%H-}, '');
  FDatabase:= XML.GetValue(Path+'Database/Value'{%H-}, '');

  C:=XML.GetValue(Path+'Params/Count/Value', 0);
  for i:=0 to C-1 do
  begin
    S:=XML.GetValue(Path+'Params/Item'+IntToStr(i)+'/Name', '');
    if S<>'' then
    begin
      FParams.Add(
        StrToFieldType(XML.GetValue(Path+'Params/Item'+IntToStr(i)+'/ParamType', '')),
        S,
        XML.GetValue(Path+'Params/Item'+IntToStr(i)+'/Value', ''));
    end;
  end;

  C:=XML.GetValue(Path+'Macros/Count/Value', 0);
  for i:=0 to C-1 do
  begin
    S:=XML.GetValue(Path+'Macros/Item'+IntToStr(i)+'/Name', '');
    if S<>'' then
    begin
      FMacros.Add(ftUnknown,
        S,
        XML.GetValue(Path+'Macros/Item'+IntToStr(i)+'/Value', ''));
    end;
  end;
end;

procedure TlrFBDataSet.SaveToXML(XML: TLrXMLConfig; const Path: String);
var
  i:integer;
  P: TQueryParam;
begin
  inherited SaveToXML(XML, Path);
  XML.SetValue(Path+'SQL/Value', TFBDataSet(DataSet).SQLSelect.Text);
  XML.SetValue(Path+'Database/Value', FDatabase);

  XML.SetValue(Path+'Params/Count/Value', FParams.Count);
  for i:=0 to FParams.Count-1 do
  begin
    P:=TQueryParam(FParams[i]);
    XML.SetValue(Path+'Params/Item'+IntToStr(i)+'/ParamType', Fieldtypenames[P.ParamType]);
    XML.SetValue(Path+'Params/Item'+IntToStr(i)+'/Name', P.ParamName);
    XML.SetValue(Path+'Params/Item'+IntToStr(i)+'/Value', P.ParamValue);
  end;

  XML.SetValue(Path+'Macros/Count/Value', FMacros.Count);
  for i:=0 to FMacros.Count-1 do
  begin
    P:=TQueryParam(FMacros[i]);
    XML.SetValue(Path+'Macros/Item'+IntToStr(i)+'/Name', P.ParamName);
    XML.SetValue(Path+'Macros/Item'+IntToStr(i)+'/Value', P.ParamValue);
  end;

end;

type

  { TLRFBDataSetParamsProperty }

  TLRFBDataSetParamsProperty = class(TPropertyEditor)
  public
    function  GetAttributes: TPropertyAttributes; override;
    function GetValue: ansistring; override;
    procedure Edit; override;
  end;

  { TLRFBDataSetDataBaseProperty }

  TLRFBDataSetDataBaseProperty = class(TFieldProperty)
  public
    procedure FillValues(const Values: TStringList); override;
  end;


  { TLRFBDataSetSQLProperty }

  TLRFBDataSetSQLProperty = class(TPropertyEditor)
  public
    function GetAttributes: TPropertyAttributes; override;
    function GetValue: ansistring; override;
    procedure Edit; override;
  end;

{ TLRFBDataSetSQLProperty }

function TLRFBDataSetSQLProperty.GetAttributes: TPropertyAttributes;
begin
  Result:=[paDialog, paReadOnly];
end;

function TLRFBDataSetSQLProperty.GetValue: ansistring;
begin
  Result:='(SQL)';
end;

procedure TLRFBDataSetSQLProperty.Edit;
var
  TheDialog : TStringsPropEditorDlg;
  AString : string;
begin
  AString := GetStrValue;
  TheDialog := TStringsPropEditorDlg.Create(nil);
  try
    TheDialog.Editor := Self;
    TheDialog.Memo.Text := AString;
    TheDialog.MemoChange(nil);
    if (TheDialog.ShowModal = mrOK) then
    begin
      AString := TrimRight(TheDialog.Memo.Text);
      //erase the last lineending if any
{      if Copy(AString, length(AString) - length(LineEnding) + 1, length(LineEnding)) = LineEnding then
        Delete(AString, length(AString) - length(LineEnding) + 1, length(LineEnding));}
      SetStrValue(AString);
//      Modified;
    end;
  finally
    TheDialog.Free;
  end;
end;

{ TLRFBDataSetParamsProperty }

function TLRFBDataSetParamsProperty.GetAttributes: TPropertyAttributes;
begin
  Result:=[paDialog, paReadOnly];
end;

function TLRFBDataSetParamsProperty.GetValue: ansistring;
begin
  Result:='(Params)';
end;

procedure TLRFBDataSetParamsProperty.Edit;
begin
  if (GetComponent(0) is TlrFBDataSet) then
    if TlrFBDataSet(GetComponent(0)).DoEditParams(UpperCase(GetName) = 'PARAMS') then
      Modified;
end;

{ TLRFBDataSetDataBaseProperty }

procedure TLRFBDataSetDataBaseProperty.FillValues(const Values: TStringList);
begin
  if (GetComponent(0) is TlrFBDataSet) then
    frGetComponents(nil, TUIBDataBase, Values, nil);
end;


initialization
  InitLRComp;

  RegisterPropertyEditor(TypeInfo(string), TlrFBDataSet, 'Database', TLRFBDataSetDataBaseProperty);
  RegisterPropertyEditor(TypeInfo(TQueryParamList), TlrFBDataSet, 'Params', TLRFBDataSetParamsProperty);
  RegisterPropertyEditor(TypeInfo(TQueryParamList), TlrFBDataSet, 'Macros', TLRFBDataSetParamsProperty);
  RegisterPropertyEditor(TypeInfo(string), TlrFBDataSet, 'SQL', TLRFBDataSetSQLProperty);

finalization
  if Assigned(lrBMP_FBDataSet) then
    FreeAndNil(lrBMP_FBDataSet);
  if Assigned(lrBMP_UIBDatabase) then
    FreeAndNil(lrBMP_UIBDatabase);
end.
