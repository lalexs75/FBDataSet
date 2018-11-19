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
{$IFDEF FPC}
{.$mode objfpc}{$H+}
{$ENDIF}
unit fbmisc;

interface
uses Classes, SysUtils, DB, FBParams, uiblib;

{$I fbmisc.inc}
const
  MaxSortField = 256;

type
  TCharSet = TSysCharSet;

  TFBDsOption =
   (poTrimCharFields,
    poRefreshAfterPost,
    poAutoParamsToFields,
    poFetchAll,
    poFillEmptyEPFromParams,
    poRefreshBeforeEdit,
    poParanoidBLOBRefresh,
    poNotSetDefaultParams
   );

  TFBDsOptions = set of TFBDsOption;
  TUpdateKinds = set of TUpdateKind;

  EFBError = class(EDatabaseError);

  { EFB_UIBError }

  EFB_UIBError = class(Exception)
  private
    FComponentName: string;
    FGDSCode: Integer;
    FErrorCode: Integer;
    FSQLCode  : Integer;
  public
    property ErrorCode: Integer read FErrorCode;
    property SQLCode: Integer read FSQLCode;
    property GDSCode: Integer read FGDSCode;
    property ComponentName:string read FComponentName;
  end;

  { EFB_UIBException }

  EFB_UIBException = class(EFB_UIBError)
  private
    FGDSExceptionText: string;
    FNumber: Integer;
  public
    property Number: Integer read FNumber;
    property GDSExceptionText:string read FGDSExceptionText;
  end;


  TFBErrorID = (fbeCircularReference, fbeEmptySQLEdit, fbeDatabaseNotAssigned,
                fbeTransactionNotAssigned, fbeParameterNotFound,
                fbeNotCachedUpdates, fbeUserAbort, fbeErrorExecuteQ,
                fbeBlobCannotBeWritten, fbeCannotInsert);

  TWhenGetGenID = (wgNever, wgOnNewRecord, wgBeforePost);

  TTransactionKind = (tkDefault, tkReadTransaction, tkUpdateTransaction);

  TBFCurrentOperationState = (cosNone, cosInPost);
  
  { TDefaultFormats }

  TDefaultFormats = class(TPersistent)
  private
    FDisplayFormatDate: string;
    FDisplayFormatDateTime: string;
    FDisplayFormatTime: string;
    FDisplayFormatNumeric: string;
    FDisplayFormatInteger: string;
    FEditFormatInteger: string;
    FEditFormatNumeric: string;
    function IsStoreDT:boolean;
    function IsStoreD:boolean;
    function IsStoreT:boolean;
  protected
    procedure AssignTo(Dest: TPersistent);override;
  public
    constructor Create;
  published
    property DisplayFormatDateTime:string read FDisplayFormatDateTime
                                   write FDisplayFormatDateTime  stored IsStoreDT ;
    property DisplayFormatDate:string read FDisplayFormatDate
                               write FDisplayFormatDate  stored IsStoreD;
    property DisplayFormatTime:string read FDisplayFormatTime
                               write FDisplayFormatTime stored IsStoreT;
    property DisplayFormatNumeric:string read FDisplayFormatNumeric
                               write FDisplayFormatNumeric stored true;
    property DisplayFormatInteger:string read FDisplayFormatInteger
                               write FDisplayFormatInteger stored true;
    property EditFormatNumeric:string read FEditFormatNumeric
                               write FEditFormatNumeric stored true;
    property EditFormatInteger:string read FEditFormatInteger
                               write FEditFormatInteger stored true;
  end;

{$IFDEF FPC}
  TUpdateAction = (uaFail, uaAbort, uaSkip, uaRetry, uaApplied);
  TUpdateRecordEvent = procedure(DataSet: TDataSet; UpdateKind: TUpdateKind;
    var UpdateAction: TUpdateAction) of object;
  TUpdateErrorEvent = procedure(DataSet: TDataSet; E: EDatabaseError;
    UpdateKind: TUpdateKind; var UpdateAction: TUpdateAction) of object;
{$ENDIF}

type
  TFBInternalSortItem = record
    FieldNo:integer;
    Asc:boolean;
  end;

  TFBInternalSortArray = array [0..MaxSortField-1] of TFBInternalSortItem;

type
  TMasterUpdateStatus   = (muClose, muOpen, muFieldChange);
  TDetailCondition      = (dcForceOpen, dcIgnoreMasterClose, dcForceMasterRefresh);
  TDetailConditions     = set of TDetailCondition;
  TMasterScrollBehavior = (msbCancel, msbPost, msbNone);

const
  DefaultMacroChar = '@';
  DefaultTermChar  = '/';
  TrueExpr = '0=0';

procedure FBError(FBErrorID:TFBErrorID; Args:array of const);
procedure FBUIBError(E: Exception; const ComponentName:string);

function FBErrorStr(FBErrorID:TFBErrorID):string;
function QuoteIdentifier(Dialect: Integer; Value: String): String;
function NameDelimiter(C: Char; Delims: TCharSet): Boolean;
function IsLiteral(C: Char): Boolean;
procedure CreateQueryParams(List: TFBParams; const Value: PChar; Macro: Boolean;
  SpecialChar: Char; Delims: TCharSet);
function Copy2LineDel(var S: string;const Line: string): string;


{$IFDEF FPC}
//function ExtractFieldName(const Fields: string; var Pos: Integer): string;
{$ELSE}
function CompareByte(const buf1;const buf2;len: Integer) : Integer;
function CompareChar0(const buf1;const buf2;len: Integer) : Integer;
function IndexChar(const buf;len: Integer;b: Char) : Integer;
{$ENDIF}

{like CompareChar0 but not compares string len: suppress comparing last #0}
function OrderCompareChar0(const buf1;const buf2;len: Integer) : Integer;

{ suppose that buf2 shorter, and compares only length(buf2) characters}
function CompareLeftPrefix(const buf1 : PChar;const buf2 : PChar) : Integer;overload;
function CompareAnsiLeftPrefix(const buf1 : PChar;const buf2 : PChar) : Integer;overload;
function CompareTextLeftPrefix(const buf1 : PChar;const buf2 : PChar) : Integer;overload;

function CompareLeftPrefix(const buf1 : AnsiString;const buf2 : AnsiString) : Integer;overload;
function CompareAnsiLeftPrefix(const buf1 : AnsiString;const buf2 : AnsiString) : Integer;overload;
function CompareAnsiLeftPrefix(const buf1 : WideString;const buf2 : WideString) : Integer;overload;
function CompareTextLeftPrefix(const buf1 : AnsiString;const buf2 : AnsiString) : Integer;overload;
function CompareTextLeftPrefix(const buf1 : WideString;const buf2 : WideString) : Integer;overload;

function CompareWideLeftPrefix(const buf1 : WideString;const buf2 : WideString) : Integer;overload;
function CompareWideTextLeftPrefix(const buf1 : WideString;const buf2 : WideString) : Integer;overload;

{ compares only common prefix chars - min(len(buf1, len(buf2))}
function ComparePrefix(const buf1 : PChar;const buf2 : PChar) : Integer;overload;
function CompareAnsiPrefix(const buf1 : PChar;const buf2 : PChar) : Integer;overload;
function CompareTextPrefix(const buf1 : PChar;const buf2 : PChar) : Integer;overload;

function ComparePrefix(const buf1 : AnsiString;const buf2 : AnsiString) : Integer;overload;
function CompareAnsiPrefix(const buf1 : AnsiString;const buf2 : AnsiString) : Integer;overload;
function CompareAnsiPrefix(const buf1 : WideString;const buf2 : WideString) : Integer;overload;
function CompareTextPrefix(const buf1 : AnsiString;const buf2 : AnsiString) : Integer;overload;
function CompareTextPrefix(const buf1 : WideString;const buf2 : WideString) : Integer;overload;

function CompareWidePrefix(const buf1 : WideString;const buf2 : WideString) : Integer;overload;
function CompareWideTextPrefix(const buf1 : WideString;const buf2 : WideString) : Integer;overload;

function DataSetLocateThrough(DataSet: TDataSet; const KeyFields: string;
  const KeyValues: Variant; Options: TLocateOptions): Boolean;

implementation
uses
{$IFDEF FIX_UTF8LOCATE}
  LCLProc,
{$ENDIF}
  math, uibconst, LazUTF8, variants

{$IFDEF MSWINDOWS}
  , windows
{$endif}
  ;

{$IFDEF FPC}
{$ELSE}
function CompareByte(const buf1;const buf2;len: Integer) : Integer;
var
  buf1Bytes : packed array[0 .. 0] of byte absolute buf1;
  buf2Bytes : packed array[0 .. 0] of byte absolute buf2;
  idx : integer;
begin
  result := 0;
  for idx := 0 to len-1 do begin
    result := buf1Bytes[idx] - buf2Bytes[idx];
    if result <> 0 then break;
  end;
end;

function CompareChar0(const buf1;const buf2;len: Integer) : Integer;
var
  buf1Bytes : packed array[0 .. 0] of char absolute buf1;
  buf2Bytes : packed array[0 .. 0] of char absolute buf2;
  idx : integer;
begin
  result := 0;
  for idx := 0 to len-1 do begin
    result := integer(buf1Bytes[idx]) - integer(buf2Bytes[idx]);
    if result <> 0 then break;
    if (buf1Bytes[idx] = #0) or (buf2Bytes[idx] = #0) then break;
  end;
end;

function IndexChar(const buf;len: Integer;b: Char) : Integer;
var
  idx : integer;
  Chars : array[0 .. 0] of char absolute buf;
begin
  result := -1;
  for idx := 0 to len do begin
    if chars[idx] = b then begin
      result := idx;
      exit;
    end;
  end;
end;
{$ENDIF}

function OrderCompareChar0(const buf1;const buf2;len: Integer) : Integer;
var
  buf1Bytes : packed array[0 .. 0] of char absolute buf1;
  buf2Bytes : packed array[0 .. 0] of char absolute buf2;
  idx : integer;
begin
  result := 0;
  for idx := 0 to len-1 do
  begin
    if (buf1Bytes[idx] = #0) or (buf2Bytes[idx] = #0) then break;
    result := integer(buf1Bytes[idx]) - integer(buf2Bytes[idx]);
    if result <> 0 then break;
  end;
end;

{ suppose that buf1 shorter, and compares only length(buf1) characters}
function CompareLeftPrefix(const buf1 : PChar;const buf2 : PChar) : Integer;
begin
  result := StrLComp(buf1, buf2, StrLen(buf1));
end;

function CompareLeftPrefix(const buf1 : AnsiString;const buf2 : AnsiString) : Integer;
begin
  if min(length(buf1) , length(buf2)) <> 0 then begin
    If length(buf1) < length(buf2) Then
        result := StrLComp(@(buf1[1]), @(buf2[1]), length(buf1))
    else
        result := 1;
  end
  else
    result := length(buf1);
end;

function CompareAnsiLeftPrefix(const buf1 : PChar;const buf2 : PChar) : Integer;
begin
  result := AnsiStrLComp(buf1, buf2, StrLen(buf1));
end;

function CompareAnsiLeftPrefix(const buf1 : AnsiString;const buf2 : AnsiString) : Integer;
begin
  if min(length(buf1) , length(buf2)) <> 0 then begin
    If length(buf1) < length(buf2) Then
          result := AnsiStrLComp(@(buf1[1]), @(buf2[1]), length(buf1))
    else
          result := 1;
  end
  else
    result := length(buf1);
end;

function CompareAnsiLeftPrefix(const buf1 : WideString;const buf2 : WideString) : Integer;
var
  S1, S2 : AnsiString;
begin
  s1 := buf1;
  s2 := buf2;
  result := CompareAnsiLeftPrefix(S1,S2);
end;

function CompareWideLeftPrefix(const buf1 : WideString;const buf2 : WideString) : Integer;
var
  len1, len2 : integer;
{$IFDEF LINUX}
  tmps : WideString;
{$ENDIF}
begin
  len1 := length(buf1);
  len2 := length(buf2);
  if min( len1, len2) <> 0 then begin
    If len2 < len2 Then begin
{$IFDEF MSWINDOWS}
        SetLastError(0);
        Result := CompareStringW(LOCALE_USER_DEFAULT, 0{NORM_IGNORECASE}, @buf1[1],
          len2, @buf2[1], len2) - 2;
        case GetLastError of
            0: ;
            ERROR_CALL_NOT_IMPLEMENTED: Result := CompareAnsiLeftPrefix(buf1, buf2);
            else
              RaiseLastOSError;
        end;
{$ENDIF}
{$IFDEF LINUX}
        tmps := buf2;
        SetLength(tmps,len1);
        Result := WideCompareStr(buf1, tmps);
        tmps := '';
{$ENDIF}
    end
    else
          result := 1;
  end
  else
    result := length(buf1);
end;

function CompareTextLeftPrefix(const buf1 : PChar;const buf2 : PChar) : Integer;
begin
  result := AnsiStrLIComp(buf1, buf2, StrLen(buf1));
end;

function CompareTextLeftPrefix(const buf1 : AnsiString;const buf2 : AnsiString) : Integer;
begin
  if min(length(buf1) , length(buf2)) <> 0 then
    result := IfThen(length(buf1) < length(buf2)
          , AnsiStrLIComp(@(buf1[1]), @(buf2[1]), length(buf1))
          , 1
          )
  else
    result := length(buf1);
end;

function CompareTextLeftPrefix(const buf1 : WideString;const buf2 : WideString) : Integer;
var
  S1, S2 : AnsiString;
begin
  s1 := buf1;
  s2 := buf2;
  result := CompareTextLeftPrefix(S1,S2);
end;

function CompareWideTextLeftPrefix(const buf1 : WideString;const buf2 : WideString) : Integer;overload;
var
  len1, len2 : integer;
{$IFDEF LINUX}
  tmps : WideString;
{$ENDIF}
begin
  len1 := length(buf1);
  len2 := length(buf2);
  if min( len1, len2) <> 0 then begin
    If len2 < len2 Then begin
{$IFDEF MSWINDOWS}
        SetLastError(0);
        Result := CompareStringW(LOCALE_USER_DEFAULT, NORM_IGNORECASE, @buf1[1],
          len2, @buf2[1], len2) - 2;
        case GetLastError of
            0: ;
            ERROR_CALL_NOT_IMPLEMENTED: Result := CompareTextLeftPrefix(buf1, buf2);
            else
              RaiseLastOSError;
        end;
{$ENDIF}
{$IFDEF LINUX}
        tmps := buf2;
        SetLength(tmps,len1);
        Result := WideCompareText(WideUpperCase(buf1), WideUpperCase(tmps));
        tmps := '';
{$ENDIF}
    end
    else
          result := 1;
  end
  else
    result := length(buf1);
end;

{ compares only common prefix chars - min(len(buf1, len(buf2))}
function ComparePrefix(const buf1 : PChar;const buf2 : PChar) : Integer;
begin
  result := StrLComp(buf1, buf2, min(StrLen(buf1), StrLen(buf2)));
end;

function ComparePrefix(const buf1 : AnsiString;const buf2 : AnsiString) : Integer;
var
  len : integer;
begin
  len := min(length(buf1) , length(buf2));
  if len <> 0 then
    result := StrLComp(@(buf1[1]), @(buf2[1]), len)
  else
    result := 0;
end;

function CompareAnsiPrefix(const buf1 : PChar;const buf2 : PChar) : Integer;
begin
  result := AnsiStrLComp(buf1, buf2, min(StrLen(buf1), StrLen(buf2)));
end;

function CompareAnsiPrefix(const buf1 : WideString;const buf2 : WideString) : Integer;
var
  S1, S2 : AnsiString;
begin
  s1 := buf1;
  s2 := buf2;
  result := CompareAnsiPrefix(S1,S2);
end;

function CompareAnsiPrefix(const buf1 : AnsiString;const buf2 : AnsiString) : Integer;
var
  len : integer;
begin
  len := min(length(buf1) , length(buf2));
  if len <> 0 then
    result := AnsiStrLComp(@(buf1[1]), @(buf2[1]), len)
  else
    result := 0;
end;

function CompareTextPrefix(const buf1 : PChar;const buf2 : PChar) : Integer;
begin
  result := AnsiStrLIComp(buf1, buf2, min(StrLen(buf1), StrLen(buf2)));
end;

function CompareTextPrefix(const buf1 : AnsiString;const buf2 : AnsiString) : Integer;
var
  len : integer;
begin
  len := min(length(buf1) , length(buf2));
  if len <> 0 then
    result := AnsiStrLIComp(@(buf1[1]), @(buf2[1]), len)
  else
    result := 0;
end;

function CompareTextPrefix(const buf1 : WideString;const buf2 : WideString) : Integer;
var
  S1, S2 : AnsiString;
begin
  s1 := buf1;
  s2 := buf2;
  result := CompareTextPrefix(S1,S2);
end;

function CompareWidePrefix(const buf1 : WideString;const buf2 : WideString) : Integer;
var
  len : integer;
{$IFDEF LINUX}
  tmps : WideString;
{$ENDIF}
begin
  len := min(length(buf1) , length(buf2));
  if len <> 0 then begin
{$IFDEF MSWINDOWS}
        SetLastError(0);
        Result := CompareStringW(LOCALE_USER_DEFAULT, 0{NORM_IGNORECASE}, @buf1[1],
          len, @buf2[1], len) - 2;
        case GetLastError of
            0: ;
            ERROR_CALL_NOT_IMPLEMENTED: Result := CompareAnsiPrefix(buf1, buf2);
            else
              RaiseLastOSError;
        end;
{$ENDIF}
{$IFDEF LINUX}
        if length(buf1) < length(buf2) then begin
          tmps := buf2;
          SetLength(tmps,len);
          Result := WideCompareStr(buf1, tmps);
        end
        else begin
          tmps := buf1;
          SetLength(tmps,len);
          Result := WideCompareStr(tmps, buf2);
        end;
        tmps := '';
{$ENDIF}
  end
  else
    result := length(buf1);
end;

function CompareWideTextPrefix(const buf1 : WideString;const buf2 : WideString) : Integer;overload;
var
  len : integer;
{$IFDEF LINUX}
  tmps : WideString;
{$ENDIF}
begin
  len := min(length(buf1) , length(buf2));
  if len <> 0 then begin
{$IFDEF MSWINDOWS}
        SetLastError(0);
        Result := CompareStringW(LOCALE_USER_DEFAULT, NORM_IGNORECASE, @buf1[1],
          len, @buf2[1], len) - 2;
        case GetLastError of
            0: ;
            ERROR_CALL_NOT_IMPLEMENTED: Result := CompareTextPrefix(buf1, buf2);
            else
              RaiseLastOSError;
        end;
{$ENDIF}
{$IFDEF LINUX}
        if length(buf1) < length(buf2) then begin
          tmps := buf2;
          SetLength(tmps,len);
          Result := WideCompareStr(WideUpperCase(buf1), WideUpperCase(tmps));
        end
        else begin
          tmps := buf1;
          SetLength(tmps,len);
          Result := WideCompareStr(WideUpperCase(tmps), WideUpperCase(buf2));
        end;
        tmps := '';
{$ENDIF}
  end
  else
    result := length(buf1);
end;

procedure FBError(FBErrorID:TFBErrorID; Args:array of const);
begin
   raise EFBError.CreateFmt(FBErrorStr(FBErrorID), Args);
end;

function GetGDSExceptText(EMsg:string):string;
var
  S:string;
begin
  //Error msg in 3-ed line of exception????
  S:=EMsg;
  Result:=Copy2LineDel(EMsg, NewLine);
  Result:=Copy2LineDel(EMsg, NewLine);
  Result:=Copy2LineDel(EMsg, NewLine);
  if Result = '' then
    Result := S;
end;

procedure FBUIBError(E: Exception; const ComponentName: string);
var
  EUIB:EFB_UIBError;
  EUIBExcept:EFB_UIBException;
begin
  if E is EUIBException then
  begin
   EUIBExcept:=EFB_UIBException.Create(E.Message);
   EUIBExcept.FGDSExceptionText:=GetGDSExceptText(E.Message);
   EUIBExcept.FComponentName:=ComponentName;
   EUIBExcept.FErrorCode:=EUIBException(E).ErrorCode;
   EUIBExcept.FSQLCode:=EUIBException(E).SQLCode;
   EUIBExcept.FGDSCode:=EUIBException(E).GDSCode;
   EUIBExcept.FNumber:=EUIBException(E).Number;
   raise EUIBExcept;
  end
  else
  if (E is EUIBError) then
  begin
   EUIB:=EFB_UIBError.Create(E.Message);
   EUIB.FComponentName:=ComponentName;
   EUIB.FErrorCode:=EUIBError(E).ErrorCode;
   EUIB.FSQLCode:=EUIBError(E).SQLCode;
   EUIB.FGDSCode:=EUIBError(E).GDSCode;
   raise EUIB;
  end
    else
    FBError(fbeErrorExecuteQ, [ComponentName, E.Message]);
end;

function FBErrorStr(FBErrorID:TFBErrorID):string;
begin
  case FBErrorID of
    fbeCircularReference:Result:=sfbeCircularReference;
    fbeEmptySQLEdit:Result:=sfbeEmptySQLEdit;
    fbeDatabaseNotAssigned:Result:=sfbeDatabaseNotAssigned;
    fbeTransactionNotAssigned:Result:=sfbeTransactionNotAssigned;
    fbeParameterNotFound:Result:=sfbeParameterNotFound;
    fbeNotCachedUpdates:Result:=sfbeNotCachedUpdates;
    fbeUserAbort:Result:=sfbeUserAbort;
    fbeErrorExecuteQ:Result:=sfbeErrorExecuteQ;
    fbeBlobCannotBeWritten:Result:=sfbeBlobCannotBeWritten;
    fbeCannotInsert:Result:=sfbeCannotInsert;
  else
    Result:=sfbeOtherError;
  end;
end;

function Copy2LineDel(var S: string;const Line: string): string;
var
  p: Integer;
begin
  p:=Pos(Line, S);
  if p=0 then
  begin
    Result:= S;
    S:='';
  end
  else
  begin
    Result:=Copy(S, 1, P-1);
    Delete(S, 1, P + Length(Line)-1);
  end;
end;

function QuoteIdentifier(Dialect: Integer; Value: String): String;
begin
  if Dialect = 1 then
    Value := AnsiUpperCase(Trim(Value))
  else
    Value := '"' + StringReplace (Value, '"', '""', [rfReplaceAll]) + '"';
  Result := Value;
end;

function NameDelimiter(C: Char; Delims: TCharSet): Boolean;
begin
  Result := (C in [' ', ',', ';', ')', #13, #10]) or (C in Delims);
end;

function IsLiteral(C: Char): Boolean;
begin
  Result := C in ['''', '"'];
end;

procedure CreateQueryParams(List: TFBParams; const Value: PChar; Macro: Boolean;
  SpecialChar: Char; Delims: TCharSet);
var
  CurPos, StartPos: PChar;
  CurChar: Char;
  Literal: Boolean;
  EmbeddedLiteral: Boolean;
  Name: string;

  function StripLiterals(Buffer: PChar): string;
  var
    Len: Word;
    TempBuf: PChar;

    procedure StripChar(Value: Char);
    begin
      if TempBuf^ = Value then
        StrMove(TempBuf, TempBuf + 1, Len - 1);
      if TempBuf[StrLen(TempBuf) - 1] = Value then
        TempBuf[StrLen(TempBuf) - 1] := #0;
    end;

  begin
    Len := StrLen(Buffer) + 1;
    TempBuf := AllocMem(Len);
    Result := '';
    try
      StrCopy(TempBuf, Buffer);
      StripChar('''');
      StripChar('"');
      Result := StrPas(TempBuf);
    finally
      FreeMem(TempBuf, Len);
    end;
  end;

begin
  if SpecialChar = #0 then Exit;
  CurPos := Value;
  Literal := False;
  EmbeddedLiteral := False;
  repeat
    CurChar := CurPos^;
    if (CurChar = SpecialChar) and not Literal and ((CurPos + 1)^ <> SpecialChar) then
    begin
      StartPos := CurPos;
      while (CurChar <> #0) and (Literal or not NameDelimiter(CurChar, Delims)) do begin
        Inc(CurPos);
        CurChar := CurPos^;
        if IsLiteral(CurChar) then begin
          Literal := Literal xor True;
          if CurPos = StartPos + 1 then EmbeddedLiteral := True;
        end;
      end;
      CurPos^ := #0;
      if EmbeddedLiteral then begin
        Name := StripLiterals(StartPos + 1);
        EmbeddedLiteral := False;
      end
      else Name := StrPas(StartPos + 1);
      if Assigned(List) then
      begin
        if List.FindParam(Name) = nil then
        begin
          if Macro then
            List.CreateParam(Name).Value := TrueExpr
          else List.CreateParam(Name);
        end;
      end;
      CurPos^ := CurChar;
      StartPos^ := '?';
      Inc(StartPos);
      StrMove(StartPos, CurPos, StrLen(CurPos) + 1);
      CurPos := StartPos;
    end
    else if (CurChar = SpecialChar) and not Literal and ((CurPos + 1)^ = SpecialChar) then
      StrMove(CurPos, CurPos + 1, StrLen(CurPos) + 1)
    else if IsLiteral(CurChar) then Literal := Literal xor True;
    Inc(CurPos);
  until CurChar = #0;
end;

{ TDefaultFormats }

procedure TDefaultFormats.AssignTo(Dest: TPersistent);
begin
  if Dest is TDefaultFormats then
  with Dest as TDefaultFormats do
  begin
    FDisplayFormatDate:=Self.FDisplayFormatDate;
    FDisplayFormatDateTime:=Self.FDisplayFormatDateTime;
    FDisplayFormatTime:=Self.FDisplayFormatTime;
    FDisplayFormatNumeric:=Self.FDisplayFormatNumeric;
    FDisplayFormatInteger:=Self.FDisplayFormatInteger;
    FEditFormatNumeric:=Self.FEditFormatNumeric;
    FEditFormatInteger:=Self.FEditFormatInteger;
  end
  else
    inherited AssignTo(Dest)
end;

constructor TDefaultFormats.Create;
begin
  FDisplayFormatDateTime:=ShortDateFormat + ' '+ShortTimeFormat;
  FDisplayFormatDate:=ShortDateFormat;
  FDisplayFormatTime:=ShortTimeFormat;
  FDisplayFormatNumeric:='#,##0.0';
  FDisplayFormatInteger:='#,##0';
  FEditFormatNumeric:='#0.0';
  FEditFormatInteger:='#0';
end;

function TDefaultFormats.IsStoreD: boolean;
begin
  Result := FDisplayFormatDate <> ShortDateFormat;
end;

function TDefaultFormats.IsStoreDT: boolean;
begin
  Result := FDisplayFormatDateTime<>(ShortDateFormat + ' '+ShortTimeFormat);
end;

function TDefaultFormats.IsStoreT: boolean;
begin
  Result := FDisplayFormatTime <> ShortTimeFormat;
end;

function DataSetLocateThrough(DataSet: TDataSet; const KeyFields: string;
  const KeyValues: Variant; Options: TLocateOptions): Boolean;
var
  FieldCount: Integer;
  Fields: TList;

  function CompareField(Field: TField; Value: Variant): Boolean;
  var
    S, S1: string;
  begin
    if Field.DataType = ftString then
    begin
      S := Field.AsString;
      S1:=Value;
      if (loPartialKey in Options) then
        Delete(S, Length(S1) + 1, MaxInt);
      if (loCaseInsensitive in Options) then
      {$IFDEF FIX_UTF8LOCATE}
          Result := AnsiCompareText(UTF8UpperCase(S), UTF8UpperCase(S1)) = 0
      {$ELSE}
          Result := AnsiCompareText(S, S1) = 0
      {$ENDIF}
      else
        Result := AnsiCompareStr(S, S1) = 0;
    end
    else
      Result := (Field.Value = Value);
  end;

  function CompareRecord: Boolean;
  var
    I: Integer;
  begin
    if (FieldCount = 1) and (not VarIsArray(KeyValues)) then
      Result := CompareField(TField(Fields.First), KeyValues)
    else
    begin
      Result := True;
      for I := 0 to FieldCount - 1 do
        Result := Result and CompareField(TField(Fields[I]), KeyValues[I]);
    end;
  end;
var
  Bookmark: TBookmark;
begin
  Result := False;
  with DataSet do begin
    CheckBrowseMode;
    if BOF and EOF then Exit;
  end;
  Fields := TList.Create;
  try
    DataSet.GetFieldList(Fields, KeyFields);
    FieldCount := Fields.Count;
    Result := CompareRecord;
    if Result then Exit;
    DataSet.DisableControls;
    try
{$IFDEF NoAutomatedBookmark}
      Bookmark := DataSet.GetBookmark;
{$ELSE}
      Bookmark := DataSet.Bookmark;
{$ENDIF}
      try
        with DataSet do begin
          First;
          while not EOF do begin
            Result := CompareRecord;
            if Result then Break;
            Next;
          end;
        end;
      finally
        if not Result {$IFDEF RX_D3} and
          DataSet.BookmarkValid(PChar(Bookmark)) {$ENDIF} then
{$IFDEF NoAutomatedBookmark}
          DataSet.GotoBookmark(Bookmark);
{$ELSE}
          DataSet.Bookmark := Bookmark;
{$ENDIF}
      end;
    finally
      DataSet.FreeBookmark(Bookmark);
      DataSet.EnableControls;
    end;
  finally
    Fields.Free;
  end;
end;

end.

