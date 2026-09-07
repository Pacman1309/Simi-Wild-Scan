# Fuentes autoritativas de diseño de DogAlert

Fecha de adopción: 5 de septiembre de 2026.

## Precedencia

Para implementación y mantenimiento se aplica este orden:

1. Los archivos `.drawio` entregados por el equipo en Google Drive fijan arquitectura, datos y comportamiento de las historias representadas.
2. `DogAlert_SRS (2).txt` fija alcance y requisitos observables.
3. El SDD, OpenAPI, esquema SQL, diagramas Mermaid y Jira deben derivarse de las dos fuentes anteriores.

Los originales se conservan sin modificaciones en `docs/diagramas_autoritativos/`. Los diagramas Mermaid de `docs/sdd/diagrams/` son vistas derivadas y no los sustituyen.

## Arquitectura adoptada

- Aplicación React Native en Android e iOS.
- SQLite local para la cola offline.
- API Java con Spring Boot.
- Autenticación propia del backend con contraseña protegida mediante hash y tokens JWT.
- MySQL administrado mediante Cloud SQL.
- API desplegada en Google Cloud Run.
- Mapas con Leaflet y datos de OpenStreetMap.
- Comunicación HTTPS.

## Modelo de datos adoptado

El archivo `DiagramaBD_DogAlert.drawio` define cuatro tablas principales:

- `Usuarios`.
- `Registros`.
- `Fotos`.
- `Bitacora_Administrativa`.

`Registros.ID_Usuario` es opcional para permitir reportes anónimos. `Fotos` conserva la evidencia binaria y `Bitacora_Administrativa` registra acciones administrativas sobre usuarios y reportes.

## Interpretaciones de seguridad

Los siguientes ajustes son obligatorios para que el diseño sea implementable sin contradecir los requisitos de seguridad:

- `Contraseña varchar(32)` se implementa como `Contrasena_Hash varchar(255)`; nunca se almacena la contraseña original.
- La etiqueta aislada `NestJS` en `HU-01-06-14_A01563881.drawio` se considera un error de rotulación, porque el diagrama de despliegue y el SRS fijan Spring Boot.
- `Registros.Imagen` se interpreta como huella o referencia de la imagen; el contenido se almacena una sola vez en `Fotos.Foto`.
- Los nombres de rutas mostrados en secuencias son ejemplos de interacción. `docs/sdd/openapi.yaml` contiene las rutas canónicas bajo `/v1`.

## Pendientes que no deben asumirse

- Algoritmo de hash concreto: por definir antes de implementar autenticación.
- Estrategia exacta de cifrado de campos sensibles en MySQL: por definir antes de producción.
- Las exportaciones se entregan como archivo/flujo temporal, conforme a HU-12; un mecanismo asíncrono requeriría una decisión posterior.
- Servicio administrado adicional para protección perimetral: por definir; Cloud Run debe exigir HTTPS desde el MVP.

## Inventario de originales

- `Deployment Diagram Dog Alert.drawio`.
- `DiagramaBD_DogAlert.drawio`.
- `HU 1 Y 3- Isabella Murillo-A01564010.drawio`.
- `HU-01-06-14_A01563881.drawio`.
- `HU-2_A01564010.drawio`.
- `HU-4_sequenceDiagram_A01564215.drawio`.
- `HU-5-sequenceDiagram_A01567335.drawio`.
- `HU-7-11-13_A01569168.drawio`.
- `HU-8_sequenceDiagram_A01564215.drawio`.
- `HU-9 Secuence Diagram - Isabella Murillo-A01564010.drawio`.
- `HU-10_sequenceDiagram_A01567335.drawio`.
- `HU-12_sequenceDiagram_A01564215.drawio`.
- `HU-15_A01569168.drawio`.
