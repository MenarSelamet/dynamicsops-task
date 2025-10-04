page 50100 "DummyJSONAPISetup"
{
    PageType = Card;
    SourceTable = "DummyJSONAPISetup";
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'DummyJSON API Setup';

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Base URL"; Rec."Base URL")
                {
                    ApplicationArea = All;
                }
                field("Username"; Rec."Username")
                {
                    ApplicationArea = All;
                }
                field("Password"; Rec."Password")
                {
                    ApplicationArea = All;
                }
                field("Use Authentication"; Rec."Use Authentication")
                {
                    ApplicationArea = All;
                }
                field("Token"; Rec."Token")
                {
                    ApplicationArea = All;
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
        area(processing)
        {
            action(GetToken)
            {
                Caption = 'Get Token';
                ApplicationArea = All;

                trigger onAction()
                begin
                    Message('This is a placeholder for the get Token Action');
                end;
            }
        }
    }
}