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

{$I fb_define.inc}
{this unit intended for fix some standart VCL units bugs
 and provide common interface for bfcustomdataset on different platforms
}

unit DBOverlap;

interface uses Classes, SysUtils
            , DB
            ;

  type
    TLargeIntFieldRev = class(DB.TLargeIntField)
      protected
        procedure SetVarValue(const Value: Variant); override;
    end;

    TLargeIntField = TLargeIntFieldRev;

  procedure RegisterOverlap;

implementation

procedure TLargeIntFieldRev.SetVarValue(const Value: Variant);
begin
  SetAsLargeInt(value);
end;

procedure RegisterOverlap;
begin
  RegisterClass(TLargeIntFieldRev);
  RegisterFields([TLargeIntFieldRev]);
  RegisterNoIcon([TLargeIntFieldRev]);
  DB.DefaultFieldClasses[ftLargeInt] := TLargeIntFieldRev;
end;

initialization
  DB.DefaultFieldClasses[ftLargeInt] := TLargeIntFieldRev;
end.
 
