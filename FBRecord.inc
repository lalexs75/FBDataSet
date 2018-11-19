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



function GetRecordNulls(const OwnerDS : TMyDBCustomDataSet; const Target : PRecordBuffer) : PBooleans; {$IFDEF FPC} inline; {$ENDIF}
{$RANGECHECKS OFF}
begin
  result := PBooleans( @(Target^.Data[OwnerDS.FRecordSize]));
end;
{.$RANGECHECKS ON}

procedure AssignOldBuffer(const OwnerDS : TMyDBCustomDataSet;
                          var Target : tRecordBuffer;
                          const OldBuffer : PRecordBuffer);  {$IFDEF FPC} inline; {$ENDIF}
begin
  if assigned(Target.OldBuffer) then
    OwnerDS.ReleaseOldBuffer(Target);
  inc(OldBuffer^.References);
  Target.OldBuffer := OldBuffer;
end;

procedure ReferenceOldBuffer(var Target : tRecordBuffer);  {$IFDEF FPC} inline; {$ENDIF}
begin
  if assigned(Target.OldBuffer) then
  begin
    inc(Target.OldBuffer^.References);
  end;
end;

