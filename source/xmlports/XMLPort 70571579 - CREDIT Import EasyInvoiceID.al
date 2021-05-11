xmlport 70571579 "CREDIT Import EasyInvoice ID"
{
    // version EasyInvoice 2020.06.29.01

    Direction = Import;
    FieldSeparator = ';';
    Format = VariableText;


    schema
    {
        textelement(Root)
        {
            tableelement("Easy Invoice Connection"; "CREDIT Easy Invoice Connection")
            {
                XmlName = 'EasyInvoiceConnection';
                UseTemporary = false;
                AutoReplace = true;
                AutoUpdate = true;
                fieldelement(Type; "Easy Invoice Connection".Type)
                {
                }
                fieldelement(DocNo; "Easy Invoice Connection"."Document No.")
                {
                }
                fieldelement(EasyInvoiceID; "Easy Invoice Connection".EasyInvoiceID)
                {
                }
                trigger OnAfterInsertRecord()
                var
                    VendLedEntry: record "Vendor Ledger Entry";
                    lEasyINvConnect: Record "CREDIT Easy Invoice Connection";
                begin

                    IF ("Easy Invoice Connection".Type = "Easy Invoice Connection".Type::"Posted Purchase Credit Memo") OR
                       ("Easy Invoice Connection".Type = "Easy Invoice Connection".Type::"Posted Purchase Invoice") THEN begin
                        VendLedEntry.SetRange("Document No.", "Easy Invoice Connection"."Document No.");

                        IF "Easy Invoice Connection".Type = "Easy invoice Connection".type::"Posted Purchase Credit Memo" THEN
                            VendLedEntry.SetRange("Document Type", VendLedEntry."Document Type"::"Credit Memo")
                        else
                            VendLedEntry.SetRange("Document Type", VendLedEntry."Document Type"::Invoice);


                        IF VendLedEntry.FindFirst() THEN BEGIN
                            lEasyINvConnect.Type := lEasyINvConnect.Type::"Vendor Ledger Entry";
                            lEasyINvConnect."Document No." := FORMAT(VendLedEntry."Entry No.");
                            lEasyINvConnect.EasyInvoiceID := "Easy Invoice Connection".EasyInvoiceID;
                            IF lEasyINvConnect.Insert(true) then;
                        END;
                    END;
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
    trigger OnPostXmlPort()
    begin
        IF GuiAllowed THEN
            IF Confirm('Ready') THEN;
    end;

}

