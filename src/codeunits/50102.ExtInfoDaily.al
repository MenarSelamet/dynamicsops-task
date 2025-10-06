codeunit 50105 "Ext Info Daily Job"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        DummyJSONMgt: Codeunit "DummyJSON API Manager";
        CustomerUserMapping: Record "CustomerUserMapping";
        CompanyName: Text;
        IBAN: Text;
        UserId: Integer;
        ProcessedCount: Integer;
        ErrorCount: Integer;
    begin
        ProcessedCount := 0;
        ErrorCount := 0;

        ProcessOpenSalesInvoices(DummyJSONMgt, ProcessedCount, ErrorCount);

        ProcessPostedSalesInvoices(DummyJSONMgt, ProcessedCount, ErrorCount);

        Session.LogMessage('000021', StrSubstNo('Daily job completed. Processed: %1, Errors: %2',
            ProcessedCount, ErrorCount), Verbosity::Normal, DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher, 'Category', 'DummyJSON');

        if ErrorCount = 0 then
            Message('Daily auto-fill completed successfully. Processed %1 documents.', ProcessedCount)
        else
            Message('Daily auto-fill completed with %1 errors out of %2 total processed documents.', ErrorCount, ProcessedCount);
    end;

    local procedure ProcessOpenSalesInvoices(var DummyJSONMgt: Codeunit "DummyJSON API Manager"; var ProcessedCount: Integer; var ErrorCount: Integer)
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CustomerUserMapping: Record "CustomerUserMapping";
        CompanyName: Text;
        IBAN: Text;
        UserId: Integer;
        HeaderModified: Boolean;
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Invoice);
        SalesHeader.SetFilter("Posting Date", '%1', Today);

        if SalesHeader.FindSet(true) then
            repeat
                if not CustomerUserMapping.Get(SalesHeader."Sell-to Customer No.") then begin
                    Session.LogMessage('000022', StrSubstNo('No user mapping found for customer %1 in document %2',
                        SalesHeader."Sell-to Customer No.", SalesHeader."No."), Verbosity::Warning,
                        DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', 'DummyJSON');
                    ErrorCount += 1;
                    continue;
                end;

                UserId := CustomerUserMapping."DummyJSON User Id";

                if not ProcessSalesHeader(DummyJSONMgt, SalesHeader, UserId, CompanyName, IBAN) then begin
                    ErrorCount += 1;
                    continue;
                end;

                SalesLine.SetRange("Document Type", SalesHeader."Document Type");
                SalesLine.SetRange("Document No.", SalesHeader."No.");
                if SalesLine.FindSet(true) then
                    repeat
                        if not ProcessSalesLine(DummyJSONMgt, SalesLine, UserId, IBAN) then
                            ErrorCount += 1;
                    until SalesLine.Next() = 0;

                ProcessedCount += 1;
            until SalesHeader.Next() = 0;
    end;

    local procedure ProcessPostedSalesInvoices(var DummyJSONMgt: Codeunit "DummyJSON API Manager"; var ProcessedCount: Integer; var ErrorCount: Integer)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        CustomerUserMapping: Record "CustomerUserMapping";
        CompanyName: Text;
        IBAN: Text;
        UserId: Integer;
    begin
        SalesInvoiceHeader.SetFilter("Posting Date", '%1', Today);

        if SalesInvoiceHeader.FindSet(true) then
            repeat
                if not CustomerUserMapping.Get(SalesInvoiceHeader."Sell-to Customer No.") then begin
                    Session.LogMessage('000023', StrSubstNo('No user mapping found for customer %1 in posted invoice %2',
                        SalesInvoiceHeader."Sell-to Customer No.", SalesInvoiceHeader."No."), Verbosity::Warning,
                        DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', 'DummyJSON');
                    ErrorCount += 1;
                    continue;
                end;

                UserId := CustomerUserMapping."DummyJSON User Id";

                if not ProcessSalesInvoiceHeader(DummyJSONMgt, SalesInvoiceHeader, UserId, CompanyName, IBAN) then begin
                    ErrorCount += 1;
                    continue;
                end;

                SalesInvoiceLine.SetRange("Document No.", SalesInvoiceHeader."No.");
                if SalesInvoiceLine.FindSet(true) then
                    repeat
                        if not ProcessSalesInvoiceLine(DummyJSONMgt, SalesInvoiceLine, UserId, IBAN) then
                            ErrorCount += 1;
                    until SalesInvoiceLine.Next() = 0;

                ProcessedCount += 1;
            until SalesInvoiceHeader.Next() = 0;
    end;

    local procedure ProcessSalesHeader(var DummyJSONMgt: Codeunit "DummyJSON API Manager"; var SalesHeader: Record "Sales Header"; UserId: Integer; var CompanyName: Text; var IBAN: Text): Boolean
    begin
        if not DummyJSONMgt.GetUserData(UserId, CompanyName, IBAN) then begin
            Session.LogMessage('000024', StrSubstNo('Failed to get user data for UserId %1 in document %2',
                UserId, SalesHeader."No."), Verbosity::Warning, DataClassification::SystemMetadata,
                TelemetryScope::ExtensionPublisher, 'Category', 'DummyJSON');
            exit(false);
        end;

        if CompanyName <> '' then begin
            SalesHeader."Ext Company Name" := CopyStr(CompanyName, 1, MaxStrLen(SalesHeader."Ext Company Name"));
            SalesHeader.Modify(true);
        end;

        exit(true);
    end;

    local procedure ProcessSalesLine(var DummyJSONMgt: Codeunit "DummyJSON API Manager"; var SalesLine: Record "Sales Line"; UserId: Integer; IBAN: Text): Boolean
    begin
        if IBAN <> '' then begin
            SalesLine."Ext IBAN" := CopyStr(IBAN, 1, MaxStrLen(SalesLine."Ext IBAN"));
            SalesLine.Modify(true);
        end;

        exit(true);
    end;

    local procedure ProcessSalesInvoiceHeader(var DummyJSONMgt: Codeunit "DummyJSON API Manager"; var SalesInvoiceHeader: Record "Sales Invoice Header"; UserId: Integer; var CompanyName: Text; var IBAN: Text): Boolean
    begin
        if not DummyJSONMgt.GetUserData(UserId, CompanyName, IBAN) then begin
            Session.LogMessage('000025', StrSubstNo('Failed to get user data for UserId %1 in posted invoice %2',
                UserId, SalesInvoiceHeader."No."), Verbosity::Warning, DataClassification::SystemMetadata,
                TelemetryScope::ExtensionPublisher, 'Category', 'DummyJSON');
            exit(false);
        end;

        if CompanyName <> '' then begin
            SalesInvoiceHeader."Ext Company Name" := CopyStr(CompanyName, 1, MaxStrLen(SalesInvoiceHeader."Ext Company Name"));
            SalesInvoiceHeader.Modify(true);
        end;

        exit(true);
    end;

    local procedure ProcessSalesInvoiceLine(var DummyJSONMgt: Codeunit "DummyJSON API Manager"; var SalesInvoiceLine: Record "Sales Invoice Line"; UserId: Integer; IBAN: Text): Boolean
    begin
        if IBAN <> '' then begin
            SalesInvoiceLine."Ext IBAN" := CopyStr(IBAN, 1, MaxStrLen(SalesInvoiceLine."Ext IBAN"));
            SalesInvoiceLine.Modify(true);
        end;

        exit(true);
    end;
}