unit MainUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, ComCtrls,
  Menus, ActnList, uib, FBCustomDataSet, DBGrids, DB, ExtCtrls, DBCtrls, LCLType,
  StdCtrls;

type

  { TMainForm }

  { TMainForm }

  { TMainForm }

  { TMainForm }

  { TMainForm }

  { TMainForm }

  { TMainForm }

  { TMainForm }

  { TMainForm }

  { TMainForm }

  { TMainForm }

  { TMainForm }

  { TMainForm }

  { TMainForm }

  { TMainForm }

  { TMainForm }

  { TMainForm }

  { TMainForm }

  { TMainForm }

  { TMainForm }

  { TMainForm }

  { TMainForm }

  { TMainForm }

  { TMainForm }

  { TMainForm }

  { TMainForm }

  { TMainForm }

  { TMainForm }

  { TMainForm }

  { TMainForm }

  { TMainForm }

  TMainForm = class(TForm)
    actCustNew: TAction;
    actCustEdit: TAction;
    actCustDelete: TAction;
    actCustFilter: TAction;
    dsDepatment: TDatasource;
    dsEmpl: TDatasource;
    DBGrid3: TDBGrid;
    DBGrid4: TDBGrid;
    quDepatment: TFBDataSet;
    quDepatmentBUDGET: TFloatField;
    quDepatmentDEPARTMENT: TFBAnsiField;
    quDepatmentDEPT_NO: TStringField;
    quDepatmentHEAD_DEPT: TStringField;
    quDepatmentLOCATION: TFBAnsiField;
    quDepatmentMNGR_NO: TSmallintField;
    quDepatmentPHONE_NO: TFBAnsiField;
    quEmpl: TFBDataSet;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    Panel2: TPanel;
    Panel3: TPanel;
    quEmplDEPT_NO: TStringField;
    quEmplEMP_NO: TSmallintField;
    quEmplFIRST_NAME: TFBAnsiField;
    quEmplFULL_NAME: TFBAnsiField;
    quEmplHIRE_DATE: TDateTimeField;
    quEmplJOB_CODE: TFBAnsiField;
    quEmplJOB_COUNTRY: TFBAnsiField;
    quEmplJOB_GRADE: TSmallintField;
    quEmplLAST_NAME: TFBAnsiField;
    quEmplPHONE_EXT: TStringField;
    quEmplSALARY: TFloatField;
    Splitter1: TSplitter;
    sysTools: TAction;
    ImageList1: TImageList;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    quSprCountryCOUNTRY: TFBAnsiField;
    quSprCountryCURRENCY: TFBAnsiField;
    quSprCustomerADDRESS_LINE1: TFBAnsiField;
    quSprCustomerADDRESS_LINE2: TFBAnsiField;
    quSprCustomerCITY: TFBAnsiField;
    quSprCustomerCONTACT_FIRST: TFBAnsiField;
    quSprCustomerCONTACT_LAST: TFBAnsiField;
    quSprCustomerCOUNTRY: TFBAnsiField;
    quSprCustomerCUSTOMER: TFBAnsiField;
    quSprCustomerCUST_NO: TLongintField;
    quSprCustomerON_HOLD: TStringField;
    quSprCustomerPHONE_NO: TFBAnsiField;
    quSprCustomerPOSTAL_CODE: TFBAnsiField;
    quSprCustomerSTATE_PROVINCE: TFBAnsiField;
    sysExit: TAction;
    hlpAbout: TAction;
    ActionList1: TActionList;
    ApplicationProperties1: TApplicationProperties;
    DBEdit1: TDBEdit;
    DBEdit2: TDBEdit;
    dbGrid2: TdbGrid;
    dsSprCustomer: TDatasource;
    dsSprCountry: TDatasource;
    dbGrid1: TdbGrid;
    MenuItem1: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    Panel1: TPanel;
    PopupMenu1: TPopupMenu;
    quSprCustomer: TFBDataSet;
    quSprCountry: TFBDataSet;
    tabDepat: TTabSheet;
    ToolBar1: TToolBar;
    ToolBar2: TToolBar;
    ToolBar3: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    UIBDataBase1: TUIBDataBase;
    tabCustomer: TTabSheet;
    trRead: TUIBTransaction;
    trWrite: TUIBTransaction;
    MainMenu1: TMainMenu;
    PageControl2: TPageControl;
    StatusBar1: TStatusBar;
    tabSprCountry: TTabSheet;
    UIBSecurity1: TUIBSecurity;
    procedure ApplicationProperties1Hint(Sender: TObject);
    procedure hlpAboutExecute(Sender: TObject);
    procedure MainFormCreate(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure PageControl2Change(Sender: TObject);
    procedure actCustEditExecute(Sender: TObject);
    procedure actCustDeleteExecute(Sender: TObject);
    procedure actCustFilterExecute(Sender: TObject);
    procedure dbGrid1TitleClick(Column: TColumn);
    procedure dbGrid2TitleClick(Column: TColumn);
    procedure quSprCountryAfterClose(DataSet: TDataSet);
    procedure quSprCustomerAfterClose(DataSet: TDataSet);
    procedure sysExitExecute(Sender: TObject);
    procedure sysToolsExecute(Sender: TObject);
    procedure UIBDataBase1BeforeConnect(Sender: TObject);
  private
    { sort engine }
    //Country
    FSFSprCountry:string;
    FSFSprCountryOrder:boolean;
    //Customers
    FSFSprCustomer:string;
    FSFSprCustomerOrder:boolean;
  public
    { public declarations }
  end; 

var
  MainForm: TMainForm;

implementation
uses sprCustomerEditUnit, sprCustomerFilterUnit, hlpAboutUnit,
  lngResourcesUnit, ConfigFormUnit, ConfigUnit;

{$R *.lfm}

{ TMainForm }

procedure TMainForm.PageControl2Change(Sender: TObject);
begin
  quSprCountry.Active:=(PageControl2.ActivePage = tabSprCountry);
  quSprCustomer.Active:=(PageControl2.ActivePage = tabCustomer);
  quDepatment.Active:=(PageControl2.ActivePage = tabDepat);
end;

procedure TMainForm.actCustEditExecute(Sender: TObject);
begin
  sprCustomerEditForm:=TsprCustomerEditForm.Create(Application);
  if (Sender as TComponent).Tag=1 then  quSprCustomer.Append
  else quSprCustomer.Edit;
  sprCustomerEditForm.CheckBox1.Checked:=quSprCustomerON_HOLD.AsString = '*';
  sprCustomerEditForm.DBComboBox1.Text:=quSprCustomerCOUNTRY.AsString;
  if sprCustomerEditForm.ShowModal=mrOk then
  begin
    quSprCustomerCOUNTRY.AsString:=sprCustomerEditForm.DBComboBox1.Text;
    if sprCustomerEditForm.CheckBox1.Checked then
      quSprCustomerON_HOLD.AsString := '*'
    else
      quSprCustomerON_HOLD.Clear;
    quSprCustomer.Post
  end
  else
    quSprCustomer.Cancel;
  sprCustomerEditForm.Free;
end;

procedure TMainForm.actCustDeleteExecute(Sender: TObject);
begin
  if Application.MessageBox(PChar(sQDeleteRecord), 'Warning',MB_ICONQUESTION + MB_YESNO)=id_Yes then
    quSprCustomer.Delete;
end;

procedure TMainForm.actCustFilterExecute(Sender: TObject);
var
  SMacro:string;

procedure AddMacro(S:string);
begin
  if SMacro<>'' then SMacro:=SMacro + ' and ';
  SMacro:=SMacro+'('+S+')';
end;

begin
  sprCustomerFilterForm:=TsprCustomerFilterForm.Create(Application);
  try
    if sprCustomerFilterForm.ShowModal=mrOk then
    begin
      quSprCustomer.Close;
      SMacro:='';
      if sprCustomerFilterForm.Edit1.Text<>'' then
        AddMacro('CUSTOMER.CUSTOMER like ''%'+sprCustomerFilterForm.Edit1.Text+'%''');
      if sprCustomerFilterForm.Edit2.Text<>'' then
        AddMacro('CUSTOMER.PHONE_NO = '''+sprCustomerFilterForm.Edit2.Text+'''');
      if SMacro<>'' then
        SMacro:=' where ' + SMacro;
      quSprCustomer.MacroByName('MacroFilter').Value:=SMacro;
      quSprCustomer.Open;
      actCustFilter.Checked:=SMacro<>'';
    end;
  finally
    sprCustomerFilterForm.Free;
  end;
end;


procedure TMainForm.dbGrid1TitleClick(Column: TColumn);
begin
  if quSprCountry.Active then
  begin
    if Column.Field.FieldName = FSFSprCountry then
      FSFSprCountryOrder:=not FSFSprCountryOrder
    else
    begin
      FSFSprCountryOrder:=true;
      FSFSprCountry := Column.Field.FieldName;
    end;
    quSprCountry.SortOnField(FSFSprCountry, FSFSprCountryOrder);
  end;
end;

procedure TMainForm.dbGrid2TitleClick(Column: TColumn);
begin
  if quSprCustomer.Active then
  begin
    if Column.Field.FieldName = FSFSprCustomer then
      FSFSprCustomerOrder:=not FSFSprCustomerOrder
    else
    begin
      FSFSprCustomerOrder:=true;
      FSFSprCustomer := Column.Field.FieldName;
    end;
    quSprCustomer.SortOnField(FSFSprCustomer, FSFSprCustomerOrder);
  end;
end;


procedure TMainForm.quSprCountryAfterClose(DataSet: TDataSet);
begin
  FSFSprCountry:='';
end;

procedure TMainForm.quSprCustomerAfterClose(DataSet: TDataSet);
begin
  FSFSprCustomer:='';
end;

procedure TMainForm.sysExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.sysToolsExecute(Sender: TObject);
var
  SaveLngName:string;
begin
  SaveLngName:=lngFileName;
  ConfigForm:=TConfigForm.Create(Application);
  ConfigForm.ShowModal;
  ConfigForm.Free;
  if SaveLngName<>lngFileName then
    ShowMessage(sNeedRestartConfigCh);
end;

procedure TMainForm.UIBDataBase1BeforeConnect(Sender: TObject);
begin
  //UIBDataBase1.PassWord:='';
end;

procedure TMainForm.MainFormCreate(Sender: TObject);
begin
  UIBDataBase1.Connected:=true;
  PageControl1Change(nil);
end;

procedure TMainForm.ApplicationProperties1Hint(Sender: TObject);
begin
  StatusBar1.SimpleText:=Application.Hint;
end;

procedure TMainForm.hlpAboutExecute(Sender: TObject);
begin
  if not Assigned(hlpAboutForm) then
    hlpAboutForm:=ThlpAboutForm.Create(Application);
  hlpAboutForm.Show;
end;

procedure TMainForm.PageControl1Change(Sender: TObject);
begin
  PageControl2Change(nil);
end;

end.

