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

{$I jedi.inc}

//Coment this line for replase SQL editor to standart strings editor
{$DEFINE FBSQLEditor}
{ .$DEFINE FB_USE_SQL_WAIT_CURSOR}
// turn on some additional checks
{ .$IFDEF USE_SAFE_CODE}
//Это определение для влюкчения старого поведения запроса обновления - выбор транзакции
//В новом стиле - возможен только явный выбор - читающая или пишушая. Никаих - "по умолчанию"
{$DEFINE OLD_REFRESH_TRAN_PARAMS}

{$I fb_define_compiler.inc}



{$IFDEF FB_USE_SQL_WAIT_CURSOR}
{$DEFINE FB_USE_LCL}
{$ENDIF}

{ ето макро реально нет надобности неиспользовать. оно задействует
   механизм надежного освобождения рекордов имеющих произвольное количество ссылок.
   сейчас реально ссылки задействованы только в реализации OldValue, при етом
   неможет теоретически возникнуть список рекордов, тоесть возможно только
   одноранговое дерево в котором несколько рекордов могут ссылаться на один общий
   старый рекорд. Для того чтобы отслеживать нарушения етого правила, при освобождении
   памяти рекордов подымается исключение при попытке освободить элемент протяженного
   списка у которого есть предки.
   ето макро имеет смысл задействовать для отладки потерь памяти рекордов
 }

{$DEFINE FB_USE_FREESTYLE_REFERENCED_RECORDS}

{$IFDEF FPC}
{$IFDEF WINDOWS}
//fix locate procedure on utf8 charset in windows
{$DEFINE FIX_UTF8LOCATE}
{$ENDIF}

{$if FPC_FULLVERSION<20701}
  {$DEFINE NoAutomatedBookmark}
{$endif}

{$ENDIF}
{$DEFINE IB7_UP}
