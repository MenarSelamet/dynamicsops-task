table 50123 "DummyJSONAPISetup"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Code; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;

        }
        field(2; "Base URL"; Text[250])
        {
            Caption = 'Base URL';
        }
        field(3; "Username"; Text[100])
        {
            Caption = 'Username';
        }
        field(4; "Password"; Text[100])
        {
            Caption = 'Password';
        }
        field(5; "Token"; Text[1000])
        {
            Caption = 'Token';
            Editable = false;
        }
        field(6; "Token Expiry"; DateTime)
        {
            Caption = 'Token Expiry';
            Editable = false;
        }
        field(7; "Use Authentication"; Boolean)
        {
            Caption = 'Use Authentication';
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }
}