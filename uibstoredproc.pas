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

unit uibstoredproc;

{$ifdef FPC}
  {$mode objfpc}{$H+}
{$endif}

interface

uses
  Classes, SysUtils,
{$ifdef FPC}
 LResources,
{$endif}
 uib;

type

  { TUIBStoredProc }

  TUIBStoredProc = class(TUIBQuery)
  private
    FSelectProc: boolean;
    FStoredProc: string;
    procedure SetSelectProc(const AValue: boolean);
    procedure SetStoredProc(const AValue: string);
    { Private declarations }
  protected
    procedure UpdateSPSql;
    procedure Loaded; override;
  public
    procedure ExecProc;
  published
    property SelectProc: boolean read FSelectProc write SetSelectProc;
    property StoredProcName: string read FStoredProc write SetStoredProc;
  end;

implementation
uses uiblib;

{ TUIBStoredProc }

procedure TUIBStoredProc.SetSelectProc(const AValue: boolean);
begin
  if FSelectProc=AValue then exit;
  FSelectProc:=AValue;
  UpdateSPSql;
end;

procedure TUIBStoredProc.SetStoredProc(const AValue: string);
begin
  if FStoredProc=AValue then exit;
  FStoredProc:=AValue;
  UpdateSPSql;
end;

procedure TUIBStoredProc.UpdateSPSql;
var
  FSaveTran: TUIBTransaction;
begin
  if csLoading in ComponentState then exit;
  if FStoredProc<>'' then
  begin
    FSaveTran:=nil;
    if (not Assigned(Transaction)) or (not Transaction.InTransaction) then
    begin
      FSaveTran:=Transaction;
      Transaction:=TUIBTransaction.Create(nil);
      Transaction.DataBase:=DataBase;
      Transaction.Options:=[tpRead, tpReadCommitted, tpNowait];
      Transaction.StartTransaction;
    end;
    try
      BuildStoredProc(FStoredProc, FSelectProc);
    finally
      if Assigned(FSaveTran) then
      begin
        Transaction.Free;
        Transaction:=FSaveTran;
      end;
    end;
  end
  else
    SQL.Clear;
end;

procedure TUIBStoredProc.Loaded;
begin
  inherited Loaded;
{ if
  UpdateSPSql;}
end;

procedure TUIBStoredProc.ExecProc;
begin
  ExecSQL;
end;

end.
