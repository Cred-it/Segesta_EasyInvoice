/// <summary>
/// PageExtension CREDIT EasyInvoice Menu (ID 70571580) extends Record Business Manager Role Center.
/// </summary>
pageextension 70571580 "CREDIT EasyInvoice Menu" extends "Business Manager Role Center"
{

    actions
    {
        addlast(Sections)
        {
            group("Easy Invoice Menu")
            {
                action("Easy Invoice Setup")
                {
                    RunObject = page "CREDIT EasyInvoice Setup";
                    ApplicationArea = All;
                }
                action("Easy Invoice Connection")
                {
                    RunObject = page "CREDIT EasyInv Connection List";
                    ApplicationArea = All;
                }
                action("Import EasyInvoice ID's")
                {
                    RunObject = xmlport "CREDIT Import EasyInvoice ID";
                    ApplicationArea = ALL;
                }
                action("Web Services")
                {
                    RunObject = page "Web Services";
                    ApplicationArea = All;

                }

            }
        }
    }
}