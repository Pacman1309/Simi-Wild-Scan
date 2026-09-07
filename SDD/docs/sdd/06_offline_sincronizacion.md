# 6. Operación offline y sincronización

## 6.1 Objetivo

Permitir terminar un reporte sin conexión y garantizar que cierre, reapertura, interrupciones y reintentos no pierdan ni dupliquen información.

## 6.2 Registro local

La tabla cifrada `outbox_report` contiene:

- `client_report_id` UUID;
- versión del esquema local;
- payload validado;
- ruta privada de foto comprimida opcional;
- SHA-256 de la foto;
- estado local;
- contador de intentos;
- siguiente intento;
- último código de error redactado;
- fechas de creación, actualización y sincronización.

La clave de SQLite se genera por instalación y se guarda en Keychain/Keystore. No se incluye en respaldos inseguros ni logs.

## 6.3 Máquina de estados

```text
LOCAL_SAVED -> SYNC_PENDING -> SYNCING -> SYNCED
                    ^             |
                    |             v
                    +-------- SYNC_ERROR
```

- `LOCAL_SAVED`: borrador completo guardado, sin solicitud programada.
- `SYNC_PENDING`: listo para enviar.
- `SYNCING`: bloqueo temporal con fecha de arrendamiento.
- `SYNC_ERROR`: error recuperable o corregible visible.
- `SYNCED`: servidor confirmó el mismo UUID.

Si la app termina durante `SYNCING`, un arrendamiento vencido devuelve el elemento a `SYNC_PENDING`.

## 6.4 Algoritmo

1. Detectar una red disponible; disponibilidad no implica Internet estable.
2. Seleccionar el elemento pendiente más antiguo cuyo `nextAttemptAt` venció.
3. Marcar `SYNCING` en una transacción local.
4. Enviar UUID en payload y `Idempotency-Key`.
5. En `200/201`, guardar ID del servidor, marcar `SYNCED` y borrar payload/foto local sensible tras confirmación.
6. En `400/422`, marcar error no automático y pedir corrección si el usuario puede editarlo.
7. En `401`, pausar registrados hasta renovar sesión; un reporte creado como registrado no se degrada silenciosamente a anónimo.
8. En `408/429/5xx` o red, programar reintento.

## 6.5 Reintentos

Espera exponencial con dispersión: base 2 s, máximo 15 min mientras la app está activa. El sistema operativo puede reanudar más tarde. `Retry-After` prevalece para `429/503`.

No existe límite que descarte automáticamente el reporte. Tras varios fallos se muestra acción manual y diagnóstico seguro.

## 6.6 Idempotencia de servidor

- Restricción única por `idempotency_key` y por `client_report_id`.
- Se conserva hash canónico del payload inicial.
- Misma llave + mismo hash: devolver recurso existente.
- Misma llave + hash distinto: `409 IDEMPOTENCY_CONFLICT`.
- La transacción reserva la llave antes de crear relaciones y auditoría.

La foto usa SHA-256 para verificar el reintento, pero el hash no decide por sí solo que dos observaciones humanas sean falsas.

## 6.7 Cambios de esquema

Cada fila incluye `schemaVersion`. Migraciones locales son incrementales y se prueban con datos de versiones anteriores. Si una migración no puede interpretar un borrador, se conserva copia cifrada y se ofrece recuperación; nunca se borra silenciosamente.

## 6.8 Privacidad local

- Archivos en directorio privado de la aplicación.
- Protección contra respaldos del sistema cuando la plataforma lo permita.
- Pantallas de error no muestran coordenadas completas.
- Al cerrar sesión se eliminan tokens; la cola no sincronizada se mantiene cifrada y requiere decisión explícita si pertenece a la cuenta.
- Tras `SYNCED`, se elimina contenido local sensible y queda solo referencia/estado mínimo.

## 6.9 Pruebas obligatorias

- Guardar sin red, cerrar, reiniciar y recuperar.
- Cortar red antes, durante y después de recibir respuesta.
- Repetir la misma solicitud diez veces: un registro servidor.
- Reiniciar durante `SYNCING`.
- Foto cercana a 1 MB y compresión fallida.
- Token vencido, `429`, `500` y timeout.
- Cola con varios reportes en orden.
- Migración de esquema con borradores existentes.
