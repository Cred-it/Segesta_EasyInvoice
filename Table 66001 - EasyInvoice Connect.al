table 66001
 "Easy Invoice Connection"
{
    // version EasyInvoice 2020.06.06.22


    fields
    {
        field(1; Type; Option)
        {
            CaptionML = ENU = 'Document Type',
                        NLD = 'Document Soort';
            OptionCaptionML = ENU = 'Purchase Invoice,Purchase Credit Memo,Posted Purchase Invoice,Posted Purchase Credit Memo,Vendor Ledger Entry',
                              NLD = 'Inkoopfactuur,Inkoop Creditfactuur,Geboekte Inkoopfactuur,Geboekte Inkoop Creditfactuur,Leverancierspost';
            OptionMembers = "Purchase Invoice","Purchase Credit Memo","Posted Purchase Invoice","Posted Purchase Credit Memo","Vendor Ledger Entry";
        }
        field(2; "Document No."; Code[20])
        {
            CaptionML = ENU = 'Document No.',
                        NLD = 'Document Nr.';
            TableRelation = IF (Type = CONST("Purchase Invoice")) "Purchase Header"."No." WHERE("Document Type" = CONST(Invoice))
            ELSE
            IF (Type = CONST("Purchase Credit Memo")) "Purchase Header"."No." WHERE("Document Type" = CONST("Credit Memo"))
            ELSE
            IF (Type = CONST("Posted Purchase Invoice")) "Purch. Inv. Header"."No."
            ELSE
            IF (Type = CONST("Posted Purchase Credit Memo")) "Purch. Cr. Memo Hdr."."No."
            ELSE
            IF (Type = CONST("Vendor Ledger Entry")) "Vendor Ledger Entry"."Entry No.";
        }
        field(10; EasyInvoiceID; Integer)
        {
            CaptionML = ENU = 'EasyInvoiceID',
                        NLD = 'EasyInvoiceID';
        }
        field(100; Datestamp; DateTime)
        {
            CaptionML = ENU = 'Datestamp',
                        NLD = 'Datumstempel';
        }
    }

    keys
    {
        key(Key1; "Type", "Document No.")
        {

        }
        key(Key2; EasyInvoiceID)
        {
            
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert();
    begin
        Datestamp := CURRENTDATETIME;
    end;

    procedure CardOpen();
    var
        lPurchaseInvoice: Record "Purchase Header";
        lPurchaseCredit: Record "Purchase Header";
        lPurchasePostInvoice: Record "Purch. Inv. Header";
        lPurchasePostCredit: Record "Purch. Cr. Memo Hdr.";
        lVendorLedgerEntry: Record "Vendor Ledger Entry";

    begin
        CASE Type OF
            Type::"Purchase Invoice":
                IF lPurchaseInvoice.GET(lPurchaseInvoice."Document Type"::Invoice, "Document No.") THEN
                    PAGE.RUNMODAL(51, lPurchaseInvoice);
            Type::"Purchase Credit Memo":
                IF lPurchaseCredit.GET(lPurchaseCredit."Document Type"::"Credit Memo", "Document No.") THEN
                    PAGE.RUNMODAL(52, lPurchaseCredit);
            Type::"Posted Purchase Invoice":
                IF lPurchasePostInvoice.GET("Document No.") THEN
                    PAGE.RUNMODAL(138, lPurchasePostInvoice);
            Type::"Posted Purchase Credit Memo":
                IF lPurchasePostCredit.GET("Document No.") THEN
                    PAGE.RUNMODAL(140, lPurchasePostInvoice);
            Type::"Vendor Ledger Entry":
                IF lVendorLedgerEntry.GET("Document No.") then
                    PAGE.RunModal(29, lVendorLedgerEntry);

        END;
    end;
}

