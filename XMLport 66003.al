xmlport 66003 "Easy Invoice Import XMLV2 Resp"
{
    // version EasyInvoice 2020.02.07.01

    // 07-02-2020 - 2020.02.07.01 Payment date

    Encoding = UTF16;
    FormatEvaluate = Xml;
    Permissions = TableData 23=rimd,
                  TableData 25=rimd,
                  TableData 38=rimd,
                  TableData 39=rimd,
                  TableData 122=rimd,
                  TableData 123=rimd,
                  TableData 124=rimd,
                  TableData 125=rimd;
    UseDefaultNamespace = true;

    schema
    {
        textelement(Root)
        {
            tableelement(Integer;Integer)
            {
                XmlName = 'Response';
                SourceTableView = SORTING(Number)
                                  WHERE(Number=CONST(1));
                textelement(fEasyInvoiceID)
                {
                    XmlName = 'EasyInvoiceID';

                    trigger OnBeforePassVariable();
                    begin
                        fEasyinvoiceID := FORMAT(gEasyInvoiceID);
                    end;     
                    
                }
                textelement(ftxtstatus)
                {
                    XmlName = 'Status';

                    trigger OnBeforePassVariable();
                    begin
                        fTxtStatus := gTxtStatus;
                    end;
                }
                textelement(ftxtresult)
                {
                    MinOccurs = Zero;
                    XmlName = 'Result';

                    trigger OnBeforePassVariable();
                    begin
                        fTxtResult := gTxtResult;
                    end;
                }
                textelement(ftxterror)
                {
                    MinOccurs = Zero;
                    XmlName = 'Error';

                    trigger OnBeforePassVariable();
                    begin
                        fTxtError  := gTxtFault;
                    end;
                }
                textelement(fcodnavinvoiceno)
                {
                    MinOccurs = Zero;
                    XmlName = 'Document_No';

                    trigger OnBeforePassVariable();
                    begin
                        fCodNavInvoiceNo := gCodNavInvoiceNo;
                    end;
                }
                textelement(fdatpayment)
                {
                    MinOccurs = Zero;
                    XmlName = 'Payment_Date';

                    trigger OnBeforePassVariable();
                    begin
                        fDatPayment := FORMAT(gDatDoc);
                    end;
                }
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
        PurchHdr : Record "Purchase Header";
        PurchInv : Record "Purch. Inv. Header";
        PurchCrMemo : Record "Purch. Cr. Memo Hdr.";
        lCduEasyInvoice : Codeunit "Easy Invoice Webservice";
    begin
    end;

    var
        gTxtResult : Text[1024];
        gTxtFault : Text;
        gDatDoc : Date;
        gCodNavInvoiceNo : Code[20];
        gTxtStatus : Text;
        gEasyInvoiceID: Integer;

    //[Scope('Personalization')]
    procedure SetParameters(ResultIn : Text;FaultIn : Text;CodNavInvoiceNoIn : Code[20];DatDocumentIn : Date;StatusIn : Text;EasyInvoiceIDIN : Integer);
    begin
        gTxtResult := ResultIn;
        gTxtFault := FaultIn;
        gCodNavInvoiceNo := CodNavInvoiceNoIn;
        gDatDoc := DatDocumentIn;
        gTxtStatus := StatusIn;
        gEasyInvoiceID := EasyInvoiceIDIN;
    end;
}

