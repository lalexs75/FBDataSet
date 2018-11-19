function FormatInt64(const Format: string; N: Int64): string;
// The function formats long integers (Int64).
// It uses FormatFloat function to format less than 19-digit numbers.
// RESTRICTION: only first section of Format will work for 19-digits numbers
//             (about sections see FormatFloat help).
// WARNING: if the function finds any error or strangeness in Format string
//          then it uses the standard IntToStr function, without formatting.
// Author: Mikhail Korolev <mialko@mail.ru>
// Created: 11.08.2009 for Aleksey Lagunov's FBDataset.
// Last modified: 11.08.2009
const
  POWER_10_18: Int64 = 1000000000000000000; // 18 zeroes
type
  TFmtStr = AnsiString;
  TFmtChar = AnsiChar;
var
  LeftN, RightN: Int64;
    Fmt, LeftFmt, RightFmt: TFmtStr;
    DPArr: array [1..255] of byte; // array of digit position in Format
    DPCnt: integer;
    DecPointPos: integer;
    SeparateThousands: boolean;
    BadFormat: boolean;
    FirstSectionLength: integer;
    LastWholeDPCnt: integer;
    index19: integer;
    i: integer;
    FS: TFormatSettings;

    procedure ParseFmt;
    // Parse Format string and fill external vars
    var i: integer;
        ch: TFmtChar;
        QCh: TFmtChar;
        InQ: boolean;
    begin //ParseFmt
       QCh:= #0; // Anti-warning
       InQ:= FALSE;
       DPCnt:= 0;
       DecPointPos:= 0;
       SeparateThousands:= FALSE;
       BadFormat:= FALSE;
       FirstSectionLength:= length(Format);
       LastWholeDPCnt:= 0;

       for i:= 1 to length(Format) do
       begin
          ch:= Format[i];
          if InQ then
          begin // Process "in quota" case separately
             if ch = QCh then // text end
                InQ:= FALSE;
             CONTINUE; // for cycle
          end;
          case ch of
             '"','''': begin // Quotation mark - text begin
                QCh:= ch;
                InQ:= TRUE;
             end;
             '#','0': begin // Digit position
                inc(DPCnt);
                DPArr[DPCnt]:= i;
             end;
             '.': begin // Decimal point
                if DecPointPos <> 0 then begin
                   BadFormat:= TRUE;
                   BREAK; // from for cycle
                end;
                DecPointPos:= i;
                LastWholeDPCnt:= DPCnt;
             end;
             ',': begin// Thousand separator
                SeparateThousands:= TRUE;
             end;
             'E','e': begin// Scientific notation
                BadFormat:= TRUE;
                BREAK; // from for cycle
             end;
             ';': begin // Sections separator
                FirstSectionLength:= i-1;
                BREAK; // from for cycle
             end;
             else begin // Unknown char
                BadFormat:= TRUE;
                BREAK; // from for cycle
             end;
          end;//case
       end;//for
       if LastWholeDPCnt = 0 then
          LastWholeDPCnt:= DPCnt;
       if InQ then
          BadFormat:= TRUE;
    end;(*ParseFmt*)
   (*-------------*)

begin //FormatInt64
   if ((N > -POWER_10_18) and (N < POWER_10_18)) or // <= 18 digits in N
      (length(Format) > 255)                        // Too long format
   then
   begin
      result:= FormatFloat(Format, N);
      Exit;
   end;
   // 19 digits in N
   ParseFmt; // Parse Format string
   if BadFormat or (FirstSectionLength = 0) or (DPCnt = 0) then
   begin
      result:= IntToStr(N);
      //result:= FormatFloat(Format, N);  // It is the variant, too.
      Exit;
   end;

   // Numbers
   LeftN:= N div POWER_10_18;
   RightN:= N mod POWER_10_18;
   if RightN < 0 then
      RightN:= -RightN;

   // Formats
   Fmt:= copy(Format, 1, FirstSectionLength); // First section only
   if LastWholeDPCnt > 18 then
   begin // enough digit positions for 19 digits
      index19:= LastWholeDPCnt-18;
      LeftFmt:= copy(Fmt, 1, DPArr[index19]); // to 19th from right dig, inclusive
      for i:= index19+1 to LastWholeDPCnt do
         Fmt[DPArr[i]]:= '0';
      RightFmt:= copy(Fmt, DPArr[index19]+1, 999);
   end
   else
   begin // 18 or less digit positions in Format
      LeftFmt:= copy(Fmt, 1, DPArr[1]); // Use upto 1st from left digit placeholder
      for i:= 1 to LastWholeDPCnt do
         Fmt[DPArr[i]]:= '0';
      SetLength(RightFmt, 18-LastWholeDPCnt);
      if length(RightFmt) > 0 then
         FillChar(RightFmt[1], length(RightFmt), '0');
      RightFmt:= RightFmt + copy(Fmt, DPArr[1], 999);
   end;
   if SeparateThousands then
      RightFmt:= RightFmt + ',';

   // Result
   result:= FormatFloat(LeftFmt, LeftN);
   if SeparateThousands then
   begin
{$IFDEF FPC}
      Result:= Result + ThousandSeparator;
{$ELSE}
      GetLocaleFormatSettings(0, FS);
      Result:= Result + FS.ThousandSeparator;
{$ENDIF}
   end;
    result:= result + FormatFloat(RightFmt, RightN);
end;(*FormatInt64*)
(*---------------*)

