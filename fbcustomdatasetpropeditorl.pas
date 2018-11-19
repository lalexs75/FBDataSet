(********************************************************************************)
(*                        FB/IB Data set (FBDataSet)                            *)
(*                                                                              *)
(* The contents of this file are subject to the GNU LIBRARY GENERAL PUBLIC      *)
(* LICENSE 2 (the "License"); you may not use this file except in compliance    *)
(* with the License. You may obtain a copy of the License at                    *)
(*  http://www.gnu.org/copyleft/lesser.html                                     *)
(*                                                                              *)
(* Software distributed under the License is distributed on an "AS IS" basis,   *)
(* WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for *)
(* the specific language governing rights and limitations under the License.    *)
(*                                                                              *)
(* Unit owner : Lagunov Aleksey <alexs@w7site.ru>                               *)
(*                                                                              *)
(********************************************************************************)

{$I fb_define.inc}
unit fbcustomdatasetpropeditorl;

interface
uses Classes, PropEdits, ComponentEditors, typinfo;

type
  TFBDataSetSQLProperty = class(TClassProperty)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure Edit; override;
  end;

  TFBDataSetEditor = class(TComponentEditor)
  public
  {$IFDEF FPC}
    DefaultEditor: TBaseComponentEditor;
    constructor Create(AComponent: TComponent; ADesigner: TComponentEditorDesigner); override;
  {$ELSE}
    DefaultEditor: IComponentEditor;
    constructor Create(AComponent: TComponent; ADesigner: IDesigner); override;
  {$ENDIF}
    destructor Destroy; override;
    function GetVerbCount:integer;override;
    function GetVerb(Index:integer):string;override;
    procedure ExecuteVerb(Index:integer);override;
//    procedure Edit;override;
  end;

  TAutoUpdateOptionsProperty = class(TClassProperty)
  public
    procedure Edit; override;
    function  GetAttributes: TPropertyAttributes; override;
    function  GetValue: string; override;
  end;


procedure Register;
implementation
uses fbcustomdataset, Forms, Controls, fbcustomdatasetautoupdateoptionseditorl,
  DB, SysUtils, fbcustomdatasetsqleditorl, LResources, DBPropEdits, uiblib,
  uibstoredproc, UIB, dcl_fb_id_StrConsts;

{$R fb_laz_resourse.res}

type

  { TUIBStoredProcNameProperty }

  TUIBStoredProcNameProperty = class(TFieldProperty)
  public
    procedure FillValues(const Values: TStringList); override;
    procedure SetValue(const NewValue: ansistring); override;
  end;

{ TUIBStoredProcNameProperty }

procedure TUIBStoredProcNameProperty.FillValues(const Values: TStringList);
var
  SP: TUIBStoredProc;
  Q:TUIBQuery;
  Tr:TUIBTransaction;
begin
  SP:=TUIBStoredProc(GetComponent(0));
  if not (SP is TUIBStoredProc) then exit;
  if not Assigned(SP.DataBase) then exit;
  if not SP.DataBase.Connected then exit;

  Tr:=TUIBTransaction.Create(nil);
  Tr.DataBase:=SP.DataBase;
  Tr.Options:=[tpRead, tpReadCommitted, tpRecVersion];
  Tr.StartTransaction;
  Q:=TUIBQuery.Create(nil);
  try
    Q.DataBase:=SP.DataBase;
    Q.Transaction:=Tr;
    Q.SQL.Text:='select rdb$procedures.rdb$procedure_name from rdb$procedures';
    Q.Open;
    Values.Clear;
    while not Q.Eof do
    begin
      Values.Add(Trim(Q.Fields.AsString[0]));
      Q.Next;
    end;
    Q.Close;
  finally
    Q.Free;
    Tr.Free;
  end;
end;

procedure TUIBStoredProcNameProperty.SetValue(const NewValue: ansistring);
begin
  try
    inherited SetValue(NewValue);
  finally
  end;
end;

procedure Register;
begin
  {$IFDEF FBSQLEditor}
  RegisterPropertyEditor(TypeInfo(TStrings), TFBDataSet, 'SQLSelect', TFBDataSetSQLProperty);
  RegisterPropertyEditor(TypeInfo(TStrings), TFBDataSet, 'SQLRefresh', TFBDataSetSQLProperty);
  RegisterPropertyEditor(TypeInfo(TStrings), TFBDataSet, 'SQLEdit', TFBDataSetSQLProperty);
  RegisterPropertyEditor(TypeInfo(TStrings), TFBDataSet, 'SQLDelete', TFBDataSetSQLProperty);
  RegisterPropertyEditor(TypeInfo(TStrings), TFBDataSet, 'SQLInsert', TFBDataSetSQLProperty); {do not localize}
  {$ENDIF}
  RegisterPropertyEditor(TypeInfo(TAutoUpdateOptions), TFBDataSet, 'AutoUpdateOptions', TAutoUpdateOptionsProperty); {do not localize}

  RegisterComponentEditor(TFBDataSet, TFBDataSetEditor);

  RegisterPropertyEditor(TypeInfo(string), TUIBStoredProc, 'StoredProcName', TUIBStoredProcNameProperty);
end;

{ TFBDataSetSQLProperty }

procedure TFBDataSetSQLProperty.Edit;
var
  SQLEditor:TFBCustomDataSetSQLEditor;
begin
  SQLEditor:=TFBCustomDataSetSQLEditor.CreateEditor(GetComponent(0) as TFBDataSet);
  if GetPropInfo^.Name='SQLDelete' then
    SQLEditor.PageControl1.ActivePageIndex:=3
  else
  if GetPropInfo^.Name='SQLEdit' then
    SQLEditor.PageControl1.ActivePageIndex:=2
  else
  if GetPropInfo^.Name='SQLInsert' then
    SQLEditor.PageControl1.ActivePageIndex:=1
  else
  if GetPropInfo^.Name='SQLRefresh' then
    SQLEditor.PageControl1.ActivePageIndex:=4
  else
  if GetPropInfo^.Name='SQLSelect' then
    SQLEditor.PageControl1.ActivePageIndex:=0;
  try
    if SQLEditor.ShowModal=mrOk then
      {inherited Designer.}Modified;
  finally
    SQLEditor.Free;
  end;
end;

function TFBDataSetSQLProperty.GetAttributes: TPropertyAttributes;
begin
  Result := inherited GetAttributes + [paDialog] - [paSubProperties];
end;

{ TFBDataSetEditor }

procedure TFBDataSetEditor.ExecuteVerb(Index: integer);
var
  SQLEditor:TFBCustomDataSetSQLEditor;
begin
  if Index < DefaultEditor.GetVerbCount then
    DefaultEditor.ExecuteVerb(Index)
  else
  begin
    case Index - DefaultEditor.GetVerbCount of
      0:begin
          SQLEditor:=TFBCustomDataSetSQLEditor.CreateEditor(Component as TFBDataSet);
          try
            if SQLEditor.ShowModal=mrOk then
              Modified;
          finally
              SQLEditor.Free;
          end;
        end;
    end;
  end;
end;

function TFBDataSetEditor.GetVerb(Index: integer): string;
begin
  if Index < DefaultEditor.GetVerbCount then
    Result := DefaultEditor.GetVerb(Index)
  else
  begin
    case Index - DefaultEditor.GetVerbCount of
      0:Result:=dcl_fb_sSQLEditor;
    end;
  end;
end;

type
  PClass = ^TClass;
constructor TFBDataSetEditor.Create(AComponent: TComponent; ADesigner: TComponentEditorDesigner);
var
  CompClass: TClass;
begin
  inherited Create(AComponent, ADesigner);
  CompClass := PClass(Acomponent)^;
  try
    PClass(AComponent)^ := TDataSet;
    DefaultEditor := GetComponentEditor(AComponent, ADesigner);
  finally
    PClass(AComponent)^ := CompClass;
  end;
end;

destructor TFBDataSetEditor.Destroy;
begin
  DefaultEditor.Free;
  inherited Destroy;
end;

function TFBDataSetEditor.GetVerbCount: integer;
begin
  Result:=DefaultEditor.GetVerbCount + 1;
end;

{ TAutoUpdateOptionsProperty }

procedure TAutoUpdateOptionsProperty.Edit;
begin
  FBCustomDataSetAutoUpdateOptionsEditorForm:=TFBCustomDataSetAutoUpdateOptionsEditorForm.Create(Application);
  try
    if FBCustomDataSetAutoUpdateOptionsEditorForm.ShowEditor(GetComponent(0) as TFBDataSet) then
      Modified;
  finally
    FBCustomDataSetAutoUpdateOptionsEditorForm.Free;
  end;
end;

function TAutoUpdateOptionsProperty.GetAttributes: TPropertyAttributes;
begin
  Result := inherited GetAttributes + [paDialog];
//  Result := [paDialog{, paReadOnly}];
end;

function TAutoUpdateOptionsProperty.GetValue: string;
begin
  with TAutoUpdateOptions(GetOrdProp(GetComponent(0), 'AutoUpdateOptions')) do
    if IsComplete then
      Result:={UpdateTableName+'.'+}KeyField+'=GenID('+GeneratorName+', '+IntToStr(IncrementBy)+')'
    else
      Result:='';
end;

end.
