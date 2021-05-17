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
                field("Hyperlink EasyInvoice"; rec."Hyperlink EasyInvoice")
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
    
    //WEG ERMEE DIT TESTJE
    actions
    {
        area(processing)
        {
            group(Card)
            {

                Caption = 'Test Encript';
                Image = DataEntry;
                action("Open Card")
                {
                    ApplicationArea = All;
                    Caption = 'Test encrypt';
                    Image = Card;
                    Promoted = true;
                    PromotedCategory = New;
                    PromotedIsBig = true;
                    ToolTip = 'Test Encrrypt';
                    trigger OnAction();
                    var Test : codeunit "CREDIT Easy Invoice Webservice";
                    begin
                      //Test.TestEncrypt(); ;
                    end;
                }
            }
        }
    }

    var
        webserviceCU: Codeunit "CREDIT Easy Invoice Webservice";
 
}

