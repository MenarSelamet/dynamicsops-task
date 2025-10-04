table 50100 "DummyJSONAPISetup"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Base URL"; Text[250])
        {
            Caption = 'Base URL';
        }
        field(2; "Username"; Text[100])
        {
            Caption = 'Username';
        }
        field(3; "Password"; Text[100])
        {
            Caption = 'Password';
        }
        field(4; "Token"; Text[1000])
        {
            Caption = 'Token';
            Editable = false;
        }
        field(5; "Token Expiry"; DateTime)
        {
            Caption = 'Token Expiry';
            Editable = false;
        }
        field(6; "Use Authentication"; Boolean)
        {
            Caption = 'Use Authentication';
        }
    }

    keys
    {
        key(PK; "Base URL")
        {
            Clustered = true;
        }
    }



}