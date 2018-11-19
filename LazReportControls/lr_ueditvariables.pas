{ LR_UEditVariables unit

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

unit LR_UEditVariables;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, db, Graphics, Dialogs, StdCtrls,
  Buttons, ButtonPanel, LR_Intrp, lrUIBData;

type

  { TlrEditUVariablesForm }

  TlrEditUVariablesForm = class(TForm)
    BitBtn1: TBitBtn;
    ButtonPanel1: TButtonPanel;
    ComboBox1: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    ListBox1: TListBox;
    Memo1: TMemo;
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
  private
    EditItem:integer;
    FParams:TQueryParamList;
  public
    procedure LoadParamList(AParams: TQueryParamList);
    procedure SaveParamList(AParams: TQueryParamList);
    procedure HideType;
  end;

var
  lrEditUVariablesForm: TlrEditUVariablesForm;

implementation
uses lr_expres, lrUIBDataConst;

{$R *.lfm}

{ TlrEditUVariablesForm }

procedure TlrEditUVariablesForm.ListBox1Click(Sender: TObject);
var
  P:TQueryParam;
begin
  if (ListBox1.Items.Count>0) and (ListBox1.ItemIndex > -1) and (ListBox1.ItemIndex<ListBox1.Items.Count) then
  begin
    if EditItem>-1 then
    begin
      P:=TQueryParam(FParams[EditItem]);
      case ComboBox1.ItemIndex of
        0:P.ParamType:=ftString; //String
        1:P.ParamType:=ftInteger; //Integer
        2:P.ParamType:=ftFloat; //Float
        3:P.ParamType:=ftDateTime; //DateTime
      else
        P.ParamType:=ftUnknown;
      end;
      P.ParamValue:=Memo1.Text;
    end;
    EditItem:=ListBox1.ItemIndex;
    P:=TQueryParam(FParams[EditItem]);
    case P.ParamType of
      ftString:ComboBox1.ItemIndex:=0; //String
      ftInteger:ComboBox1.ItemIndex:=1; //Integer
      ftFloat:ComboBox1.ItemIndex:=2; //Float
      ftDateTime:ComboBox1.ItemIndex:=3; //DateTime
    else
      ComboBox1.ItemIndex:=-1;
    end;
    Memo1.Text:=P.ParamValue;
  end;
end;

procedure TlrEditUVariablesForm.FormCreate(Sender: TObject);
begin
  //
  Caption:=sEditVariables;
  BitBtn1.Caption:=sSelectExpresion;
  Label1.Caption:=sVariablesList;
  Label2.Caption:=sVariableValue;
  Label4.Caption:=sParamType;
  //
  FParams:=TQueryParamList.Create;
  Memo1.Text:='';
end;

procedure TlrEditUVariablesForm.BitBtn1Click(Sender: TObject);
var
  EF:TlrExpresionEditorForm;
begin
  EF:=TlrExpresionEditorForm.Create(Application);
  if EF.ShowModal = mrOk then
    Memo1.Text:=EF.ResultExpresion;
  EF.Free;
end;

procedure TlrEditUVariablesForm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FParams);
end;

procedure TlrEditUVariablesForm.LoadParamList(AParams: TQueryParamList);
var
  i:integer;
  P:TQueryParam;
begin
  FParams.Clear;
  ListBox1.Items.Clear;
  for i:=0 to AParams.Count - 1 do
  begin
    P:=TQueryParam(AParams[i]);
    FParams.Add(P.ParamType, P.ParamName, P.ParamValue);
    ListBox1.Items.Add(P.ParamName);
  end;
  EditItem:=-1;
  if ListBox1.Items.Count > 0 then
  begin
    ListBox1.ItemIndex:=0;
    ListBox1Click(nil);
  end;
end;

procedure TlrEditUVariablesForm.SaveParamList(AParams: TQueryParamList);
var
  i:integer;
  P, P1:TQueryParam;
begin
  ListBox1Click(nil);
  for i:=0 to FParams.Count - 1 do
  begin
    P:=TQueryParam(FParams[i]);
    P1:=TQueryParam(AParams[i]);
    P1.ParamType:=P.ParamType;
    P1.ParamName:=P.ParamName;
    P1.ParamValue:=P.ParamValue;
  end;
end;

procedure TlrEditUVariablesForm.HideType;
begin
  Label4.Visible:=false;
  ComboBox1.Visible:=false;
  Label2.AnchorSide[akTop].Control:=Self;
  Label2.AnchorSide[akTop].Side:=asrTop;
end;

end.


