codeunit 50101 "Posting Subscriber"

{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesInvHeaderInsert', '', false, false)]
    local procedure HandleOnBeforeSalesInvHeaderInsert(var SalesInvHeader: Record "Sales Invoice Header"; var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; var IsHandled: Boolean; WhseShip: Boolean; WhseShptHeader: Record "Warehouse Shipment Header"; InvtPickPutaway: Boolean)
    begin
        SalesInvHeader."Ext Company Name" := SalesHeader."Ext Company Name";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnBeforeSalesInvLineInsert', '', false, false)]
    local procedure HandleOnBeforeSalesInvLineInsert(var SalesInvLine: Record "Sales Invoice Line"; SalesInvHeader: Record "Sales Invoice Header"; SalesLine: Record "Sales Line"; CommitIsSuppressed: Boolean; var IsHandled: Boolean; PostingSalesLine: Record "Sales Line"; SalesShipmentHeader: Record "Sales Shipment Header"; SalesHeader: Record "Sales Header"; var ReturnReceiptHeader: Record "Return Receipt Header")
    begin
        SalesInvLine."Ext IBAN" := SalesLine."Ext IBAN";
    end;
}