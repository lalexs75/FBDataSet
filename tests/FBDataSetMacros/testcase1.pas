unit TestCase1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testutils, testregistry;

type

  FBDataSetMacrosTest= class(TTestCase)
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestHookUp;
  end;

implementation

uses MainDataUnit, CustApp;

procedure FBDataSetMacrosTest.TestHookUp;
var
  DepNo:integer;
begin
  DepNo:=1;

  MainData.FBDataSet_WithParam.Params.ByNameAsInteger['DEPT_NO']:=DepNo;
  AssertEquals('Проверка параметра до открытия запроса', MainData.FBDataSet_WithParam.Params.ByNameAsInteger['DEPT_NO'], DepNo);
  MainData.FBDataSet_WithParam.Open;
  AssertEquals('Проверка параметра после открытия запроса', MainData.FBDataSet_WithParam.Params.ByNameAsInteger['DEPT_NO'], DepNo);
  MainData.FBDataSet_WithParam.Close;
  AssertEquals('Проверка параметра после закрытия запроса', MainData.FBDataSet_WithParam.Params.ByNameAsInteger['DEPT_NO'], DepNo);


  MainData.FBDataSet_WithMacro.Params.ByNameAsInteger['DEPT_NO']:=DepNo;
  AssertEquals('Проверка параметра до установки макроса', MainData.FBDataSet_WithMacro.Params.ByNameAsInteger['DEPT_NO'], DepNo);
  MainData.FBDataSet_WithMacro.MacroByName('Macro1').Value:=' and 0=0';
  AssertEquals('Проверка параметра после установки макроса', MainData.FBDataSet_WithMacro.Params.ByNameAsInteger['DEPT_NO'], DepNo);
  MainData.FBDataSet_WithMacro.Open;
  AssertEquals('Проверка параметра после открытия запроса', MainData.FBDataSet_WithMacro.Params.ByNameAsInteger['DEPT_NO'], DepNo);
  MainData.FBDataSet_WithMacro.Close;
  AssertEquals('Проверка параметра после закрытия запроса', MainData.FBDataSet_WithMacro.Params.ByNameAsInteger['DEPT_NO'], DepNo);
end;

procedure FBDataSetMacrosTest.SetUp;
begin
  MainData:=TMainData.Create(CustomApplication);
end;

procedure FBDataSetMacrosTest.TearDown;
begin

end;

initialization

  RegisterTest(FBDataSetMacrosTest);
end.

