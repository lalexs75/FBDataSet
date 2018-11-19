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
(* Unit owner : Lagunov Aleksey <alexs75@yandex.ru>                             *)
(*                                                                              *)
(********************************************************************************)

unit uibeditorsconsts;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

resourcestring
  sUIBDatabaseEditor                               = 'UIB Database Editor';
  sConnection                                      = 'Connection';
  sSelectDatabaseFile                              = 'Select database file';
  sSelectLibraryFileName                           = 'Select library file name';
  sModeLbl                                         = '&Mode';
  sServerLbl                                       = '&Server';
  sPortLbl                                         = '&Port';
  sDatabaseLbl                                     = '&Database name';
  sLibraryNameLbl                                  = '&Library name';
  sUserNameLbl                                     = '&User Name';
  sPasswordLbl                                     = 'Pass&word';
  sSQLRoleLbl                                      = 'SQL &Role';
  sCharacterSetLbl                                 = '&Character Set';

  sCommons                                         = 'Commons';

implementation

end.

