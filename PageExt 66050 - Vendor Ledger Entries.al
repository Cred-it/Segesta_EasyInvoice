pageextension 66050 EasyPostVendorLeConnectExt extends "Vendor Ledger Entries"
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

                trigger OnLookup(var Text: Text): Boolean

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
        EasyInvoiceCon: record "Easy Invoice Connection";
        EasyInvoiceWeb: Codeunit "Easy Invoice Webservice";

}

