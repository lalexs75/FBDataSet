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

unit FBCustomDataSetSQLEditorTestL;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  DBGrids, Buttons, FBCustomDataSet, DB, ComCtrls, SynEdit, StdCtrls;

type

  { TFBCustomDataSetSQLEditorTestForm }

  TFBCustomDataSetSQLEditorTestForm = class(TForm)
    Button1: TButton;
    Datasource1: TDatasource;
    dbGrid1: TdbGrid;
    FBDataSetTest: TFBDataSet;
    PageControl1: TPageControl;
    Panel1: TPanel;
    SynEdit1: TSynEdit;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  FBCustomDataSetSQLEditorTestForm: TFBCustomDataSetSQLEditorTestForm;

implementation
uses dcl_fb_id_StrConsts, LCLStrConsts;

{$R *.lfm}

{ TFBCustomDataSetSQLEditorTestForm }

procedure TFBCustomDataSetSQLEditorTestForm.FormCreate(Sender: TObject);
begin
  TabSheet1.Caption:=dcl_fb_sResult;
  TabSheet2.Caption:=dcl_fb_sPlan;
  Caption:=dcl_fb_sSQLTest;
  Button1.Caption:=rsMbClose;
end;

end.

