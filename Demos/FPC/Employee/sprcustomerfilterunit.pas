unit sprCustomerFilterUnit;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, Buttons,
  StdCtrls, ButtonPanel;

type

  { TsprCustomerFilterForm }

  TsprCustomerFilterForm = class(TForm)
    ButtonPanel1: TButtonPanel;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  sprCustomerFilterForm: TsprCustomerFilterForm;

implementation

{$R *.lfm}

end.
