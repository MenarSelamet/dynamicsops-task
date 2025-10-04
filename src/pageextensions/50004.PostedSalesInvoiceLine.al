pageextension 50106 "Posted Sales Invoice Line Ext" extends "Posted Sales Invoice Subform"
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