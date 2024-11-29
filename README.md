# Track Notifications
### Aprobaciones por correo electrónico en Business Central
Funcionalidad para procesar las confirmaciones o rechazos a las aprobaciones que Business Central notifica al aprobador por correo electrónico.

>Válido para versión de Business Central 25.0.21703.0 o superior
## Configuración
**Paso 1:** Descarga e [instala](https://learn.microsoft.com/es-es/dynamics365/business-central/ui-extensions-install-uninstall#upload-a-per-tenant-extension-pte) el archivo .app que encontrarás en el apartado *Releases* (El primer archivo .zip)

**Paso 2:** Ve a [Report Layouts](https://learn.microsoft.com/es-es/dynamics365/business-central/ui-set-report-layout), busca el report *1320 - Notification Email - Notification with Tracking* y márcalo *Por defecto*

**Paso 3:** [Crea](https://learn.microsoft.com/es-es/microsoft-365/admin/email/create-a-shared-mailbox) una cuenta compartida en Exchange y [añádela](https://learn.microsoft.com/es-es/dynamics365/business-central/admin-how-setup-email#add-email-accounts) a BC en *Email Accounts*

**Paso 4:** [Asígnale](https://learn.microsoft.com/es-es/dynamics365/business-central/admin-how-setup-email#assign-email-scenarios-to-email-accounts) a esta nueva cuenta el escenario *Notification*
>IMPORTANTE: No omitas el paso 4 para no entrar en conflicto con los correos electrónicos utilizados por otras cuentas

**Paso 5:** [Crea](https://learn.microsoft.com/es-es/dynamics365/business-central/admin-job-queues-schedule-tasks) una *Job Queue Entry* para que ejecute la *codeunit 53100* cada cierto tiempo, por ejemplo cada 3 minutos

**Listo:** Ahora los correos electrónicos que los [workflows](https://learn.microsoft.com/es-es/dynamics365/business-central/across-use-workflows) de aprobaciones mandan a los aprobadores podrán ser respondidos mediante Si / No, y opcionalmente un comentario, para que el registro o documento en cuestión sea aprobado o denegado mediante esta respuesta al correo electrónico recibido.

## Divulgación
Esta funcionalidad ha sido desarrollada como parte de un artículo sobre el desarrollo de características complementarias en Business Central. Puedes leerlo completo aquí [Aprobacion por correo electrónico](https://joseppages.notion.site/aprobaciones-por-correo-electronico-14123005c79?pvs=4)

## Descargo de responsabilidad
Este complemento se proporciona "tal cual" sin garantía de ningún tipo, ya sea expresa o implícita. El creador de este complemento no garantiza que cumpla con sus requisitos ni que su funcionamiento sea ininterrumpido o libre de errores.

Al usar este complemento, usted reconoce y acepta que:

- El creador no es responsable de ningún mal funcionamiento, error o problema que pueda surgir del uso de este complemento.
- El creador no se hace responsable de ningún daño o pérdida, incluidos, entre otros, la pérdida de datos, interrupciones del negocio o pérdidas financieras, derivados del uso de este complemento.
- Es su responsabilidad asegurarse de que el complemento sea compatible con su entorno específico de Business Central y probarlo exhaustivamente antes de usarlo en cualquier entorno de producción.
- El creador no garantiza actualizaciones continuas ni soporte para el complemento.
- Usted es responsable de cumplir con todas las leyes y regulaciones aplicables relacionadas con el uso del complemento y su acceso a los datos de Microsoft Business Central.

El uso de este complemento es bajo su propio riesgo. Se recomienda realizar copias de seguridad regulares de sus datos y actuar con precaución al utilizar herramientas o complementos de terceros junto con sus sistemas empresariales.
