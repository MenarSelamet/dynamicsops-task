page 50101 "Customer User Mapping List"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "CustomerUserMapping";
    Caption = 'Customer User Mapping';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                }
                field("DummyJSON User Id"; Rec."DummyJSON User Id")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}
