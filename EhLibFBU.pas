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

{********************************************************************************}
{ Add this unit to 'uses' clause of any unit of your project to allow TDBGridEh  }
{ to sort data in FBDataset automatically after sorting markers will be changed. }
{ TFBUDatasetFeaturesEh will sort data locally using SortOnField procedure of    }
{ FBDataset                                                                      }
{********************************************************************************}

unit EhLibFBU;

{$I EhLib.Inc}

interface

uses
  DbUtilsEh, DBGridEh, DB, FBCustomDataSet;

type
  TFBUDatasetFeaturesEh = class(TDatasetFeaturesEh)
  public
    procedure ApplySorting(Sender: TObject; DataSet: TDataSet; IsReopen: Boolean); override;
  end;

implementation
uses Classes;

procedure TFBUDatasetFeaturesEh.ApplySorting(Sender: TObject; DataSet: TDataSet; IsReopen: Boolean);
var FLD  : array of TVarRec ;
    sort : array of boolean;
    I,J  : integer;
    Grid : TCustomDBGridEh;
begin
  if Sender is TCustomDBGridEh then
  begin
    Grid:=TCustomDBGridEh(Sender);
    if Grid.SortMarkedColumns.Count=1 then
    begin
//      J:=Grid.SortMarkedColumns.Count;
      TFBCustomDataSet(Dataset).SortOnField(Grid.SortMarkedColumns[0].fieldname, Grid.SortMarkedColumns[0].Title.SortMarker=smDownEh);
    end;
  end;
end;

initialization
  RegisterDatasetFeaturesEh(TFBUDatasetFeaturesEh, TFBCustomDataSet);
end.
