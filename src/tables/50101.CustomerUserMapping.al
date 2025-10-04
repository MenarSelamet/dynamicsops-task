table 50103 "CustomerUserMapping"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
        }
        field(2; "DummyJSON User ID"; Integer)
        {
            Caption = 'DummyJSON User ID';
        }
    }

    keys
    {
        key(PK; "Customer No.")
        {
            Clustered = true;
        }
    }
}