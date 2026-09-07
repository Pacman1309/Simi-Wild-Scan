# 3. Modelo de dominio y datos

## 3.1 Fuente y alcance

El archivo `DiagramaBD_DogAlert.drawio` es la fuente absoluta del modelo. Por ello el diseño físico mantiene exactamente sus cuatro entidades principales: `Usuarios`, `Registros`, `Fotos` y `Bitacora_Administrativa`.

El SQL conserva los nombres y relaciones del diagrama. Solo normaliza el error tipográfico `ID_Ususario`, amplía el campo de contraseña para un hash seguro y agrega columnas necesarias para comportamientos que los diagramas de secuencia y el SRS ya exigen. No se agregan tablas paralelas.

Fuente física: [schema.sql](schema.sql). Diagrama derivado: [domain_er.mmd](diagrams/domain_er.mmd).

## 3.2 Entidades autoritativas

| Entidad | Propósito | Relaciones |
|---|---|---|
| `Usuarios` | Cuenta, hash de contraseña, rol, mayoría de edad, consentimiento y actividad | Un usuario puede originar muchos registros y acciones administrativas |
| `Registros` | Evento, ubicación exacta privada, características, estado, sincronización y posible relación | Autor opcional; una foto opcional; autorrelación para duplicado/corroboración |
| `Fotos` | Contenido binario, tipo, tamaño, huella y señal de coherencia de metadatos | Pertenece a un registro |
| `Bitacora_Administrativa` | Actor, acción, registro afectado, resultado, fecha y detalles redactados | Administrador y registro opcionales |

## 3.3 Correcciones técnicas mínimas

- `ID_Ususario` se implementa como `ID_Usuario` para que las llaves foráneas sean coherentes.
- `Contraseña varchar(32)` se implementa como `Contrasena_Hash varchar(255)`. Nunca se guarda la contraseña en texto plano.
- `Registros.Imagen` se interpreta como huella SHA-256 o referencia binaria. El archivo vive una sola vez en `Fotos.Foto` como `LONGBLOB`.
- Se agrega `Fotos.ID_Registro`, relación necesaria para saber a qué reporte pertenece la foto.
- El rol booleano se expresa como `USUARIO` o `ADMIN`; evita significados implícitos de cero y uno.
- La ubicación continúa como `Latitud` y `Longitud` `DOUBLE`, tal como se dibujó; las distancias se calculan con Haversine en Spring Boot.

## 3.4 Extensiones requeridas por los diagramas de secuencia

Las extensiones no alteran las cuatro entidades:

| Tabla | Campos añadidos | Requisito soportado |
|---|---|---|
| `Usuarios` | consentimiento, teléfono, último login, última actividad, anonimización | HU-02, HU-10, HU-13 |
| `Registros` | gravedad, UUID del cliente, idempotencia, fuente/precisión de ubicación, límite de Creel | HU-01, HU-03, HU-04, HU-11, HU-14 |
| `Registros` | reporte relacionado, tipo de relación y motivo | HU-08, HU-09 |
| `Fotos` | MIME, tamaño, SHA-256 y coherencia de metadatos | HU-03, HU-08, HU-09 |
| `Bitacora_Administrativa` | fecha y resultado | HU-08, HU-12, HU-15 |

## 3.5 Catálogos

- Gravedad y certeza: `BAJO`, `MEDIO`, `ALTO`.
- Tamaño: valor del catálogo de interfaz; admite `NO_DETERMINADO`.
- Collar: `TRUE`, `FALSE` o `NULL` cuando no se determinó.
- Estado de moderación: `PENDIENTE`, `VERIFICADO`, `RECHAZADO`, `DUPLICADO`, `ARCHIVADO`.
- Estado de sincronización: `PENDIENTE_LOCAL`, `SINCRONIZANDO`, `SINCRONIZADO`, `ERROR`.
- Relación: `DUPLICADO_DE` o `CORROBORA`.

El estado offline y el estado de moderación son ciclos distintos. En SQLite se conserva el estado de sincronización; al llegar al servidor el reporte inicia `PENDIENTE`.

## 3.6 Invariantes

- `ID_Usuario` es nulo para reportes anónimos.
- `ID_Reporte_Cliente` y `Clave_Idempotencia` son UUID únicos.
- Fecha, ubicación, tipo, gravedad, certeza, cantidad, tamaño, color, collar y descripción se validan antes de persistir.
- La fecha no puede preceder el lanzamiento ni superar el momento actual.
- La foto es opcional; si existe, no supera 1 MB y su MIME se valida por contenido.
- Editar un reporte propio lo devuelve a `PENDIENTE`.
- Borrar un reporte propio elimina en cascada su foto; la bitácora restante no conserva PII, descripción ni coordenadas.
- Solo `VERIFICADO` alimenta mapas, estadísticas y exportaciones públicas.

## 3.7 Coincidencias y relaciones

Spring Boot busca candidatos dentro de 10 minutos y 100 metros mediante Haversine, y después compara tamaño, color y collar. Una huella fotográfica idéntica es señal adicional. La decisión final siempre es administrativa: duplicado, corroboración u observación independiente.

Como el modelo absoluto no define una tabla de candidatos, las coincidencias se calculan bajo demanda. La relación confirmada se guarda en el propio `Registros` mediante `ID_Registro_Relacionado` y `Tipo_Relacion`.

## 3.8 Privacidad, retención y geografía

- Las coordenadas exactas se usan solo en operaciones privadas autorizadas.
- La API pública calcula una ubicación aproximada y nunca serializa `Latitud` ni `Longitud` exactas.
- El mapa de calor agrupa únicamente verificados en áreas de 150 m, conforme a HU-11.
- Los reportes fuera de Creel se muestran, pero no cuentan en estadísticas oficiales.
- Tras 12 meses sin actividad se anonimizan los datos personales de la cuenta y se desvinculan sus reportes.
- Los reportes se conservan por al menos cinco años desde la creación de la aplicación, salvo el borrado solicitado por su autor conforme al SRS.

## 3.9 Concurrencia e índices

MySQL aplica restricciones únicas a correo, UUID del cliente e idempotencia. Los índices de estado/fecha, usuario/fecha, ubicación/fecha, características y SHA-256 soportan moderación, consultas y detección de coincidencias. Las actualizaciones críticas se ejecutan dentro de transacciones y la API responde `409` ante conflictos verificables.
