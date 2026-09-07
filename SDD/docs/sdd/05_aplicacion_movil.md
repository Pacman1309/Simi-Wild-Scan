# 5. Aplicación móvil

## 5.1 Módulos

```text
src/
  app/              composición, navegación y sesión
  features/
    auth/
    reporting/
    offline/
    public-map/
    my-reports/
    moderation/
    analytics/
    exports/
    protocols/
  domain/           entidades y políticas puras
  infrastructure/   API, SQLite, GPS, cámara, storage seguro, mapas
  shared/           UI, validación, errores, i18n y telemetría
```

Cada `feature` contiene presentación, casos de uso y adaptadores mínimos; no accede directamente al almacenamiento de otra función.

## 5.2 Navegación

### Pública

- Inicio.
- Mapa público.
- Mapa de calor/filtros.
- Protocolos.
- Aviso previo y nuevo reporte.
- Registro/inicio de sesión.

### Registrada

- Todo lo público.
- Mis reportes.
- Perfil y consentimiento.
- Estado de sincronización.

### Administrativa

- Bandeja y detalle de moderación.
- Coincidencias y relaciones.
- Panel/métricas.
- Exportaciones.
- Auditoría.

Las rutas administrativas se agregan solo después de validar rol, pero la API siempre vuelve a autorizar.

## 5.3 Flujo de reporte

1. Pregunta: ¿había una persona responsable visible?
2. Aviso: no acercarse, perseguir, alimentar ni capturar; foto opcional.
3. Tipo, gravedad y certeza.
4. Fecha/hora, cantidad y características.
5. GPS o punto manual.
6. Descripción y foto opcional.
7. Resumen y confirmación.
8. Envío o guardado local.

El formulario persiste borrador al cambiar de paso. Los errores se muestran junto al campo y en un resumen accesible.

## 5.4 Permisos

| Permiso | Momento | Si se rechaza |
|---|---|---|
| Ubicación | Al elegir ubicación GPS | Selector manual de mapa |
| Cámara | Al pulsar tomar foto | Galería o continuar sin foto |
| Fotos | Al pulsar elegir de galería | Cámara o continuar sin foto |

No se solicitan permisos durante el arranque. No se solicita ubicación en segundo plano ni notificaciones en el MVP.

## 5.5 Estado y caché

- Estado efímero: navegación, filtros y campos activos.
- Estado durable cifrado: borradores/cola y metadatos de sincronización.
- Tokens: almacenamiento seguro del sistema operativo, nunca SQLite o logs.
- Caché pública: puede persistirse sin coordenadas exactas ni PII y caduca de forma configurable.

## 5.6 Accesibilidad y contenido

- Contraste y objetivos táctiles compatibles con WCAG AA aplicable.
- Etiquetas accesibles para iconos y campos.
- No depender solo de color para estado o gravedad.
- Mensajes en español claro y accionable.
- Lectura de pantalla y orden de foco probados en ambos sistemas.
- Aviso constante de que ausencia de reportes no implica seguridad.

## 5.7 Validación cliente

La app valida para ayudar, no para establecer confianza. La API repite todas las validaciones. Reglas compartidas se expresan en esquemas TypeScript sin compartir código que acople cliente y servidor.

## 5.8 Telemetría móvil

Se permiten únicamente métricas técnicas redactadas: versión, plataforma, duración, código de error y estado de sincronización. Se prohíbe registrar descripción, foto, teléfono, correo, token o coordenada.

## 5.9 Pruebas móviles

- Unitarias de validadores y estado.
- Componentes de formulario y mensajes.
- Integración con permisos simulados.
- Cierre/reapertura con cola.
- E2E en Android e iOS para anónimo, registrado y administrador.
- Prueba con cinco participantes representativos.
