pageextension 66000 ExtendMenuArea extends "Business Manager Role Center"
{

    actions
    {
        addlast(Sections)
        {
            group("Easy Invoice Menu")
            {
                action("Easy Invoice")
                {
                    RunObject = page "EasyInvoice - Setup";
                    ApplicationArea = All;
                }
                action("Easy Invoice Connection")
                {
                    RunObject = page "EasyInvoice Connection List";
                    ApplicationArea = All;
                }
                action("Import EasyInvoiceID")
                {
                    RunObject = xmlport ImportEasyInvoiceID;
                    ApplicationArea = ALL;
                }

            }
        }
    }
}