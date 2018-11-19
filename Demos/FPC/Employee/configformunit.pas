unit ConfigFormUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ButtonPanel, StdCtrls;

type

  { TConfigForm }

  TConfigForm = class(TForm)
    ButtonPanel1: TButtonPanel;
    Label1: TLabel;
    ListBox1: TListBox;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    procedure LoadPOFilesList;
  public
    { public declarations }
  end; 

var
  ConfigForm: TConfigForm;

implementation
uses Translations, gettext, ConfigUnit;

{$R *.lfm}

{ TConfigForm }

procedure TConfigForm.FormCreate(Sender: TObject);
var
  i:integer;
begin
  LoadPOFilesList;
  i:=ListBox1.Items.IndexOf(lngFileName);
  if i>=0 then
    ListBox1.ItemIndex:=i;
end;

procedure TConfigForm.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  if ModalResult = mrOk then
  begin
    if ListBox1.ItemIndex>=0 then
      lngFileName:=ListBox1.Items[ListBox1.ItemIndex];
    SaveConfig;
  end;
end;

procedure TConfigForm.LoadPOFilesList;
var
  R:TSearchRec;
  C:integer;
begin
  C:=FindFirst(lngFolder + DirectorySeparator + '*.po',faAnyFile, R);
  while C=0 do
  begin
    if (R.Attr and faDirectory) = 0 then
      ListBox1.Items.Add(R.Name);
    C:=FindNext(R);
  end;
  FindClose(R);
end;

end.

