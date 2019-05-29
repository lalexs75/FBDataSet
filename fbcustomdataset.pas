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

//UTF8-RU-ansi used

unit fbcustomdataset;

interface

uses
  SysUtils, Classes, DB, mydbunit, uiblib, uib, fbmisc, fbparams,
  uibase,
{$IFDEF FB_USE_LCL}
  ExtCtrls, Forms, Controls,
{$ENDIF}
  IniFiles {use THashedStringList}
  ;

type
  TFieldHeader = class
    FieldName:string;
    FieldNo:integer;
    FieldType:TFieldType;
    FieldSize:Cardinal;
    FieldPrecision:integer;
    FieldOffs:Cardinal;
    FieldRequired:boolean;
    {used to denote that field data uses as AnsiString/WideString types for
     ftString Field type}
    {(UTF8-RU-ansi) указывает что используется динамический тип данных - в рекорде
     реально храница указатель на данные.}
    FieldIsDinamicData : boolean;
    FieldOrigin:string;
      {this tag used for fields selection that need to save/load thair cache cells,
       at present BLOB are maintained}
    IsCached : boolean;
  end;
  PFieldHeader = TFieldHeader;

  FieldHeaderIndex = integer;

  { TFieldsHeader }

  TFieldsHeader = class(TList)
  private
    function GetFieldHeader(Index: Integer): TFieldHeader;
    procedure Notify(Ptr: Pointer; Action: TListNotification); override;
  public
    property FieldHeader[Index: Integer]:TFieldHeader read GetFieldHeader; default;
    function HeaderByName(AName:string):TFieldHeader;
  end;

const
  {(UTF8-RU-ansi) граница минимальной длинны строки, начиная с которой выгодно ее
   хранить в ansiString}
  AnsiMinSizeTh = 31;

  {this constants used by FBAnsiField class to access Get/SetData methods}
  fdNativeData = true;
  fdConvertData = false;
type
  IntegersArray = array of integer;
  {grow Dest array for 1 value and set one to a last array cell, returns an length of Dest}
  function AppendItem( var Dest : IntegersArray; Value : integer) : integer;
type
  TBlobCacheStream = class;
  TRecordsBufferIndex = class;

  {(UTF8-RU-ansi) ета запись используется для выборки БЛОБА из буфера записи методами Get/SetFieldData}
  {this type use for retrieve BLOB with Get/SetField methods}
  PBLOBFieldData = ^TBLOBFieldData;
  TBLOBFieldData = record
      IscQuad : TIscQuad;
      Cache   : TBlobCacheStream;
  end;

  TRecordsBuffer = class;
  TFBCustomDataSet = class;
  TFBUpdateRecordTypes = set of TCachedUpdateStatus;

  TFBDataLink = class(TDetailDataLink)
  protected
    FFBCustomDataSet: TFBCustomDataSet;
  protected
    procedure ActiveChanged; override;
    procedure RecordChanged(Field: TField); override;
    function GetDetailDataSet: TDataSet; override;
  public
    constructor Create(AFBCustomDataSet: TFBCustomDataSet);
    destructor Destroy; override;
  end;

  TAutoUpdateOptions = class(TPersistent)
  private
    FOwner:TFBCustomDataSet;
    FUpdateTableName: string; //Updated table
    FKeyField: string;
    FWhenGetGenID: TWhenGetGenID;
    FIncrementBy: integer;
    FGeneratorName: string; //Key field
    procedure SetKeyField(const AValue: string);
    procedure SetUpdateTableName(const AValue: string);
    procedure SetWhenGetGenID(const AValue: TWhenGetGenID);
    procedure SetGeneratorName(const AValue: string);
    procedure SetIncrementBy(const AValue: integer);
  public
    constructor Create(AOwner:TFBCustomDataSet);
    destructor Destroy; override;
    procedure ApplyGetGenID;
    procedure Assign(Source: TPersistent); override;
    function IsComplete:boolean;
  published
    property KeyField:string read FKeyField write SetKeyField;
    property UpdateTableName:string read FUpdateTableName write SetUpdateTableName;
    property WhenGetGenID:TWhenGetGenID read FWhenGetGenID write SetWhenGetGenID;
    property GeneratorName:string read FGeneratorName write SetGeneratorName;
    property IncrementBy:integer read FIncrementBy write SetIncrementBy;
  end;

(*
  TFBTimeField = class(TTimeField)
  protected
    procedure SetAsString(const AValue: string); override;
  end;
*)
  TFBAnsiMemoField = class(TMemoField)
  protected
    function GetAsString: string; override;
    procedure SetAsString(const Value: string); override;
    function GetIsNull: Boolean; override;
  end;
  FBAnsiMemoField = TFBAnsiMemoField;

  TFBAnsiField = class(TStringField)
  protected
      {uses for fast field access}
      NativeDataSet : TFBCustomDataSet;
      procedure SetDataSet(ADataSet: TDataSet); override;
      procedure SetData(const Data: AnsiString);overload;
      procedure CopyData(Source, Dest: Pointer); {$IFNDEF FPC}override;{$ENDIF}

      function GetAsString: string; override;
      function GetAsVariant: Variant; override;
      function GetAsAnsiString: AnsiString;
      function GetDataSize: Integer; override;
      procedure SetAsAnsiString(const Value: AnsiString); virtual;
      procedure SetAsString(const Value: AnsiString); overload;
      {$IFOPT H+}override;{$ELSE}virtual;{$ENDIF}
//      procedure SetAsString(const Value: ShortString); overload;
//      {$IFOPT H+}virtual;{$ELSE}override;{$ENDIF}
      procedure SetVarValue(const Value: Variant); override;
    public
      property AsString: AnsiString read GetAsAnsiString write SetAsAnsiString;
      property Value: AnsiString read GetAsAnsiString write SetAsAnsiString;
  end;
  FBAnsiField = TFBAnsiField;

{$IFDEF FPC}
  TFBBlobField = class(TBlobField)
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    procedure SaveToStrings(Strings: TStrings);
  end;

{$ENDIF}

  { TFBLargeintField }

  TFBLargeintField = class(TLargeintField)
  protected
    procedure GetText(var AText: string; ADisplayText: Boolean); override;
  end;

  TDSBLOBCacheList = TList;
  { TFBCustomDataSet }

  TFBCustomDataSet = class(TMyDBCustomDataSet)
  private
    procedure SetRefreshTransactionKind(AValue: TTransactionKind);
  protected
    FDataBase:TUIBDataBase;
    FMasterScrollBehavior: TMasterScrollBehavior;
    FOnFetchRecord: TNotifyEvent;
    FQuerySelect:TUIBQuery;
    FQueryRefresh:TUIBQuery;
    FQueryInsert:TUIBQuery;
    FQueryEdit:TUIBQuery;
    FQueryDelete:TUIBQuery;
    FFiledsHeader:TFieldsHeader;
    FRecordsBuffer:TRecordsBuffer;
    FRecordCount:integer;
    FOption: TFBDsOptions;
    FCachedUpdates: Boolean;
    FAllowedUpdateKinds: TUpdateKinds;
    FAutoUpdateOptions: TAutoUpdateOptions;
    FRefreshTransactionKind: TTransactionKind;
{$IFDEF FB_USE_LCL}
    FSQLScreenCursor: TCursor;
    FDetailWaitTimer:TTimer;
{$ENDIF}
    FUpdateRecordTypes: TFBUpdateRecordTypes;
    //Master-detail support
    FMasterFBDataLink:TFBDataLink;
    FDetailConditions: TDetailConditions;
    //Macro support - based on RXQuery from rxlib
    FSaveQueryChanged: TNotifyEvent;
    FMacros: TFBParams;
    FMacroChar: Char;
    FPatternChanged: Boolean;
    FSQLPattern: TStrings;
    FStreamPatternChanged: Boolean;
    FDisconnectExpected: Boolean;
    FAutoCommit: boolean;
    FDefaultFormats: TDefaultFormats;
    FBFCurrentOperationState:TBFCurrentOperationState;
    procedure DoFillParams(Qu:TUIBQuery; OnlyMaster:boolean);
    //Macro support - based on RXQuery from rxlib
    procedure RecreateMacros;
    procedure CreateMacros(List: TFBParams; const Value: PChar);
    procedure PatternChanged(Sender: TObject);
    procedure Expand(Query: TStrings);
    procedure QueryChanged(Sender: TObject);
    //Master-detail
    procedure MasterUpdate(MasterUpdateStatus:TMasterUpdateStatus);
    //Property metods
    procedure SetTransaction(const AValue: TUIBTransaction);
    procedure SetDataBase(const AValue: TUIBDataBase);
    function GetSQLRefresh: TStrings;
    function GetSQLSelect: TStrings;
    procedure SetSQLRefresh(const AValue: TStrings);
    procedure SetSQLSelect(const AValue: TStrings);
    function GetParams: TSQLParams;
    function GetSQLDelete: TStrings;
    function GetSQLEdit: TStrings;
    procedure SetSQLDelete(const AValue: TStrings);
    procedure SetSQLEdit(const AValue: TStrings);
    procedure SetOption(const AValue: TFBDsOptions);
    procedure SetCachedUpdates(const AValue: Boolean);
    procedure SetAllowedUpdateKinds(const AValue: TUpdateKinds);
    procedure SetDetailConditions(const AValue: TDetailConditions);
    procedure SetAutoUpdateOptions(const AValue: TAutoUpdateOptions);
    function GetSQLInsert: TStrings;
    procedure SetSQLInsert(const AValue: TStrings);
    function GetMacros: TFBParams;
    procedure SetMacroChar(const AValue: Char);
    procedure SetMacros(const AValue: TFBParams);
    function GetMacroCount: Word;
    procedure SetUpdateRecordTypes(const AValue: TFBUpdateRecordTypes);
    function StoreUpdateTransaction:boolean;
    function GetTransaction: TUIBTransaction;
    function GetUpdateTransaction: TUIBTransaction;
    procedure SetUpdateTransaction(const AValue: TUIBTransaction);
    function CheckUpdateKind(UpdateKind:TUpdateKind):boolean;
    procedure SetAutoCommit(const AValue: boolean);
    procedure UpdateStart;
    procedure UpdateCommit;
    function IsVisible(Buffer: PChar): Boolean;
    procedure SetDefaultFormats(const AValue: TDefaultFormats);
    procedure UpdateFieldsFormat;
    procedure QuerySelectOnClose(Sender: TObject);
    procedure FillEmptyEPFromSelectPar(const Q: TUIBQuery; const ParName:string);
    function DoPrepareUIBQuery(const Q: TUIBQuery): boolean;
  protected
    FMaxMEMOStringSize : cardinal;
    {use by BLOB caches to show that record data affected by caches}
{$IFDEF USE_SAFE_CODE}
    FBLOBCache : TDSBLOBCacheList;
{$ENDIF}
    FCachedFieldsCount  : cardinal;
    FCachedFields       : IntegersArray;

    FInspectRecNo:integer;
    FInspectRecord : PRecordBuffer;

    function IsInspecting : boolean;  {$IFDEF FPC} inline; {$ENDIF}
    function GetActiveBuf: PChar;reintroduce;

  protected
    CalcFieldsMap : array of FieldHeaderIndex;
    function GetCalcFieldNo(Offset : cardinal) : FieldHeaderIndex; {$IFDEF FPC} inline; {$ENDIF}
    function HeaderId(const Field : TField) : FieldHeaderIndex; {$IFDEF FPC} inline; {$ENDIF}

  protected
    // overrided metods
    procedure DoBeforeDelete; override;
    procedure DoBeforeEdit; override;
    procedure DoBeforeInsert; override;

    procedure BindFields(Binding: Boolean); override;
    procedure InternalInitFieldDefs; override;
    procedure InternalClose; override;
    procedure InternalOpen; override;
    function GetRecord(Buffer: PChar; GetMode: TGetMode;
        DoCheck: Boolean): TGetResult; override;
    procedure SetFieldData(Field: TField; Buffer: Pointer); overload; override;
    procedure SetFieldData(Field: TField; const Data : AnsiString);overload;virtual;
    procedure SetFieldData2Record(Field: TField; Buffer: Pointer;const RecBuf : PRecordBuffer);overload;virtual;
    procedure SetFieldData2Record(Field: TField; const Data : AnsiString; const RecBuf : PRecordBuffer);overload;virtual;
    procedure SetBLOBCache(Field: TField; Buffer: PBLOBFieldData); virtual;
    function InternalRecordCount: Integer; override;
    procedure InternalAfterOpen; override;
    procedure InternalEdit; override;
    procedure InternalLast; override;
    procedure InternalRefresh; override;
    procedure InternalRefreshRow(UIBQuery:TUIBQuery);
    procedure InternalPost; override;
    procedure InternalDelete; override;
    procedure InternalAddRecord(Buffer: Pointer; Append: Boolean);override;
    procedure SetFiltered(Value: Boolean); override;
    function GetDataSource: TDataSource; override;
    procedure DoOnNewRecord; override;
    procedure Loaded; override;
    function GetFieldClass(FieldType: TFieldType): TFieldClass; override;
    function IsEmptyEx: Boolean;override;
    // internal metods
    function BookmarkValid(ABookmark: TBookmark): Boolean; override;
    procedure InternalGotoBookmark(ABookmark: Pointer); override;
    procedure InternalSaveRecord(const Q:TUIBQuery; FBuff: PChar);
    procedure SetDataSource(AValue: TDataSource);
    procedure SetFieldsFromParams;
    procedure ForceMasterRefresh;
    function GetAnyRecField(SrcRecNo:integer; AField:TField):variant;
    //
    property AllowedUpdateKinds:TUpdateKinds read FAllowedUpdateKinds write SetAllowedUpdateKinds default [ukModify, ukInsert, ukDelete];
    property AutoCommit:boolean read FAutoCommit write SetAutoCommit default False;
    property DataBase:TUIBDataBase read FDataBase write SetDataBase;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property DefaultFormats:TDefaultFormats read FDefaultFormats write SetDefaultFormats;
    property DetailConditions:TDetailConditions read FDetailConditions write SetDetailConditions;
    property CachedUpdates: Boolean read FCachedUpdates write SetCachedUpdates default False;
    property Transaction:TUIBTransaction read GetTransaction write SetTransaction;
    property SQLSelect:TStrings read GetSQLSelect write SetSQLSelect;
    property SQLRefresh:TStrings read GetSQLRefresh write SetSQLRefresh;
    property SQLEdit:TStrings read GetSQLEdit write SetSQLEdit;
    property SQLDelete:TStrings read GetSQLDelete write SetSQLDelete;
    property SQLInsert:TStrings read GetSQLInsert write SetSQLInsert;
    property QuerySelect:TUIBQuery read FQuerySelect;
    property QueryRefresh:TUIBQuery read FQueryRefresh;
    property QueryInsert:TUIBQuery read FQueryInsert;
    property QueryEdit:TUIBQuery read FQueryEdit;
    property QueryDelete:TUIBQuery read FQueryDelete;
    property Params: TSQLParams read GetParams;
    property Option:TFBDsOptions read FOption write SetOption;
    property AutoUpdateOptions:TAutoUpdateOptions read FAutoUpdateOptions write SetAutoUpdateOptions;
    property MacroChar: Char read FMacroChar write SetMacroChar default DefaultMacroChar;
    property Macros: TFBParams read GetMacros write SetMacros;
    property MasterScrollBehavior:TMasterScrollBehavior read FMasterScrollBehavior write FMasterScrollBehavior default msbCancel;
    property UpdateTransaction:TUIBTransaction read GetUpdateTransaction write SetUpdateTransaction {$IFNDEF FPC} stored StoreUpdateTransaction {$ENDIF FPC};
    property OnFetchRecord:TNotifyEvent read FOnFetchRecord write FOnFetchRecord;
    property UpdateRecordTypes: TFBUpdateRecordTypes read FUpdateRecordTypes
                                                      write SetUpdateRecordTypes;
    //create the valid cache cell 4 required mode if possible, true if cell is exist
    //(UTF8-RU-ansi) создает ячейку кеша блоба по заданому режиму доступа, true - если кеш существует,
    // результат в BLOBRec
    function BlobCacheMaintain(Field: TField; Mode: TBlobStreamMode;
                            var BLOBRec : TBLOBFieldData
                          ) : boolean;
    function GetMemo(Field: TField) : AnsiString;
    procedure SetMemo(Field: TField; Value: AnsiString);

  protected
    { **************        LocalIndexes interface         *******************}

    FLocalIndexes : THashedStringList;

      {raise exception EIndexNotFound if not found}
    function GetLocalIndex(const NameOrDef : string) : TRecordsBufferIndex;
      {same as GetLocalIndex but return nil if not found}
    function FindLocalIndex(const NameOrDef : string) : TRecordsBufferIndex;
    function NewLocalIndex(const NameOrDef : string) : TRecordsBufferIndex;virtual;
    {free index if it try to be assigned with nil}
    procedure FreeLocalIndex(const NameOrDef : string; const Value : TRecordsBufferIndex);
    procedure FreeLocalIndexes;

    property LocalIndexes[const NameOrDef : string] : TRecordsBufferIndex read GetLocalIndex write FreeLocalIndex;

  public

    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    function GetFieldData(Field: TField; Buffer: Pointer): Boolean; override;
    function CreateBlobStream(Field: TField; Mode: TBlobStreamMode): TStream; override;

    procedure ApplyUpdates;
    function  CachedUpdateStatus: TCachedUpdateStatus;
    procedure CancelUpdates;
    procedure CloseOpen(AFetchAll:boolean = false);
    procedure FetchAll;
    procedure FetchNext(FCount:integer);
    procedure SortOnField(FieldName:string; Asc:boolean);
    procedure SortOnFields(FieldNames:string; Asc: array of boolean);
    procedure ExpandMacros;
    function MacroByName(const AValue: string): TFBParam;
    function Locate(const KeyFields: string; const KeyValues: Variant;
      Options: TLocateOptions): Boolean;override;
    function Lookup(const KeyFields: string; const KeyValues: Variant;
                    const ResultFields: string): Variant;overload;override;
    function Lookup(const KeyFields: string; const KeyValues: Variant;
                    const ResultFields: array of TField): Variant;overload;virtual;
    function UpdateStatus: TUpdateStatus; override;

    procedure SetFieldValues(const ValueFields : array of TField; const Values : variant); overload;
    procedure SetFieldValues(const ValueFields : string; const Values : variant); overload;
    procedure SetFieldValues(Target : PRecordBuffer; const ValueFields : array of TField; const Values : variant); overload;
    procedure SetFieldValues(Target : PRecordBuffer; const ValueFields : string; const Values : variant); overload;

    procedure GetFieldValues(const ResultFields : array of TField; var Values : variant); overload;
    procedure GetFieldValues(const ResultFields : string; var Values : variant); overload;
    procedure GetFieldValues(Source : PRecordBuffer;  const ResultFields : array of TField; var Values : variant); overload;
    procedure GetFieldValues(Source : PRecordBuffer;  const ResultFields : string; var Values : variant); overload;
    function CurRecordCachedUpdateStatus:TCachedUpdateStatus; deprecated 'use UpdateStatus instead';

    property MacroCount: Word read GetMacroCount;
    property FetchedRecordCount:integer read FRecordCount;
    //
    procedure CloneRecord(SrcRecord: integer; IgnoreFields: array of const);
    procedure CloneCurRecord(IgnoreFields: array of const);

    property MemoValue[Field: TField] : AnsiString read GetMemo write SetMemo;
    property RefreshTransactionKind:TTransactionKind read FRefreshTransactionKind write SetRefreshTransactionKind default
                                                      {$IFDEF OLD_REFRESH_TRAN_PARAMS}
                                                      tkDefault
                                                      {$ELSE}
                                                      tkReadTransaction
                                                      {$ENDIF}
                                                      ;
{$IFDEF FB_USE_LCL}
    property SQLScreenCursor  :TCursor read FSQLScreenCursor write FSQLScreenCursor default crDefault;
{$ENDIF}
  published
    {if Memo size less than this value - it stores in memoty in native way - as string}
    {(UTF8-RU-ansi) если размер Мемо меньше заданного значения - оно храница в виде строки иначе только в потоке}
    property MaxMEMOStringSize : cardinal read FMaxMEMOStringSize write FMaxMEMOStringSize default 16384;
  end;

  TRecBuf = class
  private
    FBufSize  : cardinal;
    FCurrent  : PChar;
    FOriginal : PChar;
    function GetOriginal: PChar;
  public
    constructor Create(ABufSize:cardinal);
    destructor Destroy; override;
    procedure Modify;
    property Current : PChar read FCurrent;
    property Original: PChar read GetOriginal;
  end;

  { TRecordsBuffer }

  SaveCacheList = class;
  
  TRecordsBuffer = class(TList)
  protected
    FOwner:TFBCustomDataSet;
    function CompareField(Item1, Item2:PRecordBuffer; FieldNo:integer; Asc:Boolean):integer;
    procedure SetUpdStatusFlag(Item:PRecordBuffer; Status:TCachedUpdateStatus);
    function  FindBufferByBookmark(ABookmark:Integer):PRecordBuffer;
  public
    {(UTF8-RU-ansi) счетчик изменений - используется индексами как идикатор устаревания}
    ModifyStamp : cardinal;
    constructor Create(AOwner:TFBCustomDataSet);
    destructor Destroy; override;
    procedure ReadRecordFromQuery(RecNo:integer; Sourse:TUIBQuery);
    procedure RefreshRecordFromQuery(RecNo:integer; Sourse:TUIBQuery);
    procedure SaveToBuffer(RecNo:integer; Buffer:PChar);  //Ситаем из колекции в бувер датасета
    procedure SaveFromBuffer(RecNo:integer; Buffer:PChar); //Запомним в колекции - Post
    procedure SaveFromBufferI(RecNo:integer; Buffer:PChar); //Запомним в колекции - Insert
    procedure SaveFromBufferA(RecNo:integer; Buffer:PChar); //Запомним в колекции - Append
    procedure Clear;override;
    procedure SortOnField(FieldNo:integer; Asc:boolean);
    procedure SortOnFields(const SortArray:TFBInternalSortArray;const CountEl:integer);
    procedure DeleteRecord(RecNo:integer);
    procedure EditRecord(RecNo:integer; NewBuffer : PRecordBuffer);
    procedure SaveCache(const Dest : SaveCacheList);
    procedure LoadCache(const Dest : SaveCacheList);
  end;

  TFBDataSet = class(TFBCustomDataSet)
  public
    property Params;
    property QuerySelect;
    property QueryRefresh;
    property QueryInsert;
    property QueryEdit;
    property QueryDelete;
  published
    property AfterRefresh;
    property BeforeRefresh;
    property AllowedUpdateKinds;
    property AutoCommit;
    property AutoUpdateOptions;
    property DataSource;
    property DefaultFormats;
    property DetailConditions;
    property Filtered;
    property CachedUpdates;
    property DataBase;
    property Description;
    property MacroChar;
    property Macros;
    property MasterScrollBehavior;
    property Option;
    property RefreshTransactionKind;
    property Transaction;
    property UpdateTransaction;
    property UpdateRecordTypes;
    property SQLSelect;
    property SQLRefresh;
    property SQLEdit;
    property SQLDelete;
    property SQLInsert;
{$IFDEF FB_USE_LCL}
    property SQLScreenCursor;
{$ENDIF}
    //Events
    property OnUpdateRecord;
    property OnUpdateError;
    property OnFetchRecord;
    property MaxMEMOStringSize;
  end;
  
  TCacheState = (csNotReady, csFresh, csModified, csLoadBLOB, csStoreBLOB);

  TBlobCacheStream = class(TBLOBCache)
  protected
    FState : tCacheState;
    procedure DoWriteBlob;virtual;abstract;
    procedure DoReadBlob;virtual;abstract;
    procedure EnModifyValue;virtual;

    function GetSize: Int64; override;

    procedure SetText(const Src : AnsiString);virtual;
    function GetText : AnsiString;virtual;
  public
    DS       : TFBCustomDataSet;
    Isc      : TIscQuad;
    constructor Create(aDS : TFBCustomDataSet; aOriginISC : TIscQuad);
    destructor Destroy;override;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    procedure SetSize(NewSize: Longint); override;
    function Modified : boolean;
    function New   : TBlobCacheStream;virtual;abstract;
    function Clone : TBlobCacheStream;virtual;
     {(UTF8-RU-ansi) отсылает содержимое на сервер, если оно изменено, обновляет Isc}
    procedure Flush;
    {(UTF8-RU-ansi) загружает содержимо БЛОБА с сервера}
    procedure Refresh;
    {(UTF8-RU-ansi) делает кеш устаревшим}
    procedure OutDate;
    {(UTF8-RU-ansi) ускоряет создание кеша - если текущий кеш неразделяем то переинициирует себя
      и себя же  возвращает, иначе создает новый кеш его и возвращает }
    function Change(const aIsc : tISCQuad) : TBLOBCache;
    {(UTF8-RU-ansi) тоже только если текущий кеш разделеяем - то новый не создает а возвращает нил}
    function ChangeOrNil(const aIsc : tISCQuad) : TBLOBCache;

    property AnsiText : AnsiString read GetText write SetText;
  end;


  TFBBlobStream = class(TBlobCacheStream) {TBLOBCache}
  protected
    procedure DoWriteBlob;override;
    procedure DoReadBlob;override;
  public
    function New : TBlobCacheStream;override;
  end;

  { TFBAnsiMemoStream }

  TFBAnsiMemoStream = class(TFBBlobStream)
  protected
    FMemoText : AnsiString;
    FTextShared : boolean;
    {(UTF8-RU-ansi) флаг устанавливается после чтения текста и сбрасывается после дублирования содержимого}

    procedure EnModifyValue;override;
    procedure SetText(const Src : AnsiString);override;
    function GetText : AnsiString;override;
    function Realloc(var NewCapacity: PtrInt): Pointer; override; //virtual;
  public
    constructor Create(aDS : TFBCustomDataSet; aOriginISC : TIscQuad);
    destructor Destroy;override;
    function New : TBlobCacheStream;override;
    function Clone : TBlobCacheStream;override;
  end;

  TLostBLOBCacheEvent = procedure(const DSname : string; var List : TDSBLOBCacheList);

    SaveCacheList = class(TList)
    protected
      IsSorted : boolean; 
      procedure Notify(Ptr: Pointer; Action: TListNotification); overload;
    public
      procedure Sort; overload;
      function Locate(const ISQ : TIscQuad) : TBLOBCacheStream;
    end;
    TSaveCacheList = SaveCacheList;
  {******************************************************************************
                          FLocalIndexes
*******************************************************************************}
  FBRecordCompare = function(var context ;
                              {OwnerDS : TFBCustomDataSet;}
                              valA, valB : PRecordBuffer) : integer;
  FBRecordCompareMethod = function(
                              {OwnerDS : TFBCustomDataSet;}
                              valA, valB : PRecordBuffer) : integer of object;
  iRecordComparer = interface{class(TObject)}
         function Compare(valA, valB : PRecordBuffer) : integer; overload;
         function Compare(A : PRecordBuffer; const Value : variant) : integer; overload;

    procedure Sort(var Records : TRecordsBuffer);
    function Locate(const Records : tRecordsBuffer; const Values : variant) : TBookmark;

{
         function Min(valA, valB : PRecordBuffer) : PRecordBuffer; overload; virtual;
         function Max(valA, valB : PRecordBuffer) : PRecordBuffer; overload; virtual;
         function Min(valA, valB : PRecordBuffer; AIndex, BIndex : integer): integer; overload; virtual;
         function Max(valA, valB : PRecordBuffer; AIndex, BIndex : integer): integer; overload; virtual;
}
  end;

  TRecBufStamp = cardinal;

  RBIFieldDef = record
    FieldName : AnsiString;
    Descendent : boolean;
    CaseSence  : boolean;
    PartialKey : boolean;
    AsPrefix   : boolean;
  end;

  RBITask = Array of RBIFieldDef;

  TLocalIndex = TList;
  TRecordsBufferIndex = class(TLocalIndex)
    protected
      FOwner      : TFBCustomDataSet;
      FName       : string;
                 Source      : TRecordsBuffer;
      ModifyStamp : TRecBufStamp;

      SCompare  : FBRecordCompare;
      SLookup   : FBRecordCompare;

      Structure : RBITask;
      FDefinition : AnsiString;

      function Obsolete : boolean;

      procedure SetName(const Value : string);
      procedure SetDefinition(const aDef : string);overload;


           {function Compare(valA, valB : PRecordBuffer) : integer; overload;virtual;abstract;
           function Compare(A : PRecordBuffer; const Value : variant) : integer; overload;virtual;abstract;
      }
      function CompareRec(valA, valB : PRecordBuffer) : integer;virtual;abstract;

    public
      {for the named indexes}
      property Name  : string read FName write SetName;
      property Definition : string read FDefinition write SetDefinition;

      procedure SetDefinition(const aDef : TIndexDef);overload;
      procedure Rebuild;virtual;abstract;
      procedure DoFresh;
           procedure Sort;overload;virtual;

      {output the finest Record at least}
      function SearchRec(const Values : variant; out Target : PRecordBuffer) : boolean;virtual;abstract;
      function Locate(const Values : variant) : TBookmark;
      function LocateRec(const Values : variant) : PRecordBuffer;virtual;abstract;

      constructor Create({const aDefinition : String;} AOwner:TFBCustomDataSet);
      destructor Destroy;override;
  end;

  FBRBICompareContext = record
        FieldNo,
        FieldOffset,
        NullOffset,
        FieldSize : cardinal;
        DataHigh : cardinal;
        Descending : boolean;
        {компаратор FCompare используется методом Sort при построении индекса, FLookup используется методами
          Locate и Lookup для поиска по сортироаному списку - поэтому они могут быть проще с менее глубоким
          сравнением}
        FCompare  : FBRecordCompare;
        FLookup   : FBRecordCompare;
  end;
  RBIDefines = array of FBRBICompareContext;

  TUniversalRBIndex = class(TRecordsBufferIndex)
  protected
        FFields: Array of TField;
        FCompDefines : RBIDefines;
        {FCompSpecDefines - эти компараторы используются  при сравнении CompareRec для более глубокого сравнения
         но не используются в LookupRec - это позволит использовать более точный индекс для новых менее
         точных поисков}
        FCompSpecDefines : RBIDefines;

             function CompareRec(valA, valB : PRecordBuffer) : integer;override;
             function LookupRec(valA, valB : PRecordBuffer) : integer;virtual;

  public
    constructor Create(const aDefinition : TIndexDef; AOwner:TFBCustomDataSet);overload;
    constructor Create(const aDefinition : String; AOwner:TFBCustomDataSet);overload;
    destructor Destroy;override;
    procedure Rebuild;override;
    function SearchRec(const Values : variant; out Target : PRecordBuffer) : boolean;override;
    function LocateRec(const Values : variant) : PRecordBuffer;override;
  end;

var
  DefFBDsOptions : TFBDsOptions = [poTrimCharFields, poRefreshAfterPost];
  OnLostBLOBCache : tLostBLOBCacheEvent  = nil;

type
  EIndexNotFound = class(exception);
  EUnsupportedCompare = class(exception);

implementation

uses Math,
{$IFDEF FPC}
  dbconst
{$ELSE}
  dbconsts
{$ENDIF}
  , sysConst
  , variants
  ;

{$include FBRecord.inc}

  {grow Dest array for 1 value and set one to a last array cell, returns an length of Dest}
function AppendItem( var Dest : IntegersArray; Value : integer) : integer;
begin
  SetLength(Dest, Length(Dest) + 1);
  result := Length(Dest);
  Dest[result-1] := Value;
end;

type

  PMEMOString = AnsiString;
  {(UTF8-RU-ansi) ета запись используется для хранения БЛОБА в буфере записи}
  { this record use for store BLOB in RecordBuffer}
  PBLOBRecordData = ^TBLOBRecordData;
  TBLOBRecordData = record
      IscQuad : TIscQuad;
      ListIdx : cardinal;
  end;

{*********************************************************************
                       TBlobWrapStream
this stream used to access to BLOB cache
(UTF8-RU-ansi) етот поток используется как посредник с кешем БЛОБа
*********************************************************************}
  TBlobWrapStream = class(TStream)
  protected
    FField: TField;
    FBlobStream: TBlobCacheStream;
  protected
    function GetSize: Int64; override;
  public
    Mode: TBlobStreamMode;
    constructor Create(AField: TField; ABlobStream: TBlobCacheStream;
                      aMode: TBlobStreamMode);
    function Read(var Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    procedure SetSize(NewSize: Longint); override;
    function Write(const Buffer; Count: Longint): Longint; override;
  end;

constructor TBlobWrapStream.Create(AField: TField; ABlobStream: TBlobCacheStream;
                                    aMode: TBlobStreamMode);
begin
  inherited Create;
  FField := AField;
  FBlobStream := ABlobStream;
  Mode := aMode;
  if (Mode = bmWrite) then
    FBlobStream.SetSize(0)
  else
    FBlobStream.Position := 0;
end;

function TBlobWrapStream.Read(var Buffer; Count: Longint): Longint;
begin
  result := FBlobStream.Read(Buffer, Count);
end;

function TBlobWrapStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
  result := FBlobStream.Seek(Offset, Origin);
end;

function TBlobWrapStream.GetSize: Int64;
begin
  result := FBlobStream.Size;
end;

procedure TBlobWrapStream.SetSize(NewSize: Longint);
begin
  if not (Mode in [bmWrite, bmReadWrite]) then
    FBErrorStr(fbeBlobCannotBeWritten);
  FBlobStream.SetSize(NewSize);
{  TFBCustomDataSet(FField.DataSet).DataEvent(deFieldChange, Longint(FField));}
end;

function TBlobWrapStream.Write(const Buffer; Count: Longint): Longint;
begin
  if not (Mode in [bmWrite, bmReadWrite]) then
    FBErrorStr(fbeBlobCannotBeWritten);
  result := FBlobStream.Write(Buffer, Count);
  {TFBDataSet(FField.DataSet).RecordModified(True);}
{ TFBCustomDataSet(FField.DataSet).DataEvent(deFieldChange, Longint(FField));}
end;

{*********************************************************************
this stream used to wrap access to null BLOB
(UTF8-RU-ansi) етот поток используется как пустой БЛОБ, использую для избежания
лишней работы по управлению кешем для пустых полей
*********************************************************************}
type
  TNullBlobWrapStream = class(TStream)
    protected
      function GetSize: Int64; override;
    public
      function Read(var Buffer; Count: Longint): Longint; override;
      function Seek(Offset: Longint; Origin: Word): Longint; override;
      procedure SetSize(NewSize: Longint); override;
      function Write(const Buffer; Count: Longint): Longint; override;
  end;

function TNullBLOBWrapStream.GetSize: Int64;
begin
  result := 0;
end;

function TNullBLOBWrapStream.Read(var Buffer; Count: Longint): Longint;
begin
  result := 0;
end;

function TNullBLOBWrapStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
  result := 0;
end;

procedure TNullBLOBWrapStream.SetSize(NewSize: Longint);
begin
  FBErrorStr(fbeBlobCannotBeWritten);
end;

function TNullBLOBWrapStream.Write(const Buffer; Count: Longint): Longint;
begin
  FBErrorStr(fbeBlobCannotBeWritten);
  Write := 0;
end;

const
  parPrefixNew = 'NEW_';
  parPrefixOLD = 'OLD_';

{ TFieldsHeader }
  
function TFieldsHeader.GetFieldHeader(Index: Integer): TFieldHeader;
begin
  Result:=TFieldHeader(Items[Index])
end;

procedure TFieldsHeader.Notify(Ptr: Pointer; Action: TListNotification);
var
  P:TFieldHeader absolute Ptr;
begin
  if Action = lnDeleted then
    FreeAndNil(P);
end;

function TFieldsHeader.HeaderByName(AName: string): TFieldHeader;
var
  i: Integer;
begin
  AName:=UpperCase(AName);
  Result:=nil;
  for i:=0 to Count-1 do
    if UpperCase(TFieldHeader(Items[I]).FieldName) = AName then
    begin
      Result:=TFieldHeader(Items[I]);
      exit;
    end;
end;

{ TFBCustomDataSet }

procedure TFBCustomDataSet.ApplyUpdates;
var
  CurBookmark: TBookmark;
  FUpdateAction: TUpdateAction;
  UpdateKind: TUpdateKind;
  bRecordsSkipped: Boolean;
  i, rc: integer;
  RecBuff:PRecordBuffer;
  CurUpdateTypes:TFBUpdateRecordTypes;
begin
  if not FCachedUpdates then
    FBError(fbeNotCachedUpdates, [Name]);
  if State in [dsEdit, dsInsert] then Post;
  if FRecordCount = 0 then Exit;

  DisableControls;
  {$IFDEF NoAutomatedBookmark}
  CurBookmark := GetBookmark;
  {$ELSE}
  CurBookmark := Bookmark;
  {$ENDIF}
  CurUpdateTypes := FUpdateRecordTypes;
  FUpdateRecordTypes := [cusModified, cusInserted, cusDeleted];
  try
    UpdateStart;
    First;

    i := 1;
    rc := FRecordCount;
    bRecordsSkipped :=Eof ;
    while (i <= rc) and not Eof do
    begin
      Inc(i);
      RecBuff:=@(PRecordBuffer(GetActiveBuf)^);
      case RecBuff^.CachedUpdateStatus of
        cusModified: UpdateKind := ukModify;
        cusInserted: UpdateKind := ukInsert;
      else
        UpdateKind := ukDelete;
      end;

      //if assigned manual updater - try it
      if (Assigned(FOnUpdateRecord)) then
      begin
        FUpdateAction := uaFail;
        FOnUpdateRecord(Self, UpdateKind, FUpdateAction);
      end
      else
        FUpdateAction := uaRetry;

      bRecordsSkipped := False;
      case FUpdateAction of
        uaFail: FBError(fbeUserAbort, []);
        uaAbort: SysUtils.Abort;
        uaApplied:
          begin
            RecBuff^.CachedUpdateStatus := cusUnmodified;
            FRecordsBuffer.SaveFromBuffer(RecBuff^.Bookmark, GetActiveBuf);
          end;
        uaSkip:
          bRecordsSkipped := True;
      end;

      if not bRecordsSkipped then
      begin
        while (FUpdateAction in [uaRetry]) do
        begin
          try
            case RecBuff^.CachedUpdateStatus  of
              cusModified: InternalSaveRecord(QueryEdit, GetActiveBuf);
              cusInserted: InternalSaveRecord(QueryInsert, GetActiveBuf);
              cusDeleted: InternalSaveRecord(QueryDelete, GetActiveBuf);
            end;
            FUpdateAction := uaApplied;
            if RecBuff^.CachedUpdateStatus = cusDeleted then
              FRecordsBuffer.SetUpdStatusFlag(RecBuff, cusDeletedApplied)
//              RecBuff^.CachedUpdateStatus:=cusDeletedApplied
            else
              FRecordsBuffer.SetUpdStatusFlag(RecBuff, cusUnmodified);
//              RecBuff^.CachedUpdateStatus:=cusUnmodified;
          except
            on E: EFBError do
            begin
              FUpdateAction := uaFail;
              if Assigned(FOnUpdateError) then
                FOnUpdateError(Self, E, UpdateKind, FUpdateAction);
              case FUpdateAction of
                uaFail: raise;
                uaAbort: raise EAbort(E.Message);
                uaSkip: bRecordsSkipped := True;
              end;
            end;
          end;
        end;
      end;
      Next;
    end;
    if not bRecordsSkipped then  UpdateCommit;
  finally
    FUpdateRecordTypes := CurUpdateTypes;
    {$IFDEF NoAutomatedBookmark}
    GotoBookmark(CurBookmark);
    {$ELSE}
    Bookmark := CurBookmark;
    {$ENDIF}
    Resync([]);
    FreeBookmark(CurBookmark);
    EnableControls;
  end;
end;

function TFBCustomDataSet.CachedUpdateStatus: TCachedUpdateStatus;
begin
  Result:=PMyDBInfo(Pointer(Cardinal(ActiveBuffer)+FRecordSize))^.CachedUpdateStatus;
end;

procedure TFBCustomDataSet.CancelUpdates;
begin

end;

function TFBCustomDataSet.CheckUpdateKind(
  UpdateKind: TUpdateKind): boolean;
begin
  case UpdateKind of
    ukModify:Result:=QueryEdit.SQL.Text<>'';
    ukInsert:Result:=QueryInsert.SQL.Text<>'';
    ukDelete:Result:=QueryDelete.SQL.Text<>'';
  else
    Result:=false;
  end;
  if Result then
    Result:=UpdateKind in FAllowedUpdateKinds;
end;

procedure TFBCustomDataSet.CloseOpen(AFetchAll: boolean);
var
{$IFDEF FB_USE_LCL}
  tmpCursor: Integer;
{$ENDIF}
  tmpCache : SaveCacheList;
begin
{$IFDEF FB_USE_LCL}
  if FSQLScreenCursor <> crDefault then
  begin
    tmpCursor := Screen.Cursor;
    Screen.Cursor := FSQLScreenCursor;
  end;
{$ENDIF}
  tmpCache := nil;
  DisableControls;
  try
    if Active then begin
      if AFetchAll and not (poParanoidBLOBRefresh in Option) then begin
        tmpCache := SaveCacheList.Create;
        FRecordsBuffer.SaveCache(tmpCache);
      end;
      Close;
    end;
    Open;
    if AFetchAll then
      FetchAll;
  finally
    if assigned(tmpCache) then begin
      FRecordsBuffer.LoadCache(tmpCache);
      tmpCache.Free;
    end;
    EnableControls;
{$IFDEF FB_USE_LCL}
    if FSQLScreenCursor <> crDefault then
      Screen.Cursor := tmpCursor;
{$ENDIF}
  end;
end;

constructor TFBCustomDataSet.Create(AOwner: TComponent);

function DoCreateQuery(qName:string):TUIBQuery;
begin
  Result:=TUIBQuery.Create(nil);
  Result.CachedFetch:=false;
  Result.Name:=Name+'_'+qName;
end;

begin
  inherited Create(AOwner);
  FBFCurrentOperationState:=cosNone;
  FInspectRecNo:=-1;
  FInspectRecord := nil;
  FCachedFields := nil;
  FCachedFieldsCount := 0;
  FAutoUpdateOptions:=TAutoUpdateOptions.Create(Self);
  FDefaultFormats:=TDefaultFormats.Create;

{$IFDEF FB_USE_LCL}
  FSQLScreenCursor:=crDefault;
{$ENDIF}

  FFiledsHeader:=TFieldsHeader.Create;
{$IFDEF USE_SAFE_CODE}
  FBLOBCache := TDSBLOBCacheList.Create;
{$ENDIF}
  FQuerySelect:=DoCreateQuery('QuerySelect');
  FQueryRefresh:=DoCreateQuery('QueryRefresh');
  FQueryEdit:=DoCreateQuery('QueryEdit');
  FQueryDelete:=DoCreateQuery('QueryDelete');
  FQueryInsert:=DoCreateQuery('QueryInsert');

  FRecordsBuffer:=TRecordsBuffer.Create(Self);
  FMasterFBDataLink:=TFBDataLink.Create(Self);
  FLocalIndexes := THashedStringList.Create;
  //Macros suppert - based on RxQuery from rxlib
  FMacros := TFBParams.Create(Self);
  FSQLPattern := TStringList.Create;
  FMacroChar := DefaultMacroChar;
  FSaveQueryChanged := TStringList(FQuerySelect.SQL).OnChange;
  TStringList(FQuerySelect.SQL).OnChange := QueryChanged;
  TStringList(FSQLPattern).OnChange := PatternChanged;
  //
  FOption:=DefFBDsOptions;
  FMasterScrollBehavior:=msbCancel;
  FCachedUpdates:=false;
  FAllowedUpdateKinds := [ukModify, ukInsert, ukDelete];
  FUpdateRecordTypes := [cusUnmodified, cusModified, cusInserted];

  {$IFDEF OLD_REFRESH_TRAN_PARAMS}
  FRefreshTransactionKind:=tkDefault
  {$ELSE}
  FRefreshTransactionKind:=tkReadTransaction;
  {$ENDIF}
end;

procedure TFBCustomDataSet.CreateMacros(List: TFBParams; const Value: PChar);
begin
  CreateQueryParams(List, Value, True, MacroChar, ['.']);
end;

destructor TFBCustomDataSet.Destroy;
var
  tmp : TDSBlobCacheList;
  aName : string;
begin
{$IFDEF USE_SAFE_CODE}
  tmp := FBLOBCache;
{$ENDIF}
  aName := Name;
  Active:=false;
  FFiledsHeader.Clear;
  FreeAndNil(FFiledsHeader);
  FreeAndNil(FRecordsBuffer);
  FreeAndNil(FMasterFBDataLink);
  FreeAndNil(FAutoUpdateOptions);
  FreeAndNil(FMacros);
  FreeAndNil(FSQLPattern);
  FreeAndNil(FDefaultFormats);
  FreeAndNil(FQuerySelect);
  FreeAndNil(FQueryRefresh);
  FreeAndNil(FQueryEdit);
  FreeAndNil(FQueryDelete);
  FreeAndNil(FQueryInsert);
  FreeLocalIndexes;
  FreeAndNil(FLocalIndexes);
  SetLength(CalcFieldsMap, 0);
  SetLength(FCachedFields, 0);
  inherited Destroy;
{$IFDEF USE_SAFE_CODE}
  if tmp.Count > 0 then
    if Assigned(OnLostBLOBCache) then
       OnLostBLOBCache(aName, tmp)
    else
      raise Exception.Create(ESomeBLOBCacheLoosedMsg);
  tmp.Destroy;
{$ENDIF}
end;

procedure TFBCustomDataSet.DoBeforeDelete;
begin
  if not CheckUpdateKind(ukDelete) then abort
  else inherited DoBeforeDelete;
end;

procedure TFBCustomDataSet.DoBeforeEdit;
begin
  if not CheckUpdateKind(ukModify) then abort
  else inherited DoBeforeEdit;
end;

procedure TFBCustomDataSet.DoBeforeInsert;
begin
  if not CheckUpdateKind(ukInsert) then abort
  else inherited DoBeforeInsert;
end;

procedure TFBCustomDataSet.SetRefreshTransactionKind(AValue: TTransactionKind);
begin
  {$IFDEF OLD_REFRESH_TRAN_PARAMS}
  if FRefreshTransactionKind=AValue then Exit;
  FRefreshTransactionKind:=AValue;
  {$ELSE}
//  if FRefreshTransactionKind=AValue then Exit;
  if AValue = tkDefault then
    AValue:=tkReadTransaction;
  FRefreshTransactionKind:=AValue;
  {$ENDIF}
end;

procedure TFBCustomDataSet.DoFillParams(Qu: TUIBQuery; OnlyMaster:boolean);
var
  I:integer;
  S:string;
  F:TField;
begin
  if Trim(Qu.SQL.Text)<>'' then
  begin
    for i:=0 to Qu.Params.FieldCount-1 do
    begin
      F:=nil;
      S:=Qu.Params.FieldName[i];
      if Assigned(FMasterFBDataLink.DataSource) and Assigned(FMasterFBDataLink.DataSource.DataSet) then
        F:=FMasterFBDataLink.DataSource.DataSet.FindField(S)
      else
      if not OnlyMaster then
        F:=FindField(S);
      if F<>nil then
      begin
        if F.IsNull then
          Qu.Params.IsNull[i]:=true
        else
        case F.DataType of
          ftFloat:Qu.Params.AsDouble[i]:=F.AsFloat;
          ftString:Qu.Params.AsString[i]:=F.AsString;
          ftSmallint:Qu.Params.AsSmallint[i]:=F.AsInteger;
(*
{$IFNDEF FIELD_NO_LARGEINT}
          ftLargeint:Qu.Params.AsInt64[i]:=F.AsLargeInt;
{$ELSE}
          ftLargeint:Qu.Params.AsInt64[i]:=TLargeIntField(F).AsLargeInt;
{$ENDIF}
*)
          ftLargeint:Qu.Params.AsInt64[i]:=F.AsLargeInt;
          ftInteger:Qu.Params.AsInteger[i]:=F.AsInteger;
          ftDateTime:Qu.Params.AsDateTime[i]:=F.AsDateTime;
//          ftDate:Qu.Params.AsDate[I]:=F.AsDate;
//          ftTime:Qu.Params.AsTime[i]:=F.Asti;
          ftBoolean:Qu.Params.AsBoolean[i]:=F.AsBoolean;
        end;
      end;
    end;
  end;
end;

procedure TFBCustomDataSet.DoOnNewRecord;
begin
  //Fill auto generation values
  if FAutoUpdateOptions.FWhenGetGenID = wgOnNewRecord then
    FAutoUpdateOptions.ApplyGetGenID;

  //Copy field values from maser table
  if poAutoParamsToFields in FOption then
    if Assigned(FMasterFBDataLink.DataSource) and Assigned(FMasterFBDataLink.DataSource.DataSet) then
      SetFieldsFromParams;
  inherited DoOnNewRecord;
end;

procedure TFBCustomDataSet.Expand(Query: TStrings);

  function ReplaceString(const S: string): string;
  var
    I, J, P, LiteralChars: Integer;
    Param: TFBParam;
    Found: Boolean;
  begin
    Result := S;
    for I := Macros.Count - 1 downto 0 do begin
      Param := Macros[I];
      if Param.Name = '' then Continue;
      repeat
        P := Pos(MacroChar + Param.Name, Result);
        Found := (P > 0) and ((Length(Result) = P + Length(Param.Name)) or
          NameDelimiter(Result[P + Length(Param.Name) + 1], ['.']));
        if Found then begin
          LiteralChars := 0;
          for J := 1 to P - 1 do
            if IsLiteral(Result[J]) then Inc(LiteralChars);
          Found := LiteralChars mod 2 = 0;
          if Found then
          begin
            Result := Copy(Result, 1, P - 1) + Param.Value + Copy(Result,
              P + Length(Param.Name) + 1, MaxInt);
          end;
        end;
      until not Found;
    end;
  end;

var
  I: Integer;
begin
  for I := 0 to FSQLPattern.Count - 1 do
    Query.Add(ReplaceString(FSQLPattern[I]));
end;

procedure TFBCustomDataSet.ExpandMacros;

procedure AssignParams(PSrc, PDest:TSQLParams);
var
  i: Integer;
  S, S1: String;
  C: TUIBFieldType;
  J: Word;
begin
  for i:=0 to PSrc.FieldCount - 1 do
  begin
    if PDest <> Params then
      PDest.AddFieldType(
        Params.FieldName[i],
        Params.FieldType[i],
        Params.SQLScale[i],
        7
      );

    S:=PSrc.FieldName[i];
    if PSrc.IsNull[i] then
    begin
      if PDest.TryGetFieldIndex(S, J) then
        PDest.IsNull[j]:=true;
    end
    else
    begin
//      S1:=PSrc.AsString[i];
      C:=PSrc.FieldType[i];

      if PDest.TryGetFieldIndex(S, J) then
      begin
        case PSrc.FieldType[i] of
          uftFloat, uftDoublePrecision,
          uftNumeric:PDest.ByNameAsDouble[S]:=PSrc.AsDouble[i];

          uftChar,
          uftVarchar,
          uftCstring:PDest.ByNameAsString[S]:=PSrc.AsString[i];

          uftSmallint,
          uftInteger:PDest.ByNameAsInteger[S]:=PSrc.AsInteger[i];

          uftQuad:;

          uftTimestamp:PDest.ByNameAsDateTime[S]:=PSrc.AsDateTime[i];

          uftBlob:;
          uftBlobId:;
          uftDate:PDest.ByNameAsDate[S]:=PSrc.AsDate[i];

          uftTime:PDest.ByNameAsDateTime[S]:=PSrc.AsDateTime[i];

          uftInt64:PDest.ByNameAsInt64[S]:=PSrc.AsInt64[i];

          uftArray:;
          {$IFDEF IB7_UP}
          uftBoolean:PDest.ByNameAsBoolean[S]:=PSrc.AsBoolean[i];
          {$ENDIF}
          {$IFDEF FB25_UP}, uftNull{$ENDIF}
        else
          //uftUnKnown:;
          S:='';
        end;
      end;

    end;
  end;
end;

var
  FSaveParams:TSQLParams;


procedure DoSaveParams;
begin
  FSaveParams:=TSQLParams.Create(Params.CharacterSet);
  AssignParams(Params, FSaveParams);
end;

procedure DoRestoreParams;
begin
  AssignParams(FSaveParams, Params);
  FreeAndNil(FSaveParams);
end;

var
  ExpandedSQL: TStringList;
begin
  if not FPatternChanged and not FStreamPatternChanged and
    (MacroCount = 0) then Exit;
  ExpandedSQL := TStringList.Create;
  DoSaveParams;
  try
    Expand(ExpandedSQL);
    FDisconnectExpected := True;
    try
      FQuerySelect.SQL := ExpandedSQL;
    finally
      FDisconnectExpected := False;
    end;
    DoRestoreParams;
  finally
    ExpandedSQL.Free;
  end;
end;

procedure TFBCustomDataSet.FetchAll;
var
  P:TBookmark;
begin
  if QuerySelect.Eof {or not (QuerySelect.CurrentState <> qsExecute)} then exit;
  DisableControls;
  P:=GetBookmark;
  try
    Last;
  finally
    GotoBookmark(P);
    FreeBookmark(P);
    EnableControls;
  end;
end;

procedure TFBCustomDataSet.FetchNext(FCount: integer);
var
  P:TBookmark;
begin
  DisableControls;
  P:=GetBookmark;
  try
    while (not Eof) or (FCount>0) do
    begin
      Next;
      Dec(FCount);
    end;
  finally
    GotoBookmark(P);
    FreeBookmark(P);
    EnableControls;
  end;
end;

procedure TFBCustomDataSet.ForceMasterRefresh;
begin
  if Assigned(FMasterFBDataLink.DataSource) and Assigned(FMasterFBDataLink.DataSource.DataSet) then
    FMasterFBDataLink.DataSource.DataSet.Refresh;
end;

function TFBCustomDataSet.IsInspecting : boolean;  {$IFDEF FPC} inline; {$ENDIF}
begin
  result := (FInspectRecNo >= 0) or assigned(FInspectRecord);
end;

function TFBCustomDataSet.GetActiveBuf: PChar;
begin
  if FInspectRecNo = -1 then begin
    if not assigned(FInspectRecord) then
      result := inherited GetActiveBuf
    else
      result := PChar(FInspectRecord);
  end
  else
    result := FRecordsBuffer.Items[FInspectRecNo]
end;

function TFBCustomDataSet.GetAnyRecField(SrcRecNo: integer; AField: TField
  ): variant;
begin
  FInspectRecNo:=SrcRecNo;
  try
    Result:=AField.Value;
  finally
    FInspectRecNo:=-1;
  end;
end;

function TFBCustomDataSet.GetDataSource: TDataSource;
begin
  if FMasterFBDataLink = nil then Result := nil
  else Result := FMasterFBDataLink.DataSource;
end;

function TFBCustomDataSet.GetFieldData(Field: TField;
  Buffer: Pointer): Boolean;
var
  FieldOffset:integer;
  RecBuf :PRecordBuffer;
  FieldDataPtr : pointer;
  HeaderNo : FieldHeaderIndex;
  FieldHeader   : PFieldHeader;
begin
  Result:=false;
    RecBuf:= PRecordBuffer(GetActiveBuf);
  if Assigned(RecBuf) then
  begin
    HeaderNo := HeaderId(Field);
    FieldHeader:=FFiledsHeader[HeaderNo];
    Result:=not GetRecordNulls(Self, RecBuf)^[HeaderNo];
    FieldOffset:= FieldHeader.FieldOffs;
    FieldDataPtr := @(RecBuf^.Data[FieldOffset]);
    if Result and assigned(Buffer) then
    begin
      if not (FieldHeader.FieldType in [ftString, ftWideString, ftBlob, ftMemo]) then
      begin
        {UTF8-RU-ansi : для совместимости со страндартным TStringField}
        Move(FieldDataPtr^, Buffer^, Field.DataSize);
      end
      else
      if FieldHeader.FieldType = ftString then
        PAnsiString(Buffer)^ := PAnsiString(FieldDataPtr)^
      else
      if FieldHeader.FieldType = ftWideString then
        PWideString(Buffer)^ := PWideString(FieldDataPtr)^
      else
      begin
        with PBLOBRecordData(FieldDataPtr)^ do
        begin
          if ListIdx = 0 then
            PBLOBFieldData(Buffer)^.Cache := nil
          else
          begin
            PBLOBFieldData(Buffer)^.Cache :=
              TBLOBCacheStream(RecBuf^.BlobList.Item(ListIdx));
                {have to avoid a property use due to bugs of delphi}
          end;
          if not assigned(PBLOBFieldData(Buffer)^.Cache) then
            PBLOBFieldData(Buffer)^.IscQuad := IscQuad
          else
            PBLOBFieldData(Buffer)^.IscQuad := PBLOBFieldData(Buffer)^.Cache.Isc;
        end;{with}
      end;
    end;{if Result}
  end;
end;{GetFieldData}

function TFBCustomDataSet.GetMacroCount: Word;
begin
  Result := FMacros.Count;
end;

procedure TFBCustomDataSet.SetUpdateRecordTypes(
  const AValue: TFBUpdateRecordTypes);
begin
  if FUpdateRecordTypes = AValue then exit;
  FUpdateRecordTypes := AValue;
  if Active then
    First;
end;

function TFBCustomDataSet.GetMacros: TFBParams;
begin
  if FStreamPatternChanged then
  begin
    FStreamPatternChanged := False;
    PatternChanged(nil);
  end;
  Result := FMacros;
end;

function TFBCustomDataSet.GetParams: TSQLParams;
begin
  Result := FQuerySelect.Params;
end;

function TFBCustomDataSet.GetRecord(Buffer: PChar; GetMode: TGetMode;
  DoCheck: Boolean): TGetResult;

function DoGetRecord: TGetResult;
begin
  Result:=grOk;
  case GetMode of
    gmCurrent:
      begin
        if (FCurrentRecord >= 0) then
        begin
          if FCurrentRecord < FRecordCount then
            FRecordsBuffer.SaveToBuffer(FCurrentRecord, Buffer)
          else
          begin
            while (not FQuerySelect.Eof) and (FCurrentRecord >= FRecordCount) do
            begin
              FQuerySelect.Next;
              FRecordsBuffer.ReadRecordFromQuery(FCurrentRecord, FQuerySelect);
              //FetchCurrentRecordToBuffer(FQSelect, FRecordCount, Buffer);
              Inc(FRecordCount);
            end;
            FCurrentRecord := FRecordCount - 1;
            if (FCurrentRecord >= 0) then
             FRecordsBuffer.SaveToBuffer(FCurrentRecord, Buffer)
          end;
          Result := grOk;
        end
        else
          Result := grBOF;
      end;
    gmNext:
      begin
        Result := grOk;
        if FCurrentRecord = FRecordCount then Result := grEOF
        else
        if FCurrentRecord = FRecordCount - 1 then
        begin
          if (not FQuerySelect.Eof) then
          begin
            FQuerySelect.Next;
            Inc(FCurrentRecord);
          end;
          if (FQuerySelect.Eof) then Result := grEOF
          else
          begin
            FRecordsBuffer.ReadRecordFromQuery(FCurrentRecord, FQuerySelect);
            FRecordsBuffer.SaveToBuffer(FCurrentRecord, Buffer);
            Inc(FRecordCount);
            if Assigned(FOnFetchRecord) then
              FOnFetchRecord(Self);
          end;
        end
        else
        if (FCurrentRecord < FRecordCount) then
        begin
          Inc(FCurrentRecord);
          FRecordsBuffer.SaveToBuffer(FCurrentRecord, Buffer)
        end;
      end;
    gmPrior:
      begin
        if FCurrentRecord <= 0 then
        begin
          Result := grBOF;
          FCurrentRecord:=-1;
        end
        else
        begin
          dec(FCurrentRecord);
          FRecordsBuffer.SaveToBuffer(FCurrentRecord, Buffer)
        end;
      end;
  end;
end;

begin
  if Assigned(Buffer) then
  begin
    repeat
      Result:=DoGetRecord;
      if not IsVisible(Buffer) and (GetMode = gmCurrent) then
          GetMode := gmPrior;
    until IsVisible(Buffer) or (Result <> grOK);
  end
  else
    Result:=DoGetRecord;
end;

function TFBCustomDataSet.GetSQLDelete: TStrings;
begin
  Result:=FQueryDelete.SQL;
end;

function TFBCustomDataSet.GetSQLEdit: TStrings;
begin
  Result:=FQueryEdit.SQL;
end;

function TFBCustomDataSet.GetSQLInsert: TStrings;
begin
  Result:=FQueryInsert.SQL;
end;

function TFBCustomDataSet.GetSQLRefresh: TStrings;
begin
  Result:=FQueryRefresh.SQL;
end;

function TFBCustomDataSet.GetSQLSelect: TStrings;
begin
//  Result:=FQuerySelect.SQL;
  Result:=FSQLPattern;
end;

function TFBCustomDataSet.GetTransaction: TUIBTransaction;
begin
  Result:=QuerySelect.Transaction;
end;

function TFBCustomDataSet.GetUpdateTransaction: TUIBTransaction;
begin
  Result:=QueryEdit.Transaction;
end;

procedure TFBCustomDataSet.InternalAfterOpen;
begin
  ExpandMacros;
  if Assigned(FMasterFBDataLink.DataSource) and Assigned(FMasterFBDataLink.DataSource.DataSet) then
    DoFillParams(FQuerySelect, true);
  FQuerySelect.Execute;
  FQuerySelect.OnClose:=QuerySelectOnClose;
  FRecordCount:=0;

  if not (poNotSetDefaultParams in FOption) then
    UpdateFieldsFormat;
end;

procedure TFBCustomDataSet.InternalClose;
begin
  FQuerySelect.Close;
  FRecordsBuffer.Clear;
  FRecordCount:=0;
  inherited InternalClose;
end;

procedure TFBCustomDataSet.InternalOpen;
begin
  if (csDesigning in ComponentState) and (not DataBase.Connected) then
    exit;
  inherited InternalOpen;
  if poFetchAll in Option then
    InternalLast;
  EofCrack := InternalRecordCount;
  FCurrentRecord := BofCrack;
end;

procedure TFBCustomDataSet.InternalEdit;
var
  Buffer : PRecordBuffer;
begin
  if (not FCachedUpdates) and (poRefreshBeforeEdit in FOption) then
    InternalRefresh;
  Buffer := PRecordBuffer(GetActiveBuf);
  FRecordsBuffer.EditRecord(FCurrentRecord, Buffer);
end;

procedure TFBCustomDataSet.InternalDelete;
var
  Buf:PChar;
begin
  Buf:=GetActiveBuf;
  if CachedUpdates then
  begin
    with PRecordBuffer(Buf)^ do
      if CachedUpdateStatus = cusInserted then CachedUpdateStatus := cusUninserted
      else CachedUpdateStatus := cusDeleted;
    FRecordsBuffer.SaveFromBuffer(FCurrentRecord, Buf);
  end
  else
  begin
    UpdateStart;
    InternalSaveRecord(QueryDelete, Buf);
    FRecordsBuffer.DeleteRecord(FCurrentRecord);
    Dec(FRecordCount);
    UpdateCommit;
    if dcForceMasterRefresh in DetailConditions then
      ForceMasterRefresh;
  end;
end;

function TFBCustomDataSet.GetCalcFieldNo(Offset : cardinal) : FieldHeaderIndex; {$IFDEF FPC} inline; {$ENDIF}
begin
{$IFDEF USE_SAFE_CODE}
  if offset > high(CalcFieldsMap) then
    raise Exception.Create(format('CalcFieldMap over offset %d',[offset]));
{$ENDIF}
  result := CalcFieldsMap[Offset];
{$IFDEF USE_SAFE_CODE}
  if result = 0 then
    raise Exception.Create(format('CalcFieldMap miss offset %d',[offset]));
{$ENDIF}
end;

function TFBCustomDataSet.HeaderId(const Field : TField) : FieldHeaderIndex;
begin
  result := Field.FieldNo;
  if result <= 0 then
      result := GetCalcFieldNo(Field.Offset);
  result := result -1;
end;

function HeaderOffsetCompare(Item1, Item2: Pointer): Integer;
var
  Header1 : PFieldHeader absolute Item1;
  Header2 : PFieldHeader absolute Item2;
begin
  result := Header1.FieldOffs - Header2.FieldOffs;
end;

procedure TFBCustomDataSet.BindFields(Binding: Boolean);
var
  FIdx : Integer;
  OffsetIdx : integer;
  CalcOffset : cardinal;
  Header  : PFieldHeader;
  HeaderId : FieldHeaderIndex;
  DinamicsAlign : cardinal;
  HeadersIsObsolete : boolean;
  OffsetOrdedHeaders : tList;

  function ShiftType2Align(AType : TFieldType) : cardinal;
  var
    HeaderIdx : FieldHeaderIndex;
    Header    : PFieldHeader;
  begin
    result := 0;
    for HeaderIdx := 0 to OffsetOrdedHeaders.Count-1 do begin
        Header := OffsetOrdedHeaders[HeaderIdx];
        if Header.FieldType = AType then begin
          OffsetOrdedHeaders.Move(HeaderIdx, DinamicsAlign);
          inc(DinamicsAlign);
          inc(result);
          HeadersIsObsolete := true;
        end;
    end;
  end;

procedure DoCheckFieldsCount;
var
  i: Integer;
begin
  if Fields.Count > FFiledsHeader.Count then
  begin
    for i:=0 to Fields.Count-1 do
      if Fields[i].FieldKind = fkData then
        if not Assigned(FFiledsHeader.HeaderByName(Fields[i].FieldName)) then
          raise EFBError.CreateFmt(EFieldNotFoundInDS, [Fields[i].FieldName, Name]);
  end;
end;

begin
  inherited BindFields(Binding);
  {now realign Calculated Fields by releasing reserved bytes beetwen them
   and assign the FieldNo to acces desired RecordBuffer`s data}
  {(UTF8-RU-ansi) на самом деле после нового выравнивания дополнительные байты
    остануца в конце рекорда неиспользуемым пространством, имхо ето пространство
    достаточно мало и недолжно вызывать больших затрат, чтобы с ним бороца}
  CalcOffset := FRecordSize;
  SetLength(CalcFieldsMap, CalcFieldsSize);
  for OffsetIdx := low(CalcFieldsMap) to high(CalcFieldsMap) do
    CalcFieldsMap[OffsetIdx] := 0;
  {now rescan and update headers to Fields actual data}
  OffsetOrdedHeaders := TList.Create;
  FCachedFieldsCount := 0;
  SetLength(FCachedFields, 0);
  if binding then
  begin
    DoCheckFieldsCount;
    for Fidx := 0 to Fields.Count-1 do
      begin
        if (Fields[FIdx].FieldNo < 0) and (Fields[FIdx].FieldKind in [fkCalculated, fkLookup]) then
        begin
          Header := TFieldHeader.Create;
          Header.FieldName := Fields[FIdx].FieldName;
          Header.FieldOffs := CalcOffset;
          Header.FieldType := Fields[FIdx].DataType;
          Header.FieldSize := Fields[FIdx].DataSize;
          FFiledsHeader.Add(Header);
          CalcFieldsMap[Fields[FIdx].Offset] := FFiledsHeader.IndexOf(Header) + 1;
          FRecordSize := FRecordSize + Fields[FIdx].DataSize;
          CalcOffset := FRecordSize;
        end
        else
        begin
          Header := FFiledsHeader[Fields[FIdx].FieldNo-1];
          if Header.FieldSize <> Fields[FIdx].DataSize then
          begin
            HeadersIsObsolete := true;
            Header.FieldSize := Fields[FIdx].DataSize;
          end;
        end;
        if (Fields[FIdx].DataType = ftString) and (not (Fields[FIdx] is FBAnsiField)) then
        begin
          Header.FieldType := ftFixedChar;
          HeadersIsObsolete := true;
        end
      else
      if Fields[FIdx].IsBlob then
      begin
        Header.FieldSize := SizeOf(TBLOBRecordData);
        FCachedFieldsCount := AppendItem(FCachedFields, FFiledsHeader.IndexOf(Header));
        Header.IsCached := true;
      end;
      if Header.FieldSize = 0 then
      begin
        { Field.DataSize is not defined and defaulted to 0,
          therefore to restore real datasize try use Field.Size (this is default used
          by FieldDef while creating field - exactly DB.TBlobField use this tech)
          maybe need to check DataType}
        Header.FieldSize := Fields[FIdx].Size;
      end;
      OffsetOrdedHeaders.Add(Header);
    end {if binding for}
  end
  else
  begin
    Fidx := 0;
    while Fidx < FFiledsHeader.Count do
    begin
      Header := FFiledsHeader[FIdx];
      if Header.FieldNo >= 0 then
      begin
        OffsetOrdedHeaders.Add(Header);
        inc(FIdx);
      end
      else
      begin
        FFiledsHeader.Delete(FIdx);
        Header.Destroy;
        HeadersIsObsolete := true;
      end;
    end;
   end;

  OffsetOrdedHeaders.Sort(@HeaderOffsetCompare);

  {now reorder fields in a recod so that dinadic field go at head of data}
  {(UTF8-RU-ansi) пересортируем порядок расположения полей в рекорде чтобы
   поля AnsiString, WideString размещались в начале рекорда и нормально
   обрабатывались при копировании инициации дестрое}
   DinamicsAlign := 0;
   RecordDinamics[dfsAnsi] := ShiftType2Align(ftString)-1;
   RecordDinamics[dfsWide] := ShiftType2Align(ftWideString)-1;

   RecordIsDinamic := (DinamicsAlign <> 0);

  if HeadersIsObsolete then
  begin
    {rebuild header offsets with new actual FieldSize}
    FRecordSize := 0;
    for Fidx := 0 to OffsetOrdedHeaders.Count-1 do
    begin
      Header := PFieldHeader(OffsetOrdedHeaders[FIdx]);
      with Header do
      begin
        FieldOffs := FRecordSize;
        FRecordSize := FRecordSize + FieldSize;
      end;
    end;
  end;

  FRecordBufferSize := FRecordSize
                    + sizeof (TMyDBInfo)
                    + SizeOf(Boolean) * Fields.Count
                    ;
  OffsetOrdedHeaders.Destroy;
end;

procedure TFBCustomDataSet.InternalInitFieldDefs;
var
  i:integer;
  FOfs:Cardinal;
  FieldHeader:TFieldHeader;
  Suffix: Integer;
begin
  ExpandMacros;
  DoPrepareUIBQuery(FQuerySelect);//.Prepare;

  FFiledsHeader.Clear;
  FieldDefs.BeginUpdate;
  FieldDefs.Clear;
  FOfs:=0;
  try
    for i := 0 to FQuerySelect.Fields.FieldCount - 1 do
    begin
      FieldHeader:=TFieldHeader.Create;
      FFiledsHeader.Add(FieldHeader);
      FieldHeader.FieldName:=FQuerySelect.Fields.AliasName[i];
      if FieldDefs.IndexOf(FieldHeader.FieldName) >= 0 then
      begin
        Suffix := 0;
        repeat
          Inc(Suffix);
          FieldHeader.FieldName := Format('%s_%d', [FQuerySelect.Fields.AliasName[i], Suffix]);
        until FieldDefs.IndexOf(FieldHeader.FieldName) < 0;
      end;
      FieldHeader.FieldNo:=i;
      FieldHeader.FieldRequired:=not FQuerySelect.Fields.IsNullable[i];
      FieldHeader.FieldPrecision:=-1;
      FieldHeader.FieldOffs:=FOfs;
      FieldHeader.FieldSize:=0;
      FieldHeader.FieldOrigin:=FQuerySelect.Fields.RelName[i] + '.' + FQuerySelect.Fields.SqlName[i];
      //block from  jvuibdataset - (UTF8-RU-ansi)за основу взято из jvuibdataset
      case FQuerySelect.Fields.FieldType[i] of
        uftNumeric:
          begin
            {$IFDEF FPC}
            FieldHeader.FieldType:=ftFloat;
            FOfs:=FOfs+SizeOf(Double);
            {$ELSE}
            FOfs:=FOfs+SizeOf(Double);
            case FQuerySelect.Fields.SQLType[i] of
              SQL_SHORT:
                begin
                  FieldHeader.FieldType:=ftBCD;
                  FieldHeader.FieldSize:=-FQuerySelect.Fields.Data.sqlvar[i].SqlScale;
                  if FieldHeader.FieldSize = 4 then
                    FieldHeader.FieldPrecision := 5
                  else
                    FieldHeader.FieldPrecision := 4;
                end;
              SQL_LONG:
                begin
                  FieldHeader.FieldSize := -FQuerySelect.Fields.Data.sqlvar[i].SqlScale;
                  if FieldHeader.FieldSize = 9 then
                    FieldHeader.FieldPrecision := 10
                  else
                    FieldHeader.FieldPrecision := 9;
                  if FieldHeader.FieldSize > 4 then
                    FieldHeader.FieldType:=ftFMTBcd
                  else
                    FieldHeader.FieldType:=ftBCD;
                end;
              SQL_INT64,
              SQL_QUAD:
                begin
                  FieldHeader.FieldType := ftBCD;
                  FieldHeader.FieldSize := -FQuerySelect.Fields.Data.sqlvar[i].SqlScale;
                  if FieldHeader.FieldSize = 18 then FieldHeader.FieldPrecision := 19
                  else FieldHeader.FieldPrecision := 18;
                  if FieldHeader.FieldSize > 4 then
                    FieldHeader.FieldType:=ftFMTBcd
                  else
                    FieldHeader.FieldType:=ftBCD;
                end;
              SQL_DOUBLE:FieldHeader.FieldType:=ftFloat; // possible
            else
              //raise
            end;
            {$ENDIF}
          end;
        uftChar,
        uftCstring,
        uftVarchar:
          begin
            FieldHeader.FieldSize := FQuerySelect.Fields.SQLLen[i];
            with FieldHeader do begin
            {$IFOPT H+}
              if FieldSize > SizeOf(AnsiString) then
              begin
            {$ELSE}
              if FieldSize > AnsiMinSizeTh then
              begin
            {$ENDIF}
                FieldHeader.FieldType:=ftString;
                FieldIsDinamicData := true;
                {warning - FieldSize ow use for construct fielddef with requred size
                 but at binding it will reset to actual DataSize}
                FOfs:=FOfs+SizeOf(AnsiString);
              end
              else
              begin
                FieldHeader.FieldType := ftFixedChar;
                FieldSize := FieldSize + 1;
                FOfs:=FOfs+FieldSize;
              end;
            end;
          end;
        uftSmallint:
          begin
            FieldHeader.FieldType:=ftSmallint;
            FOfs:=FOfs+SizeOf(SmallInt);
          end;
        uftInteger :
          begin
            FieldHeader.FieldType:=ftInteger;
            FOfs:=FOfs+SizeOf(Integer);
          end;
        uftFloat,
        uftDoublePrecision:
          begin
            FieldHeader.FieldType:=ftFloat;
            FOfs:=FOfs+SizeOf(Double);
          end;
        uftTimestamp:
          begin
            FieldHeader.FieldType:=ftDateTime;
            FOfs:=FOfs+SizeOf(TDateTime);
          end;
        uftBlob :
          begin
            if FQuerySelect.Fields.Data.sqlvar[i].SqlSubType = 1 then
              FieldHeader.FieldType:=ftMemo
            else
              FieldHeader.FieldType:=ftBlob;
            FieldHeader.FieldSize := SizeOf(TBLOBRecordData);
            FOfs:=FOfs+FieldHeader.FieldSize;
          end;
        uftDate :
          begin
            FieldHeader.FieldType:=ftDate;
            {$IFDEF FPC}
            FOfs:=FOfs+SizeOf(TDateTime);
            {$ELSE}
            FOfs:=FOfs+SizeOf(Integer);
            {$ENDIF}
          end;
        uftTime :
          begin
            FieldHeader.FieldType:=ftTime;
            {$IFDEF FPC}
            FOfs:=FOfs+SizeOf(TDateTime);
            {$ELSE}
            FOfs:=FOfs+SizeOf(Integer);
            {$ENDIF}
          end;
        uftInt64:
          begin
            FieldHeader.FieldType:=ftLargeint;
            FOfs:=FOfs+SizeOf(Largeint);
          end;
        {.$IFDEF IB7_UP}
        uftBoolean:
          begin
            FieldHeader.FieldType:=ftBoolean;
            FOfs:=FOfs+SizeOf(Boolean);
          end;
        {.$ENDIF}
      else
        FieldHeader.FieldType:=ftUnknown;
      end;
      FieldDefs.Add(FieldHeader.FieldName, FieldHeader.FieldType, FieldHeader.FieldSize, FieldHeader.FieldRequired);
      if FieldHeader.FieldPrecision<>-1 then
        FieldDefs.Items[FieldHeader.FieldNo].Precision:=FieldHeader.FieldPrecision;
      if FieldHeader.FieldType = ftFixedChar then
            FieldHeader.FieldSize := FieldHeader.FieldSize + 1;
    end;
    FRecordSize:=FOfs;
  finally
    FieldDefs.EndUpdate;
  end;
end;

procedure TFBCustomDataSet.InternalLast;
{$IFDEF FB_USE_LCL}
var
  tmpCursor: Integer;
{$ENDIF}
begin
  if (FQuerySelect.Eof) then
    FCurrentRecord := FRecordCount
  else
  begin
{$IFDEF FB_USE_LCL}
    if FSQLScreenCursor <> crDefault then
    begin
      tmpCursor := Screen.Cursor;
      Screen.Cursor := FSQLScreenCursor;
    end;
{$ENDIF}
    try
      try
        while not FQuerySelect.Eof do
        begin
          FQuerySelect.Next;
          if not FQuerySelect.Eof then
          begin
            FRecordsBuffer.ReadRecordFromQuery(FRecordCount, FQuerySelect);
            Inc(FRecordCount);
          end;
        end;
      except
      end;
      FCurrentRecord := FRecordCount;
    finally
{$IFDEF FB_USE_LCL}
    if FSQLScreenCursor <> crDefault then
      Screen.Cursor := tmpCursor;
{$ENDIF}
    end;
  end;
  if Assigned(FOnFetchRecord) then
    FOnFetchRecord(Self);
end;

procedure TFBCustomDataSet.InternalAddRecord(Buffer: Pointer; Append: Boolean);
begin
  if CheckUpdateKind(ukInsert) then
  begin
    if Append then
      InternalLast;
    with PRecordBuffer(ActiveBuffer)^ do
    begin
      if Append then
      begin
        Bookmark:=FRecordCount;
        FCurrentRecord:=FRecordCount;
      end
      else
        Bookmark:=FCurrentRecord;
      CachedUpdateStatus:=cusInserted;
    end;
    InternalPost;
    end
  else
    FBError(fbeCannotInsert, [Name]);
end;

procedure TFBCustomDataSet.InternalPost;

procedure DoRefresh;
begin
  if poRefreshAfterPost in Option then
    InternalRefresh;
  if dcForceMasterRefresh in DetailConditions then
    ForceMasterRefresh;
end;

begin
  CheckActive;
  FBFCurrentOperationState:=cosInPost;
  //Fill auto generation values
  if FAutoUpdateOptions.FWhenGetGenID = wgBeforePost then
    FAutoUpdateOptions.ApplyGetGenID;
  UpdateStart;

  if not FCachedUpdates then
  begin
    if State=dsEdit then
      InternalSaveRecord(QueryEdit, ActiveBuffer)
    else
      InternalSaveRecord(QueryInsert, ActiveBuffer);
  end;

  if State=dsEdit then
  begin
    with PRecordBuffer(ActiveBuffer)^ do
    if CachedUpdateStatus <> cusInserted then
      CachedUpdateStatus:=cusModified;
    FRecordsBuffer.SaveFromBuffer(FCurrentRecord, ActiveBuffer);
  end
  else
  if State=dsInsert then
  begin
    with PRecordBuffer(ActiveBuffer)^ do
      CachedUpdateStatus:=cusInserted;
    if (FCurrentRecord < FRecordCount) and (FCurrentRecord>=0) then
      FRecordsBuffer.SaveFromBufferI(FCurrentRecord, ActiveBuffer) //(UTF8-RU-ansi) Запомним в колекции - Insert
    else
    begin
      FRecordsBuffer.SaveFromBufferA(FRecordCount, ActiveBuffer); //(UTF8-RU-ansi) Запомним в колекции - Append
      FCurrentRecord:=FRecordCount;
    end;
    Inc(FRecordCount)
  end;
  if not FCachedUpdates then
  begin

{$IFDEF OLD_REFRESH_TRAN_PARAMS}
    if RefreshTransactionKind in [tkDefault, tkUpdateTransaction] then
      DoRefresh;
    UpdateCommit;
    if RefreshTransactionKind in [tkReadTransaction] then
      DoRefresh;
{$ELSE}
    if RefreshTransactionKind = tkUpdateTransaction then
      DoRefresh;
    UpdateCommit;
    if RefreshTransactionKind = tkReadTransaction then
      DoRefresh;
{$ENDIF}
  end;
  FBFCurrentOperationState:=cosNone;
end;

function TFBCustomDataSet.InternalRecordCount: Integer;
begin
  Result:=FRecordCount;
end;

procedure TFBCustomDataSet.InternalRefresh;
begin
  if FRecordCount>0 then
  begin
    DoBeforeRefresh;
    InternalRefreshRow(FQueryRefresh);
    FRecordsBuffer.SaveToBuffer(FCurrentRecord, GetActiveBuf);
    DoAfterRefresh;
  end;
end;

procedure TFBCustomDataSet.InternalRefreshRow(UIBQuery:TUIBQuery);
var
  i:integer;
  F:TField;
  S, S1:string;
begin
  if Trim(UIBQuery.SQL.Text)<>'' then
  begin
    for i:=0 to UIBQuery.Params.FieldCount-1 do
    begin
      S:=UIBQuery.Params.FieldName[i];
      S1:=AnsiUpperCase(Copy(S, 1, Length(parPrefixNew)));
      if (S1 = parPrefixNew) or (S1 = parPrefixOLD) then
        System.Delete(S, 1, Length(parPrefixNew));
      F:=FindField(S);
      if F<>nil then
      begin
        case F.DataType of
          ftFloat:UIBQuery.Params.AsDouble[i]:=F.AsFloat;
          ftString:UIBQuery.Params.AsString[i]:=F.AsString;
          ftSmallint:UIBQuery.Params.AsSmallint[i]:=F.AsInteger;
          ftInteger:UIBQuery.Params.AsInteger[i]:=F.AsInteger;
(*{$IFNDEF FIELD_NO_LARGEINT}
          ftLargeint:UIBQuery.Params.AsInt64[i]:=F.AsLargeInt;
{$ELSE}
          ftLargeint:UIBQuery.Params.AsInt64[i]:=TLargeIntField(F).AsLargeInt;
{$ENDIF}*)
          ftLargeint:UIBQuery.Params.AsInt64[i]:=F.AsLargeInt;
          ftDateTime,
          ftTime,
          ftDate:UIBQuery.Params.AsDateTime[i]:=F.AsDateTime;
          ftBoolean:UIBQuery.Params.AsBoolean[i]:=F.AsBoolean;
        end;
      end
      else
        FillEmptyEPFromSelectPar(UIBQuery, S);
    end;

    if UpdateTransaction <> Transaction then
    begin
{$IFDEF OLD_REFRESH_TRAN_PARAMS}
      case FRefreshTransactionKind of
        tkReadTransaction:UIBQuery.Transaction:=Transaction;
        tkUpdateTransaction:UIBQuery.Transaction:=UpdateTransaction;
      else
        if FBFCurrentOperationState = cosInPost then
          UIBQuery.Transaction:=UpdateTransaction
        else
          UIBQuery.Transaction:=Transaction;
      end;
{$ELSE}
      if FRefreshTransactionKind = tkUpdateTransaction then
        UIBQuery.Transaction:=UpdateTransaction
      else
        UIBQuery.Transaction:=Transaction;
{$ENDIF}
    end;
    
    try
//      UIBQuery.Execute;
//      UIBQuery.Next;
      UIBQuery.Open;
//      UIBQuery.Next;
      FRecordsBuffer.RefreshRecordFromQuery(FCurrentRecord, UIBQuery);
    finally
      UIBQuery.Close;
    end;
  end;
end;

procedure TFBCustomDataSet.InternalSaveRecord(const Q:TUIBQuery; FBuff: PChar);
var
  i, L:integer;
  F:TField;
  BLOBRec : TBLOBFieldData;
  S, S1:string;
  SourceRec : PRecordBuffer absolute FBuff;
  FOldRec:boolean;
begin
  if Trim(Q.SQL.Text)='' then
    FBError(fbeEmptySQLEdit, [Self.Name+'.'+Q.Name]);
  try
    DoPrepareUIBQuery(Q);//.Prepare;
    for i:=0 to Q.Params.FieldCount-1 do
    begin

      S:=Q.Params.FieldName[i];
      S1:=AnsiUpperCase(Copy(S, 1, Length(parPrefixNew)));

      FOldRec:=S1 = parPrefixOLD;

      if (S1 = parPrefixNew) or (S1 = parPrefixOLD) then
        System.Delete(S, 1, Length(parPrefixNew));

      F:=FindField(S);
      if F<>nil then
      begin
        if F.IsNull then
          Q.Params.IsNull[i]:=true
        else
        case F.DataType of
          ftFloat:Q.Params.AsDouble[i]:=F.AsFloat;
          ftFixedChar:Q.Params.AsString[i]:=F.AsString;
          ftString:Q.Params.AsString[i]:=F.AsString;
{$IFDEF FPC}
          ftWideString:Q.Params.AsUnicodeString[i]:=F.AsWideString;
{$ELSE}
          ftWideString:Q.Params.AsUnicodeString[i]:=(F as TWideStringField).Value;
{$ENDIF}
          ftSmallint:Q.Params.AsSmallint[i]:=F.AsInteger;
          ftInteger:{if FOldRec then
                       Q.Params.AsInteger[i]:=F.OldValue
                    else}
                       Q.Params.AsInteger[i]:=F.AsInteger;
          ftDate,
          ftDateTime, ftTime:
          begin
            Q.Params.AsDateTime[i]:=F.AsDateTime;
          end;
          ftBoolean:Q.Params.AsBoolean[i]:=F.AsBoolean;
          ftBlob,
          ftMemo:begin
                   if GetFieldData(F, @BLOBRec) then
                   begin
                      if assigned(BLOBRec.Cache) and ((BLOBRec.Cache.Modified) or (Transaction <> UpdateTransaction)) then
                      begin
                        BLOBRec.Cache.FState:=csModified;
                        BLOBRec.Cache.Flush;
                        BLOBRec.IscQuad :=BLOBRec.Cache.Isc;
                        SetBLOBCache(F, @BLOBRec);
                      end;
                      Q.Params.AsQuad[i] := BLOBRec.IscQuad;
                   end;
                 end;
          ftLargeint:Q.Params.AsInt64[i]:=F.AsLargeInt;
        end;
      end
      else
      begin
        if poFillEmptyEPFromParams in FOption then
        begin
          FillEmptyEPFromSelectPar(Q, S);
        end
      end;
    end;
    Q.Execute;
    ReleaseOldBuffer(SourceRec^);
  except
    on E:Exception do
      FBUIBError(E, Name +'.'+Q.Name);
      //FBError(fbeErrorExecuteQ, [Name, Q.Name, E.Message]);
  end;
  Q.Close;
end;

function TFBCustomDataSet.IsVisible(Buffer: PChar): Boolean;
var
  SaveState: TDataSetState;
begin
  if not (State = dsOldValue) then
  begin
    Result:=true;
    if Filtered and Assigned(OnFilterRecord) then
    begin
      SaveState := SetTempState(dsFilter);
      FFilterBuffer := Buffer;
      OnFilterRecord(Self, Result);
      RestoreState(SaveState);
    end;
    if Result then
      Result := PRecordBuffer(Buffer)^.CachedUpdateStatus in
          FUpdateRecordTypes;
  end
  else
    Result := True;
end;

procedure TFBCustomDataSet.Loaded;
begin
  inherited Loaded;
  GetMacros; {!! trying this way}
end;

function TFBCustomDataSet.GetFieldClass(FieldType: TFieldType): TFieldClass;
begin
  case FieldType of
    ftMemo :     Result := TFBAnsiMemoField;
    {$IFDEF FPC}
    ftBLOB :     Result := TFBBlobField;
    {$ENDIF}
    ftString :   Result := TFBAnsiField;
    ftLargeint : Result := TFBLargeintField;
  else
    Result := inherited GetFieldClass(FieldType);
  end;
end;

function TFBCustomDataSet.MacroByName(const AValue: string): TFBParam;
begin
  Result := FMacros.ParamByName(AValue);
end;

procedure TFBCustomDataSet.MasterUpdate(MasterUpdateStatus:TMasterUpdateStatus);
begin
  if (State  in [dsEdit, dsInsert]) then
  begin
    case FMasterScrollBehavior of
      msbCancel:Cancel;
      msbPost:Post;
    else
      exit;
    end;
  end;
  
  if (MasterUpdateStatus=muFieldChange) and Active then
    CloseOpen(false)
  else
  if (MasterUpdateStatus=muClose) and Active and not (dcIgnoreMasterClose in DetailConditions) then
    Close
  else
  if (MasterUpdateStatus=muOpen) and (dcForceOpen in DetailConditions) and not Active then
    Open;
end;

procedure TFBCustomDataSet.PatternChanged(Sender: TObject);
begin
  if (csLoading in ComponentState) then
  begin
    FStreamPatternChanged := True;
    Exit;
  end;
  Close;
  RecreateMacros;
  FPatternChanged := True;
  try
    ExpandMacros;
  finally
    FPatternChanged := False;
  end;
end;

procedure TFBCustomDataSet.QueryChanged(Sender: TObject);
begin
  FSaveQueryChanged(Sender);
  if not FDisconnectExpected then
  begin
    FSQLPattern := FQuerySelect.SQL;
  end;
end;

procedure TFBCustomDataSet.RecreateMacros;
var
  List: TFBParams;
begin
  if not (csReading in ComponentState) then
  begin
    List := TFBParams.Create(Self);
    try
      CreateMacros(List, PChar(FSQLPattern.Text));
      List.AssignValues(FMacros);
      FMacros.Clear;
      FMacros.Assign(List);
    finally
      List.Free;
    end;
  end
  else
  begin
    FMacros.Clear;
    CreateMacros(FMacros, PChar(FSQLPattern.Text));
  end;
end;

procedure TFBCustomDataSet.SetAllowedUpdateKinds(
  const AValue: TUpdateKinds);
begin
  FAllowedUpdateKinds := AValue;
end;

procedure TFBCustomDataSet.SetAutoCommit(const AValue: boolean);
begin
  FAutoCommit := AValue;
end;

procedure TFBCustomDataSet.SetAutoUpdateOptions(
  const AValue: TAutoUpdateOptions);
begin
  FAutoUpdateOptions.Assign(AValue);
end;

procedure TFBCustomDataSet.SetCachedUpdates(const AValue: Boolean);
begin
  if not AValue and FCachedUpdates and Active then
    CancelUpdates;
  FCachedUpdates := AValue;
end;

procedure TFBCustomDataSet.SetDataBase(const AValue: TUIBDataBase);
begin
  if FDataBase <> AValue then
  begin
    FDataBase := AValue;
    FQuerySelect.Close;
    FQueryRefresh.Close;
    FQueryEdit.Close;
    FQueryDelete.Close;

    if not (csLoading in ComponentState) then
    begin
      if (not Assigned(FQuerySelect.Transaction)) or (FQuerySelect.Transaction.DataBase<>AValue) then
      begin
        FQuerySelect.Transaction:=nil;
        FQueryRefresh.Transaction:=nil;
      end;

      if (not Assigned(FQueryEdit.Transaction)) or (FQueryEdit.Transaction.DataBase<>AValue) then
      begin
        FQueryEdit.Transaction:=nil;
        FQueryDelete.Transaction:=nil;
        FQueryInsert.Transaction:=nil;
      end;
    end;

    FQuerySelect.DataBase:=AValue;
    FQueryRefresh.DataBase:=AValue;
    FQueryEdit.DataBase:=AValue;
    FQueryDelete.DataBase:=AValue;
    FQueryInsert.DataBase:=AValue;
  end;
end;

procedure TFBCustomDataSet.SetDataSource(AValue: TDataSource);
begin
  if IsLinkedTo(AValue) then
    FBError(fbeCircularReference, [Name])
  else
  if Assigned(FMasterFBDataLink) then
    FMasterFBDataLink.DataSource:=AValue;
end;

procedure TFBCustomDataSet.SetDetailConditions(
  const AValue: TDetailConditions);
begin
  FDetailConditions := AValue;
end;

procedure TFBCustomDataSet.SetBLOBCache(Field: TField; Buffer: PBLOBFieldData);
var
  SaveState : tDataSetState;
  SaveModified : boolean;
  Rec : PRecordBuffer;
begin
  Rec := PRecordBuffer(GetActiveBuf);
  SetFieldData2Record(Field,Buffer,Rec);
end;

procedure TFBCustomDataSet.SetFieldData2Record(Field: TField; Buffer: Pointer;const RecBuf : PRecordBuffer);
var
  FSize:integer;
  Ptr:PByte;
  FNull:PBoolean;
  FieldHeader:TFieldHeader;
  HeaderNo : FieldHeaderIndex;
  BLOBRecord : PBLOBRecordData;
  BLOBField  : PBLOBFieldData;
  BLOBCacheIdx: byte;
begin
  if RecBuf <> nil then
  begin
    HeaderNo := HeaderId(Field);
    if Field.FieldNo >= 0 then
      Field.Validate(Buffer);
    FieldHeader:=FFiledsHeader[HeaderNo];
    FNull := @(PBooleans(GetRecordNulls(Self, RecBuf))^[HeaderNo]);
    Ptr := @(RecBuf^.Data[FieldHeader.FieldOffs]);
    if FieldHeader.FieldSize<>0 then
        FSize:=FieldHeader.FieldSize
    else
        FSize:=Field.DataSize;

    if (Buffer=nil)
       {or ((Field.DataType in [ftString]) and (PChar(Buffer)[0] = #0))}
    then begin
      FNull^:=true;
      if (Field.DataType in [ftBlob, ftMemo]) then
      begin
        if  PBLOBRecordData(Ptr)^.ListIdx <> 0 then
        begin
           RecBuf^.BlobList.SetItem(PBLOBRecordData(Ptr)^.ListIdx ,nil);
        end;
      end
      else if (FieldHeader.FieldType = ftString) then
        PAnsiString(Ptr)^ := ''
      else if (FieldHeader.FieldType = ftWideString) then
        PWideString(Ptr)^ := ''
    end
    else
    begin
      FNull^:=false;
      if not (FieldHeader.FieldType in [ftString, ftWideString, ftBlob, ftMemo]) then
        Move(Buffer^, Ptr^, FSize)
      else if FieldHeader.FieldType = ftString then
        PAnsiString(Ptr)^ := PAnsiString(Buffer)^
      else if FieldHeader.FieldType = ftWideString then
        PWideString(Ptr)^ := PWideString(Buffer)^
      else begin
        BLOBRecord := PBLOBRecordData(Ptr);
        BLOBField := PBLOBFieldData(Buffer);
        BLOBRecord^.IscQuad := BLOBField^.IscQuad;
        BLOBCacheIdx := BLOBRecord^.ListIdx;
        if BLOBCacheIdx <> 0 then
        begin
          if assigned(PBLOBFieldData(Buffer)^.Cache) then
            RecBuf^.BlobList.SetItem(BLOBCacheIdx, BLOBField^.Cache)
          else
            RecBuf^.BlobList.SetItem(BLOBCacheIdx,
                                    TFBBlobStream(RecBuf^.BlobList.Item(BLOBCacheIdx)).ChangeOrNil(BLOBField^.ISCQuad)
            );
        end
        else
        if assigned(PBLOBFieldData(Buffer)^.Cache) then
        begin
          PBLOBRecordData(Ptr)^.ListIdx := RecBuf^.BlobList.Add(PBLOBFieldData(Buffer)^.Cache);
        end;
      end;
    end;
  end;{if assigned(rec)}
end;

procedure TFBCustomDataSet.SetFieldData(Field: TField; Buffer: Pointer);
var
  Rec : PRecordBuffer;
begin
  Rec := PRecordBuffer(GetActiveBuf);
  if assigned(rec) then begin
    SetFieldData2Record(Field, Buffer, Rec);
    if not ((State in [dsCalcFields, dsFilter, dsNewValue]) or IsInspecting)
    then begin
        DataEvent(deFieldChange, PtrInt(Field));
    end;
  end;
end;{SetFieldData}

procedure TFBCustomDataSet.SetFieldData2Record(Field: TField; const Data : AnsiString; const RecBuf : PRecordBuffer);
var
  Ptr:PByte;
  FNull:PBoolean;
  FieldHeader:TFieldHeader;
  HeaderNo : FieldHeaderIndex;
begin
  if RecBuf <> nil then
  begin
    HeaderNo := HeaderId(Field);
    if Field.FieldNo >= 0 then
      Field.Validate(@Data);
    FieldHeader:=FFiledsHeader[HeaderNo];
    FNull := @(PBooleans(GetRecordNulls(Self, RecBuf))^[HeaderNo]);
    Ptr := @(RecBuf^.Data[FieldHeader.FieldOffs]);

    FNull^:=false;
{$IFDEF USE_SAFE_CODE}
    if FieldHeader.FieldType <> ftString then
      raise Exception.Create(Format(EWrongAnsiFieldAccessMsg, [Field.Name, Self.Name]));
{$ENDIF}
    PAnsiString(Ptr)^ := Data;
  end;{if assigned(rec)}
end;

procedure TFBCustomDataSet.SetFieldData(Field: TField; const Data : AnsiString);
var
  Rec : PRecordBuffer;
begin
  Rec := PRecordBuffer(GetActiveBuf);
  if assigned(rec) then
  begin
    SetFieldData2Record(Field, Data, Rec);
    if not ((State in [dsCalcFields, dsFilter, dsNewValue]) or IsInspecting)  then
    begin
        DataEvent(deFieldChange, PtrInt(Field));
    end;
  end;
end;{SetFieldData}

procedure TFBCustomDataSet.SetFieldsFromParams;
var
  i:integer;
  FMaster,FSelf:TField;
begin
  if Assigned(FMasterFBDataLink.DataSource) and Assigned(FMasterFBDataLink.DataSource.DataSet) then
  for i:=0 to FQuerySelect.Params.ParamCount-1 do
  begin
     FMaster:=FMasterFBDataLink.DataSource.DataSet.FindField(FQuerySelect.Params.FieldName[i]);
    FSelf:=FindField(FQuerySelect.Params.FieldName[i]);
    if Assigned(FMaster) and Assigned(FSelf) then
      FSelf.Assign(FMaster);
    DataEvent(deLayoutChange, FCurrentRecord);
  end;
end;

procedure TFBCustomDataSet.SetFiltered(Value: Boolean);
begin
  inherited SetFiltered(Value);
  if Active then
    First;
end;

procedure TFBCustomDataSet.SetMacroChar(const AValue: Char);
begin
  if AValue <> FMacroChar then
  begin
    FMacroChar := AValue;
    RecreateMacros;
  end;
end;

procedure TFBCustomDataSet.SetMacros(const AValue: TFBParams);
begin
  FMacros.AssignValues(AValue);
end;

procedure TFBCustomDataSet.SetOption(const AValue: TFBDsOptions);
begin
  FOption := AValue;
end;

procedure TFBCustomDataSet.SetSQLDelete(const AValue: TStrings);
begin
  FQueryDelete.SQL:=AValue;
end;

procedure TFBCustomDataSet.SetSQLEdit(const AValue: TStrings);
begin
  FQueryEdit.SQL:=AValue;
end;

procedure TFBCustomDataSet.SetSQLInsert(const AValue: TStrings);
begin
  FQueryInsert.SQL:=AValue;
end;

procedure TFBCustomDataSet.SetSQLRefresh(const AValue: TStrings);
begin
  FQueryRefresh.SQL:=AValue;
end;

procedure TFBCustomDataSet.SetSQLSelect(const AValue: TStrings);
begin
  Active:=false;
  TStringList(FSQLPattern).OnChange := nil;
  FSQLPattern.Assign(AValue);
  TStringList(FSQLPattern).OnChange := PatternChanged;
  PatternChanged(nil);
end;

procedure TFBCustomDataSet.SetTransaction(const AValue: TUIBTransaction);
begin
  if FQuerySelect.Transaction <> AValue then
  begin
    FQuerySelect.Close;
    FQueryRefresh.Close;
    if FQueryEdit.Transaction = FQuerySelect.Transaction then
    begin
      FQueryEdit.Close;
      FQueryDelete.Close;
      FQueryInsert.Close;
      FQueryEdit.Transaction:=AValue;
      FQueryDelete.Transaction:=AValue;
      FQueryInsert.Transaction:=AValue;
    end;
    FQuerySelect.Transaction:=AValue;
    FQueryRefresh.Transaction:=AValue;
  end;
end;

procedure TFBCustomDataSet.SetUpdateTransaction(
  const AValue: TUIBTransaction);
begin
  QueryInsert.Transaction:=AValue;
  QueryEdit.Transaction:=AValue;
  QueryDelete.Transaction:=AValue;
end;

procedure TFBCustomDataSet.SortOnField(FieldName: string; Asc: boolean);
begin
  //Metod for local sorting
  DisableControls;
  try
    FetchAll;
    FRecordsBuffer.SortOnField(HeaderId(FieldByName(FieldName)), Asc);
  finally
    Resync([]);
    EnableControls;
  end;
end;

procedure TFBCustomDataSet.SortOnFields(FieldNames: string;
  Asc: array of boolean);
var
  SortArray:TFBInternalSortArray;
  CntEl, C:integer;
  S:string;
begin
  FieldNames:=Trim(FieldNames);
  if FieldNames = '' then exit;
  CntEl:=0;
  FillChar(SortArray, SizeOf(TFBInternalSortArray), 0);

  C:=Pos(';', FieldNames);
  while (C>0) and (CntEl < MaxSortField-1) do
  begin
    S:=Copy(FieldNames, 1, C-1);
    System.Delete(FieldNames, 1, C);
    SortArray[CntEl].FieldNo:=FieldByName(S).FieldNo-1;
    if High(Asc)>=CntEl then
      SortArray[CntEl].Asc:=Asc[CntEl]
    else
      SortArray[CntEl].Asc:=true;
    Inc(CntEl);
    C:=Pos(';', FieldNames);
  end;

  if (FieldNames<>'') and (CntEl < MaxSortField-1) then
  begin
    SortArray[CntEl].FieldNo:=FieldByName(FieldNames).FieldNo-1;
    if High(Asc)>=CntEl then
      SortArray[CntEl].Asc:=Asc[CntEl]
    else
      SortArray[CntEl].Asc:=true;
    Inc(CntEl);
  end;
  
  if CntEl = 0 then exit;
  //Metod for local sorting
  DisableControls;
  try
    FetchAll;
    FRecordsBuffer.SortOnFields(SortArray, CntEl);
  finally
    Resync([]);
    EnableControls;
  end;
end;


function TFBCustomDataSet.StoreUpdateTransaction: boolean;
begin
  Result:=QuerySelect.Transaction<>QueryEdit.Transaction;
end;

procedure TFBCustomDataSet.UpdateCommit;
begin
  if FAutoCommit and (UpdateTransaction<>nil) then
    if UpdateTransaction<>Transaction then
      UpdateTransaction.Commit
    else
      UpdateTransaction.CommitRetaining;
end;

procedure TFBCustomDataSet.UpdateStart;
begin
  if UpdateTransaction<>nil then
    if not UpdateTransaction.InTransaction then
      UpdateTransaction.StartTransaction;
end;

procedure TFBCustomDataSet.SetDefaultFormats(const AValue: TDefaultFormats);
begin
  FDefaultFormats.Assign(AValue);
end;

procedure TFBCustomDataSet.UpdateFieldsFormat;
var
  i:integer;
begin
  for i:=0 to Fields.Count-1 do
  begin
    case Fields[i].DataType of
      ftDateTime:if ((Fields[i] as TDateTimeField).DisplayFormat = '') then
                    (Fields[i] as TDateTimeField).DisplayFormat:=DefaultFormats.DisplayFormatDateTime;
      ftDate:if ((Fields[i] as TDateTimeField).DisplayFormat = '') then
                    (Fields[i] as TDateTimeField).DisplayFormat:=DefaultFormats.DisplayFormatDate;
      ftTime:if ((Fields[i] as TDateTimeField).DisplayFormat = '') then
                    (Fields[i] as TDateTimeField).DisplayFormat:=DefaultFormats.DisplayFormatTime;
      ftFloat:begin
                if ((Fields[i] as TNumericField).DisplayFormat = '') then
                    (Fields[i] as TNumericField).DisplayFormat:=DefaultFormats.DisplayFormatNumeric;
                if ((Fields[i] as TNumericField).EditFormat = '') then
                    (Fields[i] as TNumericField).EditFormat:=DefaultFormats.EditFormatNumeric;
              end;
      ftInteger,
      ftLargeint
             :begin
                if ((Fields[i] as TNumericField).DisplayFormat = '') then
                    (Fields[i] as TNumericField).DisplayFormat:=DefaultFormats.DisplayFormatInteger;
                if ((Fields[i] as TNumericField).EditFormat = '') then
                    (Fields[i] as TNumericField).EditFormat:=DefaultFormats.EditFormatInteger;
              end;
    end;
  end;
end;

procedure TFBCustomDataSet.QuerySelectOnClose(Sender: TObject);
begin
  if FQuerySelect <> nil then
     FQuerySelect.OnClose:=nil;
  Active:=false;
end;

{(UTF8-RU-ansi) Заполним параметр в запросе Q: TJvUIBQuery значением соответсвующго параметра }
{из QuerySelect                                                                }
{Fill param value to query Q: TJvUIBQuery - get value from param whit sam name }
{from QuerySelect                                                              }
procedure TFBCustomDataSet.FillEmptyEPFromSelectPar(const Q: TUIBQuery;
  const ParName: string);
var
  Si, Qi:integer;

function DoFindParam(AQ:TUIBQuery; AParName:string):integer;
var
  i:integer;
begin
  AParName:=UpperCase(AParName);
  for i:=0 to AQ.Params.ParamCount-1 do
  begin
    if UpperCase(AQ.Params.FieldName[i]) = AParName then
    begin
      Result:=i;
      exit;
    end;
  end;
  Result:=-1;
end;

begin
  Si:=DoFindParam(FQuerySelect, ParName); //FQuerySelect.Params.GetFieldIndex(ParName);
  Qi:=DoFindParam(Q, ParName); //Q.Params.GetFieldIndex(ParName);
  if (Qi<0) or (Si<0) then exit;

  case FQuerySelect.Params.FieldType[Si] of
    uftNumeric,
    uftQuad,
    uftFloat,
    uftDoublePrecision :Q.Params.AsDouble[Qi]:=FQuerySelect.Params.AsDouble[Si];

    uftChar,
    uftVarchar,
    uftCstring         :Q.Params.AsString[Qi]:=FQuerySelect.Params.AsString[Si];

    uftSmallint,
    uftInteger         :Q.Params.AsInteger[Qi]:=FQuerySelect.Params.AsInteger[Si];

    uftTimestamp       :Q.Params.AsDateTime[Qi]:=FQuerySelect.Params.AsDateTime[Si];
    uftDate            :Q.Params.AsDate[Qi]:=FQuerySelect.Params.AsDate[Si];
    uftTime            :Q.Params.AsTime[Qi]:=FQuerySelect.Params.AsTime[Si];
    uftInt64           :Q.Params.AsInt64[Qi]:=FQuerySelect.Params.AsInt64[Si];
  end;
end;

function TFBCustomDataSet.DoPrepareUIBQuery(const Q: TUIBQuery): boolean;
begin
  Result:=false;
  try
    Q.Prepare;
    Result:=true;
  except
    on E:Exception do
    begin
      E.Message:=Format(EPrepareErrorMsg, [Name, Q.Name, sLineBreak, E.Message]);
      raise;
    end;
  end;
end;

function TFBCustomDataSet.Locate(const KeyFields: string;
  const KeyValues: Variant; Options: TLocateOptions): Boolean;
var
  O, N:integer;
begin
  o:=FCurrentRecord;
  Result := DataSetLocateThrough(Self, KeyFields, KeyValues, Options);
  if Result then
  begin
    N:=FCurrentRecord;
    FCurrentRecord:=O;
    DoBeforeScroll;
    FCurrentRecord:=N;
    DataEvent(deDataSetChange, 0);
    DoAfterScroll;
  end;
end;

procedure ClearValues(var Values : variant; maxcount : cardinal);
var
       Idx: cardinal;
begin
  if maxcount <= 1 then
    Values := NULL
  else for idx := 0 to maxcount do begin
      values[idx] := NULL;
  end;
end;

procedure TFBCustomDataSet.GetFieldValues(const ResultFields : array of TField; var Values : variant);
var
       Idx: cardinal;
begin
  if Length(ResultFields) = 1 then begin
    if assigned(ResultFields[0]) then
      Values := ResultFields[0].Value
    else
      Values := null;
  end
  else
    for idx := low(ResultFields) to high(ResultFields) do begin
      if assigned(ResultFields[idx]) then
        Values[idx] := ResultFields[idx].Value
      else
        Values[idx] := null;
    end;
end;

procedure TFBCustomDataSet.GetFieldValues(const ResultFields : string; var Values : variant);
var
  Fields : ArrayOfFields;
begin
  GetFieldList(Fields, ResultFields);
  GetFieldValues(Fields, Values);
  Fields := nil;
end;

procedure TFBCustomDataSet.GetFieldValues(Source : PRecordBuffer;
                                        const ResultFields : array of TField;
                                          var Values : variant);
var
  SaveInspector : PRecordBuffer;
begin
  if assigned(Source) then begin
    SaveInspector := FInspectRecord;
    FInspectRecord := Source;
    GetFieldValues(ResultFields, Values);
    FInspectRecord := SaveInspector;
  end
  else begin
      ClearValues(Values, high(ResultFields));
  end;
end;

procedure TFBCustomDataSet.GetFieldValues(Source : PRecordBuffer;
                                        const ResultFields : string;
                                          var Values : variant);
var
  SaveInspector : PRecordBuffer;
  Fields : ArrayOfFields;
begin
  GetFieldList(Fields, ResultFields);
  GetFieldValues(Source, Fields, Values);
  Fields := nil;
end;

function TFBCustomDataSet.CurRecordCachedUpdateStatus: TCachedUpdateStatus;
begin
  if Active and (FRecordCount > 0) then
    Result:=PRecordBuffer(GetActiveBuf)^.CachedUpdateStatus
  else
    Result:=cusUnmodified;
end;

procedure TFBCustomDataSet.SetFieldValues(const ValueFields : array of TField; const Values : variant);
var
       Idx: cardinal;
begin
  if Length(ValueFields) = 1 then begin
    if assigned(ValueFields[0]) then
      ValueFields[0].Value := Values;
  end
  else
    for idx := low(ValueFields) to high(ValueFields) do begin
      if assigned(ValueFields[idx]) then
        ValueFields[idx].Value := Values[idx];
    end;
end;

procedure TFBCustomDataSet.SetFieldValues(const ValueFields : string; const Values : variant);
var
  Fields : ArrayOfFields;
begin
  GetFieldList(Fields, ValueFields);
  SetFieldValues(Fields, Values);
end;

procedure TFBCustomDataSet.SetFieldValues(Target : PRecordBuffer; const ValueFields : array of TField; const Values : variant);
var
  SaveInspector : PRecordBuffer;
begin
  SaveInspector := FInspectRecord;
  FInspectRecord := Target;
  SetFieldValues(ValueFields, Values);
  FInspectRecord := SaveInspector;
end;

procedure TFBCustomDataSet.SetFieldValues(Target : PRecordBuffer; const ValueFields : string; const Values : variant);
var
  SaveInspector : PRecordBuffer;
begin
  SaveInspector := FInspectRecord;
  FInspectRecord := Target;
  SetFieldValues(ValueFields, Values);
  FInspectRecord := SaveInspector;
end;

function TFBCustomDataSet.Lookup(const KeyFields: string; const KeyValues: Variant;
  const ResultFields: array of TField): Variant;
var
  Index : TRecordsBufferIndex;
  Found : PRecordBuffer;
begin
  Index := LocalIndexes[KeyFields];
  Found := Index.LocateRec(KeyValues);
  GetFieldValues(Found, ResultFields, Result);
end;

function TFBCustomDataSet.UpdateStatus: TUpdateStatus;
begin
  if Active and (FRecordCount > 0) then
  begin
    case PRecordBuffer(GetActiveBuf)^.CachedUpdateStatus of
      cusModified:Result:=usModified;
      cusInserted:Result:=usInserted;
      cusDeleted:Result:=usDeleted;
    else
      Result:=usUnmodified;
       //cusUninserted
       //cusDeletedApplied
       //cusUnmodified
    end;
  end
  else
    Result:=usUnmodified;
end;

function TFBCustomDataSet.Lookup(const KeyFields: string; const KeyValues: Variant;
  const ResultFields: string): Variant;
var
  Index : TRecordsBufferIndex;
  Found : PRecordBuffer;
begin
  Index := LocalIndexes[KeyFields];
  Found := Index.LocateRec(KeyValues);
  GetFieldValues(Found, ResultFields, Result);
end;

function FieldInArray(Field: TField; Arr: array of const): boolean;
var
  i: integer;
  CI: boolean;
begin
  Result := False;
  for i := Low(Arr) to High(Arr) do
  begin
    with Arr[i] do
    begin
      case VType of
        vtInteger: Result := Field.Index = VInteger;
        vtPChar:
          Result :=
            AnsiUpperCase(Field.FieldName) = AnsiUpperCase(vPChar);
        vtAnsiString:
          Result :=AnsiUpperCase(Field.FieldName) = AnsiUpperCase(string(VAnsiString));
//            EquelNames(CI, Field.FieldName, string(VAnsiString));
      else
//        Result :=
      end
    end;
    if Result then
      exit;
  end;
end;

procedure TFBCustomDataSet.CloneRecord(SrcRecord: integer;
  IgnoreFields: array of const);
var
  i:integer;
begin
  if State <> dsInsert then
    Append;
  for i := 0 to FieldCount - 1 do
  begin
    if (Fields[i].FieldKind in [fkData]) and (not Fields[i].IsBlob)
      and (not FieldInArray(Fields[i], IgnoreFields)) then
    begin
      Fields[i].Value := GetAnyRecField(SrcRecord - 1, Fields[i]);
    end;
  end;
end;

procedure TFBCustomDataSet.CloneCurRecord(IgnoreFields: array of const);
begin
  CloneRecord(RecNo, IgnoreFields);
end;

function TFBCustomDataSet.BlobCacheMaintain(Field: TField; Mode: TBlobStreamMode;
  var BLOBRec : TBLOBFieldData) : boolean;
var
  BlobIsNull : boolean;
begin
  BlobIsNull := not GetFieldData(Field, @BLOBRec);
  Result := false;
  if ((Mode = bmWrite) and (BLOBIsNull or not assigned(BLOBrec.Cache) or not BLOBrec.Cache.Alone))
    or ((Mode = bmRead) and (Not BlobIsNull and not assigned(BLOBrec.Cache)))
    or ((Mode = bmReadWrite) and (BlobIsNull or not assigned(BLOBrec.Cache))) then
  begin
    if (Field.DataType = ftMemo) or (Field.DataType = ftFmtMemo) then
      BLOBrec.Cache := TFBAnsiMemoStream.Create(Self, BLOBrec.IscQuad)
    else
      BLOBrec.Cache := TFBBlobStream.Create(Self, BLOBrec.IscQuad);
    SetBLOBCache(field,@BLOBRec);
    BlobIsNull := false;
  end
  else
  if ((Mode = bmReadWrite) and (Not BlobIsNull and assigned(BLOBrec.Cache) and not BLOBrec.Cache.Alone)) then
  begin
    BLOBrec.Cache := BLOBrec.Cache.Clone;
    SetBLOBCache(field,@BLOBRec);
    BlobIsNull := false;
  end;
  Result := (not BlobIsNull) and assigned(BLOBrec.Cache);
end;

function TFBCustomDataSet.CreateBlobStream(Field: TField;
  Mode: TBlobStreamMode): TStream;
var
  BLOBRec : TBLOBFieldData;
begin
  if BlobCacheMaintain(Field, Mode, BLOBRec) then
    Result := TBlobWrapStream.Create(Field, BLOBRec.Cache, Mode)
  else
    Result := TNullBlobWrapStream.Create;
end;

function TFBCustomDataSet.GetMemo(Field: TField) : AnsiString;
var
  BLOBRec : TBLOBFieldData;
begin
  if BlobCacheMaintain(Field, bmRead, BLOBRec) then
    Result := BLOBRec.Cache.AnsiText
  else
    Result := '';
end;

procedure TFBCustomDataSet.SetMemo(Field: TField; Value: AnsiString);
var
  BLOBRec : TBLOBFieldData;
begin
  if BlobCacheMaintain(Field, bmWrite, BLOBRec) then
    BLOBRec.Cache.AnsiText := Value;
end;

procedure TFBCustomDataSet.InternalGotoBookmark(ABookmark: Pointer);
var
  ReqBookmark: Integer;
  Buffer: PChar;
begin
  ReqBookmark := PInteger (ABookmark)^;
  Buffer:=nil;
  if (ReqBookmark >= 0) and (ReqBookmark < InternalRecordCount) then
    FCurrentRecord := ReqBookmark
  else
  if ReqBookmark >= 0 then
  begin
    while FCurrentRecord < ReqBookmark do
    begin
      if GetRecord(Buffer, gmNext, false) <> grOk then
        break;
    end;
  end
  else
    raise EMdDataSetError.Create ('Bookmark ' +
      IntToStr (ReqBookmark) + ' not found');
end;

function TFBCustomDataSet.IsEmptyEx: Boolean;
begin
  IsEmptyEx:=(FRecordCount<=0){ or ((BofCrack<0) and (EofCrack))};
end;

function TFBCustomDataSet.BookmarkValid(ABookmark: TBookmark): Boolean;
begin
  Result := False;
  if Assigned(ABookmark) then
    Result := (PMyDBInfo(ABookmark)^.Bookmark>=0) and (PMyDBInfo(ABookmark)^.Bookmark<FRecordsBuffer.Count);
end;

{************************ FBDataSet Index interface******************************}
      {same as GetLocalIndex but return nil if not found}
function TFBCustomDataSet.FindLocalIndex(const NameOrDef : string) : TRecordsBufferIndex;
var
  idx : integer;
begin
  idx := FLocalIndexes.IndexOf(NameOrDef);
  if idx >= 0 then
    result := TRecordsBufferIndex(FLocalIndexes.Objects[idx])
  else begin
    result := nil;
  end;
end;
      {rise exception EIndexNotFound if not found}
function TFBCustomDataSet.GetLocalIndex(const NameOrDef : string) : TRecordsBufferIndex;
begin
  result :=  FindLocalIndex(NameOrDef);
  if not assigned(result) then begin
    result := NewLocalIndex(NameOrDef);
    if not assigned(result) then
      raise EIndexNotFound.Create(format(EIndexNotFoundMsg,[NameOrDef]));
  end;
end;

function TFBCustomDataSet.NewLocalIndex(const NameOrDef : string) : TRecordsBufferIndex;
begin
  result := TUniversalRBIndex.Create(NameOrDef,Self);
  FLocalIndexes.AddObject(result.Definition,result);
  if Result.Name <> '' then
    FLocalIndexes.AddObject(result.Name,result);
end;

procedure TFBCustomDataSet.FreeLocalIndex(const NameOrDef : string; const Value : TRecordsBufferIndex);
var
  idx : integer;
  tmp : TRecordsBufferIndex;
begin
  if not assigned(Value) then begin
    idx := FLocalIndexes.IndexOf(NameOrDef);
    if idx >= 0 then begin
      tmp := TRecordsBufferIndex(FLocalIndexes.Objects[idx]);
      repeat
        FLocalIndexes.Delete(idx);
        idx := FLocalIndexes.IndexOfObject(tmp);
      until idx < 0;
      tmp.Destroy;
    end;
  end;
end;

procedure TFBCustomDataSet.FreeLocalIndexes;
var
  idx : integer;
  tmp : TRecordsBufferIndex;
begin
  while FLocalIndexes.Count > 0 do begin
      idx := 0;
      tmp := TRecordsBufferIndex(FLocalIndexes.Objects[0]);
      repeat
        FLocalIndexes.Delete(idx);
        idx := FLocalIndexes.IndexOfObject(tmp);
      until idx < 0;
      tmp.Destroy;
  end;
end;

{ TRecordsBuffer }

procedure TRecordsBuffer.Clear;
var
  i:integer;
  Buffer : PChar;
begin
  for i:=0 to Count-1 do
  begin
    Buffer := PChar(Items[I]);
    FOwner.FreeRecordBuffer(Buffer);
    Items[I] := Buffer;
  end;
  inherited Clear;
  inc(ModifyStamp);
end;

function TRecordsBuffer.CompareField(Item1, Item2: PRecordBuffer; FieldNo: integer; Asc:Boolean
  ): integer;
var
  Fi1Int:PInteger absolute Item1;
  Fi2Int:PInteger absolute Item2;
  Fi1Int64:PInt64 absolute Item1;
  Fi2Int64:PInt64 absolute Item2;
  Fi1SInt:PSmallInt absolute Item1;
  Fi2SInt:PSmallInt absolute Item2;
  Fi1Card:PCardinal absolute Item1;
  Fi2Card:PCardinal absolute Item2;
  Fi1D:PDouble absolute Item1;
  Fi2D:PDouble absolute Item2;
  Fi1Bool:PInteger absolute Item1;
  Fi2Bool:PInteger absolute Item2;
  S1,S2:string;
  Nulls1 : PBooleans;
  Nulls2 : PBooleans;
begin

  Nulls1 := GetRecordNulls(FOwner, Item1);
  Nulls2 := GetRecordNulls(FOwner, Item2);
  if Nulls1^[FieldNo] and Nulls2^[FieldNo] then
  begin
    Result:=0;
    exit;
  end
  else
  if Nulls1^[FieldNo] then
  begin
    if Asc then
      Result:=-1
    else
      Result:=1;
    exit;
  end
  else
  if Nulls2^[FieldNo] then
  begin
    if Asc then
      Result:=1
    else
      Result:=-1;
    exit;
  end;

  Item1:=@(Item1^.Data[FOwner.FFiledsHeader[FieldNo].FieldOffs]);
  Item2:=@(Item2^.Data[FOwner.FFiledsHeader[FieldNo].FieldOffs]);

  case FOwner.FFiledsHeader[FieldNo].FieldType of
    ftDate,
    ftInteger:Result:=Sign(Fi1Int^-Fi2Int^);
    ftLargeint:Result:=Sign(Fi1Int64^-Fi2Int64^);
    ftDateTime,
    ftFloat:Result:=Sign(Fi1D^ - Fi2D^);
    ftString: begin
      Result:=CompareText(PAnsiString(Item1)^, PAnsiString(Item2)^);
    end;
    ftFixedChar:
      begin
        SetLength(S1, FOwner.FFiledsHeader[FieldNo].FieldSize);
        SetLength(S2, FOwner.FFiledsHeader[FieldNo].FieldSize);
        System.Move(Item1^, S1[1], FOwner.FFiledsHeader[FieldNo].FieldSize);
        System.Move(Item2^, S2[1], FOwner.FFiledsHeader[FieldNo].FieldSize);
        S1:=Trim(s1);
        S2:=Trim(s2);
        Result:=CompareText(S1, S2);
      end;
    ftSmallint:Result:=Sign(Fi1SInt^ - Fi2SInt^);
    ftTime:
      begin
        if Fi1Card^ > Fi2Card^ then Result:=1
        else
        if Fi1Card^ < Fi2Card^ then Result:=-1
        else Result:=0;
      end;
    ftBoolean:
      begin
        if Fi1Bool^ > Fi1Bool^ then Result:=1
        else
        if Fi1Bool^ < Fi1Bool^ then Result:=-1
        else Result:=0;
      end;
  else
    Result:=0;
  end;
  if not Asc then Result:= - Result;
end;

procedure TRecordsBuffer.SetUpdStatusFlag(Item: PRecordBuffer;
  Status: TCachedUpdateStatus);
var
  P:PRecordBuffer;
begin
  if Assigned(Item) then
  begin
    P:=FindBufferByBookmark(Item.Bookmark);
    if Assigned(P) then
      P^.CachedUpdateStatus:=Status;
  end;
end;

function TRecordsBuffer.FindBufferByBookmark(ABookmark: Integer
  ): PRecordBuffer;
var
  i:integer;
begin
  Result:=nil;
  for I:=0 to Count - 1 do
    if PRecordBuffer(List^[i])^.Bookmark = ABookmark then
    begin
      Result:=PRecordBuffer(List^[i]);
      exit;
    end;
end;

constructor TRecordsBuffer.Create(AOwner: TFBCustomDataSet);
begin
  inherited Create;
  FOwner:=AOwner;
end;

procedure TRecordsBuffer.DeleteRecord(RecNo: integer);
var
  i:integer;
  Buffer : PChar;
begin
  Buffer := PChar(Items[RecNo]);
  FOwner.FreeRecordBuffer(Buffer);
  Delete(RecNo);
  inc(ModifyStamp);
  for i:=0 to Count-1 do
    with PRecordBuffer(List^[i])^ do
      Bookmark:=i;
end;

procedure TRecordsBuffer.EditRecord(RecNo:integer; NewBuffer : PRecordBuffer);
begin
  if not assigned(NewBuffer^.OldBuffer) then
  begin
    AssignOldBuffer(FOwner, NewBuffer^, Items[RecNo]);
  end;
end;

destructor TRecordsBuffer.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TRecordsBuffer.ReadRecordFromQuery(RecNo:integer; Sourse:TUIBQuery);
var
  i:integer;
  P : PRecordBuffer;
  FiPtr:Pointer;
  FieldHeader:TFieldHeader;
  Nulls : PBooleans;
  S:string;
  Ansi  :AnsiString;
  Wide  : WideString;
begin
  P := PRecordBuffer(FOwner.AllocRecordBuffer);
  {FOwner.InternalInitRecord(P);}
  Add(P);
  Nulls := GetRecordNulls(FOwner, P);
  with P^ do begin
    Bookmark:=RecNo;
    BookmarkFlag:=bfCurrent;
  end;
  for i := 0 to Sourse.Fields.FieldCount - 1 do
  begin
    FieldHeader:=FOwner.FFiledsHeader[i];
    if Sourse.Fields.IsNull[i] then
    begin
      Nulls^[i]:=true;
    end
    else
    begin
      Nulls^[i]:=false;
      FiPtr:=@(P^.Data[FieldHeader.FieldOffs]);
      case FieldHeader.FieldType of
        ftBCD,
        ftFloat:PDouble(FiPtr)^:=Sourse.Fields.AsDouble[i]; //Расширить !!!
        ftFixedChar:begin
                   S:=Sourse.Fields.AsString[i];
                   if poTrimCharFields in FOwner.FOption then S:=TrimRight(S);
                   System.Move(S[1], FiPtr^, Min(FieldHeader.FieldSize, Length(S)));
                 end;
        ftString:begin
{            Ansi:=Sourse.Fields.AsString[i];
            if poTrimCharFields in FOwner.FOption then
              Ansi:=TrimRight(Ansi);
            PAnsiString(FiPtr)^ := Ansi;}
                   PAnsiString(FiPtr)^:='';
                   if poTrimCharFields in FOwner.FOption then
                     Ansi:=TrimRight(Sourse.Fields.AsString[i])
                   else
                     Ansi:=Sourse.Fields.AsString[i];
                   PAnsiString(FiPtr)^ := Ansi;
                 end;
{        ftWideString:begin
            Wide:=Sourse.Fields.AsUnicodeString[i];
            if poTrimCharFields in FOwner.FOption then
              Wide:=TrimRight(Wide);
            PWideString(FiPtr)^ := Wide;
        end;}
        ftSmallint:PSmallInt(FiPtr)^:=Sourse.Fields.AsSmallint[i];
        ftInteger:PInteger(FiPtr)^:=Sourse.Fields.AsInteger[i];
        ftDateTime:
          begin
            {.$IFDEF LINUX}
//            DecodeTimeStamp(PIscTimeStamp(Sourse.Fields.Data.sqlvar[i].sqldata),  Double(FiPtr^));
            {.$ELSE}
            DecodeTimeStamp(PIscTimeStamp(Sourse.Fields.Data.sqlvar[i].sqldata),  TTimeStamp(FiPtr^));
            Double(FiPtr^) := TimeStampToMSecs(TTimeStamp(FiPtr^));
            {.$ENDIF}
          end;
        ftDate:
          begin
            PInteger(FiPtr)^ := PInteger(Sourse.Fields.Data.sqlvar[i].sqldata)^ - DateOffset + 693594;
          end;
        ftTime:
          begin
            PInteger(FiPtr)^:=PCardinal(Sourse.Fields.Data.sqlvar[i].sqldata)^ div 10;
          end;
        ftBlob,
        ftMemo: with PBLOBRecordData(FiPtr)^ do begin
          ISCQuad:=Sourse.Fields.AsQuad[i];
          if ListIdx <> 0 then
            P^.BlobList.SetItem(
              ListIdx,
              TFBBlobStream(P^.BlobList.Item(ListIdx)).ChangeOrNil(ISCQuad)
            );
        end;
        ftLargeint:PInt64(FiPtr)^:=Sourse.Fields.AsInt64[i];
        ftBoolean:PBoolean(FiPtr)^:=Sourse.Fields.AsBoolean[i];
      else
      end
    end;
  end;
  FOwner.GetCalcFields(PChar(P));
  inc(ModifyStamp);
end;

procedure TRecordsBuffer.RefreshRecordFromQuery(RecNo: integer;
  Sourse: TUIBQuery);
var
  j,k, ii:integer;
  P : PRecordBuffer;
  FiPtr:Pointer;
  FieldHeader:TFieldHeader;
  S:string;
  Ansi  :AnsiString;
  Wide  : WideString;
  Nulls : PBooleans;
begin
  if RecNo < 0 then  exit;
  P := FOwner.FreshRecordBuffer(PRecordBuffer(Items[RecNo]));
  if (P <> PRecordBuffer(Items[RecNo])) then
    Items[RecNo] := P;
  Nulls := GetRecordNulls(FOwner, P);
  for j := 0 to FOwner.FFiledsHeader.Count-1 do
  begin
    FieldHeader:=FOwner.FFiledsHeader[j];
    K:=-1;
    for ii:=0 to Sourse.Fields.FieldCount-1 do
    begin
      if Sourse.Fields.AliasName[ii]=FieldHeader.FieldName then
      begin
        K:=ii;
        break;
      end
    end;
    if K<>-1 then
    begin
      if Sourse.Fields.IsNull[K] then
      begin
        Nulls^[j] :=true;
      end
      else
      begin
        Nulls^[j] :=false;
        FiPtr:=@(P^.Data[FieldHeader.FieldOffs]);
        case FieldHeader.FieldType of
          ftFloat,
          ftBCD:PDouble(FiPtr)^:=Sourse.Fields.AsDouble[k]; //Расширить !!!
          ftFixedChar:begin
                     S:=Sourse.Fields.AsString[k];
                     if poTrimCharFields in FOwner.FOption then
                       S:=TrimRight(S);
                     FillChar(FiPtr^, FieldHeader.FieldSize, 0);
                     System.Move(S[1], FiPtr^, Min(FieldHeader.FieldSize, Length(S)));
                   end;
          ftString:begin
            Ansi:=Sourse.Fields.AsString[k];
            if poTrimCharFields in FOwner.FOption then
              Ansi:=TrimRight(Ansi);
            PAnsiString(FiPtr)^ := Ansi;
          end;
          ftWideString:begin
            Wide:=Sourse.Fields.AsString[k];
            if poTrimCharFields in FOwner.FOption then
              Wide:=TrimRight(Wide);
            PWideString(FiPtr)^ := Wide;
          end;
          ftSmallint:PSmallInt(FiPtr)^:=Sourse.Fields.AsSmallint[k];
          ftInteger:PInteger(FiPtr)^:=Sourse.Fields.AsInteger[k];
          ftDateTime:
            begin
              {.$IFDEF  LINUX}
              //DecodeTimeStamp(PIscTimeStamp(Sourse.Fields.Data.sqlvar[k].sqldata),  Double(FiPtr^));
              {.$ELSE}
              DecodeTimeStamp(PIscTimeStamp(Sourse.Fields.Data.sqlvar[k].sqldata),  TTimeStamp(FiPtr^));
              Double(FiPtr^) := TimeStampToMSecs(TTimeStamp(FiPtr^));
              {.$ENDIF}
            end;
          ftDate:
            begin
              PInteger(FiPtr)^:=PInteger(Sourse.Fields.Data.sqlvar[k].sqldata)^ - DateOffset + 693594;
            end;
          ftTime:
            begin
              PInteger(FiPtr)^:=PCardinal(Sourse.Fields.Data.sqlvar[K].sqldata)^ div 10;
            end;


          ftBlob,
          ftMemo: with PBLOBRecordData(FiPtr)^ do begin
            ISCQuad:=Sourse.Fields.AsQuad[K];
            if  ListIdx <> 0 then
              P^.BlobList.SetItem(
                ListIdx,
                TFBBlobStream(P^.BlobList.Item(ListIdx)).ChangeOrNil(ISCQuad)
              );
          end;{ftBlob,ftMemo}
          ftLargeint:PInt64(FiPtr)^:=Sourse.Fields.AsInt64[k];
          ftBoolean:PBoolean(FiPtr)^:=Sourse.Fields.AsBoolean[k];
        else
        end{case FieldHeader.FieldType}
      end;{else if Sourse.Fields.IsNull[K]}
    end;{if K<>-1}
  end;
  FOwner.GetCalcFields(PChar(P));
  inc(ModifyStamp);
end;

procedure TRecordsBuffer.SaveFromBuffer(RecNo: integer; Buffer: PChar);
var
  Target : PRecordBuffer;
  NewCopy :PRecordBuffer;
begin
  FOwner.GetCalcFields(Buffer);
  Target := Items[RecNo];
  NewCopy := FOwner.CopyRecordBuffer(PRecordBuffer(Buffer), Target);
  if NewCopy <> Target then
    Items[Recno] := NewCopy;
  inc(ModifyStamp);
end;

procedure TRecordsBuffer.SaveFromBufferA(RecNo: integer; Buffer: PChar);
var
  P : PRecordBuffer;
begin
  FOwner.GetCalcFields(Buffer);
  P := FOwner.CopyRecordBuffer(PRecordBuffer(Buffer), nil);
  Add(P);
  inc(ModifyStamp);
  with P^ do
  begin
    References := 0;
    Bookmark:=RecNo;
    BookmarkFlag:=bfCurrent;
  end;
end;

procedure TRecordsBuffer.SaveFromBufferI(RecNo: integer; Buffer: PChar);
var
  P : PRecordBuffer;
  i:integer;
begin
  FOwner.GetCalcFields(Buffer);
  P := FOwner.CopyRecordBuffer(PRecordBuffer(Buffer), nil);
  Insert(RecNo, P);
  with P^ do
  begin
    References := 0;
    Bookmark:=RecNo;
    BookmarkFlag:=bfCurrent;
  end;
  inc(ModifyStamp);
  for i:=RecNo+1 to Count-1 do
    with PRecordBuffer(List^[i])^ do
      Bookmark:=i;
end;


procedure TRecordsBuffer.SaveToBuffer(RecNo: integer; Buffer: PChar);
var
  Source : PRecordBuffer;
  NewCopy :PRecordBuffer;
begin
  if Assigned(Buffer) and (count > 0) and (RecNo>-1) then
  begin
    Source := Items[RecNo];
    NewCopy := FOwner.CopyRecordBuffer(Source, PRecordBuffer(Buffer));
    if NewCopy <> PRecordBuffer(Buffer) then
       raise EReferencedObjLoose.Create(EReferencedDatSetRecordBufferLooseMsg);
  end;
end;

procedure TRecordsBuffer.SortOnField(FieldNo: integer; Asc: boolean);
procedure DoSort(L,R:Integer);
var
  I, J: Integer;
  P, T: Pointer;
begin
  repeat
    I := L;
    J := R;
    P := List^[(L + R) shr 1];
    repeat
      while CompareField(List^[I], P, FieldNo, Asc) < 0 do
        Inc(I);
      while CompareField(List^[J], P, FieldNo, Asc) > 0 do
        Dec(J);
      if I <= J then
      begin
        T := List^[I];
        List^[I] := List^[J];
        List^[J] := T;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then DoSort(L, J);
    L := I;
  until I >= R;
end;

var
  i:Cardinal;
begin
  if Count>0 then
  begin
    DoSort(0, Count - 1);
    for i:=0 to Count-1 do
      with  PRecordBuffer(List^[i])^ do
        Bookmark:=i;
  end
end;

procedure TRecordsBuffer.SortOnFields(const SortArray:TFBInternalSortArray;const CountEl:integer);

function DoCompare(Item1, Item2:Pointer):integer;
var
  i:integer;
begin
  Result:=0;
  for i:=0 to CountEl-1 do
  begin
    Result:=CompareField(Item1, Item2, SortArray[i].FieldNo, SortArray[i].Asc);
    if Result<>0 then exit;
  end;
end;

procedure DoSort(L,R:Integer);
var
  I, J: Integer;
  P, T: Pointer;
begin
  repeat
    I := L;
    J := R;
    P := List^[(L + R) shr 1];
    repeat
      while DoCompare(List^[I], P) < 0 do
        Inc(I);
      while DoCompare(List^[J], P) > 0 do
        Dec(J);
      if I <= J then
      begin
        T := List^[I];
        List^[I] := List^[J];
        List^[J] := T;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then DoSort(L, J);
    L := I;
  until I >= R;
end;

var
  i:Cardinal;
begin
  if Count>0 then
  begin
    DoSort(0, Count - 1);
    for i:=0 to Count-1 do
      with  PRecordBuffer(List^[i])^ do
        Bookmark:=i;
  end
end;

procedure TRecordsBuffer.SaveCache(const Dest : SaveCacheList);
var
  RecIdx    : integer;
  Header    : PFieldHeader;
  HeaderIdx : FieldHeaderIndex;
  Nulls : PBooleans;
  CurrRecord : PRecordBuffer;
  RecordFieldsMap : IntegersArray;
  Cell      : TBLOBCacheStream;
begin
    {build map of checked fields in record}
    SetLength(RecordFieldsMap, 0);
    for HeaderIdx := 0 to FOwner.FCachedFieldsCount-1 do begin
        Header := FOwner.FFiledsHeader.Items[HeaderIdx];
        AppendItem(RecordFieldsMap, Header.FieldOffs);
    end;

    {now scan records}
    for RecIdx := 0 to Count-1 do begin
      CurrRecord := Items[RecIdx];
      Nulls := GetRecordNulls(FOwner, CurrRecord);
      for HeaderIdx := 0 to FOwner.FCachedFieldsCount-1 do begin
        if not Nulls^[HeaderIdx] then
        with PBLOBRecordData(@(CurrRecord^.Data[RecordFieldsMap[HeaderIdx]]))^ do begin
            if ListIdx > 0 then begin
              Cell := TBLOBCacheStream(CurrRecord^.BlobList.Item(ListIdx));
              if not Cell.Modified then
                Dest.Add(Cell);
            end;
        end;
      end;
    end;

    SetLength(RecordFieldsMap, 0);
end;

procedure TRecordsBuffer.LoadCache(const Dest : SaveCacheList);
var
  RecIdx    : integer;
  Header    : PFieldHeader;
  HeaderIdx : FieldHeaderIndex;
  Nulls : PBooleans;
  CurrRecord : PRecordBuffer;
  RecordFieldsMap : IntegersArray;
  Cell      : TBLOBCacheStream;
begin
    {(UTF8-RU-ansi) тривиальный алгоритм поиска N записей в несортированом списке
      потребует ~ N*(N/2) операций,
      быстрая сортировка списка N элементов потребует ~ N*log2(N) операций и поск
      элемента в сортированом списке займет log2(N), в результате совокупные затраты
      на сортировку и поиск обойдуца N*(log2(N)^2)
      (N/2) становица > (log2(N)^2) при N >= 80
     }
    if Dest.Count > 128 then
        Dest.Sort;

    {build map of checked fields in record}
    SetLength(RecordFieldsMap, 0);
    for HeaderIdx := 0 to FOwner.FCachedFieldsCount-1 do begin
        Header := FOwner.FFiledsHeader.Items[HeaderIdx];
        AppendItem(RecordFieldsMap, Header.FieldOffs);
    end;

    {now scan records}
    for RecIdx := 0 to Count-1 do begin
      CurrRecord := Items[RecIdx];
      Nulls := GetRecordNulls(FOwner, CurrRecord);
      for HeaderIdx := 0 to FOwner.FCachedFieldsCount-1 do begin
        if not Nulls^[HeaderIdx] then
        with PBLOBRecordData(@(CurrRecord^.Data[RecordFieldsMap[HeaderIdx]]))^ do begin
            Cell := Dest.Locate(IscQuad);
            if assigned(Cell) then
              ListIdx := CurrRecord^.BlobList.Add(Cell);
        end;
      end;
    end;

    SetLength(RecordFieldsMap, 0);
end;

{ TRecBuf }

constructor TRecBuf.Create(ABufSize: cardinal);
begin
  FBufSize:=ABufSize;
  GetMem(FCurrent, FBufSize);
  FillChar(FCurrent^, SizeOf(FBufSize), 0);
end;

destructor TRecBuf.Destroy;
begin
  FreeMem(FCurrent, FBufSize);
  if FOriginal<>nil then
    FreeMem(FOriginal, FBufSize);
  inherited;
end;

function TRecBuf.GetOriginal: PChar;
begin
  if FOriginal=nil then Result:=FCurrent
  else Result:=FOriginal
end;


procedure TRecBuf.Modify;
begin
  if FOriginal=nil then
  begin
    GetMem(FOriginal, FBufSize);
    Move(FCurrent^, FOriginal^, FBufSize)
  end;
end;

{ TFBDataLink }

procedure TFBDataLink.ActiveChanged;
begin
  if Active then
    FFBCustomDataSet.MasterUpdate(muOpen)
  else
    FFBCustomDataSet.MasterUpdate(muClose)
end;

constructor TFBDataLink.Create(AFBCustomDataSet: TFBCustomDataSet);
begin
  inherited Create;
  FFBCustomDataSet:=AFBCustomDataSet;
end;

destructor TFBDataLink.Destroy;
begin
  FFBCustomDataSet.FMasterFBDataLink:=nil;
  inherited;
end;

function TFBDataLink.GetDetailDataSet: TDataSet;
begin
  Result:=FFBCustomDataSet;
end;

procedure TFBDataLink.RecordChanged(Field: TField);
begin
  if not (FFBCustomDataSet.FMasterFBDataLink.DataSet.State in [dsEdit, dsInsert]) then
    FFBCustomDataSet.MasterUpdate(muFieldChange);
end;

{ TAutoUpdateOptions }
procedure TAutoUpdateOptions.ApplyGetGenID;
const
  SGENSQL = 'SELECT GEN_ID(%s, %d) FROM RDB$DATABASE';  {do not localize}
var
  sqlGen : TUIBQuery;
begin
  if IsComplete and (FOwner.FieldByName(FKeyField).IsNull) then
  begin
    sqlGen := TUIBQuery.Create(nil);
    sqlGen.DataBase:=FOwner.DataBase;
    sqlGen.Transaction := FOwner.Transaction;
    try
      sqlGen.SQL.Text := Format(SGENSQL, [QuoteIdentifier(FOwner.Database.SQLDialect, FGeneratorName), FIncrementBy]);
      sqlGen.Execute;
      sqlGen.Next;
      if sqlGen.Fields.FieldType[0] = uftInt64 then
        FOwner.FieldByName(FKeyField).AsInteger := sqlGen.Fields.AsInt64[0]
      else FOwner.FieldByName(FKeyField).AsInteger := sqlGen.Fields.AsInteger[0];
      sqlGen.Close;
    finally
      sqlGen.Free;
    end;
  end;
end;

procedure TAutoUpdateOptions.Assign(Source: TPersistent);
var
  STemp : TAutoUpdateOptions absolute Source;
begin
  if Source is TAutoUpdateOptions then
  begin
    FUpdateTableName:=STemp.FUpdateTableName;
    FKeyField:=STemp.FKeyField;
    FWhenGetGenID:=STemp.FWhenGetGenID;
    FIncrementBy:=STemp.FIncrementBy;
    FGeneratorName:=STemp.FGeneratorName;
  end
  else
    inherited Assign(Source);
end;

constructor TAutoUpdateOptions.Create(AOwner: TFBCustomDataSet);
begin
  inherited Create;
  FOwner:=AOwner;
  FWhenGetGenID:=wgNever;
  FIncrementBy:=1;
end;

destructor TAutoUpdateOptions.Destroy;
begin

  inherited;
end;

function TAutoUpdateOptions.IsComplete: boolean;
begin
  Result:=(FKeyField<>'') and (FGeneratorName<>'') {and (FUpdateTableName<>'')};
end;

procedure TAutoUpdateOptions.SetGeneratorName(const AValue: string);
begin
  FGeneratorName := AValue;
end;

procedure TAutoUpdateOptions.SetIncrementBy(const AValue: integer);
begin
  FIncrementBy := AValue;
end;

procedure TAutoUpdateOptions.SetKeyField(const AValue: string);
begin
  FKeyField := AValue;
end;

procedure TAutoUpdateOptions.SetUpdateTableName(const AValue: string);
begin
  FUpdateTableName := AValue;
end;

procedure TAutoUpdateOptions.SetWhenGetGenID(const AValue: TWhenGetGenID);
begin
  FWhenGetGenID := AValue;
end;

{ TFBTimeField }
(*
procedure TFBTimeField.SetAsString(const AValue: string);
var
  R : TDateTime;
begin
  R:=StrToTime(AVAlue);
  SetData(@R);
end;
*)
{$IFDEF FPC}
(*
{ TFBStringField }

function TFBStringField.GetAsString: string;
var
  Buf : TStringFieldBuffer;
begin
  FillChar(Buf, SizeOf(TStringFieldBuffer), 0);
  if GetData(@Buf) then
    Result:=Buf
  else
    Result:='';
end;

procedure TFBStringField.SetAsString(const AValue: string);
Const NullByte : char = #0;

begin
  IF Length(AValue)=0 then
    SetData(@NullByte)
  else
    SetData(@AValue[1]);
end;

function TFBStringField.IsValidChar(InputChar: Char): Boolean;
begin
  Result:=true;
end;
*)
{$ENDIF}


{******************************************************************************
                             TBlobCacheStream
******************************************************************************}
procedure SaveCacheList.Notify(Ptr: Pointer; Action: TListNotification);
var
  Cell : TBLOBCacheStream absolute Ptr;
begin
  case Action of
    lnAdded : begin
      Cell.IncReference;
      IsSorted := false;
    end;
    lnExtracted, lnDeleted : if Cell.Dereference then Cell.Free;
  end;
end;

function CacheListCompare( Item1, Item2 : pointer) : integer;
var
  Cell1 : TBLOBCacheStream absolute Item1;
  Cell2 : TBLOBCacheStream absolute Item2;
begin
  result := Cell1.Isc.gds_quad_high - Cell2.Isc.gds_quad_high;
  if result = 0 then
    result := Cell1.Isc.gds_quad_low - Cell2.Isc.gds_quad_low;
end;

procedure SaveCacheList.Sort;
begin
  Sort(CacheListCompare);
  IsSorted := true;
end;

function CacheListLookup( Item1 : pointer; const Value : TIscQuad) : integer;
var
  Cell1 : TBLOBCacheStream absolute Item1;
begin
  result := Cell1.Isc.gds_quad_high - Value.gds_quad_high;
  if result = 0 then
    result := Cell1.Isc.gds_quad_low - Value.gds_quad_low;
end;

function SaveCacheList.Locate(const ISQ : TIscQuad) : TBLOBCacheStream;
var
    Idx, TopIdx, BotIdx : integer;
    ComparedRecord  : TBLOBCacheStream;
    cmp             : integer;
begin
  result := nil;
  if not IsSorted then begin
    {simple scan}
    for idx := 0 to count -1 do begin
      ComparedRecord := TBLOBCacheStream(Items[idx]);
      cmp := CacheListLookup(ComparedRecord, ISQ);
      if cmp = 0 then begin
        result := ComparedRecord;
        break;
      end
    end;
  end
  else begin
    {dihotome search}
    TopIdx := count -1;
    BotIdx := 0;
    while BotIdx <= TopIdx do begin
      idx := (TopIdx + BotIdx) div 2;
      ComparedRecord := TBLOBCacheStream(Items[idx]);
      cmp := CacheListLookup(ComparedRecord, ISQ);
      if (cmp = 0) then begin
        result := ComparedRecord;
        break;
      end
      else if cmp > 0 then begin
        TopIdx := Idx-1;
      end
      else
        BotIdx := Idx+1;
    end;
  end;
end;

{******************************************************************************
                             TBlobCacheStream
******************************************************************************}
procedure TBlobCacheStream.EnModifyValue;
begin
  if not (FState in [csStoreBLOB, csLoadBLOB]) then
  begin
    if references > 1 then
      raise Exception.Create('TFBBlobStream: try o modify an multiple used cache value');
    FState := csModified;
    DS.SetModified(True);
  end;
end;

function TBlobCacheStream.Modified : boolean;
begin
  result := (FState = csModified);
end;

procedure TBlobCacheStream.Flush;
begin
  if Modified then
    DoWriteBlob;
end;

procedure TBlobCacheStream.OutDate;
begin
  FState := csNotReady;
  Clear;{Save mem space}
end;

function TBlobCacheStream.ChangeOrNil(const aIsc : tISCQuad) : TBLOBCache;
begin
  result := Self;
  if not (FState in [csStoreBLOB, csLoadBLOB]) then
  if (poParanoidBLOBRefresh in DS.Option)
     or Modified
     or (ISC.gds_quad_high <> aIsc.gds_quad_high)
     or (ISC.gds_quad_low <> aIsc.gds_quad_low)
  then begin
    if Alone then
    begin
      ISC := aIsc;
      OutDate;
    end
    else
      Result := nil;
  end;
end;

function TBlobCacheStream.Change(const aIsc : tISCQuad) : TBLOBCache;
begin
  Result := ChangeOrNil(aIsc);
  if not Assigned(Result) then
    Result := TFBBlobStream.Create(DS,aISC);
end;

procedure TBlobCacheStream.Refresh;
begin
  DoReadBlob;
end;

function TBlobCacheStream.Write(const Buffer; Count: Integer): Longint;
begin
  EnModifyValue;
  Result := inherited Write(Buffer, Count);
end;

function TBlobCacheStream.Read(var Buffer; Count: Longint): Longint;
begin
  if (FState = csNotReady) then
    Refresh;
  Result := inherited Read(Buffer, Count);
end;

function TBlobCacheStream.GetSize: Int64;
begin
  if (FState = csNotReady) then
    Refresh;
  Result := inherited GetSize;
end;

procedure TBlobCacheStream.SetSize(NewSize: Longint);
begin
  EnModifyValue;
  inherited SetSize(NewSize);
end;

function TBlobCacheStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
  if (FState = csNotReady) then
    Refresh;
  Result := inherited Seek(Offset, Origin);
end;

constructor TBlobCacheStream.Create(aDS : TFBCustomDataSet; aOriginISC : tISCQuad);
begin
  inherited Create;
  DS:=aDS;
  ISC := aOriginISC;
  OutDate;
{$IFDEF USE_SAFE_CODE}
  aDS.FBLOBCache.Add(Self);
{$ENDIF}
end;

destructor TBlobCacheStream.Destroy;
begin
{$IFDEF USE_SAFE_CODE}
  DS.FBLOBCache.Remove(Self);
{$ENDIF}
  inherited Destroy;
end;

function TBlobCacheStream.Clone : TBlobCacheStream;
begin
  result := New;
  result.LoadFromStream(Self);
  result.FState := FState;
end;

function TBlobCacheStream.GetText : AnsiString;
begin
  SetLength(result, Size);
  Position := 0;
  Read(result[1],Size);
end;

procedure TBlobCacheStream.SetText(const Src : AnsiString);
begin
  SetSize(Length(Src));
  Position := 0;
  Write(Src[1],Length(Src));
end;

{******************************************************************************
                           TFBBlobStream
******************************************************************************}

procedure TFBBlobStream.DoReadBlob;
var
  BlobHandle: IscBlobHandle;
  HDB:IscDbHandle;
  HTR:IscTrHandle;
begin
    HDB:=DS.FDataBase.DbHandle;
    if not DS.UpdateTransaction.InTransaction then
      HTR:=DS.Transaction.TrHandle
    else
      HTR:=DS.UpdateTransaction.TrHandle;
    with DS.FDataBase.Lib do
    begin
      BlobHandle := nil;
      BlobOpen(HDB, HTR, BlobHandle, Isc);
      try
        FState := csLoadBLOB;
        BlobSaveToStream(BlobHandle, Self);
        BlobClose(BlobHandle);
        Seek(0, soFromBeginning);
        FState := csFresh;
      except
        BlobClose(BlobHandle);
        FState := csNotReady;
      end;
    end;
end;

procedure TFBBlobStream.DoWriteBlob;
var
  BLOBRec : TBLOBFieldData;
  BlobHandle: IscBlobHandle;
  HDB:IscDbHandle;
  HTR:IscTrHandle;
begin
  HDB:=DS.FDataBase.DbHandle;
  if not DS.UpdateTransaction.InTransaction then
    DS.UpdateTransaction.StartTransaction;
  HTR:=DS.UpdateTransaction.TrHandle;
  with DS.FDataBase.Lib do
  begin
    BlobHandle := nil;
    BLOBRec.IscQuad := BlobCreate(HDB, HTR, BlobHandle);
    try
      FState := csStoreBLOB;
      BlobWriteStream(BlobHandle, Self);
      BlobClose(BlobHandle);
      Isc := BLOBRec.IscQuad;
      FState := csFresh;
    except
      BlobClose(BlobHandle);
      FState := csModified;
    end;
  end;
end;

function TFBBlobStream.New : TBlobCacheStream;
begin
  Result := TFBBlobStream.Create(DS,ISC);
end;

{*******************************************************************************
                               TFBAnsiMemoStream
*******************************************************************************}
constructor TFBAnsiMemoStream.Create(aDS : TFBCustomDataSet; aOriginISC : TIscQuad);
begin
  inherited Create(aDS,aOriginISC);
  FTextShared := false;
  FMemoText := '';
end;

destructor TFBAnsiMemoStream.Destroy;
begin
  Ansitext := '';
  inherited destroy;
end;

function TFBAnsiMemoStream.New : TBlobCacheStream;
begin
  Result := TFBAnsiMemoStream.Create(DS,ISC);
end;

function TFBAnsiMemoStream.Clone : TBlobCacheStream;
var
  tmp : TFBAnsiMemoStream;
begin
   tmp := TFBAnsiMemoStream.create(DS,ISC);
   tmp.FState := FState;
   tmp.AnsiText :=AnsiText;
   Result := tmp;
end;

function TFBAnsiMemoStream.GetText : AnsiString;
begin
  if (FState = csNotReady) then
    Refresh;
  Result := FMemoText;
  FTextShared := true;
end;

procedure TFBAnsiMemoStream.SetText(const Src : AnsiString);
var
  L:integer;
begin
  FTextShared := false;
  EnModifyValue;
  FMemoText := Src;
  SetPointer(@FMemoText[1],length(FMemoText));
  L:=Length(FMemoText);
  Capacity := L;
  FTextShared := true;
end;

function TFBAnsiMemoStream.Realloc(var NewCapacity: PtrInt): Pointer;
begin
  if FTextShared or (Length(FMemoText) <> NewCapacity) then
    SetLength(FMemoText, NewCapacity);
  result := @FMemoText[1];
end;

procedure TFBAnsiMemoStream.EnModifyValue;
begin
  inherited EnModifyValue;
  Capacity := Size;
end;

{*****************************************************************************
                                TFBAnsiMemoField
******************************************************************************}

function TFBAnsiMemoField.GetAsString: string;
begin
  if (DataSet is TFBCustomDataSet) then
    result := (DataSet as TFBCustomDataSet).MemoValue[Self]
  else
    result := inherited GetAsString;
end;

procedure TFBAnsiMemoField.SetAsString(const Value: string);
begin
  if (DataSet is TFBCustomDataSet) then
    (DataSet as TFBCustomDataSet).MemoValue[Self] := Value
  else
    inherited SetAsString(Value);
end;

function TFBAnsiMemoField.GetIsNull: Boolean;
begin
  result := not DataSet.GetFieldData(Self,nil);
end;


{$IFDEF FPC}

{ TFBBlobField }

procedure TFBBlobField.AssignTo(Dest: TPersistent);
begin
  if Dest is TStrings then
  begin
    SaveToStrings(TStrings(Dest));
    Exit;
  end;
  inherited AssignTo(Dest);
end;

procedure TFBBlobField.SaveToStrings(Strings: TStrings);
var
  BlobStream: TStream;
begin
  BlobStream := DataSet.CreateBlobStream(Self, bmRead);
  try
    Strings.LoadFromStream(BlobStream);
  finally
    BlobStream.Free;
  end;
end;

{$ENDIF FPC}

{******************************************************************************
                            TFBAnsiField
*******************************************************************************}
procedure TFBAnsiField.SetDataSet(ADataSet: TDataSet);
begin
  inherited SetDataSet(ADataSet);
  if DataSet is TFBCustomDataSet then
    NativeDataSet := TFBCustomDataSet(DataSet)
  else
    NativeDataSet := nil;
end;

procedure TFBAnsiField.CopyData(Source, Dest: Pointer);
begin
  PAnsiString(Dest)^ := PAnsiString(Source)^;
end;

procedure TFBAnsiField.SetData(const Data: AnsiString);
begin
  if assigned(NativeDataSet) then begin
    try
      NativeDataSet.SetFieldData(Self, Data);
    finally
    end;
  end
  else
    inherited SetData(@Data, fdNativeData);
end;

{
function FBAnsiField.GetData(var Buffer: AnsiString): Boolean;
begin
  if assigned(NativeDataSet) then begin
    if  not Validating then
      result := NativeDataSet.GetFieldData(Self, Buffer)
    else begin
      result := assigned(FValueBuffer);
      Buffer := PAnsiString(FValueBuffer)^;
    end;
  end
  else
    result := inherited GetData(@Buffer, fdNativeData);
end;
}

function TFBAnsiField.GetAsAnsiString: AnsiString;
var
  TruncBuffer : AnsiString;
begin
  GetData(@TruncBuffer, fdNativeData);
  result := TruncBuffer;
end;

function TFBAnsiField.GetAsString: string;
begin
  result := GetAsAnsiString;
end;

function TFBAnsiField.GetAsVariant: Variant;
begin
  result := GetAsAnsiString;
end;

function TFBAnsiField.GetDataSize: Integer;
begin
   Result := SizeOf(AnsiString);
end;

procedure TFBAnsiField.SetAsAnsiString(const Value: AnsiString);
var
  TruncValue: AnsiString;
begin
{  if Length(Value) > Size then
    TruncValue := Copy(Value, 1, Size)
  else   }
    TruncValue := Value;
  SetData(TruncValue);
end;

procedure TFBAnsiField.SetAsString(const Value: AnsiString);
begin
  SetAsAnsiString(Value);
end;

procedure TFBAnsiField.SetVarValue(const Value: Variant);
begin
  SetAsAnsiString(Value);
end;

{******************************************************************************
                             TRecordsBufferIndex
*******************************************************************************}
const
  ObsoleteStamp = low(TRecBufStamp);
  
function IndexDef2String(const aDef : TIndexDef) : string;
var
  name : string;
  tmp : string;
  UnCasednames : string;
  DescentedNames : string;
  tmppos : integer;
begin
  UnCasedNames := UpperCase(aDef.CaseInsFields);
  DescentedNames := UpperCase(aDef.DescFields);
  tmppos := 1;
  result := '';
  while tmppos < length(aDef.Fields) do begin
    name := ExtractFieldName(aDef.Fields, tmppos);
    tmp := UpperCase(name);
    if pos(tmp, DescentedNames) > 0 then
      name := '~' + name;
    if pos(tmp,UnCasednames) = 0 then
      name := '"' + name + '"';
    result := result + name;
  end;
end;

constructor TRecordsBufferIndex.Create({const aDefinition : string; }AOwner:TFBCustomDataSet);
begin
       inherited create;
  Fowner := AOwner;
  Source := AOwner.FRecordsBuffer;
  {definition := aDefinition;}
  {Sort;}
end;

destructor TRecordsBufferIndex.Destroy;
begin
  Clear;
  Structure := nil;
  FName := '';
  FDefinition := '';
  inherited Destroy;
end;

procedure TRecordsBufferIndex.SetName(const Value : string);
begin
{
  if value = '' and FName <> '' then
    if assigned(FOwner) then with FOwner.LocalIndexes do
      DeleteRecord(IndexOf(FName))
  if value <> '' and FName = '' then
    if assigned(FOwner) then FOwner.LocalIndexes.AddObject(Value, Self);
}
  FName := Value;
end;

procedure TRecordsBufferIndex.SetDefinition(const aDef : string);
var
  Names : TStrings;
  idx   : integer;

  procedure CheckDesc;
  begin
    with Structure[idx] do begin
      if FieldName[1] = '~' then begin
        Descendent := true;
        system.Delete(FieldName,1,1);
      end;
    end;
  end;

  procedure CheckPartial;
    { sign '>' mean that part of search key could be matched}
  var
    SignPos : integer;
  begin
    with Structure[idx] do begin
      SignPos := IndexChar(FieldName[1], length(FieldName), '>');
      if SignPos > 0 then begin
        PartialKey := true;
        system.Delete(FieldName, SignPos+1, 1);
      end;
    end;
  end;

  procedure CheckPrefixing;
    { sign '<' mean that search key could be matched as prefix}
  var
    SignPos : integer;
  begin
    with Structure[idx] do begin
      SignPos := IndexChar(FieldName[1], length(FieldName), '>');
      if SignPos > 0 then begin
        PartialKey := true;
        system.Delete(FieldName,SignPos+1,1);
      end;
    end;
  end;

begin
  Names := TStringList.Create;
  Names.Delimiter := ';';
  FDefinition := UpperCase(aDef);
  Names.DelimitedText := FDefinition;
  SetLength(Structure, Names.Count);
  for idx := low(Structure) to high(Structure) do with Structure[idx] do begin
    FieldName := Names.Strings[idx];
    CheckDesc;
    CheckPrefixing;
    CheckPartial;
    CaseSence := (FieldName[1] <> '"');
    if FieldName[1] = '"' then begin
      system.Delete(FieldName,1,1);
      SetLength(FieldName, length(FieldName)-1);
    end;
  end; {for with}
  ReBuild;
end;

procedure TRecordsBufferIndex.SetDefinition(const aDef : TIndexDef);
begin
  SetDefinition(IndexDef2String(aDef));
  Name := aDef.Name;
end;

procedure TRecordsBufferIndex.Sort;
       procedure DoQuickSort(L,R:Integer);
       var
         I, J: Integer;
         P     : PRecordBuffer;
         T     : pointer;
       begin
         repeat
               I := L;
               J := R;
               P := PRecordBuffer(Items[(L + R) shr 1]);
               repeat
                 while CompareRec(PRecordBuffer(Items[I]), P) < 0 do
        Inc(I);
                 while CompareRec(PRecordBuffer(Items[J]), P) > 0 do
        Dec(J);
                 if I <= J then  begin
                       T := Items[I];
                       Items[I] := Items[J];
                       Items[J] := T;
                       Inc(I);
                       Dec(J);
                 end;
               until I > J;
               if L < J then
                       DoQuickSort(L, J);
               L := I;
         until I >= R;
       end;
begin
  Assign(Source);
  if Count>1 then
    DoQuickSort(0, Count - 1);

  ModifyStamp := Source.ModifyStamp;
end;

function TRecordsBufferIndex.Locate(const Values : variant) : TBookmark;
var
  FoundRec : PRecordBuffer;
begin
  FoundRec := LocateRec(Values);
  result := @(FoundRec^.Bookmark);
end;

function TRecordsBufferIndex.Obsolete : boolean;
begin
  result := (ModifyStamp <> Source.ModifyStamp);
end;

procedure TRecordsBufferIndex.DoFresh;
begin
  if Obsolete then Sort;
end;

{******************************************************************************
                             TUniversalRBIndex
*******************************************************************************}
constructor TUniversalRBIndex.Create(const aDefinition : string; AOwner:TFBCustomDataSet);
begin
  inherited Create(AOwner);
  FFields := nil;
  FCompDefines := nil;
  FCompSpecDefines := nil;
  definition := aDefinition;
{  Rebuild;}
end;

constructor TUniversalRBIndex.Create(const aDefinition : TIndexDef; AOwner:TFBCustomDataSet);
begin
  Create(IndexDef2String(aDefinition), AOwner);
  Name := aDefinition.Name;
end;

destructor TUniversalRBIndex.Destroy;
begin
  FCompDefines := nil;
  FFields := nil;
  inherited Destroy;
end;

function TUniversalRBIndex.LocateRec(const Values : variant) : PRecordBuffer;
var
  Found : PRecordBuffer;
begin
  if SearchRec(Values,Found) then
    Result := Found
  else
    Result := nil;
end;

function TUniversalRBIndex.SearchRec(const Values : variant; out Target : PRecordBuffer) : boolean;
var
       TopIdx, BotIdx, Idx : integer;
       cmp : integer;
  LookingRecord : PRecordBuffer;
  ComparedRecord : PRecordBuffer;
begin
  result := false;
  DoFresh;
       Target := nil;
  ComparedRecord := nil;
  if count = 0 then exit;
  
  LookingRecord := PRecordBuffer(FOwner.AllocRecordbuffer);
  FOwner.SetFieldValues(LookingRecord, FFields, Values);

  {dihotome search}
       TopIdx := count -1;
       BotIdx := 0;
       while BotIdx <= TopIdx do begin
               idx := (TopIdx + BotIdx) div 2;
    ComparedRecord := PRecordBuffer(Items[idx]);
               cmp := LookupRec(ComparedRecord, LookingRecord);
               if (cmp = 0) then begin
      result := true;
      Target := ComparedRecord;
      TopIdx := Idx-1;
    end
               else if cmp > 0 then begin
                       TopIdx := Idx-1;
               end
               else
                       BotIdx := Idx+1;
       end;
  if not result then
    Target := ComparedRecord;

  FOwner.FreeRecordbuffer(PChar(LookingRecord));
end;

function TUniversalRBIndex.LookupRec(valA, valB : PRecordBuffer) : integer;
var
  idx : integer;
begin
  for idx := Low(FCompDefines) to high(FCompDefines) do with FCompDefines[idx] do begin
    if (not boolean(ValA.Data[NullOffset])) and (not boolean(ValB.Data[NullOffset])) then begin
      result := FLookup(FCompDefines[idx],valA,valB);
    end
    else begin
      {delphi denotes that False = byte(0) and so try to compare bools like bytes
        it maybe not compatible/portable}
      result := ValA.Data[NullOffset] - ValB.Data[NullOffset];
    end;
    if result <> 0 then exit;
  end;{for}
end;

function TUniversalRBIndex.CompareRec(valA, valB : PRecordBuffer) : integer;
var
  idx : integer;
begin
  for idx := Low(FCompDefines) to high(FCompDefines) do with FCompDefines[idx] do begin
    if (not boolean(ValA.Data[NullOffset])) and (not boolean(ValB.Data[NullOffset])) then begin
      result := FCompare(FCompDefines[idx],valA,valB);
    end
    else begin
      {delphi denotes that False = byte(0) and so try to compare bools like bytes
        it maybe not compatible/portable}
      result := ValA.Data[NullOffset] - ValB.Data[NullOffset];
    end;
    if result <> 0 then exit;
  end;{for}

  for idx := Low(FCompSpecDefines) to high(FCompSpecDefines) do with FCompSpecDefines[idx] do begin
    if (not boolean(ValA.Data[NullOffset])) and (not boolean(ValB.Data[NullOffset])) then begin
      result := FCompare(FCompSpecDefines[idx],valA,valB);
    end
    else begin
      {delphi denotes that False = byte(0) and so try to compare bools like bytes
        it maybe not compatible/portable}
      result := ValA.Data[NullOffset] - ValB.Data[NullOffset];
    end;
    if result <> 0 then exit;
  end;{for}

end;

function FBRBICompareByte( var context;
                              valA, valB : PRecordBuffer) : integer;
var
  Self : FBRBICompareContext absolute context;
begin
  with self do begin
    {delphi denotes that False = byte(0) and so try to compare bools like bytes
      it maybe not compatible/portable}
    result := ValA.Data[FieldOffset] - ValB.Data[FieldOffset];
    if Descending then
      Result := - Result;
  end;
end;

function FBRBICompareSInt( var context;
                              valA, valB : PRecordBuffer) : integer;
var
  Self : FBRBICompareContext absolute context;
begin
  with self do begin
    {delphi denotes that False = byte(0) and so try to compare bools like bytes
      it maybe not compatible/portable}
    result := ShortInt(ValA.Data[FieldOffset]) - ShortInt(ValB.Data[FieldOffset]);
    if Descending then
      Result := - Result;
  end;
end;

function FBRBICompareSigned( var context;
                                  valA, valB : PRecordBuffer) : integer;
var
  Self : FBRBICompareContext absolute context;
  idx : ShortInt;
  Adata, BData : ShortInt;
begin
  with self do begin
    idx := DataHigh;
    AData := ShortInt(ValA.Data[FieldOffset + idx]);
    BData := ShortInt(ValB.Data[FieldOffset + idx]);
    result := AData - BData;
    while (result = 0) and (idx > 0) do begin
      dec(idx);
      result := ValA.Data[FieldOffset + idx] - ValB.Data[FieldOffset + idx];
    end;
    if Descending then
      Result := - Result;
  end;
end;

function FBRBICompareUnSigned( var context;
                                  valA, valB : PRecordBuffer) : integer;
var
  Self : FBRBICompareContext absolute context;
  idx : ShortInt;
begin
  with self do begin
    idx := DataHigh;
    result := 0;
    while (result = 0) and (idx > 0) do begin
      result := ValA.Data[FieldOffset + idx] - ValB.Data[FieldOffset + idx];
      dec(idx);
    end;
    if Descending then
      Result := - Result;
  end;
end;

function FBRBICompareStrOrder( var context;
                                  valA, valB : PRecordBuffer
                              ) : integer;
var
  Self : FBRBICompareContext absolute context;
begin
  with self do begin
    result := StrComp(@(ValA.Data[FieldOffset]), @(ValB.Data[FieldOffset]){, DataHigh +1});
    if Descending then
      Result := - Result;
  end;
end;

{*************************  FixedChar comparators *********************************}
function FBRBICompareAnsi( var context;
                                  valA, valB : PRecordBuffer
                              ) : integer;
var
  Self : FBRBICompareContext absolute context;
begin
  with self do begin
    result := AnsiStrComp(@(ValA.Data[FieldOffset]), @(ValB.Data[FieldOffset]){, DataHigh +1});
    if Descending then
      Result := - Result;
  end;
end;

function FBRBICompareAnsiLeftPrefix( var context;
                                  valA, valB : PRecordBuffer
                              ) : integer;
var
  Self : FBRBICompareContext absolute context;
begin
  with self do begin
    result := CompareAnsiLeftPrefix(@(ValA.Data[FieldOffset]), @(ValB.Data[FieldOffset]){, DataHigh +1});
    if Descending then
      Result := - Result;
  end;
end;

function FBRBICompareAnsiRightPrefix( var context;
                                  valA, valB : PRecordBuffer
                              ) : integer;
var
  Self : FBRBICompareContext absolute context;
begin
  with self do begin
    result := CompareAnsiLeftPrefix(@(ValB.Data[FieldOffset]), @(ValA.Data[FieldOffset]){, DataHigh +1});
    if not Descending then
      Result := - Result;
  end;
end;

function FBRBICompareAnsiPrefix( var context;
                                  valA, valB : PRecordBuffer
                              ) : integer;
var
  Self : FBRBICompareContext absolute context;
begin
  with self do begin
    result := CompareAnsiPrefix(@(ValA.Data[FieldOffset]), @(ValB.Data[FieldOffset]){, DataHigh +1});
    if Descending then
      Result := - Result;
  end;
end;

function FBRBICompareTextLeftPrefix( var context;
                                  valA, valB : PRecordBuffer
                              ) : integer;
var
  Self : FBRBICompareContext absolute context;
begin
  with self do begin
    result := CompareTextLeftPrefix(@(ValA.Data[FieldOffset]), @(ValB.Data[FieldOffset]){, DataHigh +1});
    if Descending then
      Result := - Result;
  end;
end;

function FBRBICompareTextRightPrefix( var context;
                                  valA, valB : PRecordBuffer
                              ) : integer;
var
  Self : FBRBICompareContext absolute context;
begin
  with self do begin
    result := CompareTextLeftPrefix(@(ValB.Data[FieldOffset]), @(ValA.Data[FieldOffset]){, DataHigh +1});
    if not Descending then
      Result := - Result;
  end;
end;

function FBRBICompareTextPrefix( var context;
                                  valA, valB : PRecordBuffer
                              ) : integer;
var
  Self : FBRBICompareContext absolute context;
begin
  with self do begin
    result := CompareTextPrefix(@(ValA.Data[FieldOffset]), @(ValB.Data[FieldOffset]){, DataHigh +1});
    if Descending then
      Result := - Result;
  end;
end;

function FBRBICompareText( var context;
                                  valA, valB : PRecordBuffer
                              ) : integer;
var
  Self : FBRBICompareContext absolute context;
  SA,SB: PChar;
begin
  with self do begin
    SA := @(ValA.Data[FieldOffset]);
    SB := @(ValB.Data[FieldOffset]);
    result := AnsiStrIComp(SA, SB{, DataHigh +1});
    if Descending then
      Result := - Result;
  end;
end;

{*************************  AnsiString comparators *********************************}
function FBRBICompareAnsiStr( var context;
                                  valA, valB : PRecordBuffer
                              ) : integer;
var
  Self : FBRBICompareContext absolute context;
  SA,SB: PAnsiString;
  LSA, LSB : integer;
begin
  with self do begin
    SA := @(ValA.Data[FieldOffset]);
    SB := @(ValB.Data[FieldOffset]);
    LSA := length(SA^);
    LSB := length(SB^);
    if min( LSA, LSB) <> 0 then
      result := AnsiCompareStr( SA^, SB^ {, DataHigh +1})
    else
      result := LSA - LSB;
    if Descending then
      Result := - Result;
  end;
end;

function FBRBICompareTextStr( var context;
                                  valA, valB : PRecordBuffer
                              ) : integer;
var
  Self : FBRBICompareContext absolute context;
  SA,SB: PAnsiString;
  LSA, LSB : integer;
begin
  with self do begin
    SA := @(ValA.Data[FieldOffset]);
    SB := @(ValB.Data[FieldOffset]);
    LSA := length(SA^);
    LSB := length(SB^);
    if min( LSA, LSB) <> 0 then
      result := AnsiCompareText(SA^, SB^{, DataHigh +1})
    else
      result := LSA - LSB;
    if Descending then
      Result := - Result;
  end;
end;

function FBRBICompareAnsiStrLeftPrefix( var context;
                                  valA, valB : PRecordBuffer
                              ) : integer;
var
  Self : FBRBICompareContext absolute context;
  SA,SB: PAnsiString;
begin
  with self do begin
    SA := @(ValA.Data[FieldOffset]);
    SB := @(ValB.Data[FieldOffset]);
    result := CompareAnsiLeftPrefix(SA^, SB^{, DataHigh +1});
    if Descending then
      Result := - Result;
  end;
end;

function FBRBICompareAnsiStrRightPrefix( var context;
                                  valA, valB : PRecordBuffer
                              ) : integer;
var
  Self : FBRBICompareContext absolute context;
  SA,SB: PAnsiString;
begin
  with self do begin
    SA := @(ValA.Data[FieldOffset]);
    SB := @(ValB.Data[FieldOffset]);
    result := CompareAnsiLeftPrefix(SB^, SA^{, DataHigh +1});
    if not Descending then
      Result := - Result;
  end;
end;

function FBRBICompareAnsiStrPrefix( var context;
                                  valA, valB : PRecordBuffer
                              ) : integer;
var
  Self : FBRBICompareContext absolute context;
  SA,SB: PAnsiString;
begin
  with self do begin
    SA := @(ValA.Data[FieldOffset]);
    SB := @(ValB.Data[FieldOffset]);
    result := CompareAnsiPrefix(SA^, SB^{, DataHigh +1});
    if Descending then
      Result := - Result;
  end;
end;

function FBRBICompareTextStrLeftPrefix( var context;
                                  valA, valB : PRecordBuffer
                              ) : integer;
var
  Self : FBRBICompareContext absolute context;
  SA,SB: PAnsiString;
begin
  with self do begin
    SA := @(ValA.Data[FieldOffset]);
    SB := @(ValB.Data[FieldOffset]);
    result := CompareTextLeftPrefix(SA^, SB^{, DataHigh +1});
    if Descending then
      Result := - Result;
  end;
end;

function FBRBICompareTextStrRightPrefix( var context;
                                  valA, valB : PRecordBuffer
                              ) : integer;
var
  Self : FBRBICompareContext absolute context;
  SA,SB: PAnsiString;
begin
  with self do begin
    SA := @(ValA.Data[FieldOffset]);
    SB := @(ValB.Data[FieldOffset]);
    result := CompareTextLeftPrefix(SB^, SA^{, DataHigh +1});
    if not Descending then
      Result := - Result;
  end;
end;

function FBRBICompareTextStrPrefix( var context;
                                  valA, valB : PRecordBuffer
                              ) : integer;
var
  Self : FBRBICompareContext absolute context;
  SA,SB: PAnsiString;
begin
  with self do begin
    SA := @(ValA.Data[FieldOffset]);
    SB := @(ValB.Data[FieldOffset]);
    result := CompareTextPrefix(SA^, SB^{, DataHigh +1});
    if Descending then
      Result := - Result;
  end;
end;

{*************************  WideString comparators *********************************}
function FBRBICompareWideStr( var context;
                                  valA, valB : PRecordBuffer
                              ) : integer;
var
  Self : FBRBICompareContext absolute context;
  SA,SB: PWideString;
  LSA, LSB : integer;
begin
  with self do begin
    SA := @(ValA.Data[FieldOffset]);
    SB := @(ValB.Data[FieldOffset]);
    LSA := length(SA^);
    LSB := length(SB^);
    if min( LSA, LSB) <> 0 then
      result := WideCompareStr( SA^, SB^ {, DataHigh +1})
    else
      result := LSA - LSB;
    if Descending then
      Result := - Result;
  end;
end;

function FBRBICompareWideTextStr( var context;
                                  valA, valB : PRecordBuffer
                              ) : integer;
var
  Self : FBRBICompareContext absolute context;
  SA,SB: PWideString;
  LSA, LSB : integer;
begin
  with self do begin
    SA := @(ValA.Data[FieldOffset]);
    SB := @(ValB.Data[FieldOffset]);
    LSA := length(SA^);
    LSB := length(SB^);
    if min( LSA, LSB) <> 0 then
      result := WideCompareText(SA^, SB^{, DataHigh +1})
    else
      result := LSA - LSB;
    if Descending then
      Result := - Result;
  end;
end;

function FBRBICompareWideStrLeftPrefix( var context;
                                  valA, valB : PRecordBuffer
                              ) : integer;
var
  Self : FBRBICompareContext absolute context;
  SA,SB: PWideString;
begin
  with self do begin
    SA := @(ValA.Data[FieldOffset]);
    SB := @(ValB.Data[FieldOffset]);
    result := CompareWideLeftPrefix(SA^, SB^{, DataHigh +1});
    if Descending then
      Result := - Result;
  end;
end;

function FBRBICompareWideStrRightPrefix( var context;
                                  valA, valB : PRecordBuffer
                              ) : integer;
var
  Self : FBRBICompareContext absolute context;
  SA,SB: PWideString;
begin
  with self do begin
    SA := @(ValA.Data[FieldOffset]);
    SB := @(ValB.Data[FieldOffset]);
    result := CompareWideLeftPrefix(SB^, SA^{, DataHigh +1});
    if not Descending then
      Result := - Result;
  end;
end;

function FBRBICompareWideStrPrefix( var context;
                                  valA, valB : PRecordBuffer
                              ) : integer;
var
  Self : FBRBICompareContext absolute context;
  SA,SB: PWideString;
begin
  with self do begin
    SA := @(ValA.Data[FieldOffset]);
    SB := @(ValB.Data[FieldOffset]);
    result := CompareWidePrefix(SA^, SB^{, DataHigh +1});
    if Descending then
      Result := - Result;
  end;
end;

function FBRBICompareWideTextStrLeftPrefix( var context;
                                  valA, valB : PRecordBuffer
                              ) : integer;
var
  Self : FBRBICompareContext absolute context;
  SA,SB: PWideString;
begin
  with self do begin
    SA := @(ValA.Data[FieldOffset]);
    SB := @(ValB.Data[FieldOffset]);
    result := CompareWideTextLeftPrefix(SA^, SB^{, DataHigh +1});
    if Descending then
      Result := - Result;
  end;
end;

function FBRBICompareWideTextStrRightPrefix( var context;
                                  valA, valB : PRecordBuffer
                              ) : integer;
var
  Self : FBRBICompareContext absolute context;
  SA,SB: PWideString;
begin
  with self do begin
    SA := @(ValA.Data[FieldOffset]);
    SB := @(ValB.Data[FieldOffset]);
    result := CompareWideTextLeftPrefix(SB^, SA^{, DataHigh +1});
    if not Descending then
      Result := - Result;
  end;
end;

function FBRBICompareWideTextStrPrefix( var context;
                                  valA, valB : PRecordBuffer
                              ) : integer;
var
  Self : FBRBICompareContext absolute context;
  SA,SB: PWideString;
begin
  with self do begin
    SA := @(ValA.Data[FieldOffset]);
    SB := @(ValB.Data[FieldOffset]);
    result := CompareWideTextPrefix(SA^, SB^{, DataHigh +1});
    if Descending then
      Result := - Result;
  end;
end;

{*************************************************************************}
procedure TUniversalRBIndex.Rebuild;
var
  Field : TField;
  StructIdx : integer;
  DefIdx : integer;
  SpecDefIdx : integer;

  procedure SetDef(var Target : FBRBICompareContext;
                  const CompProc : FBRecordCompare;
                  const LookupProc : FBRecordCompare);
  begin
    with Target do begin
       FieldNo := FOwner.HeaderId(Field);
       NullOffset := FOwner.FRecordSize + (FieldNo) * SizeOf(Booleans);
       FieldOffset := TFieldHeader(FOwner.FFiledsHeader[FieldNo]).FieldOffs;

       FieldSize := Field.DataSize;
       DataHigh := FieldSize-1;
       Descending := Structure[StructIdx].Descendent;
       FCompare := CompProc;
       FLookup  := LookupProc;
    end;
  end; {SetDef}

begin
  SetLength(FFields, Length(Structure));
  SetLength(FCompDefines, Length(Structure));
  SetLength(FCompSpecDefines, Length(Structure));
  DefIdx := low(FCompDefines);
  SpecDefIdx := low(FCompSpecDefines);
  for StructIdx := low(Structure) to high(Structure) do with Structure[StructIdx] do begin
    Field := FOwner.FindField(FieldName);
    FFields[StructIdx] := Field;
    if assigned(Field) then with FCompDefines[DefIdx] do begin
        case Field.DataType of
          ftSmallint,
          ftInteger,
          ftFloat,
          ftCurrency,
          ftBCD, {BCD Saved as currency by TBCDField}
          ftDate, ftTime, ftDateTime,
          ftLargeint :
            begin
              SetDef(FCompDefines[DefIdx], @FBRBICompareSigned, @FBRBICompareSigned);
            end;

          ftWord,
          ftBytes,
          ftAutoInc,
          ftTypedBinary,
          ftReference,
          ftTimeStamp : begin
            SetDef(FCompDefines[DefIdx], @FBRBICompareUnSigned, @FBRBICompareUnSigned);
          end;

          ftBoolean : begin
            SetDef(FCompDefines[DefIdx], @FBRBICompareByte, @FBRBICompareByte);
          end;

          ftVarBytes: begin
            SetDef(FCompDefines[DefIdx], @FBRBICompareStrOrder, @FBRBICompareStrOrder);
          end;

          ftWideString: begin
            if not CaseSence then begin
              SetDef(FCompDefines[DefIdx], @FBRBICompareWideTextStr, @FBRBICompareWideTextStr);
              SetDef(FCompSpecDefines[SpecDefIdx], @FBRBICompareWideStr, nil);
              inc(SpecDefIdx);

              if PartialKey and AsPrefix then
                FCompDefines[DefIdx].FLookup := @FBRBICompareWideTextStrPrefix
              else if PartialKey then
                FCompDefines[DefIdx].FLookup := @FBRBICompareWideTextStrRightPrefix
              else if AsPrefix then
                FCompDefines[DefIdx].FLookup := @FBRBICompareWideTextStrLeftPrefix;
            end
            else begin
              SetDef(FCompDefines[DefIdx], @FBRBICompareWideStr, @FBRBICompareWideStr);

              if PartialKey and AsPrefix then
                FCompDefines[DefIdx].FLookup := @FBRBICompareWideStrPrefix
              else if PartialKey then
                FCompDefines[DefIdx].FLookup := @FBRBICompareWideStrRightPrefix
              else if AsPrefix then
                FCompDefines[DefIdx].FLookup := @FBRBICompareWideStrLeftPrefix;
            end;
          end;

          ftString :begin
            if not CaseSence then begin
              SetDef(FCompDefines[DefIdx], @FBRBICompareTextStr, @FBRBICompareTextStr);
              SetDef(FCompSpecDefines[SpecDefIdx], @FBRBICompareAnsiStr, nil);
              inc(SpecDefIdx);

              if PartialKey and AsPrefix then
                FCompDefines[DefIdx].FLookup := @FBRBICompareTextStrPrefix
              else if PartialKey then
                FCompDefines[DefIdx].FLookup := @FBRBICompareTextStrRightPrefix
              else if AsPrefix then
                FCompDefines[DefIdx].FLookup := @FBRBICompareTextStrLeftPrefix;
            end
            else begin
              SetDef(FCompDefines[DefIdx], @FBRBICompareAnsiStr, @FBRBICompareAnsiStr);

              if PartialKey and AsPrefix then
                FCompDefines[DefIdx].FLookup := @FBRBICompareAnsiStrPrefix
              else if PartialKey then
                FCompDefines[DefIdx].FLookup := @FBRBICompareAnsiStrRightPrefix
              else if AsPrefix then
                FCompDefines[DefIdx].FLookup := @FBRBICompareAnsiStrLeftPrefix;
            end;
          end;

          ftFixedChar :begin
            if not CaseSence then begin
              SetDef(FCompDefines[DefIdx], @FBRBICompareText, @FBRBICompareText);
              SetDef(FCompSpecDefines[SpecDefIdx], @FBRBICompareAnsi, nil);
              inc(SpecDefIdx);

              if PartialKey and AsPrefix then
                FCompDefines[DefIdx].FLookup := @FBRBICompareTextPrefix
              else if PartialKey then
                FCompDefines[DefIdx].FLookup := @FBRBICompareTextRightPrefix
              else if AsPrefix then
                FCompDefines[DefIdx].FLookup := @FBRBICompareTextLeftPrefix;
            end
            else begin
              SetDef(FCompDefines[DefIdx], @FBRBICompareAnsi, @FBRBICompareAnsi);

              if PartialKey and AsPrefix then
                FCompDefines[DefIdx].FLookup := @FBRBICompareAnsiPrefix
              else if PartialKey then
                FCompDefines[DefIdx].FLookup := @FBRBICompareAnsiRightPrefix
              else if AsPrefix then
                FCompDefines[DefIdx].FLookup := @FBRBICompareAnsiLeftPrefix;
            end;
          end;

          else
            raise EUnsupportedCompare.CreateFmt(EUnsupportedCompareMsg, [Field.Name]);
        end;{case}
        inc(DefIdx);
    end{if};
  end;
  SetLength(FCompDefines, DefIdx);
  SetLength(FCompSpecDefines, SpecDefIdx);
  ModifyStamp := ObsoleteStamp;
end;

{ TFBLargeintField }

procedure TFBLargeintField.GetText(var AText: string; ADisplayText: Boolean);
var
  L : LargeInt;
  fmt : string;
begin
  AText:='';
  if GetValue(L) then
  begin
    if ADisplayText or (EditFormat='') then
      fmt:=DisplayFormat
    else
      fmt:=EditFormat;

    if Length(fmt)<>0 then
      AText:=FormatInt64(Fmt, L)
    else
      Str(L, AText);
  end;
end;

end.
