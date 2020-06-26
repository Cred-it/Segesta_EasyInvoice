pageextension 66040 EasyPostPurchCredConnectExt extends "Posted Purchase Credit Memo"
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
        IF NOT EasyInvoiceCon.GET(EasyInvoiceCon.Type::"Posted Purchase Credit Memo", "No.") then
            EasyInvoiceCon.INIT;
    end;

    var
        EasyInvoiceCon: record "Easy Invoice Connection";
        EasyInvoiceWeb: Codeunit "Easy Invoice Webservice";

}

