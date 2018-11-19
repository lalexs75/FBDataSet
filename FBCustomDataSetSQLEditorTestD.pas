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

unit FBCustomDataSetSQLEditorTestD;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Grids, DBGrids, DB, mydbUnit,
  FBCustomDataSet, SynEdit, ComCtrls;

type
  TFBCustomDataSetSQLEditorTestForm = class(TForm)
    Panel1: TPanel;
    Button1: TButton;
    DataSource1: TDataSource;
    FBDataSetTest: TFBDataSet;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    DBGrid1: TDBGrid;
    SynEdit1: TSynEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FBCustomDataSetSQLEditorTestForm: TFBCustomDataSetSQLEditorTestForm;

implementation

{$R *.dfm}

end.
