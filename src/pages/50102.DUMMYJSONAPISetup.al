page 50100 "DummyJSON API Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "DummyJSONAPISetup";
    InsertAllowed = false;
    DeleteAllowed = false;
    Caption = 'DummyJSON API Setup';

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                }
                field("Base URL"; Rec."Base URL")
                {
                    ApplicationArea = All;
                }
                field(Username; Rec.Username)
                {
                    ApplicationArea = All;
                }
                field(Password; Rec.Password)
                {
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                }
                field("Use Auth"; Rec."Use Authentication")
                {
                    ApplicationArea = All;
                }
            }
            group(Status)
            {
                field(Token; Rec.Token)
                {
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                    Editable = false;
                }
                field("Token Expiry"; Rec."Token Expiry")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Get New Token")
            {
                ApplicationArea = All;
                Caption = 'Get New Token';
                Image = Refresh;

                trigger OnAction()
                var
                    DummyJSONMgt: Codeunit "DummyJSON API Manager";
                begin
                    DummyJSONMgt.GetBearerToken();
                    CurrPage.Update();
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec."Base URL" := 'https://dummyjson.com';
            Rec.Insert();
        end;
    end;
}