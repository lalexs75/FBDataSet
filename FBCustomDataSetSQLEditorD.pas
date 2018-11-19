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

{$H+}
unit FBCustomDataSetSQLEditorD;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, FBCustomDataSet, StdCtrls, ExtCtrls, SynEdit, ComCtrls, Buttons,
  SynCompletionProposal, SynEditHighlighter, SynHighlighterSQL, uib,
  SynEditMiscClasses, SynEditSearch;

type
  TFBCustomDataSetSQLEditor = class(TForm)
    UIBQuery1: TUIBQuery;
    SynSQLSyn1: TSynSQLSyn;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    Panel2: TPanel;
    Panel1: TPanel;
    Splitter2: TSplitter;
    ListBoxRelations: TListBox;
    ListBoxFields: TListBox;
    Splitter1: TSplitter;
    Panel3: TPanel;
    Label1: TLabel;
    Edit1: TEdit;
    Button1: TButton;
    Button2: TButton;
    CheckBox1: TCheckBox;
    SynCompletionProposal1: TSynCompletionProposal;
    btnTest: TButton;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    Edit2: TEdit;
    Panel4: TPanel;
    Memo1: TMemo;
    Label2: TLabel;
    SynEditSearch1: TSynEditSearch;
    FindDialog1: TFindDialog;
    FontDialog1: TFontDialog;
    Panel6: TPanel;
    PageControl1: TPageControl;
    TabSheet2: TTabSheet;
    edtSelect: TSynEdit;
    Panel5: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    TabSheet5: TTabSheet;
    edtInsertSQL: TSynEdit;
    TabSheet1: TTabSheet;
    edtEditSql: TSynEdit;
    TabSheet3: TTabSheet;
    edtDeleteSQL: TSynEdit;
    TabSheet4: TTabSheet;
    edtRefreshSQL: TSynEdit;
    StatusBar1: TStatusBar;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ListBoxRelationsClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure SynCompletionProposal1Execute(Kind: SynCompletionType;
      Sender: TObject; var CurrentInput: String; var x, y: Integer;
      var CanExecute: Boolean);
    procedure PageControl1Change(Sender: TObject);
    procedure btnTestClick(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure ListBoxFieldsClick(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
    procedure Edit2KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Button2Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FindDialog1Find(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure edtSelectStatusChange(Sender: TObject;
      Changes: TSynStatusChanges);
  private
    FDS:TFBDataSet;
    procedure LoadTableList;
    procedure FillIdentifier;
    function ActiveEditor:TSynEdit;
    procedure ListBoxRelationsDblClick(Sender: TObject);
    procedure DoUpdateStatus;
  public
    constructor CreateEditor(ADS:TFBDataSet);
  end;

var
  FBCustomDataSetSQLEditor: TFBCustomDataSetSQLEditor;

implementation
uses uibconst, FBCustomDataSetSQLEditorTestD, SynEditTypes;

{$R *.dfm}

{ TFBCustomDataSetSQLEditor }

{$I listboxrelationsdblclick.inc}

constructor TFBCustomDataSetSQLEditor.CreateEditor(ADS: TFBDataSet);
begin
  inherited Create(Application);
  FDS:=ADS;
  if Assigned(FDS) then
  begin
    edtSelect.Lines.Text:=FDS.SQLSelect.Text;
    edtEditSql.Lines.Text:=FDS.SQLEdit.Text;
    edtDeleteSQL.Lines.Text:=FDS.SQLDelete.Text;
    edtRefreshSQL.Lines.Text:=FDS.SQLRefresh.Text;
    edtInsertSQL.Lines.Text:=FDS.SQLInsert.Text;
    UIBQuery1.DataBase:=FDS.DataBase;
    UIBQuery1.Transaction:=FDS.Transaction;
    LoadTableList;
    FillIdentifier;
  end;
  PageControl1.ActivePageIndex:=0;
  ListBoxRelations.OnDblClick:=ListBoxRelationsDblClick;
  Button2.Enabled:=Assigned(UIBQuery1.DataBase);
end;

procedure TFBCustomDataSetSQLEditor.FillIdentifier;
var
  i:integer;
begin
  SynSQLSyn1.TableNames.Clear;
  for i:=0 to ListBoxRelations.Items.Count-1 do
  begin
    SynSQLSyn1.TableNames.Add(ListBoxRelations.Items[i]);
  end;
end;

procedure TFBCustomDataSetSQLEditor.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if (ModalResult=mrOk) and Assigned(FDS) then
  begin
    FDS.SQLSelect.Text:=edtSelect.Lines.Text;
    FDS.SQLEdit.Text:=edtEditSql.Lines.Text;
    FDS.SQLDelete.Text:=edtDeleteSQL.Lines.Text;
    FDS.SQLRefresh.Text:=edtRefreshSQL.Lines.Text;
    FDS.SQLInsert.Text:=edtInsertSQL.Lines.Text;
  end;
end;

procedure TFBCustomDataSetSQLEditor.ListBoxRelationsClick(Sender: TObject);
var
  ind:integer;
  S:string;
begin
  if Assigned(UIBQuery1.DataBase) and Assigned(UIBQuery1.Transaction) then
  begin
    UIBQuery1.Sql.Clear;
    UIBQuery1.Sql.Add(Format(sqlSelectFields, [ListBoxRelations.Items[ListBoxRelations.ItemIndex]]));
    try
      UIBQuery1.Execute;
      ListBoxFields.Items.Clear;
      UIBQuery1.Next;
      while not UIBQuery1.Eof do
      begin
        ind:=ListBoxFields.Items.Add(trim(UIBQuery1.Fields.AsString[0]));
        UIBQuery1.ReadBlob(1, s);
        ListBoxFields.Items.Objects[ind]:=TFieldInfo.Create(s);
        UIBQuery1.Next;
      end;
    finally
      UIBQuery1.Close;
    end;
  end;
end;

function TFBCustomDataSetSQLEditor.ActiveEditor: TSynEdit;
begin
  case PageControl1.ActivePageIndex of
    0:Result:=edtSelect;
    1:Result:=edtInsertSQL;
    2:Result:=edtEditSql;
    3:Result:=edtDeleteSQL;
    4:Result:=edtRefreshSQL;
  end;
end;


procedure TFBCustomDataSetSQLEditor.Button1Click(Sender: TObject);
begin
  ListBoxRelationsDblClick(nil);
end;

procedure TFBCustomDataSetSQLEditor.SynCompletionProposal1Execute(
  Kind: SynCompletionType; Sender: TObject; var CurrentInput: String;
  var x, y: Integer; var CanExecute: Boolean);

function GetCurWord:string;
var
  S:string;
  i,j:integer;
begin
  Result:='';
  with ActiveEditor do
  begin
    S:=Trim(Copy(LineText, 1, CaretX));
    I:=Length(S);
    while (i>0) and (S[i]<>'.') do Dec(I);
    if (I>0) then
    begin
      J:=i-1;
      //Get table name
      while (j>0) and (S[j] in ['A'..'z','"']) do Dec(j);
      Result:=trim(Copy(S, j+1, i-j-1));
    end;
  end;
end;
var
  S:string;
begin
  S:=AnsiUpperCase(GetCurWord);
  if S<>'' then
  begin
    if Assigned(UIBQuery1.DataBase) and Assigned(UIBQuery1.Transaction) then
    begin
      UIBQuery1.Sql.Clear;
      UIBQuery1.Sql.Add('select RDB$RELATION_FIELDS.RDB$FIELD_NAME as FIELD_NAME from RDB$RELATION_FIELDS '+
                          'where RDB$RELATION_FIELDS.rdb$relation_name = '''+S+''' order by RDB$RELATION_FIELDS.RDB$FIELD_NAME');
      try
        UIBQuery1.Execute;
        SynCompletionProposal1.InsertList.Clear;
        SynCompletionProposal1.ItemList.Clear;
        UIBQuery1.Next;
        while not UIBQuery1.Eof do
        begin
          SynCompletionProposal1.InsertList.Add(trim(UIBQuery1.Fields.ByNameAsString['FIELD_NAME']));
          SynCompletionProposal1.ItemList.Add(trim(UIBQuery1.Fields.ByNameAsString['FIELD_NAME']));
          UIBQuery1.Next;
        end;
      finally
        UIBQuery1.Close;
      end;
    end;
  end;
end;

procedure TFBCustomDataSetSQLEditor.PageControl1Change(Sender: TObject);
begin
  SynCompletionProposal1.Editor:=ActiveEditor;
  DoUpdateStatus;
end;

procedure TFBCustomDataSetSQLEditor.CheckBox2Click(Sender: TObject);
begin
  Edit2.Enabled:=CheckBox2.Checked;
  LoadTableList;
end;

procedure TFBCustomDataSetSQLEditor.ListBoxFieldsClick(Sender: TObject);
begin
  Memo1.Lines.Clear;
  if (ListBoxFields.ItemIndex>-1) and (ListBoxFields.ItemIndex<ListBoxFields.Items.Count) then
    if Assigned(ListBoxFields.Items.Objects[ListBoxFields.ItemIndex]) then
      Memo1.Text:=TFieldInfo(ListBoxFields.Items.Objects[ListBoxFields.ItemIndex]).Description;
end;

procedure TFBCustomDataSetSQLEditor.CheckBox3Click(Sender: TObject);
begin
  Panel4.Visible:=CheckBox3.Checked;
end;

procedure TFBCustomDataSetSQLEditor.LoadTableList;
begin
  ListBoxRelations.Items.Clear;
  if Assigned(UIBQuery1.DataBase) and Assigned(UIBQuery1.Transaction) then
  begin
    UIBQuery1.Sql.Clear;
    UIBQuery1.Sql.Add('select rdb$relations.rdb$relation_name as relation_name from rdb$relations where RDB$SYSTEM_FLAG=0 order by RDB$RELATION_NAME');
    try
      UIBQuery1.Execute;
      ListBoxRelations.Items.Clear;
      UIBQuery1.Next;
      while not UIBQuery1.Eof do
      begin
        if (CheckBox2.Checked) and (Edit2.Text<>'') then
        begin
          if Pos(UpperCase(Edit2.Text), UIBQuery1.Fields.ByNameAsString['relation_name'])<>0 then
            ListBoxRelations.Items.Add(trim(UIBQuery1.Fields.ByNameAsString['relation_name']));
        end
        else
          ListBoxRelations.Items.Add(trim(UIBQuery1.Fields.ByNameAsString['relation_name']));
        UIBQuery1.Next;
      end;
    finally
      UIBQuery1.Close;
    end;
  end;
end;


procedure TFBCustomDataSetSQLEditor.Edit2KeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  LoadTableList;
end;

procedure TFBCustomDataSetSQLEditor.Button2Click(Sender: TObject);
begin
  UIBQuery1.SQL.Text:=ActiveEditor.Lines.Text;
  try
    UIBQuery1.Prepare;
    ShowMessage('Check OK!');
  except
    on E:Exception do
      ShowMessage(E.Message);
  end;
end;

procedure TFBCustomDataSetSQLEditor.SpeedButton1Click(Sender: TObject);
var
  SynSearchOptions:TSynSearchOptions;
begin
  if FindDialog1.Execute then
  begin
    ActiveEditor.SetFocus;
    SynSearchOptions:=[ssoEntireScope];
    
    if not (frDown in FindDialog1.Options) then
      Include(SynSearchOptions, ssoBackwards);

    if (frWholeWord in FindDialog1.Options) then
      Include(SynSearchOptions, ssoWholeWord);

    if (frMatchCase in FindDialog1.Options) then
      Include(SynSearchOptions, ssoMatchCase);

    ActiveEditor.SearchReplace(FindDialog1.FindText, '', SynSearchOptions);
  end;
end;

procedure TFBCustomDataSetSQLEditor.FindDialog1Find(Sender: TObject);
begin
  SynEditSearch1.Pattern:=FindDialog1.FindText;
  SynEditSearch1.FindFirst('');
end;

procedure TFBCustomDataSetSQLEditor.SpeedButton2Click(Sender: TObject);
begin
 with FontDialog1.Font do
 begin
   Name :=ActiveEditor.Font.Name;
   Size :=ActiveEditor.Font.Size;
   Color:=ActiveEditor.Font.Color;
   Style:=ActiveEditor.Font.Style;
   CharSet:=ActiveEditor.Font.CharSet;
 end;
 if FontDialog1.Execute then
   ActiveEditor.Font:=FontDialog1.Font
end;

procedure TFBCustomDataSetSQLEditor.edtSelectStatusChange(Sender: TObject;
  Changes: TSynStatusChanges);
begin
  DoUpdateStatus;
end;

procedure TFBCustomDataSetSQLEditor.DoUpdateStatus;
begin
  StatusBar1.Panels[0].Text:=Format('%d : %d', [ActiveEditor.CaretX, ActiveEditor.CaretY]);

  if ActiveEditor.Modified then
    StatusBar1.Panels[1].Text:='Modified'
  else
    StatusBar1.Panels[1].Text:='';
end;

end.
