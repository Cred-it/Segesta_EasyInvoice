page 70571576 "CREDIT EasyInv Connection List"
{
    //version EasyInvoice Connector
    //Created

    DeleteAllowed = true;
    InsertAllowed = true;
    ModifyAllowed = true;
    DelayedInsert = true;

    PageType = Worksheet;
    SourceTable = "CREDIT Easy Invoice Connection";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(gTypeSelect; gTypeSelect)
                {
                    Caption = 'Type';
                    OptionCaption = 'Invoice,Credit,Posted Invoice,Posted Credit,Vendor Ledger Entry';

                    ApplicationArea = All;
                    trigger OnValidate();
                    begin
                        rec.SETRANGE(Type, gTypeSelect);
                        CurrPage.UPDATE;
                    end;
                }
            }
            group(List)
            {
                Caption = 'List';
            }
            repeater(Group)
            {

                field("Document No."; rec."Document No.")
                {
                    ApplicationArea = All;

                }
                field(EasyInvoiceID; rec."EasyInvoiceID")
                {
                    Editable = true;
                    ApplicationArea = All;

                }
                field(OnHold; rec.OnHold)
                {
                    Editable = false;
                    ApplicationArea = All;
                }
                field(Datestamp; rec.Datestamp)
                {
                    ApplicationArea = All;
                }

            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Card)
            {

                Caption = 'Card';
                Image = DataEntry;
                action("Open Card")
                {
                    ApplicationArea = All;
                    Caption = 'Open Card';
                    Image = Card;
                    Promoted = true;
                    PromotedCategory = New;
                    PromotedIsBig = true;
                    ToolTip = 'Opens corresponding Card';
                    trigger OnAction();
                    begin
                        rec.CardOpen;
                    end;
                }
            }
        }
    }

    trigger OnOpenPage();
    begin
        rec.SETRANGE(Type, gTypeSelect);
    end;

    var
        gTypeSelect: Option Invoice,Credit,"Posted Invoice","Posted Credit","Vendor Ledger Entry";

}
