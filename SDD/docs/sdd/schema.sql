-- DogAlert: diseño físico MySQL 8.0
-- Fuente principal: DiagramaBD_DogAlert.drawio.
-- Las cuatro tablas del diagrama son el modelo absoluto del equipo.
-- Las columnas marcadas como "extensión" soportan requisitos ya aprobados en el SRS
-- y en los diagramas de secuencia, sin introducir entidades adicionales.

CREATE DATABASE IF NOT EXISTS dogalert
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE dogalert;

CREATE TABLE Usuarios (
  ID_Usuario INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  Nombre VARCHAR(150) NULL,
  Correo VARCHAR(254) NOT NULL,
  -- Corrección de seguridad del varchar(32) dibujado: aquí solo se guarda el hash.
  Contrasena_Hash VARCHAR(255) NOT NULL,
  Rol ENUM('USUARIO', 'ADMIN') NOT NULL DEFAULT 'USUARIO',
  Mayor_Edad BOOLEAN NOT NULL,

  -- Extensiones requeridas por HU-02, HU-10 y HU-13.
  Telefono VARCHAR(25) NULL,
  Contacto_Autorizado BOOLEAN NOT NULL DEFAULT FALSE,
  Aviso_Privacidad_Aceptado BOOLEAN NOT NULL DEFAULT FALSE,
  Ultimo_Login TIMESTAMP NULL,
  Ultima_Actividad TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  Datos_Anonimizados BOOLEAN NOT NULL DEFAULT FALSE,
  Estado_Cuenta ENUM('ACTIVA', 'ANONIMIZADA', 'BLOQUEADA') NOT NULL DEFAULT 'ACTIVA',
  Fecha_Creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  Fecha_Actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT UQ_Usuarios_Correo UNIQUE (Correo),
  CONSTRAINT CK_Usuarios_Contacto CHECK (
    Telefono IS NULL OR Contacto_Autorizado = TRUE
  )
) ENGINE=InnoDB;

CREATE TABLE Registros (
  ID_Registro INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  Fecha TIMESTAMP NOT NULL,
  Latitud DOUBLE NOT NULL,
  Longitud DOUBLE NOT NULL,
  -- NULL representa un reporte anónimo.
  ID_Usuario INT UNSIGNED NULL,
  TipoIncidente VARCHAR(60) NOT NULL,
  -- Huella SHA-256 o referencia binaria; el contenido vive en Fotos.Foto.
  Imagen BINARY(32) NULL,
  Descripcion TEXT NOT NULL,
  Cantidad INT UNSIGNED NOT NULL,
  Tamano VARCHAR(30) NOT NULL,
  Color VARCHAR(60) NOT NULL,
  Presencia_Collar BOOLEAN NULL,
  Certeza ENUM('BAJO', 'MEDIO', 'ALTO') NOT NULL,
  Report_Status ENUM(
    'PENDIENTE', 'VERIFICADO', 'RECHAZADO', 'DUPLICADO', 'ARCHIVADO'
  ) NOT NULL DEFAULT 'PENDIENTE',
  Telefono VARCHAR(25) NULL,
  Sync_Status ENUM('PENDIENTE_LOCAL', 'SINCRONIZANDO', 'SINCRONIZADO', 'ERROR')
    NOT NULL DEFAULT 'SINCRONIZADO',

  -- Extensiones requeridas por HU-01, HU-03, HU-04, HU-09 y HU-11.
  Gravedad ENUM('BAJO', 'MEDIO', 'ALTO') NOT NULL,
  ID_Reporte_Cliente CHAR(36) NOT NULL,
  Clave_Idempotencia CHAR(36) NOT NULL,
  Fuente_Ubicacion ENUM('GPS', 'MANUAL', 'METADATOS_FOTO') NOT NULL,
  Precision_Ubicacion_M DECIMAL(8,2) NULL,
  Fuera_Creel BOOLEAN NOT NULL DEFAULT FALSE,
  ID_Registro_Relacionado INT UNSIGNED NULL,
  Tipo_Relacion ENUM('DUPLICADO_DE', 'CORROBORA') NULL,
  Motivo_Moderacion VARCHAR(500) NULL,
  Fecha_Creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  Fecha_Actualizacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT FK_Registros_Usuarios FOREIGN KEY (ID_Usuario)
    REFERENCES Usuarios(ID_Usuario) ON DELETE SET NULL,
  CONSTRAINT FK_Registros_Relacion FOREIGN KEY (ID_Registro_Relacionado)
    REFERENCES Registros(ID_Registro) ON DELETE SET NULL,
  CONSTRAINT UQ_Registros_Cliente UNIQUE (ID_Reporte_Cliente),
  CONSTRAINT UQ_Registros_Idempotencia UNIQUE (Clave_Idempotencia),
  CONSTRAINT CK_Registros_Cantidad CHECK (Cantidad BETWEEN 1 AND 999),
  CONSTRAINT CK_Registros_Latitud CHECK (Latitud BETWEEN -90 AND 90),
  CONSTRAINT CK_Registros_Longitud CHECK (Longitud BETWEEN -180 AND 180),
  CONSTRAINT CK_Registros_Relacion CHECK (
    (ID_Registro_Relacionado IS NULL AND Tipo_Relacion IS NULL)
    OR (ID_Registro_Relacionado IS NOT NULL AND Tipo_Relacion IS NOT NULL)
  )
) ENGINE=InnoDB;

CREATE TABLE Fotos (
  ID_Fotos INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  ID_Registro INT UNSIGNED NOT NULL,
  Foto LONGBLOB NOT NULL,
  Tipo_MIME VARCHAR(50) NOT NULL,
  Tamano_Bytes INT UNSIGNED NOT NULL,
  SHA256 BINARY(32) NOT NULL,
  Metadatos_Coherentes BOOLEAN NULL,
  Fecha_Creacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT FK_Fotos_Registros FOREIGN KEY (ID_Registro)
    REFERENCES Registros(ID_Registro) ON DELETE CASCADE,
  CONSTRAINT UQ_Fotos_Registro UNIQUE (ID_Registro),
  CONSTRAINT CK_Fotos_Tamano CHECK (Tamano_Bytes BETWEEN 1 AND 1048576),
  CONSTRAINT CK_Fotos_MIME CHECK (
    Tipo_MIME IN ('image/jpeg', 'image/png', 'image/heic')
  )
) ENGINE=InnoDB;

CREATE TABLE Bitacora_Administrativa (
  ID_Bitacora INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  ID_Usuario INT UNSIGNED NULL,
  Tipo_Accion VARCHAR(80) NOT NULL,
  ID_Registro INT UNSIGNED NULL,
  Detalles TEXT NULL,
  Resultado ENUM('EXITOSO', 'DENEGADO', 'ERROR') NOT NULL DEFAULT 'EXITOSO',
  Fecha_Accion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT FK_Bitacora_Usuarios FOREIGN KEY (ID_Usuario)
    REFERENCES Usuarios(ID_Usuario) ON DELETE SET NULL,
  CONSTRAINT FK_Bitacora_Registros FOREIGN KEY (ID_Registro)
    REFERENCES Registros(ID_Registro) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE INDEX IX_Registros_Estado_Fecha
  ON Registros (Report_Status, Fecha);
CREATE INDEX IX_Registros_Usuario_Fecha
  ON Registros (ID_Usuario, Fecha);
CREATE INDEX IX_Registros_Ubicacion_Fecha
  ON Registros (Latitud, Longitud, Fecha);
CREATE INDEX IX_Registros_Coincidencia
  ON Registros (Fecha, Tamano, Color, Presencia_Collar);
CREATE INDEX IX_Fotos_SHA256 ON Fotos (SHA256);
CREATE INDEX IX_Bitacora_Fecha_Accion
  ON Bitacora_Administrativa (Fecha_Accion, Tipo_Accion);
CREATE INDEX IX_Usuarios_Retencion
  ON Usuarios (Datos_Anonimizados, Ultima_Actividad);

-- Reglas que permanecen en Spring Boot:
-- 1. Solo VERIFICADO alimenta estadísticas y mapas públicos.
-- 2. Nunca se exponen Latitud/Longitud exactas en respuestas públicas.
-- 3. Candidatos a duplicado: <= 10 minutos, <= 100 m y características compatibles.
-- 4. El mapa de calor agrupa reportes verificados en áreas de 150 m.
-- 5. Los datos personales de cuentas inactivas por 12 meses se anonimizan;
--    los reportes se conservan por al menos 5 años.
-- 6. Las contraseñas se verifican con PasswordHasher y nunca se registra texto plano.
