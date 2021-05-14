/// <summary>
/// XmlPort CREDIT EasyInv MasterData filt (ID 70571576).
/// </summary>
xmlport 70571576 "CREDIT EasyInv MasterData filt"
{
    // version EasyInvoice 2020.06.27.01

    // MCONNECT 2017-08-01 Cred-IT Object created

    UseDefaultNamespace = true;

    schema
    {
        textelement(Root)
        {
            MinOccurs = Zero;
            textelement(TableFilter)
            {
                MinOccurs = Zero;
            }
            textelement(FieldFilter)
            {
                MinOccurs = Zero;
            }
            textelement("Key")
            {
                MinOccurs = Zero;
            }
            textelement(RecordFilter)
            {
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    procedure GetParameters(var TableFilterOut : Text;var FieldFilterOut : Text;var KeyOut : Text;var RecordFilterOut : Text);
    begin
        TableFilterOut := TableFilter;
        FieldFilterOut := FieldFilter;
        KeyOut := Key;
        RecordFilterOut := RecordFilter;
    end;
}

