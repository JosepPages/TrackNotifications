pageextension 53100 "My Notification Email" extends "Notification Entries"
{
    actions
    {
        addlast(processing)
        {
            action(ReceiveEmails)
            {
                ApplicationArea = All;
                Caption = 'Recibir correos-e';
                ToolTip = 'Recibe los correos electrónicos de respuesta a todas las notificaciones de aprobaciones.';
                Image = Email;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunObject = codeunit "My Notification Email";
            }
        }
    }
}