# DogAlert

## Documento de diseño de software (SDD)

Socio formador: Asociación Mexicana de Hoteles y Moteles del Estado de Chihuahua  
Representante de aceptación: Michelle Gutiérrez  
Equipo: Francisco Javier Huerta Trujillo, Jazmín Gabriela Borunda Estrada, Isabella Murillo Salgado, Santiago Derat Hernández y Eliab Sagarnaga  
Versión: 1.1  
Fecha: 5 de septiembre de 2026  
Fecha límite del MVP: 23 de octubre de 2026

## Control del documento

| Versión | Fecha | Descripción | Responsable |
|---|---|---|---|
| 1.0 | 29/08/2026 | Diseño inicial derivado del SRS 1.0 corregido | Equipo DogAlert |
| 1.1 | 05/09/2026 | Alineación con los diagramas y la base de datos definitivos del equipo | Equipo DogAlert |

## Aprobación

La aprobación confirma que este diseño implementa el SRS conocido sin ampliar el alcance del MVP. Las decisiones abiertas se aceptan por separado antes de desarrollar los componentes afectados.

Nombre: Michelle Gutiérrez  
Resultado: [ ] Aprobado [ ] Aprobado con observaciones [ ] Requiere cambios  
Fecha/evidencia: ______________________________________________

## 1. Propósito

Definir una base implementable y verificable para DogAlert: aplicación móvil React Native, API Spring Boot, MySQL, GCP, almacenamiento offline cifrado, moderación, privacidad geográfica, exportación, auditoría y operación.

## 2. Relación con el SRS

El SRS describe el problema y los 47 RF/33 RNF. Este SDD no los reemplaza; traduce cada uno a componentes, contratos, tablas y pruebas. Para decisiones de diseño prevalecen los diagramas Draw.io definitivos; para comportamiento prevalece el SRS aprobado.

## 3. Resumen de la solución

- Una app móvil común para visitantes, usuarios registrados y administradores.
- Reportes anónimos o asociados a cuenta, con fotografía opcional.
- Cola SQLite cifrada y sincronización idempotente.
- API REST versionada, autenticación JWT propia en Spring Boot y módulos de dominio.
- Persistencia geográfica privada en MySQL.
- Publicación exclusiva de verificados con ubicación aproximada.
- Moderación humana con señales de coincidencia, sin decisión automática.
- Métricas y exportaciones con política de privacidad explícita.
- Retención de reportes por al menos cinco años y anonimización de PII tras 12 meses sin login.
- Infraestructura GCP privada, cifrada, observable y recuperable.

## 4. Arquitectura elegida

El cliente móvil se conecta por HTTPS a Cloud Run, donde se ejecuta la API Java/Spring Boot. La API registra cuentas, verifica hashes, emite y valida JWT, aplica reglas y accede a Cloud SQL/MySQL. Las fotografías se conservan en la tabla privada `Fotos`. Cloud Monitoring observa el servicio y los respaldos automáticos de Cloud SQL cubren recuperación. Los módulos públicos usan modelos separados para impedir que coordenadas exactas o PII lleguen a respuestas públicas.

Detalles: [02_arquitectura.md](02_arquitectura.md).

## 5. Datos y privacidad

La coordenada exacta, PII y fotografía son restringidas. La ubicación pública se deriva mediante cuadrícula; el valor inicial propuesto es 500 m y requiere aceptación. Los reportes oficiales dependen de un polígono versionado de Creel. El borrado del autor es físico y la bitácora conserva solo evidencia técnica mínima.

Detalles: [03_modelo_dominio_datos.md](03_modelo_dominio_datos.md) y [09_seguridad_privacidad.md](09_seguridad_privacidad.md).

## 6. Interfaces

La API usa `/v1`, JSON/ISO 8601, JWT, cursores, errores uniformes e idempotencia. El contrato formal está en [openapi.yaml](openapi.yaml). El módulo de identidad de Spring Boot implementa registro, inicio de sesión, hash y emisión de tokens.

## 7. Operación crítica

- Offline: [06_offline_sincronizacion.md](06_offline_sincronizacion.md).
- Moderación y coincidencias: [07_moderacion_duplicados.md](07_moderacion_duplicados.md).
- Mapas, métricas y exportaciones: [08_mapas_metricas_exportaciones.md](08_mapas_metricas_exportaciones.md).
- Despliegue y recuperación: [10_despliegue_operacion.md](10_despliegue_operacion.md).

## 8. Verificación

La matriz de [11_pruebas_trazabilidad.md](11_pruebas_trazabilidad.md) relaciona cada RF y RNF con diseño y prueba. El MVP requiere cero defectos críticos/altos, builds Android/iOS, seguridad y offline verificados, restauración probada y aceptación documentada del socio.

## 9. Decisiones pendientes

Antes de los tickets afectados deben resolverse el tamaño de cuadrícula pública, polígono oficial de Creel, autorización de exportaciones exactas, checklist final de verificación, política posterior a cinco años y dependencias concretas de SQLite/mapas/persistencia.

Registro: [12_decisiones_y_pendientes.md](12_decisiones_y_pendientes.md).

## 10. Anexos

- [Índice completo](README.md).
- [Esquema SQL](schema.sql).
- [Diagramas Draw.io autoritativos](../diagramas_autoritativos/).
- [Diagramas Mermaid derivados](diagrams/README.md).
- [Configuración de Jira](../../JIRA_DogAlert_configuracion.md).
- [Backlog importable](../../Jira_DogAlert_import.csv).
