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

unit dcl_fb_id_StrConsts;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils; 

resourcestring
  dcl_fb_sResult          = 'Result';
  dcl_fb_sPlan            = 'Plan';
  dcl_fb_sSQLTest         = 'SQL test...';
  dcl_fb_sTableAlias      = 'Table alias';
  dcl_fb_sDescription     = 'Description';
  dcl_fb_sReplaceSQL      = 'Replace sql';
  dcl_fb_sShowInfo        = 'Show info';
  dcl_fb_sFilter          = 'Filter';
  dcl_fb_sGenerate        = 'Generate';
  dcl_fb_sCheck           = 'Check';
  dcl_fb_sTest            = 'Test';
  dcl_fb_sSQLSelect       = 'Select SQL';
  dcl_fb_sSQLInsert       = 'Insert SQL';
  dcl_fb_sSQLEdit         = 'Edit SQL';
  dcl_fb_sSQLDelete       = 'Delete SQL';
  dcl_fb_sSQLRefresh      = 'Refresh SQL';
  dcl_fb_sSQLEditor       = 'SQL editor...';
  dcl_fb_sFBDataSetEditor = 'FBDataSet SQL Editor';
  dcl_fb_sModified        = 'Modified';

implementation

end.

