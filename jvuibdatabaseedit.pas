(********************************************************************************)
(*                        UNIFIED INTERBASE (UIB)                               *)
(*                                                                              *)
(* The contents of this file are subject to the Mozilla Public License Version  *)
(* 1.1 (the "License"); you may not use this file except in compliance with the *)
(* License. You may obtain a copy of the License at http://www.mozilla.org/MPL/ *)
(*                                                                              *)
(* Software distributed under the License is distributed on an "AS IS" basis,   *)
(* WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for *)
(* the specific language governing rights and limitations under the License.    *)
(*                                                                              *)
(* Unit owner : Henri Gourvest <hgourvest@progdigy.com>                         *)
(*                                                                              *)
(********************************************************************************)
(* $Id: jvuibdatabaseedit.pas,v 1.4 2004/12/08 19:53:22 progdigy Exp $ *)
(********************************************************************************)

unit jvuibdatabaseedit;

{$I jvuib.inc}

interface

uses
  SysUtils, LResources, Classes, Graphics, Controls, Forms, Dialogs,  StdCtrls, ExtCtrls,
  uib, uiblib, uibase, CheckLst, Menus, Buttons, ButtonPanel;

type

  { TUIBDatabaseEditForm }

  TUIBDatabaseEditForm = class(TForm)
    BrowseLib: TButton;
    ButtonPanel1: TButtonPanel;
    Connection: TGroupBox;
    LibraryName: TEdit;
    ModeLbl: TLabel;
    LibOpenDialog: TOpenDialog;
    ServerLbl: TLabel;
    PortLbl: TLabel;
    DatabaseLbl: TLabel;
    Mode: TComboBox;
    ServerName: TEdit;
    DatabaseName: TEdit;
    PortName: TEdit;
    Browse: TButton;
    DBOpenDialog: TOpenDialog;
    Parametters: TMemo;
    Test: TBitBtn;
    UserName: TEdit;
    UserNameLbl: TLabel;
    Password: TEdit;
    PasswordLbl: TLabel;
    SQLRole: TEdit;
    SQLRoleLbl: TLabel;
    CharacterSet: TComboBox;
    CharacterSetLbl: TLabel;
    LibraryNameLbl: TLabel;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure ModeChange(Sender: TObject);
    procedure BrowseClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure UserNameChange(Sender: TObject);
    procedure PasswordChange(Sender: TObject);
    procedure SQLRoleChange(Sender: TObject);
    procedure CharacterSetChange(Sender: TObject);
    procedure TestClick(Sender: TObject);
    procedure ParamettersExit(Sender: TObject);
    procedure BrowseLibClick(Sender: TObject);
  private
    FDatabase: TUIBDataBase;
    procedure SetDatabase(Database: TUIBDataBase);
    function GetDBName: string;
  public
    property Database: TUIBDataBase read FDatabase write SetDatabase;
  end;

var
  UIBDatabaseEditForm: TUIBDatabaseEditForm;

implementation
uses uibeditorsconsts;

{$R *.lfm}

{ TUIBDatabaseEditForm }

procedure TUIBDatabaseEditForm.ModeChange(Sender: TObject);
begin
  if Mode.ItemIndex = 0 then
  begin
    ServerName.Enabled := False;
    ServerLbl.Enabled := False;
    PortName.Enabled := False;
    PortLbl.Enabled := False;
  end else
  begin
    ServerName.Enabled := True;
    ServerLbl.Enabled := True;
    if Mode.ItemIndex = 1 then
    begin
      PortName.Enabled := True;
      PortLbl.Enabled := True;
    end else
    begin
      PortName.Enabled := False;
      PortLbl.Enabled := False;
    end;
  end;
end;

procedure TUIBDatabaseEditForm.FormClose(Sender: TObject;
  var CloseAction: TCloseAction);
begin
  if ModalResult = mrOk then
  begin
    Database.DatabaseName := GetDBName;
    Database.Params.Assign(Parametters.Lines);
    Database.LibraryName := LibraryName.Text;
  end;
end;

procedure TUIBDatabaseEditForm.BrowseClick(Sender: TObject);
begin
  DBOpenDialog.FileName:=DatabaseName.Text;
  if DBOpenDialog.Execute then
    DatabaseName.Text := DBOpenDialog.FileName;
end;

procedure TUIBDatabaseEditForm.BrowseLibClick(Sender: TObject);
begin
  LibOpenDialog.FileName:=LibraryName.Text;
  if LibOpenDialog.Execute then
    LibraryName.Text := LibOpenDialog.FileName;
end;

procedure TUIBDatabaseEditForm.SetDatabase(Database: TUIBDataBase);
var
  Idx1, Idx2: Integer;
  st: string;

  procedure ParseServerName(Str: string);
  var P: Integer;
  begin
    P := Pos('/', Str);
    if P = 0 then
      ServerName.Text := Str else
    begin
      ServerName.Text := copy(Str,0, P-1);
      PortName.Text := copy(Str, P+1, Length(Str));
    end;
  end;
begin
  FDatabase := Database;

  // Parse Database Name
  if Pos('\\', Database.DatabaseName) <> 0 then
  begin
    Mode.ItemIndex := 2;
    ModeChange(nil);
    st := copy(Database.DatabaseName, 3, Length(Database.DatabaseName));
    Idx1 := Pos('\', st);
    if Idx1 = 0 then
      raise Exception.Create('Unknow error')
    else begin
      ParseServerName(Copy(st, 1, Idx1 - 1));
      DatabaseName.Text:= Copy(st, Idx1 + 1, Length(st));
    end;
  end
  else
  begin
    Idx1 := Pos(':', Database.DatabaseName );
    If (Idx1 = 0) or (Idx1 = 2) then
    begin
      Mode.ItemIndex := 0;
      ModeChange(nil);
      DatabaseName.Text := Database.DatabaseName;
    end
    else
    begin
      Idx2 := Pos('@', Database.DatabaseName);
      if Idx2 = 0 then
      begin
        Mode.ItemIndex := 1;
        ModeChange(nil);
        ParseServerName(copy(Database.DatabaseName, 1, Idx1 - 1));
        DatabaseName.Text := copy(Database.DatabaseName, Idx1 + 1,
          Length(Database.DatabaseName));
      end
      else begin
        Mode.ItemIndex := 3;
        ModeChange(nil);
        ParseServerName(copy(Database.DatabaseName, 1, Idx2 - 1));
        DatabaseName.Text := copy(Database.DatabaseName, Idx2 + 1,
          Length(Database.DatabaseName));
      end;
    end;
  end;

  // Parametters
  UserName.Text := Database.UserName;
  Password.Text := Database.PassWord;
  SQLRole.Text := Database.Params.Values['sql_role_name'];
  CharacterSet.ItemIndex := ord(Database.CharacterSet);
  Parametters.Lines.Assign(Database.Params);

  // Library
  LibraryName.Text := Database.LibraryName;
end;


procedure TUIBDatabaseEditForm.FormCreate(Sender: TObject);
var i: TCharacterSet;
begin
  for i := low(TCharacterSet) to high(TCharacterSet) do
    CharacterSet.Items.Add(CharacterSetStr[i]);
  {$IFDEF WINDOWS}
  LibOpenDialog.DefaultExt:='.dll';
  LibOpenDialog.FilterIndex:=0;
  {$ELSE}
  LibOpenDialog.DefaultExt:='.so';
  LibOpenDialog.FilterIndex:=1;
  {$ENDIF}

  Test.AnchorSideTop.Control:=ButtonPanel1.OKButton;
  Test.AnchorSideBottom.Control:=ButtonPanel1.OKButton;

  DBOpenDialog.Title:=sSelectDatabaseFile;
  LibOpenDialog.Title:=sSelectLibraryFileName;

  Caption:=sUIBDatabaseEditor;
  Connection.Caption:=sConnection;
  ModeLbl.Caption:=sModeLbl;
  ServerLbl.Caption:=sServerLbl;
  PortLbl.Caption:=sPortLbl;
  DatabaseLbl.Caption:=sDatabaseLbl;
  LibraryNameLbl.Caption:=sLibraryNameLbl;
  UserNameLbl.Caption:=sUserNameLbl;
  PasswordLbl.Caption:=sPasswordLbl;
  SQLRoleLbl.Caption:=sSQLRoleLbl;
  CharacterSetLbl.Caption:=sCharacterSetLbl;
end;

procedure TUIBDatabaseEditForm.UserNameChange(Sender: TObject);
begin
  Parametters.Lines.Values['user_name'] := UserName.Text;
end;

procedure TUIBDatabaseEditForm.PasswordChange(Sender: TObject);
begin
  Parametters.Lines.Values['password'] := Password.Text;
end;

procedure TUIBDatabaseEditForm.SQLRoleChange(Sender: TObject);
begin
  Parametters.Lines.Values['sql_role_name'] := SQLRole.Text;
end;

procedure TUIBDatabaseEditForm.CharacterSetChange(Sender: TObject);
begin
  Parametters.Lines.Values['lc_ctype'] := CharacterSet.Text;
end;

function TUIBDatabaseEditForm.GetDBName: string;
function GetServerName: string;
begin
  if (PortName.Text <> '') and (mode.ItemIndex = 1) then
    result := ServerName.Text + '/' + PortName.Text else
    result := ServerName.Text;
end;
begin
  case Mode.ItemIndex of
    0: Result := DatabaseName.Text;
    1: Result := format('%s:%s', [GetServerName, DatabaseName.Text]);
    2: Result := format('\\%s\%s', [GetServerName, DatabaseName.Text]);
    3: Result := format('%s@%s', [GetServerName, DatabaseName.Text]);
  end;
end;

procedure TUIBDatabaseEditForm.TestClick(Sender: TObject);
var DB: TUIBDataBase;
begin
  DB := TUIBDataBase.Create(nil);
  try
    DB.LibraryName := LibraryName.Text;
    DB.DatabaseName := GetDBName;
    DB.Params.Assign(Parametters.Lines);
    DB.Connected := True;
  finally
    DB.Free;
  end;
  ShowMessage('Connection succeded.');
end;

procedure TUIBDatabaseEditForm.ParamettersExit(Sender: TObject);
begin
  UserName.Text := Parametters.Lines.Values['user_name'];
  Password.Text := Parametters.Lines.Values['password'];
  SQLRole.Text := Parametters.Lines.Values['sql_role_name'];
  CharacterSet.Text := Parametters.Lines.Values['lc_ctype'];
end;

end.
