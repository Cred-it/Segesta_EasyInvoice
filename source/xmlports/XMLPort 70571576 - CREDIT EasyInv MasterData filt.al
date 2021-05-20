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
            textelement(TableNameFilter)
            {
                MinOccurs = Zero;
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

    /// <summary>
    /// GetParameters.
    /// </summary>
    /// <param name="TableFilterOut">VAR Text.</param>
    /// <param name="FieldFilterOut">VAR Text.</param>
    /// <param name="KeyOut">VAR Text.</param>
    /// <param name="RecordFilterOut">VAR Text.</param>
    /// <param name="TableNameFilterOut">VAR text.</param>
    procedure GetParameters(var TableFilterOut: Text; var FieldFilterOut: Text; var KeyOut: Text; var RecordFilterOut: Text; var TableNameFilterOut: text);
    begin
        TableFilterOut := TableFilter;
        FieldFilterOut := FieldFilter;
        KeyOut := Key;
        RecordFilterOut := RecordFilter;
        TableNameFilterOut := TableNameFilter;
    end;
}

