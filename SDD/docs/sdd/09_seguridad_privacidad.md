# 9. Seguridad y privacidad

## 9.1 Datos protegidos

| Nivel | Ejemplos | Controles mínimos |
|---|---|---|
| Restringido | Coordenada exacta, correo, teléfono, foto, token | Cifrado, RBAC, auditoría, no logs |
| Interno | Estado privado, motivo, señales EXIF, coincidencias | Autenticación, rol/propiedad |
| Público | Agregados, ubicación aproximada, protocolos | DTO dedicado y validación de salida |

## 9.2 Amenazas principales

- Acceso indebido a coordenadas o PII.
- Cuenta administrativa comprometida.
- Inyección o carga de archivo malicioso.
- Abuso masivo de reportes anónimos.
- Doble envío o manipulación de idempotencia.
- Exposición en logs, respaldos o exportaciones.
- Reidentificación por mapas demasiado precisos.
- Dependencia o secreto comprometido.

## 9.3 Controles

### Identidad

- Spring Boot aplica políticas de contraseña y guarda únicamente `Contrasena_Hash` con un algoritmo moderno por definir antes de implementar.
- JWT validado por firma, emisor, audiencia y expiración.
- El JWT incluye el rol mínimo necesario, obtenido de `Usuarios.Rol`.
- Sesión administrativa expira tras 15 minutos de inactividad.
- El mecanismo de MFA administrativo queda por definir antes de producción.

### Autorización

- Guardas por rol y política de propiedad en aplicación.
- Consultas de repositorio incluyen el alcance autorizado.
- `404` para recursos ajenos cuando revelar existencia sea innecesario.
- La tabla `Fotos` no se expone directamente; solo los casos de uso autorizados pueden leerla.

### Datos

- TLS en tránsito.
- Cifrado administrado de Cloud SQL y sus respaldos; el cifrado adicional de campos sensibles queda por definir.
- PII de perfil cifrada a nivel de aplicación o columna además del cifrado de volumen.
- Llaves y secretos solo en servicio administrado; nunca GitHub ni imagen Docker.
- SQLite y fotos offline cifradas.

### Entradas y archivos

- Validación por lista permitida y límites.
- Detectar MIME por contenido, no solo extensión.
- Decodificar y re-encodear imágenes para retirar contenido activo y metadatos no requeridos.
- Conservar señales EXIF necesarias en campos privados y eliminar EXIF del archivo persistido cuando sea posible.
- SHA-256 para integridad y coincidencia.

### Abuso

- Rate limits por IP, identidad y acción; el servicio perimetral administrado concreto queda por definir.
- Límites más estrictos para anónimos.
- Alertas de volumen atípico.
- Moderación antes de publicación.

## 9.4 Logs seguros

Permitidos: request ID, ruta parametrizada, código, latencia, versión, rol general y código de error.

Prohibidos: JWT, correo, teléfono, descripción, payload, foto, EXIF y coordenadas. Los IDs se seudonimizan cuando una métrica no necesita correlación directa.

## 9.5 Retención

### Cuenta inactiva

Trabajo diario selecciona perfiles activos con `Ultima_Actividad < now - 12 meses`. En una operación idempotente:

1. invalida la cuenta y sus sesiones propias según la política elegida;
2. borra correo/teléfono y consentimiento;
3. desvincula reportes conservados;
4. marca perfil anonimizado;
5. registra el resultado en `Bitacora_Administrativa` sin PII.

### Reporte

Se conserva al menos cinco años desde creación si el autor no lo borra. La política de qué ocurre después de cinco años requiere decisión; el MVP no elimina automáticamente al cumplir exactamente cinco años.

### Borrado del autor

Se eliminan la fila de `Registros`, su fila de `Fotos`, la relación y la ubicación. Se registra un evento mínimo sin contenido ni identificador reutilizable públicamente.

## 9.6 Exportaciones y finalidad

La política por defecto es aproximada. Una exportación exacta requiere rol, motivo, destinatario y evidencia de autorización; su creación y descarga se auditan.

## 9.7 Respuesta a incidentes

1. Detectar y clasificar.
2. Revocar sesión/cuenta y restringir acceso a Cloud SQL.
3. Rotar credenciales y contener.
4. Preservar evidencia técnica redactada.
5. Evaluar alcance de datos y obligaciones de comunicación.
6. Corregir, probar y documentar.

## 9.8 Verificación

- Pruebas de autorización por rol y propiedad.
- Escaneo de secretos y dependencias en CI.
- Pruebas de archivo, tamaño, MIME, inyección y rate limit.
- Inspección de logs para ausencia de datos restringidos.
- Prueba de anonimización y borrado.
- Revisión de exportaciones y privacidad geográfica.
