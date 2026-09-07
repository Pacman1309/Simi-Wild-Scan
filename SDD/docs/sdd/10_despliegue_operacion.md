# 10. Despliegue y operación

## 10.1 Entornos

| Entorno | Uso | Datos |
|---|---|---|
| Local | Desarrollo y pruebas unitarias | Sintéticos |
| Dev | Integración continua del equipo | Sintéticos |
| Staging | E2E, carga, seguridad y UAT previa | Sintéticos o anonimizados aprobados |
| Producción | MVP aceptado | Reales |

No se copian datos productivos a entornos inferiores.

## 10.2 Topología GCP

- Endpoint HTTPS administrado de Cloud Run; protección perimetral adicional por definir.
- Cloud Run ejecuta el contenedor Java/Spring Boot.
- Cloud SQL MySQL sin IP pública y grupos de seguridad restrictivos.
- Tabla `Fotos` privada dentro de Cloud SQL MySQL.
- Autenticación propia con `PasswordHasher`, `TokenService` y JWT.
- Cloud Monitoring para métricas, logs redactados y alarmas.
- respaldos automáticos de Cloud SQL/Cloud SQL snapshots cifrados.

Fuente: [deployment.mmd](diagrams/deployment.mmd).

## 10.3 Configuración

Variables no secretas: región, tamaño de celda pública, fecha de lanzamiento, versión de límite Creel y límites operativos.

Secretos: credenciales de DB, claves de cifrado de aplicación y valores de proveedores. Se inyectan desde un almacén administrado y se rotan; no aparecen en `.env` versionado.

## 10.4 CI/CD

### Pull request

1. Formato y lint.
2. Tipos/compilación.
3. Pruebas unitarias.
4. Pruebas de contrato/schema.
5. Análisis de dependencias y secretos.
6. Build móvil/backend.
7. Revisión de otro integrante.

### Despliegue

- `main` produce artefactos inmutables identificados por commit.
- Dev automático; staging y producción con aprobación.
- Migraciones se ejecutan antes del tráfico solo si son compatibles hacia atrás.
- Producción conserva versión anterior para rollback.

## 10.5 Migraciones

Patrón expandir/migrar/contraer:

1. agregar cambios compatibles;
2. desplegar código que lee ambas formas;
3. migrar datos;
4. comprobar;
5. retirar lo antiguo en una versión posterior.

Nunca se ejecuta una migración destructiva sin respaldo verificado y plan de reversión.

## 10.6 Observabilidad

| Señal | Meta/alerta |
|---|---|
| Disponibilidad | objetivo 99.5 % mensual |
| API p95 | alerta antes de superar 5 s |
| Errores 5xx | tasa y pico anormal |
| Sincronización | error < 1 %; duplicados por reintento = 0 |
| Heatmap | p95 menor a 2 s |
| Cola de exportación | trabajos fallidos o vencidos |
| Retención | ejecución diaria y conteo de fallos |
| Seguridad | 401/403/429 anormales y controles de entrada HTTPS |

Las alertas deben incluir request ID y componente, no contenido sensible.

## 10.7 Respaldo y recuperación

- Respaldo cifrado diario con retención mínima de 30 días.
- Las fotografías se incluyen en el respaldo cifrado de Cloud SQL.
- RPO: 24 horas.
- RTO: 8 horas.
- Prueba de restauración antes de aceptación y evidencia del tiempo real.

Procedimiento: declarar incidente, detener escrituras si es necesario, restaurar a entorno aislado, verificar integridad/conteos, reanudar, reconciliar colas idempotentes y documentar.

## 10.8 Capacidad

La API inicia sin estado y escala horizontalmente. En el MVP, la exportación se genera como flujo de respuesta; si las pruebas exceden el tiempo permitido se deberá aprobar un mecanismo asíncrono antes de implementarlo. MySQL usa índices y consultas acotadas. La prueba mínima simula 100 solicitudes concurrentes y cinco años del volumen estimado.

## 10.9 Lanzamiento

Antes de producción:

- polígono Creel y tamaño de aproximación aprobados;
- administradores designados y MFA configurado;
- aviso de privacidad y protocolos publicados;
- respaldo/restauración probado;
- Android e iOS validados;
- cero defectos críticos/altos;
- aceptación de Michelle Gutiérrez documentada.
