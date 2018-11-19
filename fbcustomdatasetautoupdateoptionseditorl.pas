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

{$mode objfpc}{$H+}
unit fbcustomdatasetautoupdateoptionseditorl;

interface

uses
  LCLIntf,
  LResources, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, uib, FBCustomDataSet, ExtCtrls, DB, Buttons, ButtonPanel,
  Spin;

type

  { TFBCustomDataSetAutoUpdateOptionsEditorForm }

  TFBCustomDataSetAutoUpdateOptionsEditorForm = class(TForm)
    ButtonPanel1: TButtonPanel;
    Label1: TLabel;
    ComboBox1: TComboBox;
    Label2: TLabel;
    Label3: TLabel;
    ComboBox2: TComboBox;
    UIBQuery1: TUIBQuery;
    RadioGroup1: TRadioGroup;
    SpinEdit1: TSpinEdit;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    function ShowEditor(DS: TFBDataSet):boolean;
  end;

var
  FBCustomDataSetAutoUpdateOptionsEditorForm: TFBCustomDataSetAutoUpdateOptionsEditorForm;

implementation
uses FBMisc;

{$R *.lfm}

procedure TFBCustomDataSetAutoUpdateOptionsEditorForm.FormCreate(
  Sender: TObject);
begin
  Caption:=sAutoUpdateOptions;

  Label1.Caption:=slcUpdatedField;
  Label2.Caption:=slcGeneratorName;
  Label3.Caption:=slcIncrementBy;

  RadioGroup1.Caption:=sUpdateAction;
  RadioGroup1.Items[0]:=sNever;
  RadioGroup1.Items[1]:=sOnNewRecord;
  RadioGroup1.Items[2]:=sBeforePost;
end;

function TFBCustomDataSetAutoUpdateOptionsEditorForm.ShowEditor(
  DS: TFBDataSet):boolean;
var
  i:integer;
  OldDataBaseConnected:boolean;
begin
  Result:=false;
  UIBQuery1.DataBase:=DS.DataBase;
  UIBQuery1.Transaction:=DS.Transaction;
  if not Assigned(UIBQuery1.DataBase) then FBError(fbeDatabaseNotAssigned, [DS.Name]);
  if not Assigned(UIBQuery1.Transaction) then FBError(fbeTransactionNotAssigned, [DS.Name]);
  OldDataBaseConnected:=UIBQuery1.DataBase.Connected;

  //Fill generator list
  UIBQuery1.Execute;
  ComboBox2.Items.Clear;
  try
    while not UIBQuery1.Eof do
    begin
      ComboBox2.Items.Add(Trim(UIBQuery1.Fields.AsString[0]));
      UIBQuery1.Next
    end;
  finally
    UIBQuery1.Close;
    UIBQuery1.DataBase.Connected:=OldDataBaseConnected;
  end;
  if ComboBox2.Items.IndexOf(DS.AutoUpdateOptions.GeneratorName)<>-1 then
    ComboBox2.ItemIndex:=ComboBox2.Items.IndexOf(DS.AutoUpdateOptions.GeneratorName);

  //Fill field list
  ComboBox1.Items.Clear;
  DS.FieldDefs.Update;
  for i:=0 to DS.FieldDefs.Count-1 do
    if DS.FieldDefs[i].DataType in [ftSmallint, ftInteger, ftWord, ftFloat,
      ftCurrency, ftBCD, ftAutoInc, ftLargeint] then
      ComboBox1.Items.Add(DS.FieldDefs[i].Name);
  ComboBox1.Text:=DS.AutoUpdateOptions.KeyField;
  SpinEdit1.Value:=DS.AutoUpdateOptions.IncrementBy;
  RadioGroup1.ItemIndex:=ord(DS.AutoUpdateOptions.WhenGetGenID);

  if ShowModal = mrOK then
  begin
    DS.AutoUpdateOptions.IncrementBy:=SpinEdit1.Value;
    DS.AutoUpdateOptions.WhenGetGenID:=TWhenGetGenID(RadioGroup1.ItemIndex);
    DS.AutoUpdateOptions.KeyField:=ComboBox1.Text;
    DS.AutoUpdateOptions.GeneratorName:=ComboBox2.Items[ComboBox2.ItemIndex];
    Result:=true;
  end;
end;

end.
