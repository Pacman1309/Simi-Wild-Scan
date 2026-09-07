# 2. Arquitectura

## 2.1 Estilo

DogAlert usa una arquitectura cliente-servidor modular. El móvil separa presentación, aplicación, dominio e infraestructura; el backend se organiza por módulos de negocio con puertos de persistencia e integraciones. Esto permite probar reglas sin depender de GPS, red o MySQL.

## 2.2 Contexto

```text
Personas y administradores
          |
          v
Aplicación React Native -- mosaicos --> Proveedor de mapas
          |
       HTTPS/TLS
          v
       Entrada HTTPS de Cloud Run
          |
   Backend Spring Boot
          |
          v
 Cloud SQL/MySQL
      |
      v
 Cloud Monitoring / respaldos
```

Fuente editable: [architecture_context.mmd](diagrams/architecture_context.mmd).

## 2.3 Contenedores

| Contenedor | Responsabilidad | Datos |
|---|---|---|
| App móvil | Captura, consulta, administración móvil, cola offline y mapas | Formulario temporal, tokens seguros, caché pública |
| API | Autorización, validación, reglas, moderación, consultas, exportación | Sin estado local persistente |
| Módulo de autenticación Spring Boot | Registro, hash de credenciales, autenticación y JWT | Correo, hash e identidad autenticable |
| MySQL | Fuente transaccional | Usuarios, registros, fotos y bitácora administrativa |
| Entrada HTTPS de Cloud Run | TLS y límites perimetrales | Registros técnicos sin contenido sensible |
| Cloud Monitoring | Métricas, logs redactados y alertas | Telemetría técnica |

## 2.4 Módulos del backend

| Módulo | Responsabilidades | Dependencias permitidas |
|---|---|---|
| `identity` | Registrar, verificar hash, emitir/validar JWT, roles y actividad | Usuarios |
| `reports` | Crear, consultar, editar y borrar reportes | identity, media, geography, audit |
| `sync` | Idempotencia y respuestas de reintento | reports |
| `media` | Validar imagen, hash y metadatos | Fotos, audit |
| `moderation` | Estados, motivos, checklist y publicación | reports, matching, audit |
| `matching` | Candidatos por tiempo, distancia y características | reports, MySQL |
| `geography` | Límite de Creel, aproximación y consultas espaciales | MySQL |
| `public-read` | DTO públicos y mapa de calor | geography, reports |
| `analytics` | KPI verificados y cobertura | reports, geography |
| `exports` | CSV, XLSX, PDF, GeoJSON e imagen entregados como flujo temporal | analytics, audit |
| `retention` | Anonimización, borrado y ciclos de vida | identity, reports, media, audit |
| `audit` | Eventos administrativos y técnicos | MySQL |
| `protocols` | Texto de seguridad de solo lectura | MySQL/configuración |

Regla: ningún módulo público consulta tablas sensibles sin pasar por su caso de uso y su DTO público.

## 2.5 Capas del backend

- Controladores: HTTP, autenticación, serialización y códigos de respuesta.
- Aplicación: casos de uso, transacciones y orquestación.
- Dominio: entidades, políticas, estados e invariantes.
- Infraestructura: MySQL, JWT propio, Cloud Monitoring y generación de archivos.

Los controladores no contienen SQL ni deciden estados. Los repositorios no determinan autorización.

## 2.6 Flujos principales

### Reporte online

1. El móvil valida y comprime la foto opcional.
2. Envía `clientReportId` e `Idempotency-Key` iguales.
3. API valida esquema, fecha, rol opcional y límites.
4. API clasifica pertenencia a Creel y persiste en una transacción.
5. La foto se almacena privada y su hash queda asociado.
6. El reporte queda `PENDING` y se audita la creación.
7. Un reintento devuelve el mismo recurso sin insertar otro.

### Reporte offline

1. El formulario se cifra en SQLite con UUID y estado local.
2. Al recuperar red, un trabajador procesa la cola en orden.
3. Los reintentos usan el mismo UUID.
4. El servidor responde creado o existente.
5. La app marca `SYNCED` y elimina la copia sensible local después de confirmación.

### Publicación

1. Administrador consulta detalle exacto bajo RBAC.
2. Registra decisión y motivo.
3. Si `VERIFIED`, el reporte entra a consultas públicas mediante DTO aproximado.
4. Toda transición genera auditoría.

## 2.7 Dependencias y dirección

El dominio no importa SDK de GCP, HTTP, React Native ni MySQL. Las dependencias externas implementan interfaces como `ReportRepository`, `PhotoRepository`, `TokenService`, `MapPrivacyService` y `AuditSink`.

## 2.8 Fallos esperados

| Fallo | Comportamiento |
|---|---|
| Sin Internet | Guardar localmente y explicar estado |
| GPS rechazado | Permitir selección manual |
| API no disponible | Reintento con espera incremental |
| Persistencia de foto no disponible | Revertir la transacción y conservar el envío en la cola para un reintento idempotente |
| Mosaicos no disponibles | Mantener formulario y permitir coordenada/manual cuando sea posible; mensaje claro |
| Módulo de autenticación no disponible | Acceso público y reporte anónimo continúan si la API está disponible; las cuentas no |
| DB no disponible | API responde 503 sin perder cola del dispositivo |

## 2.9 Diagramas relacionados

- [deployment.mmd](diagrams/deployment.mmd)
- [sequence_online_report.mmd](diagrams/sequence_online_report.mmd)
- [sequence_offline_sync.mmd](diagrams/sequence_offline_sync.mmd)
- [activity_report.mmd](diagrams/activity_report.mmd)
- [activity_moderation.mmd](diagrams/activity_moderation.mmd)
