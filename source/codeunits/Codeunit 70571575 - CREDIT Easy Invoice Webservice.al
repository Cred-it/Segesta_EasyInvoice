/// <summary>
/// Codeunit CREDIT Easy Invoice Webservice (ID 70571575).
/// </summary>
codeunit 70571575 "CREDIT Easy Invoice Webservice"
{
    // version EasyInvoice 2020.06.22.01

    // Cred-IT Created;
    // 28-01-2020 - 2020.01.28.01 PermissionSet & Subscriber
    // 07-02-2020 - 2020.02.07.01 Paymentdate

    Permissions = TableData 23 = rimd,
                  TableData 25 = rimd,
                  TableData 38 = rimd,
                  TableData 39 = rimd,
                  TableData 122 = rimd,
                  TableData 123 = rimd,
                  TableData 124 = rimd,
                  TableData 125 = rimd;
    TableNo = 38;

    trigger OnRun();
    begin
        EasyInvoiceHeader(Rec);
    end;

    var
        txtAlias: array[100] of Text[250];
        txtCommand: Text[250];
        txtTable: Text[250];
        txtTableName: Text[250];
        txtFilters: array[100] of Text[250];
        txtFilterValues: array[100] of Text[250];
        txtOutput: array[100] of Text[250];
        txtIndex: array[100] of Text[250];
        recRef: RecordRef;
        refField: FieldRef;
        recField: Record Field;
        txtTemp: Text[1024];
        XMLmgt: Codeunit 6224;
        OrgLanguage: Integer;
        OutputType: Option " ","Fields",Number;
        gBtwVerschil: Boolean;
        OrderMatch: Boolean;
        PurchHdr: Record 38;
        gTmpPurchHdr: Record 38 temporary;
        gTmpPurchLine: Record 39 temporary;
        gTmpDimension: Record 349 temporary;
        gPartdel: Boolean;
        NextLineNo: Integer;
        Vendor: Record 23;
        GeneralLedgerSetup: Record 98;
        TempVATAmountLineOrg: Record 290 temporary;
        gReleaseBln: Boolean;
        gArrarEasyInvoiceLineNo: array[100000] of Integer;
        gEasyInvoiceID: Integer;


    //[Scope('Personalization')]
    /// <summary>
    /// ExportMasterData.
    /// </summary>
    /// <param name="request">XMLport "CREDIT EasyInv MasterData filt".</param>
    /// <param name="response">VAR XMLport "CREDIT EasyInv MasterData".</param>
    procedure ExportMasterData(request: XMLport "CREDIT EasyInv MasterData filt"; var response: XMLport "CREDIT EasyInv MasterData");
    var
        TableFilterOut: Text;
        FieldFilterOut: Text;
        KeyOut: Text;
        RecordFilterOut: Text;
        TableNameFilterOut: Text;

    begin
        request.IMPORT;
        request.GetParameters(TableFilterOut, FieldFilterOut, KeyOut, RecordFilterOut,TableFilterOut);
        response.SetParameters(TableFilterOut, FieldFilterOut, KeyOut, RecordFilterOut,TableNameFilterOut);
        response.EXPORT;
    end;

    //[Scope('Personalization')]
    /// <summary>
    /// ImportPurchOrder.
    /// </summary>
    /// <param name="Request">XMLport "CREDIT EasyInvoice Import".</param>
    /// <param name="Response">VAR XMLport "CREDIT EasyInvoice Import Resp".</param>
    /// <returns>Return variable Created of type Boolean.</returns>
    procedure ImportPurchOrder(Request: XMLport "CREDIT EasyInvoice Import"; var Response: XMLport "CREDIT EasyInvoice Import Resp") Created: Boolean;
    var
        lTxtResult: Text;
        lTxtFault: Text;
        lCodNavDocNo: Code[20];
        lDatDoc: Date;
        lTxtStatus: Text;
        lEasyInvoiceID: Integer;
    begin
        CLEARLASTERROR;
        IF Request.IMPORT THEN BEGIN
            Request.GetParameters(lTxtResult, lTxtFault, lCodNavDocNo, lDatDoc, lTxtStatus, lEasyInvoiceID);
            Response.SetParameters(lTxtResult, lTxtFault, lCodNavDocNo, lDatDoc, lTxtStatus, lEasyInvoiceID);
        END ELSE
            Response.SetParameters('Error', GETLASTERRORTEXT, lCodNavDocNo, lDatDoc, lTxtStatus, lEasyInvoiceID);

        Response.EXPORT;
        COMMIT;
    end;

    /// <summary>
    /// HyperText.
    /// </summary>
    /// <param name="EasyInvoiceID">Integer.</param>
    /// <returns>Return variable HyperTxt of type Text[250].</returns>
    [Scope('onPrem')]
    procedure HyperText(EasyInvoiceID: Integer) HyperTxt: Text[250];
    var
        EasyInvoiceSetup: Record "CREDIT Easy Invoice setup";
    begin
        EasyInvoiceSetup.GET;
        EasyInvoiceSetup.TESTFIELD("Hyperlink EasyInvoice");
        IF EasyInvoiceID = 0 THEN
            EXIT('')
        ELSE
            EXIT(STRSUBSTNO(EasyInvoiceSetup."Hyperlink EasyInvoice", EasyInvoiceID));
    end;


    //[ServiceEnabled]
    /// <summary>
    /// EasyInvoicePost.
    /// </summary>
    /// <param name="PurchHeader">VAR Record "Purchase Header".</param>
    /// <param name="PurchInvHeaderNo">VAR Code[20].</param>
    /// <param name="PurchCrMemoHeaderNo">VAR Code[20].</param>
    [Scope('onPrem')]
    procedure EasyInvoicePost(var PurchHeader: Record "Purchase Header"; var PurchInvHeaderNo: Code[20]; var PurchCrMemoHeaderNo: Code[20]);
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        lEasyInvConnect: Record "CREDIT Easy Invoice Connection";
        nEasyInvConnect: Record "CREDIT Easy Invoice Connection";
    begin

        //GET EasyInvConnect
        //lEasyInvConnect.SetCurrentKey(EasyInvoiceID);


        CASE PurchHeader."Document Type" OF

            //PurchHeader."Document Type"::Order : EasyInvoiceHandler.ChangeStatus(PurchHeader.EasyInvoiceID,1,PurchInvHeader."No.",0D);

            PurchHeader."Document Type"::Invoice:
                BEGIN

                    IF NOT lEasyInvConnect.GET(lEasyInvConnect.Type::"Purchase Invoice", PurchHeader."No.") then
                        EXIT;

                    IF PurchInvHeader.GET(PurchInvHeaderNo) THEN BEGIN

                        //Insert New Easy Connect
                        nEasyInvConnect := lEasyInvConnect;
                        nEasyInvConnect.type := nEasyInvConnect.type::"Posted Purchase Invoice";
                        nEasyInvConnect."Document No." := PurchInvHeaderNo;
                        nEasyInvConnect.OnHold := (PurchInvHeader."On Hold" <> '');
                        IF nEasyInvConnect.Insert(TRUE) THEN
                            lEasyInvConnect.Delete();

                        IF VendorLedgerEntry.GET(PurchInvHeader."Vendor Ledger Entry No.") THEN BEGIN
                            nEasyInvConnect.Type := nEasyInvConnect.Type::"Vendor Ledger Entry";
                            nEasyInvConnect."Document No." := FORMAT(VendorLedgerEntry."Entry No.");
                            nEasyInvConnect.OnHold := (VendorLedgerEntry."On Hold" <> '');
                            IF nEasyInvConnect.Insert(TRUE) THEN;
                        END;
                    END;

                END;
            PurchHeader."Document Type"::"Credit Memo":
                BEGIN

                    IF NOT lEasyInvConnect.GET(lEasyInvConnect.Type::"Purchase Credit Memo", PurchHeader."No.") then
                        EXIT;

                    IF PurchCrMemoHeader.GET(PurchCrMemoHeaderNo) THEN BEGIN

                        //Insert New Easy Connect
                        nEasyInvConnect := lEasyInvConnect;
                        nEasyInvConnect.type := nEasyInvConnect.type::"Posted Purchase Credit Memo";
                        nEasyInvConnect."Document No." := PurchCrMemoHeaderNo;
                        nEasyInvConnect.OnHold := (PurchCrMemoHeader."On Hold" <> '');
                        IF nEasyInvConnect.Insert(TRUE) THEN
                            lEasyInvConnect.Delete();

                        IF VendorLedgerEntry.GET(PurchCrMemoHeader."Vendor Ledger Entry No.") THEN BEGIN
                            nEasyInvConnect.Type := nEasyInvConnect.Type::"Vendor Ledger Entry";
                            nEasyInvConnect."Document No." := FORMAT(VendorLedgerEntry."Entry No.");
                            nEasyInvConnect.OnHold := (VendorLedgerEntry."On Hold" <> '');
                            IF nEasyInvConnect.Insert(TRUE) THEN;
                        END;
                    END;
                END;

        //PurchHeader."Document Type"::"Return Order"  : EasyInvoiceHandler.ChangeStatus(PurchHeader.EasyInvoiceID,1,ReturnShptHeader."No.",
        //0D);

        END;
    end;

    /// <summary>
    /// ExportStatus.
    /// </summary>
    /// <param name="vEasyInvoiceID">VAR Integer.</param>
    /// <param name="gCodNavInvoiceNo">VAR code[20].</param>
    /// <param name="gtxtResult">VAR text.</param>
    /// <param name="gStatus">VAR text.</param>
    /// <param name="gTxtFault">VAR text.</param>
    /// <param name="gdatpayment">VAR text.</param>
    [Scope('onPrem')]
    procedure ExportStatus(var vEasyInvoiceID: Integer; var gCodNavInvoiceNo: code[20]; var gtxtResult: text; var gStatus: text; var gTxtFault: text; var gdatpayment: text);
    var
        VendLE: Record "Vendor Ledger Entry";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        PurchHeader: Record "Purchase Header";
        lEasyInvConnect: Record "CREDIT Easy Invoice Connection";
    begin

        //Betaald / Gedeeltelijk betaald

        lEasyInvConnect.SetCurrentKey(EasyInvoiceID);
        lEasyInvConnect.SetRange(EasyInvoiceID, vEasyInvoiceID);
        lEasyInvConnect.SetRange(Type, lEasyInvConnect.Type::"Vendor Ledger Entry");

        IF lEasyInvConnect.FindFirst() THEN
            IF VendLE.GET(lEasyInvConnect."Document No.") THEN BEGIN
                VendLE.CALCFIELDS("Original Amount", "Remaining Amount");
                gTxtResult := 'Succes';

                //debet
                IF VendLE."Document Type" = VendLE."Document Type"::Invoice THEN BEGIN
                    IF (VendLE."Remaining Amount" > 0) AND (VendLE."Remaining Amount" > VendLE."Original Amount") THEN BEGIN
                        ;
                        gstatus := ('Gedeeltelijk betaald');
                        EXIT;
                    END;

                    IF (VendLE."Remaining Amount" = 0) AND (VendLE."Remaining Amount" > VendLE."Original Amount") THEN BEGIN
                        gDatPayment := Date2txt(VendLE."Closed at Date"); //07-02-2020
                        gstatus := ('Betaald');
                        EXIT;
                    END;
                END;

                //credit
                IF VendLE."Document Type" = VendLE."Document Type"::"Credit Memo" THEN BEGIN
                    IF (VendLE."Remaining Amount" < 0) AND (VendLE."Remaining Amount" < VendLE."Original Amount") THEN BEGIN
                        ;
                        gStatus := ('Gedeeltelijk betaald');
                        EXIT;
                    END;

                    IF (VendLE."Remaining Amount" = 0) AND (VendLE."Remaining Amount" < VendLE."Original Amount") THEN BEGIN
                        gDatPayment := Date2txt(VendLE."Closed at Date"); //07-02-2020
                        gStatus := ('Betaald');
                        EXIT;
                    END;
                END;


            END;

        //Geboekt debet
        lEasyInvConnect.SetRange(Type, lEasyInvConnect.Type::"Posted Purchase Invoice");
        IF lEasyInvConnect.FINDFIRST AND (PurchInvHeader.GET(lEasyInvConnect."Document No.")) THEN BEGIN
            gTxtResult := 'Succes';
            gCodNavInvoiceNo := PurchInvHeader."No.";
            gStatus := ('Geboekt'); //op factuur nr.: '+PurchInvHeader."No.");
            EXIT;
        END;

        //Geboekt credit
        lEasyInvConnect.SetRange(type, lEasyInvConnect.Type::"Posted Purchase Credit Memo");
        IF lEasyInvConnect.FINDFIRST AND (PurchCrMemoHeader.GET(lEasyInvConnect."Document No.")) THEN BEGIN
            gTxtResult := 'Succes';
            gCodNavInvoiceNo := PurchCrMemoHeader."No.";
            gStatus := ('Geboekt'); //op factuur nr.: '+PurchInvHeader."No.");
            EXIT;
        END;

        //Ingelezen debet 
        lEasyInvConnect.SetRange(Type, lEasyInvConnect.Type::"Purchase Invoice");
        IF lEasyInvConnect.FINDFIRST AND
           PurchHeader.GET(Purchheader."Document Type"::Invoice, lEasyInvConnect."Document No.") THEN BEGIN
            gTxtResult := 'Succes';
            gCodNavInvoiceNo := PurchHeader."No.";
            gStatus := ('Ingelezen');
            EXIT;
        END;

        //Ingelezen credit
        lEasyInvConnect.SetRange(Type, lEasyInvConnect.Type::"Purchase Credit Memo");
        IF lEasyInvConnect.FINDFIRST AND
            PurchHeader.GET(Purchheader."Document Type"::"Credit Memo", lEasyInvConnect."Document No.") THEN BEGIN
            gTxtResult := 'Succes';
            gCodNavInvoiceNo := PurchHeader."No.";
            gStatus := ('Ingelezen');
            EXIT;
        END;

        gTxtResult := 'Error';
        gTxtFault := STRSUBSTNO('Factuur met EasyInvoiceID %1 niet gevonden', gEasyInvoiceID);


        gStatus := ('Onbekend');
    end;

    //*********************************************************************************************************************************
    //*********************************************************************************************************************************
    //***************************                             Process Purchase               ******************************************
    //*********************************************************************************************************************************
    //*********************************************************************************************************************************

    /// <summary>
    /// EasyInvoiceHeader.
    /// </summary>
    /// <param name="Rec">VAR Record "Purchase Header".</param>
    [Scope('onPrem')]
    procedure EasyInvoiceHeader(var Rec: Record "Purchase Header");
    var
        ReleasePurch: Codeunit "Release Purchase Document";
        LocDimSet: Integer;
    begin
        GeneralLedgerSetup.GET;

        PurchHdr := Rec;

        PurchHdr.INIT;

        PurchHdr.SetHideValidationDialog(TRUE);

        //'Leveranciernummer'
        PurchHdr.VALIDATE("Buy-from Vendor No.", gTmpPurchHdr."Buy-from Vendor No.");

        //EasyInvoiceID := gTmpPurchHdr.EasyInvoiceID;

        //'Betalen aan Leveranciernummer'
        IF gTmpPurchHdr."Pay-to Vendor No." <> '' THEN
            PurchHdr.VALIDATE("Pay-To Vendor No.", gTmpPurchHdr."Pay-To Vendor No.");

        //'Notatype'
        PurchHdr.VALIDATE("Document Type", gTmpPurchHdr."Document Type");

        //'Boekingsdatum'
        PurchHdr."Posting Date" := gTmpPurchHdr."Posting Date";

        //'Factuurnummer'
        PurchHdr."Vendor Invoice No." := gTmpPurchHdr."Vendor Invoice No.";

        //'Boekingsdatum'
        IF gTmpPurchHdr."Posting Date" <> 0D THEN
            PurchHdr.VALIDATE("Posting Date", gTmpPurchHdr."Posting Date");

        IF gTmpPurchHdr."Bank Account Code" <> '' THEN BEGIN
            //'Bankrekening'
            EVALUATE(PurchHdr."Bank Account Code", CheckBank(PurchHdr."Buy-from Vendor No.", gTmpPurchHdr."Prepmt. Posting Description"));
        END;

        //'Bedrag'
        PurchHdr.Amount := gTmpPurchHdr.Amount;

        //'Bedrag incl. BTW'
        PurchHdr."Amount Including VAT" := gTmpPurchHdr."Amount Including VAT";

        //** Totaalcontrole factuur **
        PurchHdr."Doc. Amount Incl. VAT" := gTmpPurchHdr."Doc. Amount Incl. VAT";
        PurchHdr."Doc. Amount VAT" := gTmpPurchHdr."Doc. Amount VAT";
        //** Totaalcontrole factuur **


        //'Credit Memo'
        IF PurchHdr."Document Type" = PurchHdr."Document Type"::"Credit Memo" THEN BEGIN
            PurchHdr."Vendor Cr. Memo No." := gTmpPurchHdr."Vendor Invoice No.";
        END;


        //** Betaalblokkade factuur **
        //'On Hold'
        IF PurchHdr."Document Type" = PurchHdr."Document Type"::Invoice THEN BEGIN
            PurchHdr.VALIDATE("On Hold", gTmpPurchHdr."On Hold");
        END;
        //** Betaalblokkade factuur **

        IF PurchHdr.INSERT(TRUE) THEN BEGIN

            PurchHdr.VALIDATE("Buy-from Vendor No.");

            //'Document datum'
            IF gTmpPurchHdr."Document Date" <> 0D THEN
                PurchHdr.VALIDATE("Document Date", gTmpPurchHdr."Document Date");

            //'Vervaldatum'
            IF gTmpPurchHdr."Due Date" <> 0D THEN
                PurchHdr.VALIDATE("Due Date", gTmpPurchHdr."Due Date");

            //'Description'
            PurchHdr."Posting Description" := gTmpPurchHdr."Posting Description";
            IF PurchHdr."Posting Description" = '' THEN
                PurchHdr."Posting Description" := FORMAT(PurchHdr."Document Type") + ' ' + PurchHdr."No.";

            //** Buitenlandse valuta **
            IF (gTmpPurchHdr."Currency Code" <> '') AND (gTmpPurchHdr."Currency Code" <> GeneralLedgerSetup."LCY Code") THEN BEGIN
                //'Currency Code'
                PurchHdr.VALIDATE("Currency Code", gTmpPurchHdr."Currency Code");
            END;
            //** Buitenlandse valuta **

            PurchHdr.MODIFY;

            CLEAR(gPartdel);

            //Create Lines
            ReadEasyInvoiceLine(gEasyInvoiceID);

            //Create EasyInvoice Connection
            CreateEasyInvConnection(gEasyInvoiceID, PurchHdr);

        END;
        //'Insert mislukt'

        //<<10-08-2020 Dimensions on Header
        LocDimSet := ReadEasyInvoiceDimension(0, '', '');
        IF LocDimSet <> 0 THEN BEGIN
            PurchHdr."Dimension Set ID" := LocDimSet;
            PurchHdr.MODIFY;
        END;
        //>>

        ValidateChecks(PurchHdr."No.");

        //*************************************
        //********   UITZOEKEN  ***************
        //*************************************

        //Uitzoeken
        //IF NOT gPartdel THEN
        //  PutRecord(EasyInvoiceID,"No.",'fCodNavInvoiceNo')
        //ELSE
        //  PutRecordDeel(EasyInvoiceID,"No.",'fCodNavInvoiceNo');

        //StatusHeader := "No.";
        Vendor.GET(gTmpPurchHdr."Buy-from Vendor No.");

        //06-08-2018
        IF gReleaseBln THEN
            ReleasePurch.RUN(PurchHdr);
        //>>

        Rec := PurchHdr;
    end;

    /// <summary>
    /// ReadEasyInvoiceLine.
    /// </summary>
    /// <param name="ParEasyInvoiceNo">Integer.</param>
    [Scope('onPrem')]
    procedure ReadEasyInvoiceLine(ParEasyInvoiceNo: Integer);

    var
        SQLStatment: Text[1000];
        PurchLine: Record 39;
        Soort: Integer;
        LocDecDiscount: Decimal;
        LocRecItem: Record 27;
        PurchRcpLine: Record 121;
        PurchRetShpLine: Record 6651;
        TmpDim: Record 348 temporary;
        LocQty: Decimal;
        lDecVat: Decimal;
        partdel: Boolean;
    begin
        //Loop TmpPurchLines and create PurchLines

        IF gTmpPurchLine.FINDSET THEN
            REPEAT
                CLEAR(partdel);

                //WITH PurchLine DO BEGIN
                PurchLine.INIT;

                NextLineNo += 10000; //****** -----OrderMatch----- ******

                //'Documentsoort'
                PurchLine.VALIDATE("Document Type", PurchHdr."Document Type");
                //'Documentnummer'
                PurchLine.VALIDATE("Document No.", PurchHdr."No.");


                IF NOT OrderMatch THEN BEGIN     //****** -----OrderMatch----- ******

                    //'Regelnr'
                    PurchLine."Line No." := gTmpPurchLine."Line No." * 10000;

                END ELSE                    //****** -----OrderMatch----- ******
                    PurchLine."Line No." := NextLineNo; //****** -----OrderMatch----- ******

                //Create a connection between Line no's
                gArrarEasyInvoiceLineNo[PurchLine."Line No." / 100] := gTmpPurchLine."Line No.";//****** -----OrderMatch----- ******

                //<<***** ORDERMATCH
                IF gTmpPurchLine.Type <> gTmpPurchLine.Type::"Charge (Item)" THEN BEGIN  //******* CHARGE 21-01-2014 *****

                    //Ontvangst
                    IF gTmpPurchLine."Document Type" = gTmpPurchLine."Document Type"::Invoice THEN BEGIN
                        PurchLine."Receipt No." := gTmpPurchLine."Receipt No.";
                        PurchLine."Receipt Line No." := gTmpPurchLine."Receipt Line No.";

                        IF PurchLine."Receipt No." <> '' THEN//01-10-2017 Lege Ontvangsten
                            IF PurchRcpLine.GET(PurchLine."Receipt No.", PurchLine."Receipt Line No.") THEN BEGIN
                                CheckBlockDeellev(PurchLine, partdel);
                                IF NOT partdel THEN
                                    InsertInvLineFromRcptLine(PurchLine)

                                ELSE BEGIN
                                    PurchLine."Receipt No." := '';
                                    PurchLine."Receipt Line No." := 0;
                                    PurchLine.VALIDATE(Type, PurchRcpLine.Type);
                                    PurchLine.VALIDATE("No.", PurchRcpLine."No.");
                                    PurchLine.VALIDATE("Variant Code", PurchRcpLine."Variant Code");
                                    PurchLine.VALIDATE("Location Code", PurchRcpLine."Location Code");
                                    PurchLine.VALIDATE("Unit of Measure", PurchRcpLine."Unit of Measure");
                                    PurchLine.VALIDATE("Unit of Measure Code", PurchRcpLine."Unit of Measure Code");
                                    PurchLine.VALIDATE(Quantity, PurchRcpLine.Quantity);
                                END;
                            END;
                    END;
                END;

                //Retour 01-10-2017
                IF PurchLine."Document Type" = PurchLine."Document Type"::"Credit Memo" THEN BEGIN
                    PurchLine."Return Shipment No." := gTmpPurchLine."Receipt No.";
                    PurchLine."Return Shipment Line No." := gTmpPurchLine."Receipt Line No.";

                    IF PurchLine."Return Shipment No." <> '' THEN//01-10-2017 Lege Ontvangsten
                        IF PurchRetShpLine.GET(PurchLine."Return Shipment No.", PurchLine."Return Shipment Line No.") THEN BEGIN
                            CheckBlockDeellev(PurchLine, partdel);
                            IF NOT partdel THEN
                                IF PurchLine."Document Type" = PurchLine."Document Type"::"Credit Memo" THEN
                                    InsertInvLineFromRetShptLine(PurchLine)  //01-10-2017
                                ELSE BEGIN
                                    PurchLine."Receipt No." := '';
                                    PurchLine."Receipt Line No." := 0;
                                    PurchLine.VALIDATE(Type, PurchRcpLine.Type);
                                    PurchLine.VALIDATE("No.", PurchRcpLine."No.");
                                    PurchLine.VALIDATE("Variant Code", PurchRcpLine."Variant Code");
                                    PurchLine.VALIDATE("Location Code", PurchRcpLine."Location Code");
                                    PurchLine.VALIDATE("Unit of Measure", PurchRcpLine."Unit of Measure");
                                    PurchLine.VALIDATE("Unit of Measure Code", PurchRcpLine."Unit of Measure Code");
                                    PurchLine.VALIDATE(Quantity, PurchRcpLine.Quantity);
                                END;
                        END;
                END;
                //<<***** ORDERMATCH

                //'Regelsoort'
                /*EVALUATE(Soort,GetRecordLine('fOptType'));
                CASE Soort OF
                  1 : Type:=Type::"G/L Account";
                  2 : Type:=Type::Item;
                  4 : Type:=Type::"Fixed Asset";
                  5 : Type:=Type::"Charge (Item)";
                END;
                */
                PurchLine.Type := gTmpPurchLine.Type;

                //'Nr.'
                IF (gTmpPurchLine."Receipt No." = '') OR partdel OR ((PurchLine.Type = PurchLine.Type::"Charge (Item)") AND (PurchLine."Document Type" = PurchLine."Document Type"::Invoice)) THEN BEGIN //01-10-2017

                    PurchLine."No." := gTmpPurchLine."No.";

                    PurchLine."Receipt No." := '';
                    PurchLine."Receipt Line No." := 0;

                    PurchLine.VALIDATE("No.");

                    PurchLine."Receipt No." := gTmpPurchLine."Receipt No.";
                    PurchLine."Receipt Line No." := gTmpPurchLine."Receipt Line No.";
                END;


                //'Omschrijving'
                PurchLine.Description := gTmpPurchLine.Description;

                //eenheid
                PurchLine."Unit of Measure Code" := gTmpPurchLine."Unit of Measure Code";


                //'Aantal'
                PurchLine.Quantity := gTmpPurchLine.Quantity;

                //'Credit memo'

                //'Eenheidskosten'
                PurchLine."Direct Unit Cost" := gTmpPurchLine."Direct Unit Cost";

                //<<01-10-2017
                IF Vendor."Prices Including VAT" THEN BEGIN
                    lDecVat := gTmpPurchLine."VAT Base Amount";
                    PurchLine."Direct Unit Cost" += lDecVat;
                END;
                //>>

                //** Order matching **
                //'Ontvangst Nr.'
                IF (gTmpPurchLine."Receipt No." <> '') AND NOT partdel THEN BEGIN
                    IF PurchLine."Document Type" = PurchLine."Document Type"::Invoice THEN BEGIN //23-01-2018

                        PurchLine."Receipt No." := gTmpPurchLine."Receipt No.";
                        PurchLine."Receipt Line No." := gTmpPurchLine."Receipt Line No.";
                        //>>
                    END; //23-01-2018

                    //<<23-01-2018 ******************
                    IF PurchLine."Document Type" = PurchLine."Document Type"::"Credit Memo" THEN BEGIN

                        PurchLine."Return Shipment No." := gTmpPurchLine."Receipt No.";
                        PurchLine."Return Shipment Line No." := gTmpPurchLine."Receipt Line No.";
                        //>>
                    END;
                    //>> *****************************

                    PurchLine.VALIDATE(Quantity);

                    IF gTmpPurchLine."Unit of Measure Code" <> '' THEN BEGIN
                        //'Eenheidscode'
                        PurchLine."Unit of Measure Code" := gTmpPurchLine."Unit of Measure Code";
                        IF (PurchLine."Quantity Received" = 0) AND (PurchLine."Return Qty. Shipped" = 0) THEN //06-03-2018
                            IF NOT PurchLine."Drop Shipment" THEN //01-10-2017
                                PurchLine.VALIDATE("Unit of Measure Code");
                    END;

                    //'Eenheidskosten'
                    PurchLine."Direct Unit Cost" := gTmpPurchLine."Direct Unit Cost";

                END;

                //'Ontvangst Regelnr.'
                IF gTmpPurchLine."Receipt Line No." <> 0 THEN
                    IF PurchLine."Document Type" = PurchLine."Document Type"::Invoice THEN//**** 22-06-2018
                        PurchLine."Receipt Line No." := gTmpPurchLine."Receipt Line No."
                    ELSE
                        PurchLine."Return Shipment Line No." := gTmpPurchLine."Receipt Line No.";
                //** Order matching **

                //'kortingspercentage'
                IF gTmpPurchLine."Line Discount %" <> 0 THEN
                    PurchLine.VALIDATE("Line Discount %", gTmpPurchLine."Line Discount %")

                ELSE
                    //<<11-09-2018
                    PurchLine.VALIDATE("Line Discount %", 0);
                //>>

                IF gTmpPurchLine."Shortcut Dimension 1 Code" <> '' THEN BEGIN
                    //'DimCode1'
                    PurchLine."Shortcut Dimension 1 Code" := gTmpPurchLine."Shortcut Dimension 1 Code";
                    PurchLine.VALIDATE("Shortcut Dimension 1 Code");
                END;
                IF gTmpPurchLine."Shortcut Dimension 2 Code" <> '' THEN BEGIN
                    //'DimCode2'
                    PurchLine."Shortcut Dimension 2 Code" := gTmpPurchLine."Shortcut Dimension 2 Code";
                    PurchLine.VALIDATE("Shortcut Dimension 2 Code");
                END;

                //'BTW Prod. Boekgrp'
                IF gTmpPurchLine."VAT Prod. Posting Group" <> '' THEN BEGIN
                    PurchLine.VALIDATE("VAT Prod. Posting Group", gTmpPurchLine."VAT Prod. Posting Group");
                END;

                IF gTmpPurchLine."Gen. Prod. Posting Group" <> '' THEN BEGIN
                    PurchLine.VALIDATE("Gen. Prod. Posting Group", gTmpPurchLine."Gen. Prod. Posting Group");
                END;

                //<<11-02-2015 Project No
                IF gTmpPurchLine."Job No." <> '' THEN BEGIN
                    PurchLine.VALIDATE("Job No.", gTmpPurchLine."Job No.");
                END;
                //>>

                IF partdel THEN
                    PurchLine.Description := 'DEELLEV ' + COPYSTR(PurchLine.Description, 1, 42);
                //

                //<<20-02-2019
                IF OrderMatch THEN BEGIN
                    PurchLine.VALIDATE("Direct Unit Cost", gTmpPurchLine."Direct Unit Cost");
                END;
                //>>

                //<<03-04-2020 TransHistorisch posten
                IF gTmpPurchLine."Deferral Code" <> '' THEN
                    PurchLine.VALIDATE("Deferral Code", gTmpPurchLine."Deferral Code");
                //>>

                IF NOT PurchLine.INSERT(TRUE) THEN;
                //'Insert misluk'

                //01-10-2017
                IF (PurchLine."Receipt No." <> '') AND (PurchLine.Type <> PurchLine.Type::"Charge (Item)") THEN
                    InsertPurchExtText(PurchLine, PurchLine."Receipt No.");

                //01-10-2017
                IF (PurchLine."Return Shipment No." <> '') AND (PurchLine.Type <> PurchLine.Type::"Charge (Item)") THEN
                    InsertPurchExtText(PurchLine, PurchLine."Return Shipment No.");

            //END;

            UNTIL gTmpPurchLine.NEXT = 0;

    end;

    /// <summary>
    /// ReadEasyInvoiceDimension.
    /// </summary>
    /// <param name="ParEasyLineNo">Integer.</param>
    /// <param name="locDimension1">Code[20].</param>
    /// <param name="locDimension2">Code[20].</param>
    /// <returns>Return variable DimEntrySetID of type Integer.</returns>
    [Scope('onPrem')]
    procedure ReadEasyInvoiceDimension(ParEasyLineNo: Integer; locDimension1: Code[20]; locDimension2: Code[20]) DimEntrySetID: Integer;
    var
        DimSetEntryTmp: Record 480 temporary;
        DimMgt: Codeunit 408;
    begin
        gTmpDimension.SETRANGE(Code, FORMAT(ParEasyLineNo));
        IF gTmpDimension.FINDSET THEN
            REPEAT

                //WITH DimSetEntryTmp DO BEGIN
                DimSetEntryTmp.INIT;
                DimSetEntryTmp."Dimension Set ID" := 37;
                //EVALUATE("Dimension Code",);
                //IF "Dimension Code" <> '' THEN
                DimSetEntryTmp.VALIDATE("Dimension Code", gTmpDimension."Dimension Code");

                IF EVALUATE(DimSetEntryTmp."Dimension Value Code", gTmpDimension.Name) THEN//GetRecordDim('fCodDimensionValue'));
                                                                                           //IF "Dimension Value Code" <> '' THEN
                    DimSetEntryTmp.VALIDATE("Dimension Value Code");

                IF NOT DimSetEntryTmp.INSERT(TRUE) THEN;
                //'Insert mislukt'

                CASE TRUE OF
                    GeneralLedgerSetup."Global Dimension 1 Code" = DimSetEntryTmp."Dimension Code":
                        locDimension1 := DimSetEntryTmp."Dimension Value Code";
                    GeneralLedgerSetup."Global Dimension 2 Code" = DimSetEntryTmp."Dimension Code":
                        locDimension2 := DimSetEntryTmp."Dimension Value Code";
                END;

            //END;
            UNTIL gTmpDimension.NEXT = 0;
        EXIT(DimMgt.GetDimensionSetID(DimSetEntryTmp));
    end;

    /// <summary>
    /// ValidateChecks.
    /// </summary>
    /// <param name="DocNo">Code[20].</param>
    [Scope('onPrem')]
    procedure ValidateChecks(DocNo: Code[20]);
    var
        LocPurchHdr: Record 38;
        LocPurchLine: Record 39;
        LocPurchLine2: Record 39;
        DecDummy: Decimal;
        LocDiscount: Decimal;
        LocRecItem: Record 27;
        LocDirectUnitCost: Decimal;
        LocDocDim: Record 348;
        LocDimSet: Integer;
    begin
        LocPurchLine.RESET;
        LocPurchLine.SETFILTER("Document Type", '%1|%2', LocPurchLine."Document Type"::Invoice, LocPurchLine."Document Type"::"Credit Memo");
        LocPurchLine.SETRANGE("Document No.", DocNo);
        LocPurchLine.SETRANGE("Receipt No.", '');
        LocPurchLine.SETFILTER(Type, '<>%1', LocPurchLine.Type::" ");
        IF LocPurchLine.FINDSET THEN
            REPEAT

                LocDiscount := LocPurchLine."Line Discount %";

                IF (LocPurchLine.Type <> LocPurchLine.Type::" ") THEN BEGIN
                    LocDirectUnitCost := LocPurchLine."Direct Unit Cost";
                    LocPurchLine.VALIDATE(Quantity);
                    LocPurchLine.VALIDATE("Direct Unit Cost", LocDirectUnitCost)
                END;

                IF (LocPurchLine.Type = LocPurchLine.Type::Item) AND (LocPurchLine."Direct Unit Cost" = 0) AND
                  LocRecItem.GET(LocPurchLine."No.") THEN BEGIN
                    LocPurchLine.VALIDATE("Direct Unit Cost", LocRecItem."Unit Price");
                    LocPurchLine.VALIDATE("Line Discount %", LocDiscount);
                END;

                IF (LocDiscount <> 0) THEN
                    LocPurchLine.VALIDATE("Line Discount %", LocDiscount);

                LocPurchLine.MODIFY;
            UNTIL LocPurchLine.NEXT = 0;

        //Dimensies & BTW
        LocPurchLine.SETRANGE("Receipt No.");

        CLEAR(gBtwVerschil);
        LocPurchLine2.RESET;
        LocPurchLine2.COPYFILTERS(LocPurchLine);
        CreateVatAmountLines(LocPurchLine2);


        IF LocPurchLine.FINDSET THEN
            REPEAT
                IF LocPurchLine."Line No." MOD 10000 = 0 THEN BEGIN

                    //<<10-08-2020
                    LocDimSet := ReadEasyInvoiceDimension(gArrarEasyInvoiceLineNo[LocPurchLine."Line No." / 100],
                                                                            LocPurchLine."Shortcut Dimension 1 Code", LocPurchLine."Shortcut Dimension 2 Code");
                    IF LocDimSet <> 0 THEN BEGIN
                        LocPurchLine."Dimension Set ID" := LocDimSet;
                        LocPurchLine.MODIFY;
                    END;
                    //>>

                    CheckBTW(gArrarEasyInvoiceLineNo[LocPurchLine."Line No." / 100], LocPurchLine);
                END;
            UNTIL LocPurchLine.NEXT = 0;


        IF gBtwVerschil THEN
            IF NOT LocPurchLine.ISEMPTY THEN
                AdjustVatAmount(LocPurchLine);

        //Charge
        LocPurchLine.RESET;
        LocPurchLine.SETFILTER("Document Type", '%1|%2', LocPurchLine."Document Type"::Invoice, LocPurchLine."Document Type"::"Credit Memo");
        LocPurchLine.SETRANGE("Document No.", DocNo);
        LocPurchLine.SETRANGE(Type, LocPurchLine.Type::"Charge (Item)");
        IF LocPurchLine.FINDSET THEN
            REPEAT
                CheckCharge(LocPurchLine);
            UNTIL LocPurchLine.NEXT = 0;

        //

        SELECTLATESTVERSION;
    end;

    /// <summary>
    /// AdjustVatAmount.
    /// </summary>
    /// <param name="PurchLine">VAR Record 39.</param>
    [Scope('onPrem')]
    procedure AdjustVatAmount(var PurchLine: Record 39);
    var
        TempPurchLine: Record 39 temporary;
        FrmVATSpec: Page 576;
    begin
        TempVATAmountLineOrg.MODIFYALL(Modified, TRUE);
        PurchLine.UpdateVATOnLines(1, PurchHdr, PurchLine, TempVATAmountLineOrg);
    end;

    /// <summary>
    /// CheckBTW.
    /// </summary>
    /// <param name="ParEasyInvoiceLineNo">Integer.</param>
    /// <param name="ParPurchLine">Record 39.</param>
    [Scope('onPrem')]
    procedure CheckBTW(ParEasyInvoiceLineNo: Integer; ParPurchLine: Record 39);
    var
        SQLStatment: Text[1024];
        VATValue: Decimal;
        LocCountBTW: Decimal;
    begin
        //SQLCommandDim := SQLConnection.CreateCommand();
        //SQLCommandDim.CommandText := SQLStatment;
        //SQLReaderDim := SQLCommandDim.ExecuteReader;

        LocCountBTW := ParPurchLine."Line Amount" * ParPurchLine."VAT %" * 0.01;


        //*** Iets mee doen
        gTmpPurchLine.SETRANGE("Line No.", ParEasyInvoiceLineNo);
        IF gTmpPurchLine.FindFirst() THEN BEGIN

            VATValue := gTmpPurchLine."VAT Base Amount";
            IF ABS(LocCountBTW) <> ABS(VATValue) THEN BEGIN
                gBtwVerschil := TRUE;
            END;
            //Error('Btw inbase : ' +  FORMAT(LocCountBTW) +' vs ' + Format(VATValue));

        END;

        //SQLReaderDim.Close;

        //'BTW regelscheck functie'
        IF STRPOS(ParPurchLine.Description, 'DEELLEV') = 0 THEN BEGIN
            IF TempVATAmountLineOrg.GET(ParPurchLine."VAT Identifier", ParPurchLine."VAT Calculation Type",
                                        ParPurchLine."Tax Group Code", ParPurchLine."Use Tax", ParPurchLine."Line Amount" >= 0) THEN BEGIN


                IF TempVATAmountLineOrg."VAT %" <> 0 THEN BEGIN
                    TempVATAmountLineOrg.VALIDATE("VAT Difference", 0);
                    TempVATAmountLineOrg.CheckVATDifference(ParPurchLine."Currency Code", TRUE);
                    IF ParPurchLine."VAT Base Amount" < 0 THEN
                        VATValue := -(ABS(VATValue));

                    TempVATAmountLineOrg."VAT Amount" := TempVATAmountLineOrg."VAT Amount" + VATValue;
                    TempVATAmountLineOrg."VAT Difference" := TempVATAmountLineOrg."VAT Amount" - TempVATAmountLineOrg."Calculated VAT Amount";
                    TempVATAmountLineOrg."Amount Including VAT" := TempVATAmountLineOrg."VAT Base" + TempVATAmountLineOrg."VAT Amount";
                    TempVATAmountLineOrg.MODIFY(TRUE);

                END;

            END;

        END;

    end;


    /// <summary>
    /// CheckBank.
    /// </summary>
    /// <param name="Vendor">Code[20].</param>
    /// <param name="BankNo">Text[30].</param>
    /// <returns>Return value of type Code[20].</returns>
    [Scope('onPrem')]
    procedure CheckBank(Vendor: Code[20]; BankNo: Text[30]): Code[20];
    var
        LocVendBankAcc: Record 288;
    begin
        //WITH LocVendBankAcc DO BEGIN
        LocVendBankAcc.SETRANGE("Vendor No.", Vendor);
        LocVendBankAcc.SETRANGE("Bank Account No.", COPYSTR(BankNo, 1, 30));
        IF NOT LocVendBankAcc.FINDFIRST THEN BEGIN
            LocVendBankAcc.SETRANGE("Bank Account No.");
            LocVendBankAcc.SETRANGE(IBAN, BankNo);
            IF NOT LocVendBankAcc.FINDFIRST THEN
                ERROR(STRSUBSTNO('Bankrekening bestaat niet voor leverancier %1', Vendor))
            ELSE
                EXIT(LocVendBankAcc.Code);
        END;
        EXIT(LocVendBankAcc.Code);
        //END;
    end;

    /// <summary>
    /// CheckBlockDeellev.
    /// </summary>
    /// <param name="PurchLine">VAR Record 39.</param>
    /// <param name="pPartdel">VAR Boolean.</param>
    [Scope('onPrem')]
    procedure CheckBlockDeellev(var PurchLine: Record 39; var pPartdel: Boolean);
    var
        PurchRcpLine: Record 121;
        LocQty: Decimal;
        LocPurchLine: Record 39;
        SQLStatment2: Text[1000];
        Item: Record 27;
    begin
        IF NOT Item.GET(PurchLine."No.") THEN
            EXIT;
        IF (Item."Item Tracking Code" = '') THEN
            EXIT;

        IF PurchLine."Receipt No." <> '' THEN //01-10-2017 Lege Ontvangsten
            IF PurchRcpLine.GET(PurchLine."Receipt No.", PurchLine."Receipt Line No.") THEN BEGIN
                LocQty := gTmpPurchLine.Quantity;
                IF LocQty = 0 THEN
                    EXIT;
                pPartdel := LocQty <> PurchRcpLine."Qty. Rcd. Not Invoiced";
            END;

        IF pPartdel THEN
            gPartdel := TRUE;
    end;



    /// <summary>
    /// CheckCharge.
    /// </summary>
    /// <param name="PurchLine">VAR Record 39.</param>
    [Scope('onPrem')]
    procedure CheckCharge(var PurchLine: Record 39);
    var
        AssignItemChargePurch: Codeunit 5805;
        ItemChargeAssgntPurch: Record 5805;
        Currency: Record 4;
        GetReceipts: Codeunit 74;
        GetRetShp: Codeunit 6648;
        PurchRcptLine: Record 121;
        PurchOrderLine: Record 39;
        PurchShptLine: Record 6651;
    begin
        IF NOT Currency.GET(PurchLine."Currency Code") THEN
            Currency.INIT;
        //WITH PurchLine DO BEGIN
        PurchLine.GET(PurchLine."Document Type", PurchLine."Document No.", PurchLine."Line No.");
        PurchLine.TESTFIELD(PurchLine.Type, PurchLine.Type::"Charge (Item)");
        PurchLine.TESTFIELD("No.");
        PurchLine.TESTFIELD(Quantity);

        ItemChargeAssgntPurch.RESET;
        ItemChargeAssgntPurch.SETRANGE("Document Type", PurchLine."Document Type");
        ItemChargeAssgntPurch.SETRANGE("Document No.", PurchLine."Document No.");
        ItemChargeAssgntPurch.SETRANGE("Document Line No.", PurchLine."Line No.");
        ItemChargeAssgntPurch.SETRANGE("Item Charge No.", PurchLine."No.");
        IF NOT ItemChargeAssgntPurch.FINDLAST THEN BEGIN
            ItemChargeAssgntPurch."Document Type" := PurchLine."Document Type";
            ItemChargeAssgntPurch."Document No." := PurchLine."Document No.";
            ItemChargeAssgntPurch."Document Line No." := PurchLine."Line No.";
            ItemChargeAssgntPurch."Item Charge No." := PurchLine."No.";

            IF (PurchLine."Inv. Discount Amount" = 0) AND (NOT PurchHdr."Prices Including VAT") THEN
                ItemChargeAssgntPurch."Unit Cost" := PurchLine."Unit Cost"
            ELSE
                IF PurchHdr."Prices Including VAT" THEN
                    ItemChargeAssgntPurch."Unit Cost" :=
                      ROUND(
                        (PurchLine."Line Amount" - PurchLine."Inv. Discount Amount") / PurchLine.Quantity / (1 + PurchLine."VAT %" / 100),
                        Currency."Unit-Amount Rounding Precision")
                ELSE
                    ItemChargeAssgntPurch."Unit Cost" :=
                      ROUND(
                        (PurchLine."Line Amount" - PurchLine."Inv. Discount Amount") / PurchLine.Quantity,
                        Currency."Unit-Amount Rounding Precision");

        END;

        //<<12-07-2018  ***********
        IF PurchRcptLine.GET(PurchLine."Receipt No.", PurchLine."Receipt Line No.") THEN
            GetReceipts.GetItemChargeAssgnt(PurchRcptLine, PurchLine."Qty. to Invoice");  //12-07-2018
        IF PurchShptLine.GET(PurchLine."Return Shipment No.", PurchLine."Return Shipment Line No.") THEN
            GetRetShp.GetItemChargeAssgnt(PurchShptLine, PurchLine."Qty. to Invoice");  //12-07-2018
                                                                                        //>>12-07-2018  ***********

        IF PurchLine."Document Type" IN [PurchLine."Document Type"::"Return Order", PurchLine."Document Type"::"Credit Memo"] THEN
            AssignItemChargePurch.CreateDocChargeAssgnt(ItemChargeAssgntPurch, PurchLine."Return Shipment No.")
        ELSE
            AssignItemChargePurch.CreateDocChargeAssgnt(ItemChargeAssgntPurch, PurchLine."Receipt No.");

        AssignItemChargePurch.SuggestAssgnt2(PurchLine, PurchLine.Quantity, PurchLine.Amount, 1);
        CLEAR(AssignItemChargePurch);

        //END;
    end;

    /// <summary>
    /// ConvDecToText.
    /// </summary>
    /// <param name="pValue">Decimal.</param>
    /// <returns>Return variable result of type Text[30].</returns>
    [Scope('onPrem')]
    procedure ConvDecToText(pValue: Decimal) result: Text[30];
    begin
        result := FORMAT(pValue, 0, '<Precision,5:5><Sign><Integer><Decimals>');
        result := CONVERTSTR(result, ',', '.');
    end;

    /// <summary>
    /// ConvertDate.
    /// </summary>
    /// <param name="parTxt">Text[1024].</param>
    /// <param name="parDate">VAR Date.</param>
    /// <returns>Return value of type Text[20].</returns>
    [Scope('onPrem')]
    procedure ConvertDate(parTxt: Text[1024]; var parDate: Date): Text[20];
    var
        DD: Integer;
        MM: Integer;
        YY: Integer;
    begin
        IF parTxt = '' THEN
            EXIT;

        EVALUATE(DD, COPYSTR(parTxt, 4, 2));
        EVALUATE(MM, COPYSTR(parTxt, 1, 2));
        EVALUATE(YY, '20' + COPYSTR(parTxt, 7, 2));
        parDate := DMY2DATE(DD, MM, YY);
    end;

    /// <summary>
    /// CreateEasyInvConnection.
    /// </summary>
    /// <param name="ParEasyInvoiceNo">Integer.</param>
    /// <param name="parPurchHdr">VAR Record "Purchase Header".</param>
    [Scope('onPrem')]
    procedure CreateEasyInvConnection(ParEasyInvoiceNo: Integer; var parPurchHdr: Record "Purchase Header");
    var
        lEasyInvConnect: Record "CREDIT Easy Invoice Connection";

    begin

        //Docuemnt type
        IF parPurchHdr."Document Type" = parPurchHdr."Document Type"::Invoice THEN
            lEasyInvConnect.Type := lEasyInvConnect.TYpe::"Purchase Invoice"
        ELSE
            lEasyInvConnect.Type := lEasyInvConnect.Type::"Purchase Credit Memo";

        lEasyInvConnect."Document No." := PurchHdr."No.";
        lEasyInvConnect.EasyInvoiceID := ParEasyInvoiceNo;
        lEasyInvConnect.OnHold := (parPurchHdr."On Hold" <> '');
        IF lEasyInvConnect.INSERT(TRUE) THEN;

    end;

    //[Scope('Personalization')]
    /// <summary>
    /// CreateTmp.
    /// </summary>
    /// <param name="pTmpHeader">Temporary VAR Record "Purchase Header".</param>
    /// <param name="pTmpLine">Temporary VAR Record "Purchase Line".</param>
    /// <param name="pTmpDim">Temporary VAR Record "Dimension Value".</param>
    /// <param name="pEasyInvoiceID">integer.</param>
    [Scope('onPrem')]
    procedure CreateTmp(var pTmpHeader: Record "Purchase Header" temporary; var pTmpLine: Record "Purchase Line" temporary; var pTmpDim: Record "Dimension Value" temporary; pEasyInvoiceID: integer);
    begin
        gTmpPurchHdr.DELETEALL;
        gTmpPurchLine.DELETEALL;
        gTmpDimension.DELETEALL;

        //EasyInvoiceID
        gEasyInvoiceID := pEasyInvoiceID;

        //Header
        gTmpPurchHdr := pTmpHeader;
        gTmpPurchHdr.INSERT;

        //Lines
        IF pTmpLine.FINDSET THEN
            REPEAT
                gTmpPurchLine := pTmpLine;
                gTmpPurchLine.INSERT;
            UNTIL pTmpLine.NEXT = 0;

        //Dims
        IF pTmpDim.FINDSET THEN
            REPEAT
                gTmpDimension := pTmpDim;
                gTmpDimension.INSERT;
            UNTIL pTmpDim.NEXT = 0;
    end;

    /// <summary>
    /// CreateVatAmountLines.
    /// </summary>
    /// <param name="Purchline">VAR Record 39.</param>
    [Scope('onPrem')]
    procedure CreateVatAmountLines(var Purchline: Record 39);
    var
        TempPurchLine: Record 39 temporary;
    begin
        //Create Temp. VatAmountLines
        TempVATAmountLineOrg.DELETEALL;
        TempPurchLine.CalcVATAmountLines(1, PurchHdr, Purchline, TempVATAmountLineOrg);
        TempVATAmountLineOrg.MODIFYALL("VAT Amount", 0);
    end;

    /// <summary>
    /// Date2txt.
    /// </summary>
    /// <param name="input">Date.</param>
    /// <returns>Return value of type text.</returns>
    [Scope('onPrem')]
    procedure Date2txt(input: Date): text;
    var
        dateformat: text;
    begin
        dateformat := '<Day,2>-<Month,2>-<Year4>';
        EXIT(FORMAT(input, 0, dateformat));
    end;



    /// <summary>
    /// ExitStatusHeader.
    /// </summary>
    /// <returns>Return variable ExitTxt of type Text[250].</returns>
    [Scope('onPrem')]
    procedure ExitStatusHeader() ExitTxt: Text[250];
    begin
        //EXIT(StatusHeader);
    end;



    /// <summary>
    /// getJsonTextField.
    /// </summary>
    /// <param name="O">JsonObject.</param>
    /// <param name="Member">Text.</param>
    /// <returns>Return value of type text.</returns>
    procedure getJsonTextField(O: JsonObject; Member: Text): text;
    var
        result: JsonToken;
    begin
        IF O.Get(Member, Result) THEN
            exit(result.AsValue().AsText());

        EXIT('*error json*');

    end;



    /// <summary>
    /// InsertInvLineFromRcptLine.
    /// </summary>
    /// <param name="PurchLine">VAR Record 39.</param>
    [Scope('onPrem')]
    procedure InsertInvLineFromRcptLine(var PurchLine: Record 39);
    var
        PurchInvHeader: Record 38;
        PurchOrderHeader: Record 38;
        PurchOrderLine: Record 39;
        TempPurchLine: Record 39;
        Currency: Record 4;
        TransferOldExtLines: Codeunit 379;
        ItemTrackingMgt: Codeunit 6500;
        PurchRcpLine: Record 121;
        Item: Record 27;
    begin
        //Item Tracking
        IF NOT PurchRcpLine.GET(PurchLine."Receipt No.", PurchLine."Receipt Line No.") THEN
            EXIT;

        TempPurchLine := PurchLine;
        PurchInvHeader := PurchHdr;
        TransferOldExtLines.ClearLineNumbers;

        IF PurchOrderLine.GET(
            PurchOrderLine."Document Type"::Order, PurchRcpLine."Order No.", PurchRcpLine."Order Line No.")
        THEN BEGIN
            IF (PurchOrderHeader."Document Type" <> PurchOrderLine."Document Type"::Order) OR
               (PurchOrderHeader."No." <> PurchOrderLine."Document No.")
            THEN
                PurchOrderHeader.GET(PurchOrderLine."Document Type"::Order, PurchRcpLine."Order No.");

            IF PurchInvHeader."Prices Including VAT" <> PurchOrderHeader."Prices Including VAT" THEN
                IF PurchRcpLine."Currency Code" <> '' THEN
                    Currency.GET(PurchRcpLine."Currency Code")
                ELSE
                    Currency.InitRoundingPrecision;

            IF PurchInvHeader."Prices Including VAT" THEN BEGIN
                IF NOT PurchOrderHeader."Prices Including VAT" THEN
                    PurchOrderLine."Direct Unit Cost" :=
                      ROUND(
                        PurchOrderLine."Direct Unit Cost" * (1 + PurchOrderLine."VAT %" / 100),
                        Currency."Unit-Amount Rounding Precision");
            END ELSE BEGIN
                IF PurchOrderHeader."Prices Including VAT" THEN
                    PurchOrderLine."Direct Unit Cost" :=
                      ROUND(
                        PurchOrderLine."Direct Unit Cost" / (1 + PurchOrderLine."VAT %" / 100),
                        Currency."Unit-Amount Rounding Precision");
            END;
        END ELSE BEGIN
        END;
        PurchLine := PurchOrderLine;


        PurchLine."Line No." := NextLineNo;

        PurchLine."Document Type" := TempPurchLine."Document Type";
        PurchLine."Document No." := TempPurchLine."Document No.";
        PurchLine."Variant Code" := PurchRcpLine."Variant Code";
        PurchLine."Location Code" := PurchRcpLine."Location Code";
        PurchLine."Quantity (Base)" := 0;
        PurchLine.Quantity := 0;
        PurchLine."Outstanding Qty. (Base)" := 0;
        PurchLine."Outstanding Quantity" := 0;
        PurchLine."Quantity Received" := 0;
        PurchLine."Qty. Received (Base)" := 0;
        PurchLine."Quantity Invoiced" := 0;
        PurchLine."Qty. Invoiced (Base)" := 0;
        PurchLine."Sales Order No." := '';
        PurchLine."Sales Order Line No." := 0;
        PurchLine."Drop Shipment" := FALSE;
        PurchLine."Special Order Sales No." := '';
        PurchLine."Special Order Sales Line No." := 0;
        PurchLine."Special Order" := FALSE;
        PurchLine.VALIDATE("Direct Unit Cost", PurchOrderLine."Direct Unit Cost");
        PurchLine.VALIDATE("Line Discount %", PurchOrderLine."Line Discount %");
        PurchLine."Attached to Line No." :=
          TransferOldExtLines.TransferExtendedText(
            PurchRcpLine."Line No.",
            PurchLine."Line No.",
            PurchRcpLine."Attached to Line No.");
        PurchLine."Shortcut Dimension 1 Code" := PurchOrderLine."Shortcut Dimension 1 Code";
        PurchLine."Shortcut Dimension 2 Code" := PurchOrderLine."Shortcut Dimension 2 Code";
        PurchLine."Dimension Set ID" := PurchOrderLine."Dimension Set ID";

        IF PurchRcpLine."Sales Order No." = '' THEN
            PurchLine."Drop Shipment" := FALSE
        ELSE
            PurchLine."Drop Shipment" := TRUE;

        IF Item.GET(PurchLine."No.") AND (Item."Item Tracking Code" <> '') THEN
            ItemTrackingMgt.CopyHandledItemTrkgToInvLine(PurchOrderLine, PurchLine);
    end;

    /// <summary>
    /// InsertInvLineFromRetShptLine.
    /// </summary>
    /// <param name="PurchLine">VAR Record 39.</param>
    [Scope('onPrem')]
    procedure InsertInvLineFromRetShptLine(var PurchLine: Record 39);
    var
        PurchOrderLine: Record 39;
        TempPurchLine: Record 39;
        TransferOldExtLines: Codeunit 379;
        ItemTrackingMgt: Codeunit 6500;
        ExtTextLine: Boolean;
        PurchInvHeader: Record 38;
        PurchRetShpLine: Record 6651;
        Text000: label 'Return Shipment No. %1:'; //, NLD = 'Retourverzendnr. %1:';
        Text001: label 'The program cannot find this purchase line.'; //, NLD = 'Kan deze inkoopregel niet vinden.';
        Text002: label 'Exp. rec. date:';//, NLD = 'Verw. ontvangstdatum: %1';
        ReturnShipmentHeader: Record 6650;
    begin

        IF NOT PurchRetShpLine.GET(PurchLine."Return Shipment No.", PurchLine."Return Shipment Line No.") THEN
            EXIT;


        TempPurchLine := PurchLine;
        PurchInvHeader := PurchHdr;
        TransferOldExtLines.ClearLineNumbers;



        IF PurchLine."Return Shipment No." <> PurchRetShpLine."Document No." THEN BEGIN
            PurchLine.INIT;
            PurchLine."Line No." := NextLineNo;
            PurchLine."Document Type" := TempPurchLine."Document Type";
            PurchLine."Document No." := TempPurchLine."Document No.";
            PurchLine.Description := STRSUBSTNO(Text000, PurchRetShpLine."Document No.");
            PurchLine.INSERT;
            NextLineNo := NextLineNo + 10000;
        END;

        TransferOldExtLines.ClearLineNumbers;

        ExtTextLine := (TransferOldExtLines.GetNewLineNumber(PurchRetShpLine."Attached to Line No.") <> 0);

        IF NOT PurchOrderLine.GET(
            PurchOrderLine."Document Type"::"Return Order", PurchRetShpLine."Return Order No.", PurchRetShpLine."Return Order Line No.")
        THEN BEGIN
            IF ExtTextLine THEN BEGIN
                PurchOrderLine.INIT;
                PurchOrderLine."Line No." := PurchRetShpLine."Return Order Line No.";
                PurchOrderLine.Description := PurchRetShpLine.Description;
                PurchOrderLine."Description 2" := PurchRetShpLine."Description 2";
            END ELSE
                ERROR(Text001);
        END;
        PurchLine := PurchOrderLine;
        PurchLine."Line No." := NextLineNo;
        PurchLine."Document Type" := TempPurchLine."Document Type";
        PurchLine."Document No." := TempPurchLine."Document No.";
        PurchLine."Variant Code" := PurchRetShpLine."Variant Code";
        PurchLine."Location Code" := PurchRetShpLine."Location Code";
        PurchLine."Return Reason Code" := PurchRetShpLine."Return Reason Code";
        PurchLine."Quantity (Base)" := 0;
        PurchLine.Quantity := 0;
        PurchLine."Outstanding Qty. (Base)" := 0;
        PurchLine."Outstanding Quantity" := 0;
        PurchLine."Return Qty. Shipped" := PurchRetShpLine.Quantity - PurchRetShpLine."Quantity Invoiced";
        PurchLine."Return Qty. Shipped (Base)" := PurchRetShpLine."Quantity (Base)" - PurchRetShpLine."Qty. Invoiced (Base)";
        PurchLine."Quantity Invoiced" := 0;
        PurchLine."Qty. Invoiced (Base)" := 0;
        PurchLine."Sales Order No." := '';
        PurchLine."Sales Order Line No." := 0;
        PurchLine."Drop Shipment" := FALSE;
        PurchLine."Return Shipment No." := PurchRetShpLine."Document No.";
        PurchLine."Return Shipment Line No." := PurchRetShpLine."Line No.";
        IF NOT ExtTextLine THEN BEGIN
            PurchLine.VALIDATE(Quantity, PurchRetShpLine.Quantity - PurchRetShpLine."Quantity Invoiced");
            PurchLine.VALIDATE("Direct Unit Cost", PurchOrderLine."Direct Unit Cost");
            PurchLine.VALIDATE("Line Discount %", PurchOrderLine."Line Discount %");
        END;
        PurchLine."Attached to Line No." :=
          TransferOldExtLines.TransferExtendedText(
            PurchRetShpLine."Line No.",
            NextLineNo,
            PurchRetShpLine."Attached to Line No.");
        PurchLine."Shortcut Dimension 1 Code" := PurchOrderLine."Shortcut Dimension 1 Code";
        PurchLine."Shortcut Dimension 2 Code" := PurchOrderLine."Shortcut Dimension 2 Code";
        PurchLine.INSERT;

        ItemTrackingMgt.CopyHandledItemTrkgToInvLine(PurchOrderLine, PurchLine);
    end;


    /// <summary>
    /// InsertPurchExtText.
    /// </summary>
    /// <param name="PurchLine">VAR Record 39.</param>
    /// <param name="CommentText">Text[50].</param>
    [Scope('onPrem')]
    procedure InsertPurchExtText(var PurchLine: Record 39; CommentText: Text[50]);
    var
        ToPurchLine: Record 39;
        Text000: label 'Receipt No %1'; //ENU = 'Receipt No. %1:', NLD = 'Ontvangstnr. %1:';
        Text001: label 'Return Shipment No. %1:';//, NLD = 'Retourverzendnr. %1:';
    begin
        ToPurchLine.RESET;
        ToPurchLine.SETRANGE("Document Type", PurchHdr."Document Type");
        ToPurchLine.SETRANGE("Document No.", PurchHdr."No.");
        ToPurchLine.SETRANGE(Type, 0);
        IF PurchLine."Document Type" = PurchLine."Document Type"::Invoice THEN
            ToPurchLine.SETFILTER(Description, STRSUBSTNO(Text000, CommentText))
        ELSE
            ToPurchLine.SETFILTER(Description, STRSUBSTNO(Text001, CommentText));

        IF NOT ToPurchLine.ISEMPTY THEN
            EXIT;

        ToPurchLine.INIT;
        ToPurchLine."Document Type" := PurchLine."Document Type";
        ToPurchLine."Document No." := PurchLine."Document No.";
        ToPurchLine."Line No." := PurchLine."Line No." - 1;

        IF PurchLine."Document Type" = PurchLine."Document Type"::Invoice THEN
            ToPurchLine.Description := STRSUBSTNO(Text000, CommentText)
        ELSE
            ToPurchLine.Description := STRSUBSTNO(Text001, CommentText);

        IF ToPurchLine.INSERT THEN;
    end;

    // *****************************************
    // *******        JSon Webcall      ********
    // *****************************************
    /// <summary>
    /// IPget.
    /// </summary>
    /// <returns>Return value of type Text.</returns>
    procedure IPget(): Text;
    var
        client: HttpClient;
        Response: HttpResponseMessage;
        J: JsonObject;
        Reponsetext: Text;
    begin
        if client.get('https://api.ipify.org?format=json', Response) then
            if Response.IsSuccessStatusCode() then begin
                response.content().ReadAs(Reponsetext);
                j.ReadFrom(Reponsetext);
                exit(getJsonTextField(j, 'ip'));
            end;
        EXIT('*error api*');

    end;





    /// <summary>
    /// SetOrderMatch.
    /// </summary>
    /// <param name="ParOM">Boolean.</param>
    [Scope('onPrem')]
    procedure SetOrderMatch(ParOM: Boolean);
    begin
        OrderMatch := ParOM
    end;

    // *****************************************
    // ********     PDF Functions      *********
    // *****************************************


    //*******************************************
    //*******************************************
    //*******************************************

    // *****************************************
    // ********   Event Subscribers    *********
    // *****************************************

    [Scope('onPrem')]
    [EventSubscriber(ObjectType::Codeunit, 90, 'OnAfterPostPurchaseDoc', '', true, true)]
    local procedure PostInvoice(var PurchaseHeader: Record 38; var GenJnlPostLine: Codeunit 12; PurchRcpHdrNo: Code[20]; RetShptHdrNo: Code[20]; PurchInvHdrNo: Code[20]; PurchCrMemoHdrNo: Code[20]);
    begin
        //23-01-2019

        IF PurchaseHeader.ISTEMPORARY THEN
            EXIT;

        EasyInvoicePost(PurchaseHeader, PurchInvHdrNo, PurchCrMemoHdrNo);
    end;
}

