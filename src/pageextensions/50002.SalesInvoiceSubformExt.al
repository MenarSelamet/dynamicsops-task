pageextension 50101 "Sales Invoice Subform Ext" extends "Sales Invoice Subform"
{
    layout
    {
        addlast(Control1)
        {
            field("Ext IBAN"; Rec."Ext IBAN")
            {
                ApplicationArea = All;
            }
        }

    }

    actions
    {
        addlast("&Line")
        {
            action(FetchLineInfo)
            {
                Caption = 'Fetch IBAN';
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

                    Rec."Ext IBAN" := CopyStr(IBAN, 1, MaxStrLen(Rec."Ext IBAN"));
                    Rec.Modify();

                    Message('Line information fetched successfully.');
                end;

            }
        }
    }
}