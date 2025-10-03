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

    actions
    {
        addlast("&Line")
        {
            action(FetchLineInfo)
            {
                Caption = 'Fetch IBAN';
                ApplicationArea = All;
                Image = Import;

                trigger onAction()
                var
                    IBAN: Text;
                begin
                    Message('This is the Ext IBAN Button');
                    Rec."Ext IBAN" := 'DE89370400440532013000';
                end;
            }
        }
    }
}