pageextension 50104 "Posted Sales Invoice Ext" extends "Posted Sales Invoice"
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