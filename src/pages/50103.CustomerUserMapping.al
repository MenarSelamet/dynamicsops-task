page 50102 "Customer User Mapping"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = CustomerUserMapping;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Customer No."; Rec."Customer No.")
                {
                    ApplicationArea = All;
                }
                field("DummyJSON User ID"; Rec."DummyJSON User ID")
                {
                    ApplicationArea = All;
                }
            }
        }

    }
}