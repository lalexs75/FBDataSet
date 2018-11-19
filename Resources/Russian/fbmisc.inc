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
  sfbeOtherError        = 'Другая ошибка';
  sfbeCircularReference = 'Циклическая ссылка компонент запрещена (%s).'; //fbeCircularReference
  sfbeEmptySQLEdit      = 'Пустой текст SQL запроса редактирования (%s).'; //sfbeEmptySQLEdit
  sfbeDatabaseNotAssigned = 'Свойство Database не присвоено (%s)';
  sfbeTransactionNotAssigned = 'Свойство Transaction не присвоено (%s)';
  sfbeParameterNotFound = 'Параметр не найден (%s)';
  sfbeNotCachedUpdates  = 'Не включен ражим кэширования (%s)';
  sfbeUserAbort = 'Отменено пользователем';
  sfbeErrorExecuteQ       = 'Ошибка выполнения запроса %s (%s).';
  sfbeBlobCannotBeWritten = 'Blob поток не может быть записан.';
  sfbeGetRecordInvalidRec = 'GetRecord: Ошибка поиска записи';

  EReferencedRecordBufferLooseMsg = 'Попытка освободить не существующий буфер данных';
  EReferencedDatSetRecordBufferLooseMsg = 'Попытка освободить не существующий буфер набора данных';
  EReferencedBLOBCacheLooseMsg    = 'TBLOBCache:попытка освободить используемый буфер данных';
  EAccessIncorectBLOBCacheMsg = 'TBLOBList: попытка доступа к несуществующему кешу';
  ESomeBLOBCacheLoosedMsg = 'Остались потеряные кеши';

const //Localizations
  slcOk     = 'OK';
  slcCancel = 'Отмена';
  slcHelp   = 'Помощь';
  //Auto update options window
  slcUpdatedField  = 'Изменяемое поле';
  slcGeneratorName = 'Генератор';
  slcIncrementBy   = 'Приращение';
