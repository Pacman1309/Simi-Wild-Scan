# 12. Registro de decisiones y pendientes

## 12.1 Decisiones adoptadas

| ID | Decisión | Razón | Estado |
|---|---|---|---|
| DEC-001 | Arquitectura móvil + API modular | Compatible con SRS y trabajo en equipo | Adoptada |
| DEC-002 | UUID del cliente e idempotency key única | Evita duplicados por reintento | Adoptada |
| DEC-003 | DTO públicos separados | Reduce exposición accidental | Adoptada |
| DEC-004 | Draw.io como fuente del modelo y SQL como implementación física | Respeta la base definitiva y permite migraciones explícitas en MySQL | Adoptada |
| DEC-005 | Foto privada, no pública en MVP | Minimización y riesgo de reidentificación | Adoptada |
| DEC-006 | Exportación como archivo/flujo temporal | Coincide con HU-12 y evita un almacén adicional no definido | Adoptada |
| DEC-007 | Borrado del autor es físico | RF-026 exige eliminación completa | Adoptada |
| DEC-008 | Estados offline separados de moderación | Son ciclos de vida diferentes | Adoptada |
| DEC-009 | UTC en persistencia, local en interfaz | Consistencia temporal | Adoptada |
| DEC-010 | Panel administrativo dentro de la app | Restricción expresa del SRS | Adoptada |
| DEC-011 | Autenticación propia en Spring Boot con hash y JWT | Fijada por HU-02 y el modelo `Usuarios` | Adoptada |
| DEC-012 | Fotografías en `Fotos.Foto` de MySQL | Fijada por el diagrama de base de datos | Adoptada |

## 12.2 Propuestas que requieren aceptación

| ID | Asunto | Propuesta inicial | Impacto | Responsable/fecha límite |
|---|---|---|---|---|
| OPEN-001 | Precisión pública | Cuadrícula de 500 m; aumentar en baja densidad | Privacidad y utilidad del mapa | Jazmín/Michelle, antes de Sprint 2 |
| OPEN-002 | Límite oficial de Creel | GeoJSON versionado entregado por socio/autoridad | Define estadísticas oficiales | Isabella/Michelle, antes de Sprint 2 |
| OPEN-003 | Exportación exacta | Formato de autorización con finalidad y destinatario | Privacidad y auditoría | Jazmín/Michelle, antes de Sprint 3 |
| OPEN-004 | Evidencia de verificación | Checklist del SDD como mínimo | Consistencia de moderación | Eliab/Michelle, antes de Sprint 3 |
| OPEN-005 | Después de cinco años | Conservar anonimizado hasta nueva política; no borrar automático | Costos y cumplimiento | Michelle, antes de producción |
| OPEN-006 | Dependencia SQLite cifrada | Elegir paquete mantenido tras spike Android/iOS | Riesgo de compilación | Santiago, Sprint 0/1 |
| OPEN-007 | Adaptador de persistencia backend | Evaluar migraciones SQL + adaptador compatible MySQL | Productividad y consultas | Eliab/Jazmín, Sprint 0 |
| OPEN-008 | Proveedor de mosaicos | Seleccionar por costo, cobertura, licencia y privacidad | Mapas y presupuesto | Paco/Isabella, Sprint 0 |
| OPEN-009 | MFA administrativo | Habilitar antes de producción | Seguridad operativa | Isabella/Jazmín, Sprint 3 |
| OPEN-010 | Algoritmo de hash | Seleccionar Argon2id o bcrypt mediante spike | Seguridad de credenciales | Isabella/Eliab, Sprint 1 |
| OPEN-011 | Protección perimetral adicional | Evaluar servicio administrado después de validar HTTPS y rate limits | Seguridad/costo | Isabella/Jazmín, Sprint 3 |

## 12.3 Regla de resolución

Una decisión abierta bloquea únicamente los tickets que dependen de ella. La resolución debe registrar:

- opción seleccionada y alternativas;
- fecha y participantes;
- RF/RNF afectados;
- impacto en OpenAPI, SQL, diagramas y pruebas;
- evidencia de aceptación del socio cuando cambie comportamiento o privacidad.

## 12.4 Control de cambios

1. Crear ticket `CHANGE` en Jira.
2. Identificar requisitos y archivos afectados.
3. Estimar costo, riesgo y calendario.
4. Obtener aceptación cuando corresponda.
5. Actualizar SRS primero si cambia el qué; SDD si cambia el cómo.
6. Actualizar pruebas y trazabilidad antes de cerrar.
