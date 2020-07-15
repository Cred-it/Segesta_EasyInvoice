page 70571575 "CREDIT EasyInvoice Setup"
{
    // version EasyInvoice Connector
    // EasyInvoice Connector 2020-06-01 Cred-IT Object created

    DeleteAllowed = true;
    InsertAllowed = true;
    ModifyAllowed = true;
    Caption = 'EasyInvoice Setup';
    PageType = Card;
    SourceTable = "CREDIT Easy Invoice setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Hyperlink EasyInvoice"; "Hyperlink EasyInvoice")
                {
                    ApplicationArea = All;
                    Editable = true;

                }
                field("Ip Server"; webserviceCU.IPget())
                {
                    ApplicationArea = All;
                    Editable = true;


                }
            }
        }
    }

    var
        webserviceCU: Codeunit "CREDIT Easy Invoice Webservice";


}

