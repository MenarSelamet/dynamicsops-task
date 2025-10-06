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
                    DummyJSONMgt: Codeunit "DummyJSON API Manager";
                    CompanyName: Text;
                    IBAN: Text;
                    UserId: Integer;
                begin
                    UserId := DummyJSONMgt.GetUserIdFromCustomer(Rec."Sell-to Customer No.");
                    DummyJSONMgt.GetUserData(UserId, CompanyName, IBAN);

                    Rec."Ext Company Name" := CopyStr(CompanyName, 1, MaxStrLen(Rec."Ext Company Name"));
                    Rec.Modify();

                    Message('Header information fetched successfully.');
                end;

            }
            action("Debug User Data")
            {
                ApplicationArea = All;
                Caption = 'Debug User Data';
                ToolTip = 'Debug the user data fetch for this customer';
                Image = Debug;

                trigger OnAction()
                var
                    DummyJSONMgt: Codeunit "DummyJSON API Manager";
                    UserId: Integer;
                begin
                    UserId := DummyJSONMgt.GetUserIdFromCustomer(Rec."Sell-to Customer No.");
                    DummyJSONMgt.DebugUserData(UserId);
                end;
            }
        }
    }
}