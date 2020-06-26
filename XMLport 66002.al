xmlport 66002 "Easy Invoice Import XMLV2"
{
    // version EasyInvoice 2020.02.07.01

    // 28-10-2019 - Date format DD-MM-YYYY
    // 29-10-2019 - Point for decimal fields (for dutch environment calculate to comma)
    // 11-11-2019 - 2019.12.05.01 Dimensions on Header : CheckDimHeader
    // 13-01-2020 - 2020.01.13.01 Decimal calculation
    // 28-01-2020 - 2020.01.28.01 Decimal Determation, OnHold on Credits too,fTxtStatus
    // 07-02-2020 - 2020.02.07.01 Payment date

    Encoding = UTF16;
    FormatEvaluate = Xml;
    Permissions = TableData 23 = rimd,
                  TableData 25 = rimd,
                  TableData 38 = rimd,
                  TableData 39 = rimd,
                  TableData 122 = rimd,
                  TableData 123 = rimd,
                  TableData 124 = rimd,
                  TableData 125 = rimd;
    UseDefaultNamespace = true;

    schema
    {
        textelement(Root)
        {
            tableelement(tmppurchaseheader; "Purchase Header")
            {
                AutoReplace = false;
                AutoSave = false;
                AutoUpdate = false;
                XmlName = 'PurchaseHeader';
                UseTemporary = true;
                textelement(foptstatus)
                {
                    MinOccurs = Zero;
                    XmlName = 'fOptStatus';
                }
                textelement(EasyInvID) //;EasyInvoiceID)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                    XmlName = 'fIntEasyInvoiceID';
                    trigger OnAfterAssignVariable()
                    var
                    begin
                        IF NOT EVALUATE(gEasyInvoiceID, EasyInvID) then
                            gEasyInvoiceID := 0;

                    end;
                }

                fieldelement(fOptInvoiceKind; TmpPurchaseHeader."Document Type")
                {
                    MinOccurs = Zero;
                }
                fieldelement(fCodVendorNo; TmpPurchaseHeader."Buy-from Vendor No.")
                {
                    MinOccurs = Zero;
                }

                fieldelement(fCodPayVendorNo; TmpPurchaseHeader."Pay-to Vendor No.")
                {
                    MinOccurs = Zero;
                }

                fieldelement(fCodVendorInvoiceNo; TmpPurchaseHeader."Vendor Invoice No.")
                {
                    MinOccurs = Zero;
                }
                textelement(fdatdocumentdate)
                {
                    MinOccurs = Zero;
                    XmlName = 'fDatDocumentDate';
                }
                fieldelement(fDecNetAmount; TmpPurchaseHeader.Amount)
                {
                    MinOccurs = Zero;
                }
                fieldelement(fDecVAT; TmpPurchaseHeader."Doc. Amount VAT")
                {
                    MinOccurs = Zero;
                }
                fieldelement(fDecBrutAmount; TmpPurchaseHeader."Doc. Amount Incl. VAT")
                {
                    MinOccurs = Zero;
                }
                fieldelement(fTxtOnHold; TmpPurchaseHeader."On Hold")
                {
                    MinOccurs = Zero;
                }
                textelement(fdatpayment)
                {
                    MinOccurs = Zero;
                    XmlName = 'fDatPayment';
                }
                textelement(fdatpostingdate)
                {
                    MinOccurs = Zero;
                    XmlName = 'fDatPostingDate';
                }
                fieldelement(fTxtBanknr; TmpPurchaseHeader."Bank Account Code")
                {
                    MinOccurs = Zero;
                }
                textelement(fdatduedate)
                {
                    MinOccurs = Zero;
                    XmlName = 'fDatDueDate';
                }
                fieldelement(fTxtDescription; TmpPurchaseHeader."Posting Description")
                {
                    MinOccurs = Zero;
                }
                fieldelement(fCodCurrency; TmpPurchaseHeader."Currency Code")
                {
                    MinOccurs = Zero;
                }
                textelement(foptreleaseinvoice)
                {
                    MinOccurs = Zero;
                    XmlName = 'fOptReleaseInvoice';

                    trigger OnAfterAssignVariable();
                    begin
                        //gPostInvoice := (fOptReleaseInvoice = '1');
                    end;
                }
                textelement(foptpostinvoice)
                {
                    XmlName = 'fOptPostInvoice';

                    trigger OnAfterAssignVariable();
                    begin
                        gPostInvoice := (fOptPostInvoice = '1');
                    end;
                }
                textelement(ftxtprebook)
                {
                    MinOccurs = Zero;
                    XmlName = 'fTxtPrebook';
                }

                trigger OnBeforeInsertRecord();
                var
                    EasyInvoiceID: Integer;
                begin

                    //Verwerk de factuur
                    IF fOptStatus = '0' THEN BEGIN

                        //Controle
                        //<<15-04-2019
                        IF CheckExistsEasyInvoiceID(gEasyInvoiceID) THEN BEGIN
                            gFault := TRUE;
                            currXMLport.BREAK;
                            EXIT;
                        END;

                        IF CheckExistsVendorInvoiceNo(TmpPurchaseHeader."Vendor Invoice No.") THEN BEGIN
                            gFault := TRUE;
                            currXMLport.BREAK;
                            EXIT;
                        END;

                        //15-04-2019

                        WITH TmpPurchaseHeader DO BEGIN

                            //Dates
                            ConvertDate(fDatPostingDate, "Posting Date");
                            ConvertDate(fDatDocumentDate, "Document Date");
                            ConvertDate(fDatDueDate, "Due Date");


                            //fictief Document Nr geven
                            "No." := 'EASY001';

                            //CreateTmp
                            gTMPHeader := TmpPurchaseHeader;
                            IF gTMPHeader.INSERT THEN;

                        END;
                    END;

                    //Blokkade weghalen
                    IF fOptStatus = '1' THEN BEGIN

                        //gTxtResult := CheckOnHold(TmpPurchaseHeader.EasyInvoiceID);
                        gFault := TRUE;
                        currXMLport.SKIP;
                        EXIT;

                    END;

                    //Welke Status heeft de factuur
                    IF fOptStatus = '2' THEN BEGIN
                        //gTxtStatus := CheckStatus(TmpPurchaseHeader.EasyInvoiceID);
                        gTxtResult := 'Succes';  //28-01-2020
                        gFault := TRUE;
                        currXMLport.SKIP;
                        EXIT;
                    END;
                end;
            }
            tableelement(tmppurchaseline; "Purchase Line")
            {
                AutoSave = false;
                AutoUpdate = false;
                MinOccurs = Zero;
                XmlName = 'PurchaseLine';
                UseTemporary = true;
                textelement(finteasyinvoiceidline)
                {
                    MinOccurs = Once;
                    XmlName = 'fIntEasyInvoiceID';

                    trigger OnAfterAssignVariable();
                    begin
                        //IF fIntEasyInvoiceID <> fIntEasyInvoiceIDLine THEN
                        //  ERROR('EasyInvoice ID line and Header not same') ;
                    end;
                }
                fieldelement(fIntLineNo; TmpPurchaseLine."Line No.")
                {
                    MinOccurs = Once;
                }
                fieldelement(fOptType; TmpPurchaseLine.Type)
                {
                    MinOccurs = Once;
                }
                fieldelement(fCodNo; TmpPurchaseLine."No.")
                {
                    MinOccurs = Zero;
                }
                fieldelement(fTxtDescription; TmpPurchaseLine.Description)
                {
                    MinOccurs = Zero;
                }
                fieldelement(fCodUnitOfMeasure; TmpPurchaseLine."Unit of Measure Code")
                {
                    MinOccurs = Zero;
                }
                fieldelement(fCodReceiptNr; TmpPurchaseLine."Receipt No.")
                {
                    MinOccurs = Zero;
                }
                fieldelement(fDecQuantity; TmpPurchaseLine.Quantity)
                {
                    MinOccurs = Zero;
                }
                fieldelement(fDecUnitPrice; TmpPurchaseLine."Direct Unit Cost")
                {
                    MinOccurs = Zero;
                }
                fieldelement(fIntReceiptLine; TmpPurchaseLine."Receipt Line No.")
                {
                    MinOccurs = Zero;
                }
                fieldelement(fTxtGlobDim1; TmpPurchaseLine."Shortcut Dimension 1 Code")
                {
                    MinOccurs = Zero;
                }
                fieldelement(fTxtGlobDim2; TmpPurchaseLine."Shortcut Dimension 2 Code")
                {
                    MinOccurs = Zero;
                }
                textelement(fTxtGlobDim3)
                {
                    MinOccurs = Zero;
                }
                fieldelement(fTxtProdPostingGroup; TmpPurchaseLine."VAT Prod. Posting Group")
                {
                    MinOccurs = Zero;
                }
                fieldelement(fDecTaxAmount; TmpPurchaseLine."VAT Base Amount")
                {
                    MinOccurs = Zero;
                }
                fieldelement(fDecUnitPercentage; TmpPurchaseLine."Line Discount %")
                {
                    MinOccurs = Zero;
                }
                fieldelement(fTxtGenProdPostingGroup; TmpPurchaseLine."Gen. Prod. Posting Group")
                {
                    MinOccurs = Zero;
                }
                textelement(fdecnavtax)
                {
                    MinOccurs = Zero;
                    XmlName = 'fDecNavTax';
                }
                textelement(fdecnavnet)
                {
                    MinOccurs = Zero;
                    XmlName = 'fDecNavNet';

                    trigger OnAfterAssignVariable();
                    begin
                        Checkdec(fDecNavNet);
                    end;
                }
                fieldelement(fCodProject; TmpPurchaseLine."Job No.")
                {
                    MinOccurs = Zero;
                }
                fieldelement(fCodDeferral; TmpPurchaseLine."Deferral Code")
                {
                    MinOccurs = Zero;
                }

                trigger OnAfterInitRecord();
                begin
                    //<<02-10-2019
                    IF gFault THEN
                        currXMLport.SKIP;
                    //>
                end;

                trigger OnBeforeInsertRecord();
                begin
                    //<<02-10-2019
                    //Fictief Document No.
                    TmpPurchaseLine."Document Type" := TmpPurchaseHeader."Document Type";
                    TmpPurchaseLine."Document No." := TmpPurchaseHeader."No.";
                    gTMPLine := TmpPurchaseLine;
                    IF NOT gTMPLine.INSERT THEN BEGIN
                        gFault := TRUE;
                        gTxtFault := GETLASTERRORTEXT;
                    END;
                end;
            }
            tableelement(tmpdimensionline; "Dimension Value")
            {
                AutoReplace = false;
                AutoSave = false;
                AutoUpdate = false;
                MinOccurs = Zero;
                XmlName = 'Dimension';
                UseTemporary = true;
                textelement(fIntEasyInvoiceID)
                {
                }
                fieldelement(fIntLineNo; TmpDimensionLine.Code)
                {
                }
                fieldelement(fCodDimensionCode; TmpDimensionLine."Dimension Code")
                {
                }
                fieldelement(fCodDimensionValue; TmpDimensionLine.Name)
                {
                }

                trigger OnAfterInitRecord();
                begin
                    //<<02-10-2019
                    IF gFault THEN
                        currXMLport.SKIP;
                end;

                trigger OnAfterInsertRecord();
                begin

                    TmpDimensionLine."Consolidation Code" := 'EasyInvoice';

                    gTMPDim := TmpDimensionLine;
                    IF NOT gTMPDim.INSERT THEN BEGIN
                        gFault := TRUE;
                        gTxtFault := GETLASTERRORTEXT;
                    END;

                    IF gFault THEN
                        currXMLport.SKIP;
                end;
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

    trigger OnPostXmlPort();
    var
        PurchHdr: Record "Purchase Header";
        //PurchInv: Record 122;
        //PurchCrMemo: Record 124;
        lEasyInvoiceConnect: Record "Easy Invoice Connection";
        lCduEasyInvoice: Codeunit "Easy Invoice Webservice";

    begin
        //****  Error Process ****
        IF gFault THEN
            EXIT;

        //**** Process Invoice ****

        //Codeunit leegmaken
        CLEAR(lCduEasyInvoice);

        //Variabelen doorgeven aan de codeunit
        lCduEasyInvoice.CreateTmp(gTMPHeader, gTMPLine, gTMPDim, gEasyInvoiceID);

        //Verwerken van de codeunit;
        IF lCduEasyInvoice.RUN(PurchHdr) THEN BEGIN
            gTxtStatus := 'Ingelezen';
            IF PurchHdr."On Hold" <> '' THEN
                gTxtStatus += ' On Hold';
            gTxtResult := 'Succes';
            gCodNavInvoiceNo := PurchHdr."No.";
        END ELSE BEGIN
            gTxtStatus := 'Niet Ingelezen';
            gTxtFault := GETLASTERRORTEXT;
            gTxtResult := 'Error';
            gFault := TRUE;
            EXIT;
        END;

        //Boeken


        //Error Process

        //Boeken factuur
        IF gPostInvoice THEN BEGIN

            COMMIT;
            CLEARLASTERROR;
            CheckPrebook(PurchHdr);
            IF NOT CODEUNIT.RUN(CODEUNIT::"Purch.-Post", PurchHdr) THEN BEGIN
                gTxtStatus := 'Ingelezen';
                gTxtFault := COPYSTR(GETLASTERRORTEXT, 1, 1000);
                gTxtResult := 'Error';
            END ELSE BEGIN

                COMMIT;

                //Debet
                IF PurchHdr."Document Type" = PurchHdr."Document Type"::Invoice THEN BEGIN

                    lEasyInvoiceConnect.SetCurrentKey(EasyInvoiceID);
                    lEasyInvoiceConnect.SetRange(EasyInvoiceID, gEasyInvoiceID);
                    lEasyInvoiceConnect.SetRange(Type, lEasyInvoiceConnect.type::"Posted Purchase Invoice");

                    IF lEasyInvoiceConnect.FINDLAST THEN BEGIN
                        gCodNavInvoiceNo := lEasyInvoiceConnect."Document No.";
                        gTxtFault := '';
                        gTxtResult := 'Succes';
                        gTxtStatus := 'Geboekt'
                    END ELSE BEGIN
                        gTxtResult := 'Error';
                        gTxtFault := 'Geboekte factuur nr. niet gevonden';
                    END;
                END

                //Credit  --22-10-2019
                ELSE BEGIN

                    lEasyInvoiceConnect.SetCurrentKey(EasyInvoiceID);
                    lEasyInvoiceConnect.SetRange(EasyInvoiceID, gEasyInvoiceID);
                    lEasyInvoiceConnect.SetRange(Type, lEasyInvoiceConnect.type::"Posted Purchase Invoice");
                    IF lEasyInvoiceConnect.FINDLAST THEN BEGIN
                        gCodNavInvoiceNo := lEasyInvoiceConnect."Document No.";
                        gTxtFault := '';
                        gTxtResult := 'Succes';
                        gTxtStatus := 'Geboekt';
                    END
                    ELSE BEGIN
                        gTxtResult := 'Error';
                        gTxtFault := 'Geboekte credit nr. niet gevonden';
                    END;
                END;

            END;
        END;
    end;

    trigger OnPreXmlPort();
    begin
        //IF GUIALLOWED THEN
        //IF CONFIRM('PreXML') THEN;
        DimSetEntryTmp.DELETEALL;
        DetDecSign;
    end;

    var
        Text000: TextConst ENU = 'An error has occurred while reading the picture on XmlPort %1', NLD = 'Fout bij lezen van afbeelding op XmlPort %1';
        PurchHdr: Record 38;
        Notatype: Integer;
        EasyInvoiceLine: Integer;
        DocType: Integer;
        OrdernrGbl: Code[20];
        PurchSetup: Record 312;
        DocType2: Integer;
        StatusHeader: Text[250];
        GeneralLedgerSetup: Record 98;
        OrderMatch: Boolean;
        NextLineNo: Integer;
        EasyInvoiceLineNo: array[100000] of Integer;
        Partdel: Boolean;
        gPartdel: Boolean;
        "**** VAT Amount *****": Boolean;
        gBTWVerschil: Boolean;
        TempVATAmountLineOrg: Record 290 temporary;
        DimSetEntryTmp: Record 480 temporary;
        DimMgt: Codeunit 408;
        PurchRetShpLine: Record 6651;
        Vendor: Record 23;
        gTxtResult: Text[1024];
        gEasyInvoiceID: Integer;
        gFault: Boolean;
        gDummydec: Decimal;
        gDecSign: Text;
        gTMPHeader: Record "Purchase Header" temporary;
        gTMPLine: Record "Purchase Line" temporary;
        gTMPDim: Record "Dimension Value" temporary;
        gTxtFault: Text;
        gTxtStatus: Text;
        gCodNavInvoiceNo: Code[20];
        gDatDocument: Date;
        gPostInvoice: Boolean;

    procedure ConvertDate(parTxt: Text[1024]; var parDate: Date): Text[20];
    var
        DD: Integer;
        MM: Integer;
        YY: Integer;
    begin
        IF parTxt = '' THEN
            EXIT;

        //21-01-2019
        EVALUATE(DD, COPYSTR(parTxt, 1, 2));
        EVALUATE(MM, COPYSTR(parTxt, 4, 2));
        EVALUATE(YY, COPYSTR(parTxt, 7, 4));
        parDate := DMY2DATE(DD, MM, YY);
        //EVALUATE(parDate,parTxt);
    end;

    local procedure CheckStatus(var vEasyInvoiceID: Integer): Text;
    var
        VendLE: Record "Vendor Ledger Entry";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        PurchHeader: Record "Purchase Header";
        lEasyInvConnect: Record "Easy Invoice Connection";
    begin

        //Betaald / Gedeeltelijk betaald

        lEasyInvConnect.SetCurrentKey(EasyInvoiceID);
        lEasyInvConnect.SetRange(EasyInvoiceID, vEasyInvoiceID);
        lEasyInvConnect.SetRange(Type, lEasyInvConnect.Type::"Vendor Ledger Entry");

        IF lEasyInvConnect.FindFirst() AND VendLE.GET(lEasyInvConnect."Document No.") THEN BEGIN
            VendLE.CALCFIELDS("Original Amount", "Remaining Amount");
            gTxtResult := 'Succes';

            IF (VendLE."Remaining Amount" > 0) AND (VendLE."Remaining Amount" > VendLE."Original Amount") THEN BEGIN
                ;
                EXIT('Gedeeltelijk betaald');
            END;

            IF (VendLE."Remaining Amount" = 0) AND (VendLE."Remaining Amount" > VendLE."Original Amount") THEN BEGIN
                fDatPayment := FORMAT(VendLE."Closed at Date"); //07-02-2020
                EXIT('Betaald')
            END;

            //EXIT;

        END;

        //Geboekt debet
        lEasyInvConnect.SetRange(Type, lEasyInvConnect.Type::"Posted Purchase Invoice");
        IF lEasyInvConnect.FINDFIRST AND (PurchInvHeader.GET(lEasyInvConnect."Document No.")) THEN BEGIN
            gTxtResult := 'Succes';
            gCodNavInvoiceNo := PurchInvHeader."No.";
            EXIT('Geboekt'); //op factuur nr.: '+PurchInvHeader."No.");
        END;

        //Geboekt credit
        lEasyInvConnect.SetRange(type, lEasyInvConnect.Type::"Posted Purchase Credit Memo");
        IF lEasyInvConnect.FINDFIRST AND (PurchCrMemoHeader.GET(lEasyInvConnect."Document No.")) THEN BEGIN
            gTxtResult := 'Succes';
            gCodNavInvoiceNo := PurchCrMemoHeader."No.";
            EXIT('Geboekt'); //op factuur nr.: '+PurchInvHeader."No.");
        END;

        //Ingelezen debet 
        lEasyInvConnect.SetRange(Type, lEasyInvConnect.Type::"Purchase Invoice");
        IF lEasyInvConnect.FINDFIRST AND
           PurchHeader.GET(Purchheader."Document Type"::Invoice, lEasyInvConnect."Document No.") THEN BEGIN
            gTxtResult := 'Succes';
            gCodNavInvoiceNo := PurchHeader."No.";
            EXIT('Ingelezen');
        END;

        //Ingelezen credit
        lEasyInvConnect.SetRange(Type, lEasyInvConnect.Type::"Purchase Credit Memo");
        IF lEasyInvConnect.FINDFIRST AND
            PurchHeader.GET(Purchheader."Document Type"::"Credit Memo", lEasyInvConnect."Document No.") THEN BEGIN
            gTxtResult := 'Succes';
            gCodNavInvoiceNo := PurchHeader."No.";
            EXIT('Ingelezen');
        END;

        gTxtResult := 'Error';
        gTxtFault := STRSUBSTNO('Factuur met EasyInvoiceID %1 niet gevonden', gEasyInvoiceID);


        EXIT('Onbekend');
    end;

    local procedure CheckPrebook(var PurchHdr: Record 38);
    begin
        IF (fTxtPrebook <> '') THEN //prebook
            PurchHdr."Posting No." := fTxtPrebook;
    end;

    local procedure CheckExistsEasyInvoiceID(EasyInvId: Integer): Boolean;
    var
        lPurchHdr: Record 38;
        lPurchInvHeader: Record 122;
        PurchHdrExistsTxt: TextConst ENU = 'Purchase Invoice/Credit %1 exists for EasyInvoice ID %2', NLD = 'Inkoopfactuur/credit %1 bestaat al voor EasyInvoice ID %2';
        PurchInvHdrExistsTxt: TextConst ENU = 'Posted Purchase Invoice %1 exists for EasyInvoice ID %2', NLD = 'Geboekte Inkoopfactuur %1 bestaat al voor EasyInvoice ID %2';
        lPurchCrMemoHdr: Record 124;
        PurchCrMemoHdrExistsTxt: TextConst ENU = 'Posted Purchase Credit Memo %1 exists for EasyInvoice ID %2', NLD = 'Geboekte Credit Inkoopfactuur %1 bestaat al voor EasyInvoice ID %2';
        EasyInvoiceConnect: record "Easy Invoice Connection";
    begin

        EasyInvoiceConnect.SetCurrentKey(EasyInvoiceID);
        EasyInvoiceConnect.SetRange(EasyInvoiceID, EasyInvId);

        IF EasyInvoiceConnect.FINDFIRST THEN begin

            CASE EasyInvoiceConnect.Type of

                //Purchase Invoice
                EasyInvoiceConnect.Type::"Purchase Invoice":

                    begin
                        IF lPurchHdr.GET(lPurchHdr."Document Type"::Invoice, EasyInvoiceConnect."Document No.") THEN BEGIN
                            gTxtStatus := 'Ingelezen';
                            IF lPurchHdr."On Hold" <> '' THEN
                                gTxtStatus += ' On Hold';
                            gTxtFault := STRSUBSTNO(PurchHdrExistsTxt, lPurchHdr."No.", EasyInvId);
                            gTxtResult := 'Error';
                            EXIT(TRUE);
                        END;
                    end;

                //Purchase Credit
                EasyInvoiceConnect.Type::"Purchase Credit Memo":

                    begin
                        IF lPurchHdr.GET(lPurchHdr."Document Type"::"Credit Memo", EasyInvoiceConnect."Document No.") THEN BEGIN
                            gTxtStatus := 'Ingelezen';
                            IF lPurchHdr."On Hold" <> '' THEN
                                gTxtStatus += ' On Hold';
                            gTxtFault := STRSUBSTNO(PurchHdrExistsTxt, lPurchHdr."No.", EasyInvId);
                            gTxtResult := 'Error';
                            EXIT(TRUE);
                        END;
                    end;

                //Posted Purchase Invoice
                EasyInvoiceConnect.Type::"Posted Purchase Invoice":

                    begin
                        IF lPurchInvHeader.get(EasyInvoiceConnect."Document No.") THEN BEGIN
                            gTxtStatus := 'Geboekt';
                            IF lPurchInvHeader."On Hold" <> '' THEN
                                gTxtStatus += ' On Hold';
                            gTxtFault := STRSUBSTNO(PurchInvHdrExistsTxt, lPurchInvHeader."No.", EasyInvId);
                            gTxtResult := 'Error';
                            EXIT(TRUE);
                        END;

                    end;

                //Posted Purchase Invoice
                EasyInvoiceConnect.Type::"Posted Purchase Credit Memo":

                    begin
                        IF lPurchCrMemoHdr.get(EasyInvoiceConnect."Document No.") then BEGIN
                            gTxtStatus := 'Geboekt';
                            IF lPurchCrMemoHdr."On Hold" <> '' THEN
                                gTxtStatus += ' On Hold';
                            gTxtFault := STRSUBSTNO(PurchCrMemoHdrExistsTxt, lPurchCrMemoHdr."No.", EasyInvId);
                            gTxtResult := 'Error';
                            EXIT(TRUE);
                        END;

                    END;
            END;

            EXIT(FALSE);
        end ELSE

        //No valid connection found 
        BEGIN
            //    gTxtStatus := 'Onbekend';
            //    gTxtFault := STRSUBSTNO('Geen factuurcombinatie gevonden voor EasyIvoiceID %1',gEasyInvoiceID);
            EXIT(FALSE);
        END;

    end;

    local procedure CheckExistsVendorInvoiceNo(VendorInvoice: Text): Boolean;
    var
        lPurchHdr: Record 38;
        lPurchInvHeader: Record 122;
        PurchHdrExistsTxt: TextConst ENU = 'Purchase Invoice/Credit %1 exists for Vendor Invoice %2', NLD = 'Inkoopfactuur/credit %1 bestaat al voor factuurnummer leverancier %2';
        PurchInvHdrExistsTxt: TextConst ENU = 'Posted Purchase Invoice %1 exists for VendorInvoice No %2', NLD = 'Geboekte Inkoopfactuur %1 bestaat al voor factuurnr. leverancier %2';
        lPurchCrMemoHdr: Record 124;
        PurchCrMemoHdrExistsTxt: TextConst ENU = 'Posted Purchase Credit Memo %1 exists for Vendor Cr. memo No %2', NLD = 'Geboekte Credit Inkoopfactuur %1 bestaat al voor Credit  factuur no. Leverancier %2';
    begin
        lPurchHdr.SETRANGE("Vendor Invoice No.", VendorInvoice);
        IF lPurchHdr.FINDFIRST THEN BEGIN
            gTxtStatus := 'Ingelezen';
            IF lPurchHdr."On Hold" <> '' THEN
                gTxtStatus += ' On Hold';
            gTxtFault := STRSUBSTNO(PurchHdrExistsTxt, lPurchHdr."No.", VendorInvoice);
            gTxtResult := 'Error';
            EXIT(TRUE);
        END;

        lPurchInvHeader.SETRANGE("Vendor Invoice No.", VendorInvoice);
        IF lPurchInvHeader.FINDFIRST THEN BEGIN
            gTxtStatus := 'Geboekt';
            IF lPurchInvHeader."On Hold" <> '' THEN
                gTxtStatus += ' On Hold';
            gTxtFault := STRSUBSTNO(PurchInvHdrExistsTxt, lPurchInvHeader."No.", VendorInvoice);
            gTxtResult := 'Error';
            EXIT(TRUE);
        END;

        lPurchCrMemoHdr.SETRANGE("Vendor Cr. Memo No.", VendorInvoice);
        IF lPurchCrMemoHdr.FINDFIRST THEN BEGIN
            gTxtStatus := 'Geboekt';
            IF lPurchCrMemoHdr."On Hold" <> '' THEN
                gTxtStatus += ' On Hold';
            gTxtFault := STRSUBSTNO(PurchCrMemoHdrExistsTxt, lPurchCrMemoHdr."No.", VendorInvoice);
            gTxtResult := 'Error';
            EXIT(TRUE);
        END;

        EXIT(FALSE);
    end;

    local procedure CheckOnHold(var vEasyInvoiceID: Integer): Text;
    var
        VendLE: Record "Vendor Ledger Entry";
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
        PurchHeader: Record "Purchase Header";
        EasyInvoiceConnect: record "Easy Invoice Connection";
    begin

        EasyInvoiceConnect.SetCurrentKey(EasyInvoiceID);
        EasyInvoiceConnect.SetRange(EasyInvoiceID, vEasyInvoiceId);

        IF NOT EasyInvoiceConnect.FINDLAST THEN
            EXIT;


        //Ongeboekte Documenten On Hold
        IF (TmpPurchaseHeader."On Hold" = '') AND (fOptStatus = '1') THEN BEGIN


            //Purchase Invoice
            IF (EasyInvoiceConnect.Type = EasyInvoiceConnect.Type::"Purchase Invoice") AND
                PurchHeader.GET(PurchHeader."Document Type"::Invoice, EasyInvoiceConnect."Document No.") THEN BEGIN
                PurchHdr."On Hold" := '';
                PurchHdr.MODIFY;
                gCodNavInvoiceNo := PurchHdr."No.";
                gTxtStatus := 'Ingelezen';
                EXIT('On Hold verwijderd');

            END;

            //Purchase Credit
            IF (EasyInvoiceConnect.Type = EasyInvoiceConnect.Type::"Purchase Credit Memo") AND
                PurchHeader.GET(PurchHeader."Document Type"::"Credit Memo", EasyInvoiceConnect."Document No.") THEN BEGIN
                PurchHdr."On Hold" := '';
                PurchHdr.MODIFY;
                gCodNavInvoiceNo := PurchHdr."No.";
                gTxtStatus := 'Ingelezen';
                EXIT('On Hold verwijderd');

            END;
            //ELSE BEGIN
            //  EXIT('Ongeboekte factuur niet gevonden : '+fCodNavInvoiceNo);

        END;

        //Geboekte Documenten On Hold
        IF (TmpPurchaseHeader."On Hold" = '') THEN BEGIN

            //Debet
            IF TmpPurchaseHeader."Document Type" = TmpPurchaseHeader."Document Type"::Invoice THEN BEGIN

                IF NOT ((EasyInvoiceConnect.Type = EasyInvoiceConnect.Type::"Posted Purchase Invoice") AND
                         PurchInvHeader.GET(EasyInvoiceConnect."Document No.")) THEN BEGIN

                    gTxtStatus := 'Onbekend';
                    gTxtFault := STRSUBSTNO('Geboekte factuur niet gevonden voor EasyInvoiceID %1', gEasyInvoiceID);

                    EXIT('Error');

                END ELSE BEGIN
                    PurchInvHeader."On Hold" := '';
                    PurchInvHeader.MODIFY;

                    //Vendor Ledger Entries
                    VendLE.RESET;
                    VendLE.SETRANGE("Document Type", VendLE."Document Type"::Invoice);
                    VendLE.SETRANGE("Document No.", PurchInvHeader."No.");
                    VendLE.MODIFYALL("On Hold", '');
                    gCodNavInvoiceNo := PurchInvHeader."No.";
                    gTxtStatus := 'Geboekt';
                    EXIT('On Hold verwijderd');
                END;
            END;

            //Credit
            IF TmpPurchaseHeader."Document Type" = TmpPurchaseHeader."Document Type"::"Credit Memo" THEN BEGIN

                IF NOT ((EasyInvoiceConnect.Type = EasyInvoiceConnect.Type::"Posted Purchase Credit Memo") AND
                        PurchCrMemoHeader.GET(EasyInvoiceConnect."Document No.")) THEN BEGIN

                    gTxtStatus := 'Onbekend';
                    gTxtFault := STRSUBSTNO('Geboekte Creditfactuur niet gevonden voor EasyInvoiceID %1', gEasyInvoiceID);
                    EXIT('Error');

                END ELSE BEGIN
                    PurchCrMemoHeader."On Hold" := '';
                    PurchCrMemoHeader.MODIFY;

                    //Vendor Ledger Entries
                    VendLE.RESET;
                    VendLE.SETRANGE("Document Type", VendLE."Document Type"::"Credit Memo");
                    VendLE.SETRANGE("Document No.", PurchCrMemoHeader."No.");
                    VendLE.MODIFYALL("On Hold", '');
                    gCodNavInvoiceNo := PurchCrMemoHeader."No.";
                    gTxtStatus := 'Geboekt';
                    EXIT('On Hold verwijderd');
                END;
            END;
        END;

        //Niets gevonden in ongeboekt
        IF (TmpPurchaseHeader."On Hold" = '') AND (fOptStatus = '1') THEN BEGIN
            gTxtStatus := 'Onbekend';

            gTxtFault := STRSUBSTNO('Ongeboekte factuur niet gevonden voor EasyIvoiceID %1', gEasyInvoiceID);
            EXIT('Error');
        END;
    end;

    local procedure Checkdec(var DecIn: Text);
    var
        lDecDummy: Decimal;
    begin
        IF DecIn = '' THEN
            EXIT;

        IF STRPOS(DecIn, ',') <> 0 THEN
            ERROR('Comma Not allowed in decimal');

        IF STRPOS(DecIn, gDecSign) = 0 THEN //28-01-2020
                                            // check for GER and FR OR NL language
                                            //IF ((GLOBALLANGUAGE = 1031) OR (GLOBALLANGUAGE = 1036) OR (GLOBALLANGUAGE =1043)) THEN
            DecIn := CONVERTSTR(DecIn, '.', ','); // replaces point by comma

        IF NOT EVALUATE(lDecDummy, DecIn) THEN
            ERROR('No decimal');
    end;

    local procedure DetDecSign();
    var
        lDec: Decimal;
    begin
        //28-01-2020
        lDec := 1;
        gDecSign := FORMAT(lDec, 0, '<Decimals,2>');
        gDecSign := COPYSTR(gDecSign, 1, 1);
    end;

    //[Scope('Personalization')]
    procedure GetParameters(var ResultOut: Text; var FaultOut: Text; var DocumentOut: Code[20]; var PayDateOut: Date; var StatusOut: Text; EasyInvoiceIDOUT: integer);
    begin
        ResultOut := gTxtResult;
        FaultOut := gTxtFault;
        DocumentOut := gCodNavInvoiceNo;
        PayDateOut := gDatDocument;
        StatusOut := gTxtStatus;
        EasyInvoiceIDOut := gEasyInvoiceID;
    end;
}

