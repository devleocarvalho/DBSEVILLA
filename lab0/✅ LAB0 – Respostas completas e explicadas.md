# ✅ LAB 0: Respuestas Completas, Modelado y Reglas de Negocio

Este documento consolida el análisis de requisitos del **Sistema de Gestión Académica Universitaria (IISSI-1 - Universidad de Sevilla)**, estructurado para fundamentar la implementación relacional en **MariaDB**.

---

## 🏛️ 1. Entidades del Sistema

A partir de los Requisitos de Información (**RI001 – RI006**), identificamos cuatro categorías de entidades:

### Entidades Principales (Fuertes / Independientes)
* **Grado:** Títulos de grado impartidos en el centro universitario.
* **Persona:** Superclase que centraliza los datos personales y civiles comunes.

### Especializaciones (Herencia 1:1 de `Persona`)
* **Profesor:** Persona con perfil y atribuciones docentes.
* **Alumno:** Persona con perfil y expediente académico discente.

### Entidades Dependientes (1:N)
* **Asignatura:** Materias pertenecientes a un único título de grado (`Grado`).
* **Grupo:** Divisiones prácticas (`Laboratorio`) o teóricas (`Teoría`) de una asignatura en un año académico.

### Entidades Asociativas (Relaciones N:M y Evaluaciones)
* **Matricula (`Alumno` ↔ `Asignatura`):** Registro de matrícula del alumno en la asignatura.
* **PertenenciaGrupo (`Alumno` ↔ `Grupo`):** Asignación del alumno a grupos específicos.
* **Docencia (`Profesor` ↔ `Grupo`):** Asignación de profesores a grupos con su respectiva carga de créditos.
* **Nota (`Alumno` ↔ `Grupo`):** Calificación obtenida por un alumno en un grupo concreto.

---

## 📋 2. Atributos de Cada Entidade

> [!NOTE]
> **Refinamiento Técnico:** Se separan los **atributos propios** de las **claves foráneas (FK)** que establecen las relaciones entre tablas.

### `Grado` (RI001)
* `id_grado` (PK, Clave subrogada / autonumérica)
* `nombre` (VARCHAR): Nombre del grado.
* `duracion_anos` (TINYINT): Número de años (de 3 a 6 años - RN013).

### `Asignatura` (RI002)
* `id_asignatura` (PK)
* `nombre` (VARCHAR): Nombre completo de la asignatura.
* `acronimo` (VARCHAR): Sigla de identificación única (ej. 'IISSI-1').
* `creditos` (TINYINT): Valor fijo de 6 o 12 créditos (RN010).
* `curso` (TINYINT): Curso académico entre 1 y 6 (RN016).
* `tipo` (ENUM): `'Obligatoria'`, `'Optativa'`, `'Formación Básica'`.
* *Clave Foránea (FK):* `id_grado` → Referencia a `Grado(id_grado)`.

### `Grupo` (RI003)
* `id_grupo` (PK)
* `nombre` (VARCHAR): Identificador del grupo (ej. 'T1', 'L1', 'L2').
* `ano_academico` (YEAR): Año académico entre 2000 y 2100 (RN015).
* `actividad` (ENUM): `'Teoría'` o `'Laboratorio'`.
* *Clave Foránea (FK):* `id_asignatura` → Referencia a `Asignatura(id_asignatura)`.

### `Persona` (RI004, RI005)
* `id_persona` (PK)
* `dni` (CHAR(9)): 8 números y 1 letra (RN014).
* `nombre` (VARCHAR): Nombre de pila.
* `apellidos` (VARCHAR): Apellidos completos.
* `edad` (TINYINT): Edad comprendida entre 16 y 70 años (RN012).
* `email` (VARCHAR): Correo electrónico institucional.

### `Profesor` (Especialización de `Persona` - RI004)
* `id_profesor` (PK y FK compartida): Referencia a `Persona(id_persona)`.
* `categoria` (ENUM): `'Ayudante'`, `'Ayudante Doctor'`, `'Titular'`, `'Catedrático'`.

### `Alumno` (Especialización de `Persona` - RI005)
* `id_alumno` (PK y FK compartida): Referencia a `Persona(id_persona)`.
* `metodo_acceso` (ENUM): `'Selectividad'`, `'Ciclo'`, `'Mayor'`, `'Titulado'`, `'Extranjero'`.

### Entidades Asociativas y sus Atributos Propios

| Tabla Asociativa | Claves Foráneas (Composición de la PK) | Atributos Propios |
| :--- | :--- | :--- |
| **`Docencia`** (Profesor ↔ Grupo) | `id_profesor`, `id_grupo` | **`creditos`** (DECIMAL): Carga lectiva de créditos asignada al profesor en ese grupo. |
| **`Matricula`** (Alumno ↔ Asignatura) | `id_alumno`, `id_asignatura` | Fecha de matrícula / Estado |
| **`PertenenciaGrupo`** (Alumno ↔ Grupo) | `id_alumno`, `id_grupo` | Fecha de asignación al grupo |
| **`Nota`** (RI006) | `id_nota` (PK), `id_alumno` (FK), `id_grupo` (FK) | **`valor`** (DECIMAL 0.0 - 10.0), **`convocatoria`** (ENUM: Primera, Segunda, Tercera, Extraordinaria), **`es_matricula_honor`** (BOOLEAN). |

---

## 🔗 3. Relaciones y Cardinalidades

```
[Grado] 1 ────────── N [Asignatura]
                           1
                           │
                           ▼
                           N
                        [Grupo]
                        ▲     ▲
      (Docencia) N      │     │      N (PertenenciaGrupo / Nota)
   ┌────────────────────┘     └───────────────────┐
   │                                              │
[Profesor]                                     [Alumno]
   │ 1                                            │ 1
   │ (Herencia)                                   │ (Herencia)
   ▼ 1                                            ▼ 1
[Persona] ◄───────────────────────────────────────┘
```

* **Grado 1 — N Asignatura:** Varias asignaturas forman parte de un grado y una asignatura pertenece a un único grado.
* **Asignatura 1 — N Grupo:** Cada asignatura está formada por grupos de teoría y laboratorio.
* **Persona 1 — 1 Profesor / Alumno:** Especialización disjunta mediante clave primaria compartida (`1:1`).
* **Alumno N — M Asignatura (`Matricula`):** Un alumno se matricula en varias asignaturas.
* **Alumno N — M Grupo (`PertenenciaGrupo`):** Un alumno pertenece a grupos específicos.
* **Profesor N — M Grupo (`Docencia`):** Un profesor imparte docencia en grupos, con una carga de créditos asociada.
* **Alumno + Grupo 1 — N Nota:** Las notas están asociadas a un alumno y a un grupo específico.

---

## ⚖️ 4. Reglas de Negocio (RN) y Mapeo SQL

| Código | Descripción de la Regla | Mecanismo de Implementación en MariaDB |
| :---: | :--- | :--- |
| **RN001** | Para ser Matrícula de Honor (MH) la nota debe ser $\ge 9.0$ | `CHECK (es_matricula_honor = 0 OR valor >= 9.0)` |
| **RN002** | Un alumno solo puede tener notas en grupos a los que pertenece | `TRIGGER BEFORE INSERT/UPDATE ON notas` |
| **RN003** | Un grupo no puede tener más de 2 profesores | `TRIGGER BEFORE INSERT ON docencias` |
| **RN004** | Máximo 1 grupo de teoría y 1 de laboratorio por asignatura para cada alumno | `TRIGGER BEFORE INSERT ON pertenencias_grupos` |
| **RN005** | Una nota no puede alterarse de una vez en más de 4 puntos | `TRIGGER BEFORE UPDATE ON notas` |
| **RN006** | Por asignatura: máx. 1 grupo de teoría y 2 de laboratorio | `TRIGGER BEFORE INSERT ON grupos` |
| **RN007** | Un alumno solo puede pertenecer a grupos de asignaturas matriculadas | `TRIGGER BEFORE INSERT ON pertenencias_grupos` |
| **RN008** | Acceso por Selectividad exige edad $\ge 16$ | `TRIGGER BEFORE INSERT ON alumnos` |
| **RN009** | Todos los atributos son obligatorios | Restricción `NOT NULL` en todas las columnas |
| **RN010** | Créditos de asignatura sólo pueden ser 6 o 12 | `CHECK (creditos IN (6, 12))` |
| **RN011** | Rango de notas comprendido entre 0.0 y 10.0 | `CHECK (valor BETWEEN 0.0 AND 10.0)` |
| **RN012** | Edad de las personas comprendida entre 16 y 70 años | `CHECK (edad BETWEEN 16 AND 70)` |
| **RN013** | Años del grado comprendidos entre 3 y 6 | `CHECK (duracion_anos BETWEEN 3 AND 6)` |
| **RN014** | Formato de DNI: 8 números seguidos de 1 letra | `CHECK (dni REGEXP '^[0-9]{8}[A-Za-z]$')` |
| **RN015** | Rango de año académico entre 2000 y 2100 | `CHECK (ano_academico BETWEEN 2000 AND 2100)` |
| **RN016** | Curso de asignatura comprendido entre 1 y 6 | `CHECK (curso BETWEEN 1 AND 6)` |
| **RN017** | Unicidad de nota por alumno, asignatura, convocatoria y año | Restricción `UNIQUE` compuesta o validada en `TRIGGER` |

---

## 🎯 5. Requisitos Funcionales (RF) y Comandos SQL

* **RF001 (Añadir nota):** `INSERT INTO notas (id_alumno, id_grupo, valor, convocatoria, es_matricula_honor) VALUES (...);`
* **RF002 (Borrar notas de alumno):** `DELETE FROM notas WHERE id_alumno = (SELECT id_persona FROM personas WHERE dni = ?);`
* **RF003 (Listado de alumnos ordenado):** `SELECT p.nombre, p.apellidos, a.nombre, g.nombre FROM personas p JOIN alumnos al ON p.id_persona = al.id_alumno ... ORDER BY p.apellidos, p.nombre;`
* **RF004 (Alumnos mayores de 40 años):** `SELECT p.* FROM personas p JOIN alumnos al ON p.id_persona = al.id_alumno WHERE al.metodo_acceso = 'Mayor';`
* **RF005 (Asignaturas de grado y curso):** `SELECT nombre, acronimo, creditos, tipo FROM asignaturas WHERE id_grado = ? AND curso = ? ORDER BY acronimo;`
* **RF006 (Expediente académico final):** `SELECT ... GROUP BY id_asignatura` seleccionando las calificaciones correspondientes al mayor año y convocatoria.
* **RF007 (Nota media de alumno):** `SELECT AVG(valor) FROM notas WHERE id_alumno = ?;`
* **RF008 (Listado de asignaturas de un grado):** `SELECT * FROM asignaturas WHERE id_grado = ?;`

---

## 🔒 6. Requisitos No Funcionales (RNF - Control de Acceso)

Implementado mediante sentencias **DCL (Data Control Language)** en MariaDB:
* **Administrador (`admin`):** Control total sobre todas las tablas y operaciones (`GRANT ALL PRIVILEGES ON gestion_academica.* TO 'admin'@'localhost';`).
* **Profesor (`teacher`):** Lectura completa en todas las tablas y escritura exclusivamente en notas (`GRANT SELECT ON gestion_academica.* TO 'teacher'@'localhost';` y `GRANT INSERT, UPDATE ON gestion_academica.notas TO 'teacher'@'localhost';`).
* **Alumno (`student`):** Solo acceso de lectura en todas las tablas (`GRANT SELECT ON gestion_academica.* TO 'student'@'localhost';`).

---

## 🧪 7. Pruebas de Aceptación (Casos de Prueba Negativos)

Operaciones que el sistema debe rechazar para verificar la integridad de las reglas:
1. ❌ **Grados (RN013):** Intentar crear un grado con duración de 2 o 7 años.
2. ❌ **Asignaturas (RN010, RN016):** Intentar crear asignatura con 3, 4, 8 créditos o en curso 0 o 7.
3. ❌ **Grupos (RN006, RN015):** Intentar crear grupo con año 1999 o 2101, o un segundo grupo de teoría.
4. ❌ **Personas (RN009, RN012, RN014):** Intentar insertar atributos NULL, edad 15 o 71, o DNI con formato erróneo.
5. ❌ **Profesores (RN003):** Intentar asignar un tercer profesor a un grupo.
6. ❌ **Alumnos (RN008):** Crear alumno menor de 16 años con acceso por Selectividad.
7. ❌ **Matrículas (RN007):** Añadir un alumno a un grupo sin estar previamente matriculado en la asignatura.
8. ❌ **Pertenencia a grupos (RN004):** Añadir alumno a dos grupos de teoría o dos de laboratorio de la misma asignatura.
9. ❌ **Notas (RN001, RN002, RN005, RN011, RN017):**
   * Nota fuera de rango (ej. 11.0 o -1.0).
   * Matrícula de Honor con nota inferior a 9.0 (ej. 6.2).
   * Nota duplicada en la misma convocatoria y año.
   * Modificar una nota en más de 4 puntos de golpe (ej. de 9.8 a 0.5).