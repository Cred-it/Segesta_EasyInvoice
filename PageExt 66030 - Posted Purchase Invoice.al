pageextension 66030 EasyPostInvoiceConnectExt extends "Posted Purchase Invoice"
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
        EasyInvoiceCon: record "Easy Invoice Connection";
        EasyInvoiceWeb: Codeunit "Easy Invoice Webservice";

}

