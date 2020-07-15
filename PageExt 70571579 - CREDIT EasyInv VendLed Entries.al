pageextension 70571579 "CREDIT EasyInv VendLed Entries" extends "Vendor Ledger Entries"
{

    layout
    {

        addafter("Posting Date")
        {
            field(EasyInvoiceID; EasyInvoiceCon.EasyInvoiceID)
            {
                ApplicationArea = All;
                Editable = false;
                Enabled = true;
                Lookup = true;

                trigger OnAssistEdit()    
                begin
                    Hyperlink(EasyInvoiceWeb.HyperText(EasyInvoiceCon.EasyInvoiceID));
                end;
            }
        }

    }

    trigger OnAfterGetRecord()
    begin
        IF NOT EasyInvoiceCon.GET(EasyInvoiceCon.Type::"Vendor Ledger Entry", "Entry No.") then
            EasyInvoiceCon.INIT;
    end;

    var
        EasyInvoiceCon: record "CREDIT Easy Invoice Connection";
        EasyInvoiceWeb: Codeunit "CREDIT Easy Invoice Webservice";

}

