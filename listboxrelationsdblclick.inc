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

type
  TFieldInfo = class
    Description:string;
    CalcField:boolean;
    constructor Create(const ADescription:string; ACalcField:boolean);
  end;

  { TFieldInfo }
constructor TFieldInfo.Create(const ADescription:string; ACalcField:boolean);
begin
  inherited Create;
  Description:=ADescription;
  CalcField:=ACalcField;
end;


  { TFBCustomDataSetSQLEditor }
procedure TFBCustomDataSetSQLEditor.ListBoxRelationsDblClick(
   Sender: TObject);
var
  i: integer;
  Als, FieldsStr, Tmp: string;
  S_FIELD: String;
  S_VAL: String;
begin
  if ActiveEditor <> nil then
  begin
    if (ListBoxRelations.Items.Count>0) and (ListBoxRelations.ItemIndex>-1) and
       (ListBoxRelations.ItemIndex<ListBoxRelations.Items.Count) then
    with ActiveEditor do
    begin
      if CheckBox1.Checked then Lines.Clear;
      case Pagecontrol1.ActivePageIndex of
        0:begin
            if ListBoxFields.SelCount = 0 then
            begin
              Lines.Add('select');
              Lines.Add('  *');
              Lines.Add('from');
              if Edit1.Text<> '' then
                Lines.Add('  ' + ListBoxRelations.Items[ListBoxRelations.ItemIndex] + ' ' + Edit1.Text)
              else
                Lines.Add('  ' + ListBoxRelations.Items[ListBoxRelations.ItemIndex]);
            end
            else
            begin
              Lines.Add('select');
              if Edit1.Text <> '' then
                Als := Edit1.Text
              else
                Als := ListBoxRelations.Items[ListBoxRelations.ItemIndex];
              FieldsStr := '';
              for i := 0 to ListBoxFields.Items.Count - 1 do
              begin
                if ListBoxFields.Selected[i] then
                begin
                  if FieldsStr <> '' then Lines.Add(FieldsStr + ',');
                  FieldsStr := '  ' + Als + '.' + ListBoxFields.Items[i];
                end;
              end;
              if FieldsStr <> '' then Lines.Add(FieldsStr);
              Lines.Add('from');
              if Als <> ListBoxRelations.Items[ListBoxRelations.ItemIndex] then
                Lines.Add('  ' + ListBoxRelations.Items[ListBoxRelations.ItemIndex] + ' ' + Als)
              else
                Lines.Add('  ' + ListBoxRelations.Items[ListBoxRelations.ItemIndex]);
            end;
          end;
        1:begin
            Lines.clear;
            Lines.Add('insert into ' + ListBoxRelations.Items[ListBoxRelations.ItemIndex]);

            if ListBoxFields.SelCount > 0 then
            begin
              S_FIELD:='';
              S_VAL:='';
              for i:=0 to ListBoxFields.Items.Count - 1 do
              begin
                if ListBoxFields.Selected[i] then
                begin
                  S_FIELD:=S_FIELD + ListBoxFields.Items[i] + ', ';
                  S_VAL:=S_VAL + ':'+ ListBoxFields.Items[i] + ', ';
                end;
              end;
              S_FIELD:=Copy(S_FIELD, 1, Length(S_FIELD) - 2);
              S_VAL:=Copy(S_VAL, 1, Length(S_VAL)-2);

              Lines.Add('  ('+ S_FIELD +')');
              Lines.Add('values');
              Lines.Add('  ('+ S_VAL +')');
            end
            else
            begin
              Tmp := ListBoxFields.Items[0];
              if ListBoxFields.Items.Count - 1 > 0 then
              begin
                for i := 1 to ListBoxFields.Items.Count - 1 do
                  tmp := tmp + ', ' + ListBoxFields.Items[i];
              end;
              tmp := '(' + tmp + ')';
              Lines.Add(tmp);
              Tmp := ':' + ListBoxFields.Items[0];
              if ListBoxFields.Items.Count - 1 > 0 then
              begin
                for i := 1 to ListBoxFields.Items.Count - 1 do
                  tmp := tmp + ', ' + ':' + ListBoxFields.Items[i];
              end;
              tmp := 'values (' + tmp + ')';
              Lines.Add(tmp);
            end;
          end;
        2: GenerateUpdateSQLText;
        3:begin
            Lines.clear;
            Lines.Add('delete');
            Lines.Add('from');
            Lines.Add('  '+ListBoxRelations.Items[ListBoxRelations.ItemIndex]);
            GenerateWhereSQLText(ListBoxRelations.Items[ListBoxRelations.ItemIndex]);
            end;
        4:begin
            Lines.clear;
            Lines.Add('select');
            Lines.Add('  *');
            Lines.Add('from');
            Lines.Add('  ' +ListBoxRelations.Items[ListBoxRelations.ItemIndex]);
            GenerateWhereSQLText(ListBoxRelations.Items[ListBoxRelations.ItemIndex]);
          end;
      end;
    end;
  end;
end;


procedure TFBCustomDataSetSQLEditor.btnTestClick(Sender: TObject);
begin
  if Assigned(FDS.DataBase) and Assigned(FDS.Transaction) then
  begin
    FBCustomDataSetSQLEditorTestForm:=TFBCustomDataSetSQLEditorTestForm.Create(Application);
    try
      FBCustomDataSetSQLEditorTestForm.FBDataSetTest.DataBase:=FDS.DataBase;
      FBCustomDataSetSQLEditorTestForm.FBDataSetTest.Transaction:=FDS.Transaction;
      FBCustomDataSetSQLEditorTestForm.FBDataSetTest.SQLSelect.Text:=ActiveEditor.Lines.Text;
      FBCustomDataSetSQLEditorTestForm.FBDataSetTest.DefaultFormats.Assign(FDS.DefaultFormats);
      FBCustomDataSetSQLEditorTestForm.FBDataSetTest.Open;
      FBCustomDataSetSQLEditorTestForm.SynEdit1.Text:=FBCustomDataSetSQLEditorTestForm.FBDataSetTest.QuerySelect.Plan;
      FBCustomDataSetSQLEditorTestForm.SynEdit1.Highlighter:=SynSQLSyn1;
      FBCustomDataSetSQLEditorTestForm.Caption:='Test of '+FBCustomDataSetSQLEditorTestForm.FBDataSetTest.Name+' - '+PageControl1.ActivePage.Caption;
      FBCustomDataSetSQLEditorTestForm.ShowModal
    except
      on E:Exception do
        ShowMessage(E.Message);
    end;
    FBCustomDataSetSQLEditorTestForm.Free
  end;
end;

