pageextension 50100 "Sales Invoice Ext" extends "Sales Invoice"
{
    layout
    {
        addlast(General)
        {
            field("Ext Company Name"; Rec."Ext Company Name")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addlast(processing)
        {
            action(FetchHeaderInfo)
            {
                Caption = 'Fetch Header Info';
                ApplicationArea = All;
                Image = Import;

                trigger OnAction()
                var
                    Fetcher: Codeunit "Dummy JSON API Manager";
                    CompanyName: Text;
                begin
                    CompanyName := Fetcher.GetRandomCompanyName();
                    if CompanyName <> '' then
                        Rec."Ext Company Name" := CompanyName;
                    Rec.Modify(true);
                end;
            }
        }
    }
}