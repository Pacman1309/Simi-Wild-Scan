# 1. Objetivos y principios de diseño

## 1.1 Objetivo técnico

Construir un MVP móvil confiable que capture reportes aun con conectividad irregular, preserve la seguridad de las personas, proteja ubicaciones y datos personales, y produzca evidencia verificada y exportable para el socio formador.

## 1.2 Atributos prioritarios

En orden de decisión:

1. Seguridad física del reportante: nunca se exige acercarse ni tomar fotografía.
2. Privacidad: coordenadas exactas y PII no salen de funciones administrativas autorizadas.
3. Integridad: un reintento no crea duplicados y una edición vuelve a moderación.
4. Disponibilidad de captura: el reporte puede guardarse sin Internet.
5. Trazabilidad: requisitos, tickets, código, pruebas y decisiones conservan identificadores.
6. Rendimiento: se cumplen los umbrales RNF sin sacrificar controles anteriores.
7. Facilidad de uso: el flujo básico debe completarse en 90 segundos o menos.

## 1.3 Actores y confianza

| Actor | Identidad | Capacidades | Datos prohibidos |
|---|---|---|---|
| Visitante | Sin sesión | Consultar protocolos, mapa y datos públicos | PII, coordenada exacta, estados privados |
| Reportante anónimo | Sin sesión | Enviar reporte y consultar lo público | Editar/eliminar después del envío |
| Usuario registrado | JWT emitido por Spring Boot | Reportar y administrar sus reportes | Reportes privados de terceros |
| Administrador | JWT propio + rol ADMIN | Moderar, consultar exactos, métricas, exportar y auditar | Acciones fuera de finalidad o sin registro |
| Servicio de retención | Rol técnico mínimo | Anonimizar cuentas vencidas | Uso interactivo o exportación |
| Socio formador | Fuera del sistema o cuenta autorizada | Aceptación y uso de entregables permitidos | Acceso implícito a PII o exactos |

Los menores solo usan la modalidad anónima. La confirmación de mayoría de edad no pretende verificar legalmente la edad; funciona como declaración previa al registro.

## 1.4 Límites del sistema

- El módulo de autenticación de Spring Boot aplica `PasswordHasher`, conserva solo el hash y emite JWT.
- DogAlert conserva perfil, consentimiento, reportes, evidencia, moderación y auditoría.
- El proveedor de mapas entrega mosaicos; no recibe PII ni el contenido del reporte.
- La tabla privada `Fotos` de MySQL almacena las imágenes cifradas; no existe acceso público directo.
- Las autoridades reciben exportaciones anonimizadas salvo autorización formal documentada.

## 1.5 Principios de implementación

### Separación público/privado

No se reutilizará un DTO administrativo en un endpoint público. Los modelos públicos se construyen mediante consultas y serializadores específicos que no contienen campos exactos ni PII.

### Privacidad por defecto

- Consentimiento de contacto inicia en `false`.
- Fotografía y teléfono son opcionales.
- Coordenadas exactas nunca aparecen en logs de aplicación.
- Exportaciones externas usan ubicación aproximada.

### Defensa en profundidad

La interfaz oculta funciones no autorizadas, pero la API vuelve a validar identidad, rol, propiedad y finalidad. Cloud SQL permanece privado aunque falle una capa anterior.

### Idempotencia primero

Cada reporte se identifica en el dispositivo antes de enviarse. El servidor aplica una restricción única; la detección de duplicados semánticos no reemplaza este control.

### Neutralidad

Los textos, estados y métricas describen actividad reportada. No diagnostican, recomiendan tratamientos ni presentan ausencia de datos como ausencia de riesgo.

## 1.6 Restricciones verificables

| Restricción | Consecuencia de diseño |
|---|---|
| Android e iOS | Un cliente React Native y pruebas en ambos sistemas |
| Panel administrativo móvil | Rutas protegidas dentro de la misma app; no se crea portal web |
| Conectividad irregular | Persistencia local cifrada, reintentos y estados visibles |
| Foto opcional y máximo 1 MB | Compresión previa y validación doble cliente/servidor |
| Cinco años de reportes | Índices temporales/geográficos y políticas de almacenamiento |
| PII tras 12 meses sin login | Trabajo diario idempotente de anonimización |
| Fecha límite 23/10/2026 | Decisiones sencillas, servicios administrados y alcance MVP estricto |

## 1.7 Convenciones

- Identificadores internos: UUID v4.
- Tiempo: UTC en API y DB; presentación en zona local del dispositivo.
- Fechas API: ISO 8601.
- Coordenadas: WGS84, SRID 4326.
- Distancias: metros, calculados con Haversine en Spring Boot a partir de WGS84.
- Idioma de código: inglés; interfaz y mensajes del MVP: español.
- Estados persistidos: mayúsculas en inglés; etiquetas visibles: español.
- Versionado API: prefijo mayor `/v1`.
