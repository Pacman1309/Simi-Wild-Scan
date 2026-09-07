# 8. Mapas, métricas y exportaciones

## 8.1 Privacidad geográfica

La DB conserva `Registros.Latitud` y `Registros.Longitud` para operaciones autorizadas. La API pública transforma el punto a una celda cuadrada configurable de 500 m y devuelve el centro de la celda. No devuelve precisión GPS, EXIF, dirección ni distancia al punto real.

Para zonas sensibles o baja densidad se puede aumentar el tamaño de celda. Reducirlo requiere revisión de privacidad y aprobación documentada.

## 8.2 Mapa público

Fuente: solo `VERIFICADO`. Campos permitidos:

- ID público no correlacionable con claves de administración;
- fecha con precisión aprobada;
- tipo, gravedad, cantidad y características no identificadoras;
- ubicación aproximada;
- indicador externo a Creel;
- advertencia de cobertura.

No se publica foto en el MVP salvo decisión posterior explícita, porque puede revelar personas, placas, propiedades o coordenadas.

## 8.3 Mapa de calor

La consulta agrega reportes verificados por celda, rango de fecha, tipo y gravedad. El resultado incluye celda, conteo y periodo, nunca puntos exactos.

Para cumplir ≤ 2 s:

- índices MySQL sobre estado/fecha y ubicación/fecha;
- límites obligatorios de fecha y bbox razonable;
- caché breve por filtros;
- vista/materialización si las pruebas con cinco años lo requieren.

## 8.4 Límite de Creel

El polígono oficial se carga como configuración versionada. Al crear o editar un reporte, Spring Boot evalúa el punto y guarda `Fuera_Creel`.

Hasta recibir la geometría aprobada, el entorno productivo no debe afirmar estadísticas oficiales definitivas. Este punto figura como pendiente bloqueante.

## 8.5 Métricas

Todas usan reportes `VERIFICADO` y, para cifras oficiales, `Fuera_Creel = false`:

- número de reportes/avistamientos;
- suma de perros observados, etiquetada como observaciones y no como perros únicos;
- eventos por tipo y gravedad;
- tendencia por periodo;
- celdas de concentración;
- cobertura: reportantes, periodos/celdas con actividad y proporción de externos.

Una estimación de perros únicos, si se agrega, debe tener método, intervalo/limitación y etiqueta `APROXIMADA`; no puede ser una suma directa.

## 8.6 Exportaciones

| Formato | Uso | Implementación |
|---|---|---|
| CSV | Datos tabulares interoperables | UTF-8, encabezados y diccionario |
| XLSX | Análisis del socio | Hojas Datos, Resumen y Metodología |
| PDF | Informe presentable | Portada, filtros, KPI, advertencias y fecha |
| GeoJSON | Análisis geográfico | FeatureCollection con política exacta/aproximada |
| PNG | Imagen del mapa actual | Captura con leyenda, filtros y atribución |

## 8.7 Política de exportación

- `PUBLIC_APPROXIMATE`: sin PII, ubicaciones aproximadas; valor por defecto y entregables al gobierno.
- `ADMIN_EXACT`: exactos solo con rol, finalidad, motivo y autorización formal cuando sale del sistema.

Cada solicitud registra en `Bitacora_Administrativa` al solicitante, filtros, formato, política, motivo, conteo y resultado. El archivo se devuelve como flujo temporal y no se conserva como histórico.

## 8.8 Consistencia

Panel y exportación llaman al mismo servicio de filtros y métricas. La exportación fija una marca temporal para que cifras y filas correspondan al mismo corte.

## 8.9 Advertencias obligatorias

- Ausencia de reportes no significa ausencia de perros o riesgo.
- Los datos reflejan participación comunitaria y moderación.
- Cantidad observada no equivale a individuos únicos.
- Reportes externos no integran las estadísticas oficiales de Creel.
