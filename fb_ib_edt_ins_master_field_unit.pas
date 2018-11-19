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

unit fb_ib_edt_ins_master_field_unit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ButtonPanel;

type

  { TeditorInsertMasterFieldForm }

  TeditorInsertMasterFieldForm = class(TForm)
    ButtonPanel1: TButtonPanel;
    ListBox1: TListBox;
    procedure ListBox1DblClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  editorInsertMasterFieldForm: TeditorInsertMasterFieldForm;

implementation

{$R *.lfm}

{ TeditorInsertMasterFieldForm }

procedure TeditorInsertMasterFieldForm.ListBox1DblClick(Sender: TObject);
begin
  ModalResult:=mrOk;
end;

end.

