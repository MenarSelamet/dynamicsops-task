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
    actions
    {
        addlast(processing)
        {
            action(FetchHeaderInfo)
            {
                Caption = 'Fetch Header Info';
                ApplicationArea = All;
                Image = Import;

                trigger OnAction()
                begin
                    Message('This is the Ext Company Button');
                end;
            }
        }
    }
}