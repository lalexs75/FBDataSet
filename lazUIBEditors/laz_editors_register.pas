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
  Classes, SysUtils, PropEdits, componenteditors, typinfo, jvuib;

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
  
procedure Register;
implementation
uses jvuibdatabaseedit, Forms, LCLType, Controls, jvuibtransactionedit;

procedure Register;
begin
  RegisterComponentEditor(TJvUIBDataBase, TUIBDatabaseEditor);
  RegisterComponentEditor(TJvUIBTransaction, TUIBTransactionEditor);
end;

{ TUIBDatabaseEditor }

procedure TUIBDatabaseEditor.ExecuteVerb(Index: Integer);
begin
  with TUIBDatabaseEditForm.Create(Application) do
  try
    Database := TJvUIBDataBase(Component);
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
    Transaction := TJvUIBTransaction(Component);
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

end.

