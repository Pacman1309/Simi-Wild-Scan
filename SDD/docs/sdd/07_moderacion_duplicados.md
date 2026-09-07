# 7. Moderación, duplicados y corroboración

## 7.1 Objetivo

Publicar únicamente reportes suficientemente coherentes y seguros sin presentar una decisión automática como verdad. La moderación evalúa evidencia disponible; no diagnostica al animal ni determina intervención.

## 7.2 Bandeja

La lista administrativa muestra fecha, hora, ubicación, tipo, gravedad, cantidad, características, estado, foto disponible y señales de coincidencia. Filtros: fechas, tipo, gravedad, estado y pertenencia a Creel.

La coordenada exacta y contacto consentido aparecen solo en detalle y generan auditoría de acceso cuando la política lo requiera.

## 7.3 Checklist de verificación

El administrador registra:

- campos completos;
- coherencia interna entre tipo, gravedad, descripción y cantidad;
- ausencia de contenido explícito o impropio;
- fecha y ubicación plausibles;
- foto/metadatos revisados si existen;
- posibles duplicados revisados;
- resultado y motivo.

La fotografía no es obligatoria. Metadatos y número de reportes son señales, nunca prueba absoluta.

## 7.4 Coincidencia por evento

Se genera candidato cuando:

1. diferencia absoluta de `Registros.Fecha` ≤ 600 segundos;
2. distancia Haversine entre `Latitud`/`Longitud` ≤ 100 m;
3. tamaño, color y collar son compatibles.

Compatibilidad:

- un valor `UNDETERMINED` no contradice;
- tamaño conocido distinto contradice;
- collar conocido distinto contradice;
- color se normaliza; coincide si hay término común o uno es indeterminado.

El candidato incluye distancia, diferencia temporal y señales coincidentes. No cambia estado.

## 7.5 Señales fuertes de duplicación

- mismo `ID_Reporte_Cliente` o `Clave_Idempotencia`: reintento técnico, no crea segundo reporte;
- mismo `Fotos.SHA256`: candidato fuerte;
- contenido normalizado prácticamente idéntico: candidato fuerte;
- mismo autor, tiempo y payload canónico: candidato fuerte.

Aunque una señal sea fuerte, la relación semántica queda visible y revisable. El hash de una foto puede repetirse legítimamente si dos personas comparten una imagen, por lo que se documenta la decisión.

## 7.6 Relaciones

- `DUPLICADO_DE`: el reporte hijo no aporta una observación independiente. Debe apuntar al registro canónico y su estado pasa a `DUPLICADO`.
- `CORROBORA`: observación independiente compatible. Ambos reportes conservan su identidad y pueden verificarse por separado.

Una pareja no puede ser simultáneamente duplicada y corroborante. Cambiar la relación exige motivo y auditoría.

## 7.7 Estados y publicación

| Estado | Público | Estadísticas | Acción típica |
|---|:---:|:---:|---|
| PENDIENTE | No | No | Revisar |
| VERIFICADO | Sí, aproximado | Sí si pertenece a Creel | Mantener/publicar |
| RECHAZADO | No | No | Conservar motivo |
| DUPLICADO | No | No | Relacionar con canónico |
| ARCHIVADO | No | No | Retirar sin afirmar falsedad |

## 7.8 Edición y eliminación

- Editar un reporte propio invalida la verificación previa y lo devuelve a `PENDIENTE`.
- Se conserva historial de decisiones, no una copia pública anterior.
- Eliminar por el autor borra contenido, foto, ubicación y vínculos personales. Relaciones quedan eliminadas o reajustadas en transacción.
- La bitácora solo registra que ocurrió un borrado, cuándo y por qué tipo de actor, sin valores eliminados.

## 7.9 Pruebas

- Límites exactos: 100 m/101 m y 600 s/601 s.
- Características desconocidas frente a conocidas.
- Foto igual y descripción distinta.
- Observaciones independientes convertidas en corroboración.
- Edición de verificado a pendiente.
- Transición sin motivo rechazada.
- Usuario no administrador recibe `403`.
