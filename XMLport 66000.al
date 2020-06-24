xmlport 66000 "Easy Invoice MasterDataV2"
{
    // version EasyInvoice 2020.06.27.01

    // MCONNECT 2017-08-01 Cred-IT Object created

    Direction = Export;
    UseDefaultNamespace = true;

    schema
    {
        textelement(Root)
        {
            MinOccurs = Zero;
            textattribute(xmlns1)
            {
                TextType = Text;
                XmlName = 'xmlns1';
            }
            tableelement(table;Integer)
            {
                MinOccurs = Zero;
                XmlName = 'Table';
                SourceTableView = SORTING(Number)
                                  ORDER(Ascending);
                UseTemporary = true;
                textelement(table_no)
                {
                    XmlName = 'TableNo';

                    trigger OnBeforePassVariable();
                    begin
                        Table_No := FORMAT(RecRef.NUMBER);
                    end;
                }
                textelement(test1)
                {
                    XmlName = 'TableName';
                }
                textelement(tablefilters)
                {
                    XmlName = 'TableFilters';

                    trigger OnBeforePassVariable();
                    begin
                        TableFilters := KeyFilter;
                    end;
                }
                textelement(fieldfilterz)
                {
                    XmlName = 'FieldFilters';

                    trigger OnBeforePassVariable();
                    begin
                        FieldFilterz := FieldFilter;
                    end;
                }
                textelement(recordfilterz)
                {
                    XmlName = 'RecordFilter';

                    trigger OnBeforePassVariable();
                    begin
                        RecordFilterz := RecordFilter;
                    end;
                }
                tableelement(record;Integer)
                {
                    XmlName = 'Record';
                    SourceTableView = SORTING("Number");
                    tableelement(fieldtmp;Field)
                    {
                        LinkFields = "No."=FIELD("Number");
                        LinkTable = "Table";
                        XmlName = 'Field';
                        UseTemporary = true;
                        fieldattribute(FieldNo;FieldTmp."No.")
                        {
                            Occurrence = Required;
                        }
                        fieldattribute(FieldName;FieldTmp."Field Caption")
                        {
                            Occurrence = Optional;
                        }
                        textattribute(FieldValue)
                        {
                            Occurrence = Optional;
                        }

                        trigger OnAfterGetRecord();
                        begin
                            FieldValue := GetFieldValue(RecRef,Table.Number,FieldTmp."No.");
                        end;
                    }

                    trigger OnAfterGetRecord();
                    begin
                        IF Record.Number > 1 THEN
                          IF RecRef.NEXT = 0 THEN
                            currXMLport.BREAK;
                    end;

                    trigger OnPreXmlItem();
                    begin
                        Record.SETRANGE(Number,1,RecRef.COUNT);

                        IF RecordFilter <> ''  THEN BEGIN
                          Record.SETFILTER(Number,RecordFilter);
                          IF Record.FINDFIRST THEN
                            RecRef.NEXT(Record.Number-1);
                        END;
                    end;
                }

                trigger OnAfterGetRecord();
                begin
                    FieldTmp.DELETEALL;
                    CLEAR(RecRef);
                    RecRef.OPEN(Table.Number);
                    IF KeyFilter <> '' THEN
                      RecRef.SETVIEW(KeyFilter);

                    
                    Test1 := FORMAT(RecRef.NAME);
                    IF NOT RecRef.FINDSET THEN
                      currXMLport.SKIP;
                    CreateFields(Table.Number,FieldFilter);
                end;

                trigger OnPreXmlItem();
                begin
                    //<<************ TEST VALUES)
                    //TableFilter := '27'; //**** number **
                    //FieldFilter := '1..10';
                    //KeyFilter := 'SORTING(No) ORDER(Ascending) WHERE (No.=FILTER(1000..2000))';
                    //RecordFilter := '1..100'
                    //>>****************************

                    CreateTables(TableFilter);
                end;
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    trigger OnPreXmlPort();
    begin
        xmlns1 := 'urn:microsoft-dynamics-nav/xmlports/x55000';
    end;

    var
        i : Integer;
        RecRef : RecordRef;
        TableName : Text;
        TableFilter : Text;
        FieldFilter : Text;
        KeyFilter : Text;
        RecordFilter : Text;

    

    local procedure GetFieldValue(var recRef : RecordRef;var intTableID : Integer;var intFieldNo : Integer) ValueOut : Text;
    var
        blnValue : Boolean;
        decValue : Decimal;
        i : Integer;
        intValue : Integer;
        DocNameSpace : Text[50];
        txtFieldName : Text[250];
        txtTemp1 : Text[1024];
        intNo : Integer;
        j : Integer;
        FilterChar : Text[10];
        Found : Boolean;
        FuncPos : Integer;
        "*****" : Integer;
        txtAlias : array [100] of Text[250];
        txtCommand : Text[250];
        txtTable : Text[250];
        txtTableName : Text[250];
        txtFilters : array [100] of Text[250];
        txtFilterValues : array [100] of Text[250];
        txtOutput : array [100] of Text[250];
        txtIndex : array [100] of Text[250];
        refField : FieldRef;
        recField : Record Field;
        txtTemp : Text[1024];
        OrgLanguage : Integer;
        OutputType : Option " ","Fields",Number;
    begin

        //FIELDS FROM TABLE
        i:=1;
        IF txtAlias[i] <> '' THEN
          txtFieldName := txtAlias[i]
        ELSE
          txtFieldName := txtOutput[i];

        recField.RESET;
        recField.SETRANGE(TableNo,intTableID);
        recField.SETRANGE("No.",intFieldNo);

        IF recField.FINDFIRST THEN BEGIN
          txtFieldName := recField.FieldName;
          refField:=recRef.FIELD(recField."No.");
          IF recField.Class = recField.Class::FlowField THEN
            refField.CALCFIELD;

          ValueOut := FORMAT(refField.VALUE);
          CASE recField.Type OF
            recField.Type::Boolean:
              BEGIN
                blnValue := refField.VALUE;
                ValueOut := ConvertBoolToText(blnValue);
              END;
            recField.Type::DateFormula:
              BEGIN
                ValueOut := ConvertDateFormToInt(ValueOut);
              END;
            recField.Type::Decimal:
              BEGIN
                decValue := refField.VALUE;
                ValueOut := ConvertDecToText(decValue);
              END;
          END;
        END;
    end;

    local procedure ConvertBoolToText(pBool : Boolean) : Code[20];
    begin
        IF pBool THEN
          EXIT('TRUE')
        ELSE
          EXIT('FALSE');
    end;

    local procedure ConvertTextToBool(pText : Code[20]) : Boolean;
    begin
        IF pText[1] IN ['T','J'] THEN
          EXIT(TRUE)
        ELSE
          EXIT(FALSE);
    end;

    local procedure ConvertDecToText(pValue : Decimal) Result : Text[30];
    begin
        Result := FORMAT(pValue,0,'<Precision,2:2><Sign><Integer><Decimals>');
        Result := CONVERTSTR(Result,',','.');
    end;

    local procedure ConvertTextToDec(pText : Text[30]) Result : Decimal;
    var
        I : Decimal;
        txtSeperator : Text[1];
    begin
        I := 0.25;
        txtSeperator := COPYSTR(FORMAT(I),2,1);

        pText := CONVERTSTR(pText,'.',txtSeperator);
        IF NOT(EVALUATE(Result,pText)) THEN
          Result := 0;
    end;

    local procedure ConvertDateFormToInt(Ptext : Text) : Text;
    var
        charlc : Char;
    begin
        FOR i := 1 TO STRLEN(Ptext) DO BEGIN
          charlc := Ptext[i];
          IF NOT (charlc IN [1,2,3,4,5,6,7,8,9,0]) THEN
            EXIT(COPYSTR(Ptext,1,i+1));
        END;
    end;

    local procedure CreateTables(TableFilterIn : Text);
    var
        Numberrec : Record integer;
    begin
        WITH Numberrec DO BEGIN
          SETFILTER(Number,TableFilterIn);
          IF FINDSET THEN
            REPEAT
              Table := Numberrec;
              IF Table.INSERT THEN;
          UNTIL NEXT = 0;
        END;
    end;

    local procedure CreateFields(TableFilterIn : Integer;FieldFilterIn : Text);
    var
        FieldRec : Record Field;
    begin
        WITH FieldRec DO BEGIN
          SETRANGE(TableNo,TableFilterIn);
          IF FieldFilter <> '' THEN
            SETFILTER("No.",FieldFilterIn);
          IF FINDSET THEN
            REPEAT
              FieldTmp := FieldRec;
              FieldTmp.INSERT;
            UNTIL NEXT = 0;
        END;
    end;

    procedure SetParameters(var TableFilterIn : Text;var FieldFilterIn : Text;var KeyIn : Text;var RecordFilterIn : Text);
    begin
        TableFilter := TableFilterIn;
        FieldFilter := FieldFilterIn;
        KeyFilter := KeyIn;
        RecordFilter := RecordFilterIn;
    end;
}

