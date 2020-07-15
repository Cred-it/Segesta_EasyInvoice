pageextension 66030 "CREDIT EasyInv Posted Invoice" extends "Posted Purchase Invoice"
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
        IF NOT EasyInvoiceCon.GET(EasyInvoiceCon.Type::"Posted Purchase Invoice", "No.") then
            EasyInvoiceCon.INIT;
    end;

    var
        EasyInvoiceCon: record "CREDIT Easy Invoice Connection";
        EasyInvoiceWeb: Codeunit "CREDIT Easy Invoice Webservice";

}

