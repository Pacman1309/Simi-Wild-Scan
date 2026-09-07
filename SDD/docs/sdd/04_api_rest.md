# 4. Diseño de API REST

Contrato de máquina: [openapi.yaml](openapi.yaml).

## 4.1 Convenciones

- Base: `/v1`.
- JSON UTF-8 salvo carga multipart y descarga de archivos.
- Fechas ISO 8601 UTC.
- Paginación por cursor opaco.
- JWT propio en `Authorization: Bearer`.
- `X-Request-Id` propagado o generado para trazabilidad.
- `Idempotency-Key` obligatorio al crear reportes.
- Respuestas públicas y administrativas usan esquemas distintos.

## 4.2 Errores

```json
{
  "error": {
    "code": "REPORT_DATE_INVALID",
    "message": "La fecha del evento no es válida.",
    "requestId": "uuid",
    "details": [{ "field": "eventAt", "reason": "future" }]
  }
}
```

No se devuelven excepciones, SQL, rutas, tokens, PII ni coordenadas en errores.

## 4.3 Endpoints públicos

| Método | Ruta | Resultado | RF |
|---|---|---|---|
| GET | `/health` | Estado técnico mínimo | RNF-REN-01 |
| GET | `/public/protocols` | Protocolo vigente | RF-001, RF-046 |
| GET | `/public/reports` | Reportes verificados con ubicación aproximada | RF-001, RF-031 a 036 |
| GET | `/public/heatmap` | Celdas agregadas y conteos | RF-032, RF-034 a 036 |
| POST | `/reports` | Reporte anónimo o registrado opcional | RF-002, RF-007 a 020 |

`GET /public/reports` acepta `bbox`, `from`, `to`, `eventType`, `severity` y `cursor`. Nunca permite filtrar por autor.

## 4.4 Identidad y perfil

Registro e inicio de sesión se realizan contra el módulo de autenticación del backend Spring Boot. La contraseña en texto plano solo viaja por HTTPS, se procesa con `PasswordHasher` y nunca se persiste.

| Método | Ruta | Resultado |
|---|---|---|
| POST | `/auth/register` | Crea una cuenta adulta y devuelve un JWT |
| POST | `/auth/login` | Verifica correo/contraseña, actualiza actividad y devuelve un JWT |
| POST | `/auth/logout` | Cierra la sesión en el dispositivo; revoca el token si se implementa lista de revocación |
| POST | `/me/session` | Sincroniza perfil y actualiza último login |
| GET | `/me/profile` | Perfil propio y consentimiento |
| PATCH | `/me/contact-consent` | Consentimiento y teléfono opcional |

La casilla inicia desmarcada. Retirar consentimiento limpia teléfono salvo que otra obligación aprobada exija conservarlo.

## 4.5 Reportes propios

| Método | Ruta | Resultado |
|---|---|---|
| GET | `/me/reports` | Todos los reportes del usuario, cualquier estado |
| GET | `/me/reports/{id}` | Detalle propio |
| PATCH | `/me/reports/{id}` | Edita y regresa a `PENDING` |
| DELETE | `/me/reports/{id}` | Borrado físico y evento técnico mínimo |

Un usuario no puede inferir la existencia de un reporte ajeno: propiedad inválida responde `404`.

## 4.6 Administración

| Método | Ruta | Resultado |
|---|---|---|
| GET | `/admin/reports` | Lista privada filtrable |
| GET | `/admin/reports/{id}` | Detalle exacto, evidencia y contacto consentido |
| POST | `/admin/reports/{id}/moderation` | Cambia estado con motivo/checklist |
| GET | `/admin/reports/{id}/matches` | Posibles coincidencias |
| POST | `/admin/reports/{id}/relationships` | Marca duplicado o corroboración |
| GET | `/admin/metrics` | KPI sobre verificados |
| POST | `/admin/exports` | Genera y devuelve un archivo/flujo temporal |
| GET | `/admin/audit` | Bitácora paginada y filtrable |

## 4.7 Creación de reporte

`POST /reports` usa `multipart/form-data`:

- `payload`: JSON conforme a `ReportCreate`.
- `photo`: archivo opcional JPEG/PNG/HEIC aceptado por política y convertido a formato seguro antes de persistir.

El cliente genera `clientReportId`; el encabezado `Idempotency-Key` debe tener el mismo valor. Primera llamada: `201`. Reintento idéntico: `200` con `replayed: true`. Misma llave con contenido distinto: `409 IDEMPOTENCY_CONFLICT`.

## 4.8 Autorización

| Operación | Anónimo | Usuario | Admin |
|---|:---:|:---:|:---:|
| Consultar público | Sí | Sí | Sí |
| Crear reporte | Sí | Sí | Sí |
| Consultar/editar/borrar propio | No | Sí | Sí, solo si es propio por esta ruta |
| Consultar exacto | No | No | Sí |
| Moderar/exportar/auditar | No | No | Sí |

## 4.9 Límites

- Cuerpo JSON: 64 KB.
- Foto ya comprimida: 1 MB.
- Descripción: 20 a 2,000 caracteres.
- Exportaciones: una activa por administrador y formato; límites adicionales configurables.
- Rate limit diferenciado: lectura pública, creación anónima, autenticada y administración.

Los valores concretos de solicitudes/minuto se afinan con pruebas y con el control perimetral que se seleccione; el rechazo usa `429` y `Retry-After`.

## 4.10 Compatibilidad

Cambios aditivos mantienen `/v1`. Quitar o reinterpretar campos exige `/v2`, migración y periodo de convivencia. La app envía su versión; API puede rechazar una versión insegura con un error explícito de actualización.
