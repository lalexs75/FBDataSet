unit hlpAboutUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ButtonPanel;

type

  { ThlpAboutForm }

  ThlpAboutForm = class(TForm)
    ButtonPanel1: TButtonPanel;
    Label1: TLabel;
    Label10: TLabel;
    CSDVersionLabel: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  hlpAboutForm: ThlpAboutForm = nil;

const
  BuildDate = {$I %DATE%};
  Version = '1.0';
  fpcVersion = {$I %FPCVERSION%};
  TargetCPU = {$I %FPCTARGETCPU%};
  TargetOS = {$I %FPCTARGETOS%};

implementation
uses InterfaceBase;

{$R *.lfm}

{ ThlpAboutForm }

procedure ThlpAboutForm.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  CloseAction:=caFree;
  hlpAboutForm:=nil;
end;

procedure ThlpAboutForm.FormCreate(Sender: TObject);
begin
  Label5.Caption:='Build date: ' + BuildDate;
  Label6.Caption:='Version: ' + Version;
  Label7.Caption:='FPC version : '+ fpcVersion;
  Label8.Caption:='Target CPU : '+ TargetCPU;
  Label9.Caption:='Target OS : ' + TargetOS;
  Label10.Caption:='LCL version : ' + LCLVersion;

  case WidgetSet.LCLPlatform of
    lpGtk:CSDVersionLabel.Caption:='Widget : '+'GTK widget set';
    lpGtk2:CSDVersionLabel.Caption:='Widget : '+'GTK 2 widget set';
    lpWin32:CSDVersionLabel.Caption:='Widget : '+'Win32/Win64 widget set';
    lpWinCE:CSDVersionLabel.Caption:='Widget : '+'WinCE widget set';
    lpCarbon:CSDVersionLabel.Caption:='Widget : '+'Carbon widget set';
    lpQT:CSDVersionLabel.Caption:='Widget : '+'QT widget set';
    lpfpGUI:CSDVersionLabel.Caption:='Widget : '+'FpGUI widget set';
  else
    CSDVersionLabel.Caption:='Other gui';
  end;
end;


end.

