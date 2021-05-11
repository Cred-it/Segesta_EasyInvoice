table 70571575 "CREDIT Easy Invoice setup"
{
    // version EasyInvoice 2020.06.06.22


    //Hyperlink to EasyInvoice Webapplication

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
        }

        field(2; "Hyperlink EasyInvoice"; Text[1024])
        {
            
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
