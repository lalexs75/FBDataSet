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

unit fbcustomdatasetsqleditorl;

{$mode objfpc}{$H+}

interface

uses
  LCLIntf, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Buttons, SynCompletion,
  SynEditHighlighter, SynHighlighterSQL, uib, FBCustomDataSet,
  SynEditMiscClasses, SynEditSearch, LResources, ButtonPanel, SynEdit, types;

type

  { TFBCustomDataSetSQLEditor }

  TFBCustomDataSetSQLEditor = class(TForm)
    ButtonPanel1: TButtonPanel;
    FindDialog1: TFindDialog;
    ImageList1: TImageList;
    Splitter3: TSplitter;
    quGetObjLIst: TUIBQuery;
    ListBoxFields: TListBox;
    ListBoxRelations: TListBox;
    Panel6: TPanel;
    Panel7: TPanel;
    Panel8: TPanel;
    SpeedButton3: TSpeedButton;
    Splitter2: TSplitter;
    StatusBar1: TStatusBar;
    SynSQLSyn1: TSynSQLSyn;
    Panel2: TPanel;
    PageControl1: TPageControl;
    TabSheet2: TTabSheet;
    edtSelectSQL: TSynEdit;
    TabSheet1: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    Panel1: TPanel;
    Splitter1: TSplitter;
    Panel3: TPanel;
    Label1: TLabel;
    Edit1: TEdit;
    btnGenSQL: TButton;
    btnCheckSQL: TButton;
    edtEditSql: TSynEdit;
    edtDeleteSQL: TSynEdit;
    edtRefreshSQL: TSynEdit;
    CheckBox1: TCheckBox;
    btnTest: TButton;
    TabSheet5: TTabSheet;
    edtInsertSQL: TSynEdit;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    Edit2: TEdit;
    Panel4: TPanel;
    Memo1: TMemo;
    Label2: TLabel;
    Panel5: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    FontDialog1: TFontDialog;
    quGetPKFields: TUIBQuery;
    quFieldsList: TUIBQuery;
    procedure btnTestClick(Sender: TObject);
    procedure edtSelectSQLStatusChange(Sender: TObject;
      Changes: TSynStatusChanges);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure ListBoxRelationsClick(Sender: TObject);
    procedure btnGenSQLClick(Sender: TObject);
    procedure ListBoxRelationsDrawItem(Control: TWinControl; Index: Integer;
      ARect: TRect; State: TOwnerDrawState);
    procedure PageControl1Change(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure ListBoxFieldsClick(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
    procedure Edit2KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure btnCheckSQLClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FindDialog1Find(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
  private
    FDS:TFBDataSet;
    SynCompletion:TSynCompletion;
    FConfigFileName:string;
    procedure GenerateUpdateSQLText;
    procedure GenerateWhereSQLText(const FTableName: string);
    procedure LoadTableList;
    procedure FillIdentifier;
    function ActiveEditor:TSynEdit;
    procedure ListBoxRelationsDblClick(Sender: TObject);
    //procedure ccComplete(var Value: ansistring; Shift: TShiftState);
    procedure ccExecute(Sender: TObject);
    procedure DoCfgLoad;
    procedure DoCfgStore;
    procedure DoSetEditorOpt(AFontName:string; AFontSize:integer;
         AColor:TColor; ACharSet:TFontCharSet);
    procedure DoUpdateStatus;
  public
    constructor CreateEditor(ADS:TFBDataSet);
  end;

var
  FBCustomDataSetSQLEditor: TFBCustomDataSetSQLEditor;

implementation
uses fbcustomdatasetsqleditortestl, fb_ib_edt_ins_master_field_unit, dclFBDataSetUtils,
  SynEditTypes, LazIDEIntf, IniFiles, dcl_fb_id_StrConsts, LCLProc;

{$R *.lfm}

procedure ClearStringsObjList(AStings:TStrings);
var
  I:integer;
  P:TObject;
begin
 for i:=0 to AStings.Count-1 do
 begin
   P:=AStings.Objects[i];
   AStings.Objects[i]:=nil;
   if Assigned(P) then
     P.Free;
 end;
end;

{ TFBCustomDataSetSQLEditor }

{$I listboxrelationsdblclick.inc}

constructor TFBCustomDataSetSQLEditor.CreateEditor(ADS: TFBDataSet);
begin
  inherited Create(Application);
  FDS:=ADS;
  if Assigned(FDS) then
  begin
    edtSelectSQL.Lines.Text:=FDS.SQLSelect.Text;
    edtEditSql.Lines.Text:=FDS.SQLEdit.Text;
    edtDeleteSQL.Lines.Text:=FDS.SQLDelete.Text;
    edtRefreshSQL.Lines.Text:=FDS.SQLRefresh.Text;
    edtInsertSQL.Lines.Text:=FDS.SQLInsert.Text;

    quGetObjLIst.DataBase:=FDS.DataBase;
    quGetObjLIst.Transaction:=FDS.Transaction;
    quGetPKFields.DataBase:=FDS.DataBase;
    quGetPKFields.Transaction:=FDS.Transaction;
    quFieldsList.DataBase:=FDS.DataBase;
    quFieldsList.Transaction:=FDS.Transaction;

    LoadTableList;
    FillIdentifier;
    Caption:=dcl_fb_sFBDataSetEditor + ' : '+FDS.Name;
  end
  else
    Caption:=dcl_fb_sFBDataSetEditor;

  PageControl1.ActivePageIndex:=0;
  ListBoxRelations.OnDblClick:=@ListBoxRelationsDblClick;
  btnCheckSQL.Enabled:=Assigned(quGetObjLIst.DataBase);
  
  SynCompletion:=TSynCompletion.Create(Self);
  SynCompletion.AddEditor(edtSelectSQL);
  SynCompletion.AddEditor(edtEditSql);
  SynCompletion.AddEditor(edtDeleteSQL);
  SynCompletion.AddEditor(edtRefreshSQL);
  SynCompletion.AddEditor(edtInsertSQL);
  SynCompletion.OnExecute:=@ccExecute;

  FConfigFileName:='fbdatasetoptions.ini';
  if Assigned(LazarusIDE) then
  begin
    {$IFDEF WINDOWS}
    FConfigFileName:=AnsiToUtf8(LazarusIDE.GetPrimaryConfigPath + DirectorySeparator + FConfigFileName);
    {$ELSE}
    FConfigFileName:=LazarusIDE.GetPrimaryConfigPath + DirectorySeparator + FConfigFileName;
    {$ENDIF}
  end;
{  BitBtn3.Caption:=rsMbOK;
  BitBtn4.Caption:=rsMbOK;}
  Label1.Caption:=dcl_fb_sTableAlias;
  Label2.Caption:=dcl_fb_sDescription;
  CheckBox1.Caption:=dcl_fb_sReplaceSQL;
  CheckBox3.Caption:=dcl_fb_sShowInfo;
  CheckBox2.Caption:=dcl_fb_sFilter;

  btnGenSQL.Caption:=dcl_fb_sGenerate;
  btnCheckSQL.Caption:=dcl_fb_sCheck;
  btnTest.Caption:=dcl_fb_sTest;

  TabSheet2.Caption:=dcl_fb_sSQLSelect;
  TabSheet5.Caption:=dcl_fb_sSQLInsert;
  TabSheet1.Caption:=dcl_fb_sSQLEdit;
  TabSheet3.Caption:=dcl_fb_sSQLDelete;
  TabSheet4.Caption:=dcl_fb_sSQLRefresh;
{
  btnGenSQL.Top:=ButtonPanel1.HelpButton.Top;
  btnCheckSQL.Top:=ButtonPanel1.HelpButton.Top;
  btnTest.Top:=ButtonPanel1.HelpButton.Top;

  btnGenSQL.Height:=ButtonPanel1.HelpButton.Height;
  btnCheckSQL.Height:=ButtonPanel1.HelpButton.Height;
  btnTest.Height:=ButtonPanel1.HelpButton.Height;
}
  btnGenSQL.AnchorSide[akLeft].Control:=ButtonPanel1.HelpButton;
  btnCheckSQL.AnchorSide[akLeft].Control:=btnGenSQL;
  btnTest.AnchorSide[akLeft].Control:=btnCheckSQL;

  btnGenSQL.AnchorSide[akTop].Control:=ButtonPanel1.HelpButton;
  btnCheckSQL.AnchorSide[akTop].Control:=ButtonPanel1.HelpButton;
  btnTest.AnchorSide[akTop].Control:=ButtonPanel1.HelpButton;

  btnGenSQL.AnchorSide[akBottom].Control:=ButtonPanel1.HelpButton;
  btnCheckSQL.AnchorSide[akBottom].Control:=ButtonPanel1.HelpButton;
  btnTest.AnchorSide[akBottom].Control:=ButtonPanel1.HelpButton;
{
  btnGenSQL.Constraints.MinWidth := ButtonPanel1.HelpButton.Constraints.MinWidth;
  btnGenSQL.Constraints.MinHeight := ButtonPanel1.HelpButton.Constraints.MinHeight;

  btnCheckSQL.Constraints.MinWidth := ButtonPanel1.HelpButton.Constraints.MinWidth;
  btnCheckSQL.Constraints.MinHeight := ButtonPanel1.HelpButton.Constraints.MinHeight;

  btnTest.Constraints.MinWidth := ButtonPanel1.HelpButton.Constraints.MinWidth;
  btnTest.Constraints.MinHeight := ButtonPanel1.HelpButton.Constraints.MinHeight;
}
//  ListBoxFields.OnDrawItem:=;
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
  var CloseAction: TCloseAction);
begin
  if (ModalResult=mrOk) and Assigned(FDS) then
  begin
    FDS.SQLSelect.Text:=edtSelectSQL.Lines.Text;
    FDS.SQLEdit.Text:=edtEditSql.Lines.Text;
    FDS.SQLDelete.Text:=edtDeleteSQL.Lines.Text;
    FDS.SQLRefresh.Text:=edtRefreshSQL.Lines.Text;
    FDS.SQLInsert.Text:=edtInsertSQL.Lines.Text;
  end;
  DoCfgStore;
end;

procedure TFBCustomDataSetSQLEditor.FormShow(Sender: TObject);
begin
  DoCfgLoad;
end;

procedure TFBCustomDataSetSQLEditor.ListBoxRelationsClick(Sender: TObject);
var
  ind:integer;
  S:string;
begin
  if (ListBoxRelations.ItemIndex > -1) and Assigned(quGetObjLIst.DataBase)
    and Assigned(quGetObjLIst.Transaction) then
  begin
    quFieldsList.Params.ByNameAsString['relation_name']:=ListBoxRelations.Items[ListBoxRelations.ItemIndex];
    try
      quFieldsList.Open;
      ClearStringsObjList(ListBoxFields.Items);
      ListBoxFields.Items.Clear;
      while not quFieldsList.Fields.Eof do
      begin
        ind:=ListBoxFields.Items.Add(trim(quFieldsList.Fields.AsString[0]));
        quFieldsList.ReadBlob(1, s);
        ListBoxFields.Items.Objects[ind]:=TFieldInfo.Create(s, quFieldsList.Fields.ByNameAsInteger['calc_field_flag']=1);
        quFieldsList.Next;
      end;
    finally
      quFieldsList.Close;
    end;
  end;
end;

function TFBCustomDataSetSQLEditor.ActiveEditor: TSynEdit;
begin
  case PageControl1.ActivePageIndex of
    0:Result:=edtSelectSQL;
    1:Result:=edtInsertSQL;
    2:Result:=edtEditSql;
    3:Result:=edtDeleteSQL;
    4:Result:=edtRefreshSQL;
  end;
end;


procedure TFBCustomDataSetSQLEditor.btnGenSQLClick(Sender: TObject);
begin
  ListBoxRelationsDblClick(nil);
end;

procedure TFBCustomDataSetSQLEditor.ListBoxRelationsDrawItem(
  Control: TWinControl; Index: Integer; ARect: TRect; State: TOwnerDrawState);
var
  Cnv:TCanvas;
  S:string;
  i:integer;
const
  Offset = 20;
begin
  Cnv:=(Control as TListBox).Canvas;
  Cnv.FillRect(ARect);       { clear the rectangle }

  if (Index>=0) and (Index< ListBoxRelations.Items.Count) then
  begin
    I:=PtrInt(ListBoxRelations.Items.Objects[Index]);
    ImageList1.Draw(Cnv, ARect.Left, ARect.Top, i, true);
    S:=ListBoxRelations.Items[Index];

    Cnv.TextOut(ARect.Left + Offset, (ARect.Top + ARect.Bottom  - Cnv.TextHeight('Wg')) div 2, S);  { display the text }
  end;
end;

(*
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
    if Assigned(quGetObjLIst.DataBase) and Assigned(quGetObjLIst.Transaction) then
    begin
      quGetObjLIst.Sql.Clear;
      quGetObjLIst.Sql.Add('select RDB$RELATION_FIELDS.RDB$FIELD_NAME as FIELD_NAME from RDB$RELATION_FIELDS '+
                          'where RDB$RELATION_FIELDS.rdb$relation_name = '''+S+''' order by RDB$RELATION_FIELDS.RDB$FIELD_NAME');
      try
        quGetObjLIst.Execute;
        SynCompletionProposal1.InsertList.Clear;
        SynCompletionProposal1.ItemList.Clear;
        quGetObjLIst.Next;
        while not quGetObjLIst.Eof do
        begin
          SynCompletionProposal1.InsertList.Add(trim(quGetObjLIst.Fields.ByNameAsString['FIELD_NAME']));
          SynCompletionProposal1.ItemList.Add(trim(quGetObjLIst.Fields.ByNameAsString['FIELD_NAME']));
          quGetObjLIst.Next;
        end;
      finally
        quGetObjLIst.Close;
      end;
    end;
  end;
end;
*)

procedure TFBCustomDataSetSQLEditor.ccExecute(Sender: TObject);
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
    if Assigned(quGetObjLIst.DataBase) and Assigned(quGetObjLIst.Transaction) then
    begin
      quGetObjLIst.Sql.Clear;
      quGetObjLIst.Sql.Add('select RDB$RELATION_FIELDS.RDB$FIELD_NAME as FIELD_NAME from RDB$RELATION_FIELDS '+
                          'where RDB$RELATION_FIELDS.rdb$relation_name = '''+S+''' order by RDB$RELATION_FIELDS.RDB$FIELD_NAME');
      try
        quGetObjLIst.Execute;
//        SynCompletionProposal1.InsertList.Clear;
        SynCompletion.ItemList.Clear;
        {$IFDEF FPC}
 //       SynCompletion.OnPaintItem;
        {$ELSE}
        {$ENDIF}
        quGetObjLIst.Next;
        while not quGetObjLIst.Eof do
        begin
//          SynCompletion.InsertList.Add(trim(quGetObjLIst.Fields.ByNameAsString['FIELD_NAME']));
          SynCompletion.ItemList.Add(trim(quGetObjLIst.Fields.ByNameAsString['FIELD_NAME']));
          quGetObjLIst.Next;
        end;
      finally
        quGetObjLIst.Close;
      end;
    end;
  end;
end;

procedure TFBCustomDataSetSQLEditor.DoCfgLoad;
var
  Ini:TIniFile;

  AFontName:string;
  AFontSize:integer;
  AColor:TColor;
  ACharSet:TFontCharSet;
begin
  Ini:=TIniFile.Create(FConfigFileName);
  Ini.StripQuotes:=false;
  Left:=Ini.ReadInteger('Position', 'Left', Left);
  Top:=Ini.ReadInteger('Position', 'Top', Top);
  Width:=Ini.ReadInteger('Position', 'Width', Width);
  Height:=Ini.ReadInteger('Position', 'Height', Height);

  AFontName:=Ini.ReadString('Font', 'Name', ActiveEditor.Font.Name);
  AFontSize:=Ini.ReadInteger('Font', 'Size', ActiveEditor.Font.Size);
  AColor:=Ini.ReadInteger('Font', 'Color', ActiveEditor.Font.Color);
  ACharSet:=Ini.ReadInteger('Font', 'CharSet', ActiveEditor.Font.CharSet);

  Ini.Free;

  DoSetEditorOpt(AFontName, AFontSize, AColor, ACharSet);
end;

procedure TFBCustomDataSetSQLEditor.DoCfgStore;
var
  Ini:TIniFile;
begin
  Ini:=TIniFile.Create(FConfigFileName);
  Ini.StripQuotes:=false;
  Ini.WriteInteger('Position', 'Left', Left);
  Ini.WriteInteger('Position', 'Top', Top);
  Ini.WriteInteger('Position', 'Width', Width);
  Ini.WriteInteger('Position', 'Height', Height);

  Ini.WriteString('Font', 'Name', ActiveEditor.Font.Name);
  Ini.WriteInteger('Font', 'Size', ActiveEditor.Font.Size);
  Ini.WriteInteger('Font', 'Color', ActiveEditor.Font.Color);
  Ini.WriteInteger('Font', 'CharSet', ActiveEditor.Font.CharSet);

  Ini.Free;
end;

procedure TFBCustomDataSetSQLEditor.DoSetEditorOpt(AFontName: string;
  AFontSize: integer; AColor:TColor;
  ACharSet:TFontCharSet);
  
procedure DoSetOpt(AEdt:TSynEdit);
begin
  AEdt.Font.Name:=AFontName;
  AEdt.Font.Size:=AFontSize;
  AEdt.Font.Color:=AColor;
  AEdt.Font.CharSet:=ACharSet;
end;

begin
  DoSetOpt(edtSelectSQL);
  DoSetOpt(edtInsertSQL);
  DoSetOpt(edtEditSql);
  DoSetOpt(edtDeleteSQL);
  DoSetOpt(edtRefreshSQL);
end;

procedure TFBCustomDataSetSQLEditor.DoUpdateStatus;
begin
  StatusBar1.Panels[0].Text:=Format('%d : %d', [ActiveEditor.CaretX, ActiveEditor.CaretY]);

  if ActiveEditor.Modified then
    StatusBar1.Panels[1].Text:=dcl_fb_sModified
  else
    StatusBar1.Panels[1].Text:='';
end;


procedure TFBCustomDataSetSQLEditor.PageControl1Change(Sender: TObject);
begin
  if Visible then
    ActiveEditor.SetFocus;
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
var
  i:integer;
begin
  ListBoxRelations.Items.Clear;
  if Assigned(quGetObjLIst.DataBase) and Assigned(quGetObjLIst.Transaction) then
  begin
    {quGetObjLIst.Sql.Clear;
    quGetObjLIst.Sql.Add('select rdb$relations.rdb$relation_name as relation_name from rdb$relations where RDB$SYSTEM_FLAG=0 order by RDB$RELATION_NAME');}
    try
      quGetObjLIst.Execute;
      ListBoxRelations.Items.Clear;
      quGetObjLIst.Next;
      while not quGetObjLIst.Eof do
      begin
        if (CheckBox2.Checked) and (Edit2.Text<>'') then
        begin
          if Pos(UpperCase(Edit2.Text), quGetObjLIst.Fields.ByNameAsString['relation_name'])<>0 then
          begin
            I:=ListBoxRelations.Items.Add(trim(quGetObjLIst.Fields.ByNameAsString['relation_name']));
            ListBoxRelations.Items.Objects[i]:=TObject(Pointer(quGetObjLIst.Fields.ByNameAsInteger['obj_flag']));
          end;
        end
        else
        begin
          I:=ListBoxRelations.Items.Add(trim(quGetObjLIst.Fields.ByNameAsString['relation_name']));
          ListBoxRelations.Items.Objects[i]:=TObject(Pointer(quGetObjLIst.Fields.ByNameAsInteger['obj_flag']));
        end;
        quGetObjLIst.Next;
      end;
    finally
      quGetObjLIst.Close;
    end;
  end;
end;

procedure TFBCustomDataSetSQLEditor.GenerateUpdateSQLText;
var
  b: boolean;
  FTableName:string;
  FieldsStr: string;
  i, cnt:integer;
  P:TFieldInfo;
begin
  FTableName:=ListBoxRelations.Items[ListBoxRelations.ItemIndex];

  ActiveEditor.Lines.clear;
  ActiveEditor.Lines.Add('update');
  ActiveEditor.Lines.Add('  '+ DoQuoteName(FTableName));
  ActiveEditor.Lines.Add('set ');
  Cnt := 0;
  for i := 1 to ListBoxFields.Items.Count - 1 do
  begin
    P:=ListBoxFields.Items.Objects[i] as TFieldInfo;
    if (ListBoxFields.Selected[i]) and (not P.CalcField) then
    begin
      FieldsStr :='  ' + {FTableName +'.' + }DoQuoteName(ListBoxFields.Items[i]) + ' = :' + DoQuoteName(ListBoxFields.Items[i]);
      if Cnt>0 then
        ActiveEditor.Lines[ActiveEditor.Lines.Count-1]:=ActiveEditor.Lines[ActiveEditor.Lines.Count-1] +',';
      ActiveEditor.Lines.Add(FieldsStr);
      inc(cnt);
    end;
  end;

  if Cnt = 0 then
    for i := 1 to ListBoxFields.Items.Count - 1 do
    begin
      P:=ListBoxFields.Items.Objects[i] as TFieldInfo;
      if not P.CalcField then
      begin
        FieldsStr :='  ' + DoQuoteName(FTableName) + '.' + DoQuoteName(ListBoxFields.Items[i]) + ' = :' + DoQuoteName(ListBoxFields.Items[i]);
        if Cnt>0 then
          ActiveEditor.Lines[ActiveEditor.Lines.Count-1]:=ActiveEditor.Lines[ActiveEditor.Lines.Count-1] +',';
        ActiveEditor.Lines.Add(FieldsStr);
        inc(cnt);
      end;
    end;

  GenerateWhereSQLText(FTableName);
end;

procedure TFBCustomDataSetSQLEditor.GenerateWhereSQLText(const FTableName: string);
var
  C: integer;
  SPrefix, FieldsStr: string;
begin
  if Assigned(quGetPKFields.DataBase) and Assigned(quGetPKFields.Transaction)
    then
  begin
    ActiveEditor.Lines.Add('where ');
    quGetPKFields.Params.ByNameAsString['relation_name']:=FTableName;
    quGetPKFields.Open(True);
    quGetPKFields.FetchAll;
    C:=quGetPKFields.Fields.RecordCount;
    if C>1 then
      SPrefix:='    '
    else
      SPrefix:='  ';

    quGetPKFields.First;
    while not quGetPKFields.Fields.Eof do
    begin
      FieldsStr:=Trim(quGetPKFields.Fields.ByNameAsString['rdb$field_name']);
      if quGetPKFields.Fields.CurrentRecord > 0 then
        ActiveEditor.Lines.Add('  and');

      ActiveEditor.Lines.Add(SPrefix + DoQuoteName(FTableName) +'.'+ DoQuoteName(FieldsStr) + ' = :'+DoQuoteName(FieldsStr));
      quGetPKFields.Fields.Next;
    end;
    quGetPKFields.Close;
  end
end;


procedure TFBCustomDataSetSQLEditor.Edit2KeyUp(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  LoadTableList;
end;

procedure TFBCustomDataSetSQLEditor.btnCheckSQLClick(Sender: TObject);
begin
  quGetObjLIst.SQL.Text:=ActiveEditor.Lines.Text;
  try
    quGetObjLIst.Prepare;
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
{  SynEditSearch1.Pattern:=FindDialog1.FindText;
  SynEditSearch1.FindFirst('');}
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
 begin
   edtSelectSQL.Font:=FontDialog1.Font;
   edtInsertSQL.Font:=FontDialog1.Font;
   edtEditSql.Font:=FontDialog1.Font;
   edtDeleteSQL.Font:=FontDialog1.Font;
   edtRefreshSQL.Font:=FontDialog1.Font;
 end;
end;

procedure TFBCustomDataSetSQLEditor.SpeedButton3Click(Sender: TObject);
var
  i:integer;
begin
  if Assigned(FDS.DataSource) and Assigned(FDS.DataSource.DataSet) and (FDS.DataSource.DataSet.FieldCount>0) then
  begin
    editorInsertMasterFieldForm:=TeditorInsertMasterFieldForm.Create(Application);
    try
      editorInsertMasterFieldForm.ListBox1.Items.Clear;
      for i:=0 to FDS.DataSource.DataSet.FieldCount-1 do
        editorInsertMasterFieldForm.ListBox1.Items.Add(FDS.DataSource.DataSet.Fields[i].FieldName);
      if editorInsertMasterFieldForm.ListBox1.Items.Count>0 then
        editorInsertMasterFieldForm.ListBox1.ItemIndex:=0;
        
      if (editorInsertMasterFieldForm.ShowModal = mrOk) then
      begin
        if editorInsertMasterFieldForm.ListBox1.ItemIndex>=0 then
          ActiveEditor.SelText:=editorInsertMasterFieldForm.ListBox1.Items[editorInsertMasterFieldForm.ListBox1.ItemIndex];
      end;
    finally
      editorInsertMasterFieldForm.Free;
    end;
  end;
end;

procedure TFBCustomDataSetSQLEditor.edtSelectSQLStatusChange(Sender: TObject;
  Changes: TSynStatusChanges);
begin
  DoUpdateStatus;
end;

end.
