pageextension 70571575 "CREDIT EasyInv Purch Invoice" extends "Purchase Invoice"
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
        IF NOT EasyInvoiceCon.GET(EasyInvoiceCon.Type::"Purchase Invoice", Rec."No.") then
            EasyInvoiceCon.INIT;
    end;

    var
        EasyInvoiceCon: record "CREDIT Easy Invoice Connection";
        EasyInvoiceWeb: Codeunit "CREDIT Easy Invoice Webservice";

}

