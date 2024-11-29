reportextension 53100 "My Notification Email" extends "Notification Email"
{
    dataset
    {
        add("Notification Entry")
        {
            column(NotifEntrySystemId; "Notification Entry".SystemId) { }
        }
    }
    rendering
    {
        layout(MyNotificationEmail)
        {
            Caption = 'Notification with Tracking';
            Summary = 'Provides an ID so that the email response can be tracked.';
            Type = Word;
            LayoutFile = '.\src\MyNotificationEmail.docx';
        }
    }
}