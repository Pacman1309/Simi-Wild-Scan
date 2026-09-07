# Configuración actual de Jira para DogAlert

Esta guía documenta la configuración publicada en el proyecto `SCRUM` de Jira. Las fuentes funcionales y técnicas son `DogAlert_SRS (2).txt` y los diagramas de `docs/diagramas_autoritativos/`.

## 1. Fechas oficiales

| Etapa | Inicio | Entregable / cierre |
|---|---:|---:|
| Requerimientos | 10/08/2026 | 25/08/2026 |
| Diseño | 26/08/2026 | 05/09/2026 |
| Desarrollo I | 06/09/2026 | 18/09/2026 |
| Desarrollo II | 19/09/2026 | 02/10/2026 |
| Pruebas | 03/10/2026 | 09/10/2026 |
| Estabilización y despliegue | 10/10/2026 | 23/10/2026 |

Las fechas representan límites de entregables. Ninguna actividad hija puede vencer después del cierre de su etapa.

## 2. Estructura publicada

El backlog tiene exactamente 60 elementos:

- 9 épicas de producto.
- 35 historias de usuario en Jira.
- 14 tareas técnicas, documentales, de calidad y despliegue.
- 2 tareas de ceremonias Scrum.

Las historias usan identificadores de backlog `STORY-01` a `STORY-35`. Estos identificadores no sustituyen ni amplían la numeración de historias de usuario del SRS; la trazabilidad real se conserva en los criterios, requisitos y diagramas aplicables.

## 3. Épicas

| Jira | Épica | Periodo |
|---|---|---|
| SCRUM-98 | Planeación, SRS y arquitectura | 10/08–05/09 |
| SCRUM-99 | Navegación, cuentas y roles | 06/09–02/10 |
| SCRUM-100 | Registro online y validaciones | 06/09–02/10 |
| SCRUM-101 | Cola offline y sincronización | 06/09–02/10 |
| SCRUM-102 | Mapas y privacidad geográfica | 06/09–02/10 |
| SCRUM-103 | Moderación, estados y coincidencias | 06/09–02/10 |
| SCRUM-104 | Pruebas, estabilización y despliegue | 03/10–23/10 |
| SCRUM-105 | Panel, métricas y exportaciones | 06/09–02/10 |
| SCRUM-106 | Seguridad, privacidad y retención | 06/09–02/10 |

## 4. Ceremonias Scrum

| Jira | Ceremonia | Fecha | Evidencia esperada |
|---|---|---|---|
| SCRUM-157 | Sprint Planning de desarrollo | 06/09/2026 | Objetivo, capacidad, selección del backlog, responsables y acuerdos |
| SCRUM-156 | Daily Stand-up con evidencia | 07/09–02/10/2026 | Dos registros formales como mínimo con avances, plan y bloqueos de cada integrante |

`SCRUM-157` está en curso desde el 6 de septiembre. La actividad de Daily Stand-up cubre todo el desarrollo y exige al menos dos evidencias fechadas, como pidió el profesor.

## 5. Distribución por etapa

- Requerimientos: aprobación del SRS; backlog, riesgos y trazabilidad. Estado: `Finalizada`.
- Diseño: arquitectura GCP, Spring Boot, JWT propio, MySQL y validación de diagramas. Estado: `Finalizada`.
- Desarrollo I: cuentas, roles, captura online, cola offline y sincronización.
- Desarrollo II: privacidad geográfica, mapas, moderación, métricas, exportaciones y seguridad.
- Pruebas: pruebas unitarias, integración, E2E, seguridad, carga, rendimiento y usabilidad.
- Despliegue: integración de entregables, aceptación de la socia formadora y liberación del MVP.

## 6. Tecnología vigente

- Aplicación móvil React Native para Android e iOS.
- Backend Spring Boot.
- Autenticación con JWT propio.
- Base de datos MySQL.
- Infraestructura en Google Cloud Platform.

No se debe agregar PostgreSQL ni AWS salvo una decisión posterior formalmente aprobada y reflejada primero en el SRS y los diagramas autoritativos.

## 7. Estados y flujo

Flujo configurado: `Tareas por hacer` → `En curso` → `En revisión` → `Finalizada`.

Al 06/09/2026 están finalizados la épica de planeación y sus cuatro trabajos de Requerimientos/Diseño. El Sprint Planning está en curso; el trabajo de desarrollo permanece preparado en `Tareas por hacer` hasta que el equipo confirme su selección durante la ceremonia.

## 8. Responsabilidades

- Isabella: Scrum Master, arquitectura, cuentas/roles, moderación y aceptación.
- Eliab: backend, requisitos, reportes, sincronización y duplicados.
- Jazmín: datos, seguridad, privacidad, métricas y calidad.
- Santiago: integración, offline, pruebas, diagramas y documentación.
- Paco: UX/UI, aplicación móvil, formularios y mapas.
- Michelle Gutiérrez: revisión y aceptación como socia formadora, sin tareas de desarrollo.

## 9. Definition of Done

Una actividad puede cerrarse cuando el código o documento está integrado y revisado, sus criterios de aceptación tienen evidencia, las pruebas aplicables pasan, la trazabilidad está actualizada y no quedan defectos críticos o altos relacionados.

## 10. Consultas JQL de control

```text
project = SCRUM ORDER BY key ASC
```

```text
project = SCRUM AND issuetype = Epic
```

```text
project = SCRUM AND issuetype = Historia
```

```text
project = SCRUM AND labels = scrum-ceremony ORDER BY duedate ASC
```

```text
project = SCRUM AND labels = development AND duedate > "2026-10-02"
```

La última consulta debe devolver cero resultados.
