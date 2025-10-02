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
}