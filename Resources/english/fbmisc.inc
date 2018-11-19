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

const //Exception messages
  sfbeOtherError          = 'Other error';
  sfbeCircularReference   = 'The cyclic reference a component is forbidden (%s).'; //fbeCircularReference
  sfbeEmptySQLEdit        = 'Empty edit SQL statament (%s).'; //sfbeEmptySQLEdit
  sfbeDatabaseNotAssigned = 'Database not assigned (%s)';
  sfbeTransactionNotAssigned = 'Transaction not assigned (%s)';
  sfbeParameterNotFound   = 'Parameter not found (%s)';
  sfbeNotCachedUpdates    = 'Not Cached Updates (%s)';
  sfbeUserAbort           = 'User abort';
  sfbeErrorExecuteQ       = 'Error execute query %s (%s).';
  sfbeBlobCannotBeWritten = 'Blob stream cannot be written.';
  sfbeCannotInsert        = 'Cannot Insert %s.';
  sfbeGetRecordInvalidRec = 'GetRecord: Invalid record';

  EReferencedRecordBufferLooseMsg = 'try to free referenced record buffer';
  EReferencedDatSetRecordBufferLooseMsg = 'try to free referenced DatSet record buffer';
  EReferencedBLOBCacheLooseMsg    = 'TBLOBCache:try to destroy used cache';
  EAccessIncorectBLOBCacheMsg = 'TBLOBList: access to unregistred BLOBCache cell';
  ESomeBLOBCacheLoosedMsg = 'Some BLOBCache cells loosed';

const //Localizations
  slcOk     = 'OK';
  slcCancel = 'Cancel';
  slcHelp   = 'Help';
  //Auto update options window
  slcUpdatedField  = 'Updated field';
  slcGeneratorName = 'Generator name';
  slcIncrementBy   = 'Increment by';
