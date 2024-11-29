codeunit 53100 "My Notification Email"
{
    Permissions = tabledata "Email Account" = R,
                  tabledata "Email Inbox" = R,
                  tabledata "Notification Entry" = R,
                  tabledata "Approval Entry" = R,
                  tabledata "Approval Comment Line" = RIM;

    trigger OnRun()
    begin
        RetrieveApprovalReplies()
    end;

    procedure RetrieveApprovalReplies()
    var
        EmailAccount: Record "Email Account" temporary;
        EmailInbox: Record "Email Inbox";
        NotificationEntry: Record "Notification Entry";
        ApprovalEntry: Record "Approval Entry";
        ApprovalCommentLine: Record "Approval Comment Line";
        EmailScenario: Codeunit "Email Scenario";
        Email: Codeunit Email;
        EmailMessageReceived: Codeunit "Email Message";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        TypeHelper: Codeunit "Type Helper";
        Subject: Text;
        Body: Text;
        TrackingId: Guid;
        ApprovalProcessed: Boolean;
        ReplyMessage: Text;
        TrackCodeLiteralLbl: Label 'TRACKCODE #', Locked = true;
    begin
        // Busca la cuenta asignada al escenario Notification
        if not EmailScenario.IsThereEmailAccountSetForScenario(Enum::"Email Scenario"::Notification) then
            exit;
        EmailScenario.GetEmailAccount(Enum::"Email Scenario"::Notification, EmailAccount);

        // Recupera los correos electrónicos recibidos sin leer
        Email.RetrieveEmails(EmailAccount."Account Id", EmailAccount.Connector, EmailInbox);
        if EmailInbox.FindSet() then
            repeat
                Clear(ReplyMessage);

                // New email received
                EmailMessageReceived.Get(EmailInbox."Message Id");
                Body := EmailMessageReceived.GetBody();
                if StrPos(Body, TrackCodeLiteralLbl) = 0 then
                    ReplyMessage := 'No se ha encontrado el código de seguimiento. Tu correo electrónico no tendrá ningún efecto.';

                while StrPos(Body, TrackCodeLiteralLbl) <> 0 do begin
                    Clear(ApprovalProcessed);

                    TrackingId := CopyStr(
                                        Body,
                                        StrPos(Body, TrackCodeLiteralLbl) + StrLen(TrackCodeLiteralLbl),
                                        36
                                    );
                    Body :=
                        CopyStr(
                            Body,
                            1,
                            StrPos(Body, TrackCodeLiteralLbl) - 1
                        )
                        +
                        CopyStr(
                            Body,
                            StrPos(Body, TrackCodeLiteralLbl) + StrLen(TrackCodeLiteralLbl) + 36 + 1
                        );

                    NotificationEntry.GetBySystemId(TrackingId);
                    if NotificationEntry."Triggered By Record".TableNo <> Database::"Approval Entry" then
                        ReplyMessage += StrSubstNo(
                                            'La notificación %1 no corresponde a aprobación alguna.%2',
                                            TrackingId,
                                            TypeHelper.CRLFSeparator()
                                        )
                    else begin
                        ApprovalEntry.Reset();
                        ApprovalEntry.Get(NotificationEntry."Triggered By Record");
                        ApprovalEntry.SetRecFilter();
                        if ApprovalEntry.Status = ApprovalEntry.Status::Open then
                            case UpperCase(CopyStr(Body, 1, 2)) of
                                'SÍ', 'SI':
                                    begin
                                        ApprovalsMgmt.ApproveApprovalRequests(ApprovalEntry);
                                        ReplyMessage += StrSubstNo(
                                                            'La aprobación %1 ha sido aprobada.%2',
                                                            TrackingId,
                                                            TypeHelper.CRLFSeparator()
                                                        );
                                        ApprovalProcessed := true;
                                    end;
                                'NO':
                                    begin
                                        ApprovalsMgmt.RejectApprovalRequests(ApprovalEntry);
                                        ReplyMessage += StrSubstNo(
                                                            'La aprobación %1 ha sido denegada.%2',
                                                            TrackingId,
                                                            TypeHelper.CRLFSeparator()
                                                        );
                                        ApprovalProcessed := true;
                                    end;
                                else
                                    ReplyMessage += StrSubstNo(
                                                        'No se ha detectado una respuesta válida para la aprobación %1%2',
                                                        TrackingId,
                                                        TypeHelper.CRLFSeparator()
                                                    );
                            end;
                    end;

                    if ApprovalProcessed then begin
                        ApprovalCommentLine.SetRange("Table ID", ApprovalEntry."Table ID");
                        ApprovalCommentLine.SetRange("Record ID to Approve", ApprovalEntry."Record ID to Approve");

                        // Captura la cuenta de email del que respondió al email de notificación
                        ApprovalCommentLine.Init();
                        ApprovalCommentLine."Entry No." := 0;
                        ApprovalCommentLine.Validate("Table ID", ApprovalEntry."Table ID");
                        ApprovalCommentLine.Validate("Record ID to Approve", ApprovalEntry."Record ID to Approve");
                        ApprovalCommentLine.Validate("Workflow Step Instance ID", ApprovalEntry."Workflow Step Instance ID");
                        ApprovalCommentLine.Validate(Comment, CopyStr(
                                                                StrSubstNo(
                                                                    'Correo-e recibido de %1',
                                                                    EmailInbox."Sender Address"
                                                                ),
                                                                1,
                                                                MaxStrLen(ApprovalCommentLine.Comment)
                                                            ));
                        ApprovalCommentLine.Insert(true);

                        // Captura el posible comentario a partir de la palabra Si / No
                        ApprovalCommentLine.Init();
                        ApprovalCommentLine."Entry No." := 0;
                        ApprovalCommentLine.Validate("Table ID", ApprovalEntry."Table ID");
                        ApprovalCommentLine.Validate("Record ID to Approve", ApprovalEntry."Record ID to Approve");
                        ApprovalCommentLine.Validate("Workflow Step Instance ID", ApprovalEntry."Workflow Step Instance ID");
                        ApprovalCommentLine.Validate(Comment, CopyStr(
                                                                Body,
                                                                4,
                                                                MaxStrLen(ApprovalCommentLine.Comment)
                                                            ));
                        ApprovalCommentLine.Insert(true);
                    end;
                end;

                // Envía respuesta
                if ReplyMessage <> '' then begin
                    Subject := EmailMessageReceived.GetSubject();
                    if UpperCase(CopyStr(Subject, 1, 2)) <> 'RE' then
                        Subject := 'Re: ' + Subject;
                    EmailMessageReceived.CreateReply(
                        EmailInbox."Sender Address",
                        Subject,
                        ReplyMessage,
                        false,
                        EmailMessageReceived.GetExternalId()
                    );
                    Email.Send(EmailMessageReceived, EmailAccount);
                end;
            until EmailInbox.Next() = 0;
    end;

    // Se establece el IsHandled porque sino el código en la CU "Approvals Mgmt." hace una comprobación de que
    //   el usuario que está aprobando o denegando sea el usuario aprobador o un admin de aprobaciones,
    //   en este caso, el usuario que esté ejecutando esta codeunit.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnBeforeCheckUserAsApprovalAdministrator', '', false, false)]
    local procedure OnBeforeCheckUserAsApprovalAdministrator(var IsHandled: Boolean)
    begin
        IsHandled := true;
    end;
}