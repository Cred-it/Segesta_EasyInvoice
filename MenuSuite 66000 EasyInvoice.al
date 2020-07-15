pageextension 66000 "CREDIT EasyInvoice Menu" extends "Business Manager Role Center"
{

    actions
    {
        addlast(Sections)
        {
            group("Easy Invoice Menu")
            {
                action("Easy Invoice")
                {
                    RunObject = page "CREDIT EasyInvoice Setup";
                    ApplicationArea = All;
                }
                action("Easy Invoice Connection")
                {
                    RunObject = page "CREDIT EasyInv Connection List";
                    ApplicationArea = All;
                }
                action("Import EasyInvoiceID")
                {
                    RunObject = xmlport "CREDIT Import EasyInvoiceID";
                    ApplicationArea = ALL;
                }

            }
        }
    }
}