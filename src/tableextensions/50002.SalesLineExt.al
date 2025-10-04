tableextension 50101 "Sales Line Ext" extends "Sales Line"
{
    fields
    {
        field(50111; "Ext IBAN"; Code[34])
        {
            Caption = 'Ext IBAN';
        }
    }
}