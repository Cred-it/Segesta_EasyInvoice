page 66001 "EasyInvoice Connection List"
{
    //version EasyInvoice Connector
    //Created

    DeleteAllowed = true;
    InsertAllowed = true;
    ModifyAllowed = true;
    DelayedInsert = true;

    PageType = Worksheet;
    SourceTable = 66001;

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
                        SETRANGE(Type, gTypeSelect);
                        CurrPage.UPDATE;
                    end;
                }
            }
            group(List)
            {
                Caption = 'Lijst';
            }
            repeater(Group)
            {

                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;

                }
                field(EasyInvoiceID; "EasyInvoiceID")
                {
                    Editable = true;
                    ApplicationArea = All;

                }
                field(Datestamp; Datestamp)
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
                        CardOpen;
                    end;
                }
            }
        }
    }

    trigger OnOpenPage();
    begin
        SETRANGE(Type, gTypeSelect);
    end;

    var
        gTypeSelect: Option Invoice,Credit,"Posted Invoice","Posted Credit","Vendor Ledger Entry";

}
