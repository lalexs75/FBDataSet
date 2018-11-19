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
(* Unit owner : Lagunov Aleksey <alexs75@hotbox.ru>                             *)
(*                                                                              *)
(********************************************************************************)

unit laz_editors_register;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, PropEdits, componenteditors, typinfo, uib, DBPropEdits;

type

  { TUIBDatabaseEditor }

  TUIBDatabaseEditor = class(TComponentEditor)
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;

  { TUIBTransactionEditor }

  TUIBTransactionEditor = class(TComponentEditor)
  public
    procedure ExecuteVerb(Index: Integer); override;
    function GetVerb(Index: Integer): string; override;
    function GetVerbCount: Integer; override;
  end;
  
  { TUIBDatabaseDBNameProperty }

  TUIBDatabaseDBNameProperty = class(TStringPropertyEditor)
  public
    function GetAttributes: TPropertyAttributes; override;
    procedure Edit; override;
  end;

  { TUIBDatabaseRoleNameProperty }

  TUIBDatabaseRoleNameProperty = class(TFieldProperty)
  public
    procedure FillValues(const Values: TStringList); override;
    procedure SetValue(const NewValue: ansistring); override;
  end;

procedure Register;
implementation
uses jvuibdatabaseedit, Forms, LCLType, Controls, jvuibtransactionedit, uiblib;

procedure Register;
begin
  RegisterComponentEditor(TUIBDataBase, TUIBDatabaseEditor);
  RegisterComponentEditor(TUIBTransaction, TUIBTransactionEditor);

  RegisterPropertyEditor(TypeInfo(string), TUIBDataBase, 'DatabaseName', TUIBDatabaseDBNameProperty);
  RegisterPropertyEditor(TypeInfo(string), TUIBDataBase, 'Role', TUIBDatabaseRoleNameProperty);
end;

{ TUIBDatabaseEditor }

procedure TUIBDatabaseEditor.ExecuteVerb(Index: Integer);
begin
  with TUIBDatabaseEditForm.Create(Application) do
  try
    Database := TUIBDataBase(Component);
    if ShowModal = mrOk then
      inherited Designer.Modified;
  finally
    Free;
  end;
end;

function TUIBDatabaseEditor.GetVerb(Index: Integer): string;
begin
  Result := 'Database Editor ...';
end;

function TUIBDatabaseEditor.GetVerbCount: Integer;
begin
  Result := 1;
end;

{ TUIBTransactionEditor }

procedure TUIBTransactionEditor.ExecuteVerb(Index: Integer);
begin
  with TUIBTransactionEditForm.Create(Application) do
  try
    Transaction := TUIBTransaction(Component);
    if ShowModal = mrOk then
      inherited Designer.Modified;
  finally
    Free;
  end;
end;

function TUIBTransactionEditor.GetVerb(Index: Integer): string;
begin
  Result := 'Transaction Editor ...';
end;

function TUIBTransactionEditor.GetVerbCount: Integer;
begin
  Result:=1;
end;

{ TUIBDatabaseDBNameProperty }

function TUIBDatabaseDBNameProperty.GetAttributes: TPropertyAttributes;
begin
  Result:=inherited GetAttributes + [paDialog];
end;

procedure TUIBDatabaseDBNameProperty.Edit;
var
  UIBDataBase: TUIBDataBase;
begin
  UIBDataBase := GetComponent(0) as TUIBDataBase;
  with TUIBDatabaseEditForm.Create(Application) do
  try
    Database := TUIBDataBase(UIBDataBase);
    if ShowModal = mrOk then
      Modified;
  finally
    Free;
  end;
end;

{ TUIBDatabaseRoleNameProperty }
const
  sRoleList =
    'select rdb$roles.rdb$role_name from rdb$roles order by rdb$roles.rdb$role_name';

procedure TUIBDatabaseRoleNameProperty.FillValues(const Values: TStringList);
var
  D:TUIBDataBase;
  Q:TUIBQuery;
  Tr:TUIBTransaction;
begin
  D:=TUIBDataBase(GetComponent(0));
  if not (D is TUIBDataBase) then exit;
  if not D.Connected then exit;

  Tr:=TUIBTransaction.Create(nil);
  Tr.DataBase:=D;
  Tr.Options:=[tpRead, tpReadCommitted, tpRecVersion];
  Tr.StartTransaction;
  Q:=TUIBQuery.Create(nil);
  try
    Q.DataBase:=D;
    Q.Transaction:=Tr;
    Q.SQL.Text:=sRoleList;
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

procedure TUIBDatabaseRoleNameProperty.SetValue(const NewValue: ansistring);
begin
  try
    inherited SetValue(NewValue);
  finally
  end;
end;

end.

