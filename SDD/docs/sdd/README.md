# SDD de DogAlert

Versión: 1.0  
Fecha: 29 de agosto de 2026  
Estado: base aprobable para implementación  
Fuentes normativas: `DogAlert_SRS (2).txt` y `docs/diagramas_autoritativos/`

## Propósito

Este paquete describe cómo se construirá DogAlert. El SRS determina qué debe hacer el producto; el SDD define la arquitectura, responsabilidades, datos, contratos, controles y pruebas necesarias para implementarlo sin cambiar su alcance.

En caso de conflicto:

1. Los diagramas definitivos fijan el diseño aprobado por el equipo.
2. El SRS vigente fija alcance y comportamiento observable.
3. El SDD, OpenAPI, SQL, Mermaid y Jira deben mantenerse como derivados consistentes.
4. Una decisión nueva que cambie comportamiento observable requiere ticket de cambio y aceptación del socio formador.

## Índice

| Archivo | Contenido |
|---|---|
| [SDD_DogAlert.md](SDD_DogAlert.md) | Portada, control, aprobación y resumen ejecutivo |
| [01_objetivos_y_principios.md](01_objetivos_y_principios.md) | Objetivos, restricciones, actores y principios |
| [02_arquitectura.md](02_arquitectura.md) | Contexto, contenedores, módulos y flujos |
| [03_modelo_dominio_datos.md](03_modelo_dominio_datos.md) | Entidades, invariantes, estados y privacidad de datos |
| [04_api_rest.md](04_api_rest.md) | Convenciones y catálogo de endpoints |
| [05_aplicacion_movil.md](05_aplicacion_movil.md) | Capas, navegación, permisos y UX móvil |
| [06_offline_sincronizacion.md](06_offline_sincronizacion.md) | Cola cifrada, reintentos e idempotencia |
| [07_moderacion_duplicados.md](07_moderacion_duplicados.md) | Verificación, estados, duplicados y corroboración |
| [08_mapas_metricas_exportaciones.md](08_mapas_metricas_exportaciones.md) | Privacidad geográfica, indicadores y exportación |
| [09_seguridad_privacidad.md](09_seguridad_privacidad.md) | Modelo de amenazas y controles |
| [10_despliegue_operacion.md](10_despliegue_operacion.md) | GCP, CI/CD, observabilidad, respaldo y recuperación |
| [11_pruebas_trazabilidad.md](11_pruebas_trazabilidad.md) | Estrategia, matrices RF/RNF y aceptación |
| [12_decisiones_y_pendientes.md](12_decisiones_y_pendientes.md) | Decisiones adoptadas y asuntos por confirmar |
| [openapi.yaml](openapi.yaml) | Contrato OpenAPI 3.1 |
| [schema.sql](schema.sql) | Esquema físico inicial MySQL |
| [diagrams](diagrams/) | Fuentes Mermaid de los diagramas |
| [../diagramas_autoritativos](../diagramas_autoritativos/) | Originales Draw.io definitivos del equipo |
| [../FUENTES_AUTORITATIVAS.md](../FUENTES_AUTORITATIVAS.md) | Precedencia, decisiones e interpretaciones de seguridad |

## Alcance de diseño

El SDD cubre el MVP móvil para Android e iOS, API REST, autenticación, persistencia geográfica, fotografías, operación offline, moderación, mapas públicos aproximados, métricas, exportaciones, auditoría, retención, infraestructura y pruebas.

No diseña seguimiento en tiempo real, atención veterinaria, campañas, adopciones, notificaciones cercanas, portal web ni carga histórica previa al lanzamiento.

## Decisiones base

- Cliente móvil React Native con TypeScript.
- Backend modular Java con Spring Boot.
- MySQL en Cloud SQL, con las tablas principales definidas por el diagrama de base de datos.
- Autenticación propia en Spring Boot con contraseña hasheada y JWT; la aplicación nunca almacena contraseñas en claro.
- Google Cloud Run, Cloud SQL, Cloud Monitoring y respaldos cifrados.
- Fotografías binarias en la tabla `Fotos`; mecanismo temporal de exportaciones por definir.
- Cola offline SQLite cifrada y llave protegida por Keychain/Keystore.
- API versionada bajo `/v1` y mutaciones idempotentes mediante UUID del cliente.
- Coordenada exacta privada; vistas públicas agregadas a una cuadrícula configurable.
- Solo reportes `VERIFIED` alimentan mapas públicos y métricas oficiales.
- Borrado del autor elimina contenido, ubicación y archivos; permanece únicamente un evento técnico sin PII.

## Responsabilidad documental

| Área | Responsable principal | Revisión cruzada |
|---|---|---|
| Arquitectura e integración | Isabella | Jazmín |
| Backend y moderación | Eliab | Santiago |
| Datos, seguridad y privacidad | Jazmín | Eliab |
| Mobile, UX y mapas | Paco | Isabella |
| Pruebas y diagramas | Santiago | Todo el equipo |

## Criterio de terminado del SDD

El diseño está listo para implementar cuando:

- los archivos no contradicen el SRS;
- cada RF y RNF está ligado a un componente y una prueba;
- las decisiones abiertas que bloquean código están resueltas;
- OpenAPI, esquema SQL y diagramas describen el mismo modelo;
- Michelle Gutiérrez aprueba cualquier precisión que afecte comportamiento público o privacidad.
