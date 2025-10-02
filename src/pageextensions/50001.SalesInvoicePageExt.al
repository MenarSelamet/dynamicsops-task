pageextension 50100 "Sales Invoice Ext" extends "Sales Invoice"
{
    layout
    {
        addlast(General)
        {
            field("Ext Company Name"; Rec."Ext Company Name")
            {
                ApplicationArea = All;
            }
        }
    }
}