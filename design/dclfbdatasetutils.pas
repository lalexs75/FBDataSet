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

unit dclFBDataSetUtils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

function DoQuoteName(const AName:string; aQute:boolean = false):string;
implementation

function DoQuoteName(const AName: string; aQute: boolean): string;
var
  FLoCase, FHiCase: Boolean;
  I: Integer;
begin
  FLoCase:=false;
  FHiCase:=false;
  I:=1;
  while i < Length(AName) do
  begin
    if (AName[i] = '"') then
    begin
      Inc(i);
      while ((i<Length(AName)) and (AName[i]<>'"')) do Inc(i);
      aQute:=i<>Length(AName);
    end
    else
    if (AName[i]>#127) then
    begin
      aQute:=true;
      break;
    end
    else
    if AName[i] in ['a'..'z'] then
      FLoCase:=true
    else
    if AName[i] in ['A'..'Z'] then
      FHiCase:=true;
    Inc(i);
  end;

  if FLoCase and FHiCase then
    aQute:=true;

  if aQute then
    Result:=AnsiQuotedStr(AName, '"')
  else
    Result:=AName;
end;

end.

