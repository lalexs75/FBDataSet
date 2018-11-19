unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, lrUIBData, LR_Class, LR_Desgn, LRDialogControls,
  uib, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    CheckBox1: TCheckBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    frDesigner1: TfrDesigner;
    frReport1: TfrReport;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    LRDialogControls1: TLRDialogControls;
    lrUIBData1: TlrUIBData;
    UIBDataBase1: TUIBDataBase;
    UIBTransaction1: TUIBTransaction;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure UIBDataBase1AfterConnect(Sender: TObject);
  private
    procedure UpdateControls;
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button2Click(Sender: TObject);
begin
  UIBDataBase1.DatabaseName:=Edit1.Text;
  UIBDataBase1.UserName:=Edit2.Text;
  UIBDataBase1.PassWord:=Edit3.Text;
  UIBDataBase1.Connected:=true;
  UpdateControls;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
  FRepFile: RawByteString;
begin
  FRepFile:=ExtractFileDir(ParamStr(0)) + PathDelim + 'test_report.lrf';

  if FileExists(FRepFile) then
    frReport1.LoadFromFile(FRepFile)
  else
    frReport1.FileName:=FRepFile;
  if CheckBox1.Checked then
    frReport1.DesignReport
  else
    frReport1.ShowReport;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  UpdateControls;
end;

procedure TForm1.UIBDataBase1AfterConnect(Sender: TObject);
begin
  UIBTransaction1.StartTransaction;
end;

procedure TForm1.UpdateControls;
begin
  Label1.Enabled:=not UIBDataBase1.Connected;
  Label2.Enabled:=not UIBDataBase1.Connected;
  Label3.Enabled:=not UIBDataBase1.Connected;

  Edit1.Enabled:=not UIBDataBase1.Connected;
  Edit2.Enabled:=not UIBDataBase1.Connected;
  Edit3.Enabled:=not UIBDataBase1.Connected;

  Button2.Enabled:=not UIBDataBase1.Connected;
  Button1.Enabled:=UIBDataBase1.Connected;
  CheckBox1.Enabled:=UIBDataBase1.Connected;
end;

end.

