pageextension 70571576 "CREDIT EasyInv Purch Cr.Memo" extends "Purchase Credit Memo"
{

    layout
    {

        addafter("Buy-from Country/Region Code")
        {
            field(EasyInvoiceID; EasyInvoiceCon.EasyInvoiceID)
            {
                ApplicationArea = All;
                Editable = false;
                Enabled = true;
                
                trigger OnAssistEdit()
                begin
                    Hyperlink(EasyInvoiceWeb.HyperText(EasyInvoiceCon.EasyInvoiceID));
                end;

            }
        }

    }

    trigger OnAfterGetRecord()
    begin
        IF NOT EasyInvoiceCon.GET(EasyInvoiceCon.Type::"Purchase Credit Memo", "No.") then
            EasyInvoiceCon.INIT;
    end;

    var
        EasyInvoiceCon: record "CREDIT Easy Invoice Connection";
        EasyInvoiceWeb: Codeunit "CREDIT Easy Invoice Webservice";

}

