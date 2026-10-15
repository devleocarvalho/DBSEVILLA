# ✅ LAB 1: Creación de Esquema Relacional y Carga de Datos

Este documento resume los fundamentos, la arquitectura de tablas, las normas de estilo y todos los comandos SQL ejecutados en el **Lab 1 (IISSI-1 - Universidad de Sevilla)**.

---

## 🎯 1. Objetivos del Laboratorio

* Aprender la sintaxis **DDL (Data Definition Language)** para la creación de esquemas relacionales con `CREATE TABLE`.
* Dominar la asignación óptima de **tipos de datos** (`INT`, `TINYINT`, `VARCHAR`, `CHAR`, `DECIMAL`, `YEAR`, `BOOLEAN`).
* Implementar **Claves Primarias (PK)** simples y compuestas, con soporte de autonumérico (`AUTO_INCREMENT`).
* Implementar **Claves Ajenas / Foráneas (FK)** para modelar relaciones de **Herencia (1:1)**, **1 a N** y **N a M**.
* Ejecutar la carga inicial de datos con **DML (Data Manipulation Language)** mediante `INSERT INTO`.

---

## 📐 2. Normas de Estilo Oficiales (IISSI-1)

1. **Palabras reservadas de SQL en MAYÚSCULAS:** `CREATE TABLE`, `PRIMARY KEY`, `FOREIGN KEY`, `NOT NULL`, `AUTO_INCREMENT`, `INSERT INTO`, `SELECT`, `JOIN`.
2. **Nombres de tablas:** En minúsculas, `snake_case` y en **plural** (ej. `people`, `degrees`, `teaching_loads`).
3. **Nombres de columnas y atributos:** En minúsculas y `snake_case` (ej. `person_id`, `first_name`, `duration_years`).
4. **Idioma del código:** El código SQL (tablas, campos y restricciones) se escribe en **inglés**, mientras que la documentación y comentarios están en **español**.
5. **Base de datos de trabajo:** `GradesDB`.

---

## 🏗️ 3. Arquitectura y Tipos de Datos Explicados

| Tabla | Rol / Tipo de Relación | Clave Primaria (PK) | Claves Ajenas (FK) | Conceptos Clave |
| :--- | :--- | :--- | :--- | :--- |
| **`people`** | Entidad Fuerte Base | `person_id` (AUTO_INCREMENT) | Ninguna | Centraliza datos comunes de personas (`dni CHAR(9)`, `age TINYINT`). |
| **`professors`** | Herencia 1:1 de `people` | `professor_id` | `professor_id` ➔ `people` | Clave primaria compartida que actúa simultáneamente como PK y FK. |
| **`students`** | Herencia 1:1 de `people` | `student_id` | `student_id` ➔ `people` | Igual que profesores: hereda la identidad civil de la persona. |
| **`degrees`** | Entidad Fuerte | `degree_id` (AUTO_INCREMENT) | Ninguna | Títulos de grado con duración (`TINYINT` de 1 byte). |
| **`subjects`** | Entidad Débil / Dependiente | `subject_id` (AUTO_INCREMENT) | `degree_id` ➔ `degrees` | Relación 1:N con grados. Tipo con `VARCHAR(30)`. |
| **`groups`** | Entidad Dependiente | `group_id` (AUTO_INCREMENT) | `subject_id` ➔ `subjects` | Subdivisión en teoría/laboratorio. Año con tipo `YEAR`. |
| **`group_enrollments`** | Tabla Intermedia (N:M) | `(student_id, group_id)` | `student_id` ➔ `students`<br>`group_id` ➔ `groups` | Asignación de alumnos a grupos. La pareja de FK forma la PK compuesta. |
| **`grades`** | Entidad de Evaluación | `grade_id` (AUTO_INCREMENT) | `student_id` ➔ `students`<br>`group_id` ➔ `groups` | Notas de alumnos (`DECIMAL(4,2)`: 2 enteros y 2 decimales). |
| **`subject_enrollments`**| Tabla Intermedia (N:M) | `(student_id, subject_id)` | `student_id` ➔ `students`<br>`subject_id` ➔ `subjects` | Matrícula formal de alumnos en asignaturas. |
| **`teaching_loads`** | Clase Asociación (N:M) | `(professor_id, group_id)` | `professor_id` ➔ `professors`<br>`group_id` ➔ `groups` | Carga docente con atributo propio: `credits DECIMAL(4,1)`. |

---

## 💻 4. Script Completo de Creación de Tablas (`createdb.sql`)

```sql
-- 1. Creación e inicialización de la base de datos
DROP DATABASE IF EXISTS GradesDB;
CREATE DATABASE GradesDB CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE GradesDB;

-- 2. Eliminación previa ordenada (desactivando FK checks temporalmente)
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS teaching_loads;
DROP TABLE IF EXISTS subject_enrollments;
DROP TABLE IF EXISTS grades;
DROP TABLE IF EXISTS group_enrollments;
DROP TABLE IF EXISTS groups;
DROP TABLE IF EXISTS subjects;
DROP TABLE IF EXISTS degrees;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS professors;
DROP TABLE IF EXISTS people;

SET FOREIGN_KEY_CHECKS = 1;

-- 3. Definición de Tablas

-- Personas (Superclase)
CREATE TABLE people (
    person_id INT AUTO_INCREMENT,
    dni CHAR(9) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(150) NOT NULL,
    age TINYINT NOT NULL,
    email VARCHAR(255) NOT NULL,
    PRIMARY KEY (person_id)
);

-- Profesores (Herencia 1:1)
CREATE TABLE professors (
    professor_id INT,
    category VARCHAR(30) NOT NULL,
    PRIMARY KEY (professor_id),
    FOREIGN KEY (professor_id) REFERENCES people(person_id)
);

-- Alumnos (Herencia 1:1)
CREATE TABLE students (
    student_id INT,
    access_method VARCHAR(20) NOT NULL,
    PRIMARY KEY (student_id),
    FOREIGN KEY (student_id) REFERENCES people(person_id)
);

-- Grados
CREATE TABLE degrees (
    degree_id INT AUTO_INCREMENT,
    degree_name VARCHAR(80) NOT NULL,
    duration_years TINYINT NOT NULL,
    PRIMARY KEY (degree_id)
);

-- Asignaturas (1:N con Grados)
CREATE TABLE subjects (
    subject_id INT AUTO_INCREMENT,
    degree_id INT NOT NULL,
    subject_name VARCHAR(120) NOT NULL,
    acronym VARCHAR(12) NOT NULL,
    credits TINYINT NOT NULL,
    course TINYINT NOT NULL,
    subject_type VARCHAR(30) NOT NULL,
    PRIMARY KEY (subject_id),
    FOREIGN KEY (degree_id) REFERENCES degrees(degree_id)
);

-- Grupos (1:N con Asignaturas)
CREATE TABLE groups (
    group_id INT AUTO_INCREMENT,
    subject_id INT NOT NULL,
    group_name VARCHAR(40) NOT NULL,
    activity VARCHAR(15) NOT NULL,
    academic_year YEAR NOT NULL,
    PRIMARY KEY (group_id),
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);

-- Pertenencia a Grupos (N:M entre Alumnos y Grupos)
CREATE TABLE group_enrollments (
    student_id INT,
    group_id INT,
    PRIMARY KEY (student_id, group_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (group_id) REFERENCES groups(group_id)
);

-- Notas (Evaluaciones de Alumnos en Grupos)
CREATE TABLE grades (
    grade_id INT AUTO_INCREMENT,
    student_id INT NOT NULL,
    group_id INT NOT NULL,
    grade_value DECIMAL(4,2) NOT NULL,
    exam_call VARCHAR(20) NOT NULL,
    with_honors BOOLEAN NOT NULL DEFAULT 0,
    PRIMARY KEY (grade_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (group_id) REFERENCES groups(group_id)
);

-- Matrícula en Asignaturas (N:M entre Alumnos y Asignaturas)
CREATE TABLE subject_enrollments (
    student_id INT,
    subject_id INT,
    PRIMARY KEY (student_id, subject_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id)
);

-- Docencia / Carga Docente (Clase Asociación N:M entre Profesores y Grupos con Créditos)
CREATE TABLE teaching_loads (
    professor_id INT,
    group_id INT,
    credits DECIMAL(4,1) NOT NULL,
    PRIMARY KEY (professor_id, group_id),
    FOREIGN KEY (professor_id) REFERENCES professors(professor_id),
    FOREIGN KEY (group_id) REFERENCES groups(group_id)
);
```

---

## 📥 5. Inserción de Datos Iniciales (`populatedb.sql`)

```sql
SET FOREIGN_KEY_CHECKS = 0;

DELETE FROM teaching_loads;
DELETE FROM subject_enrollments;
DELETE FROM grades;
DELETE FROM group_enrollments;
DELETE FROM groups;
DELETE FROM subjects;
DELETE FROM degrees;
DELETE FROM students;
DELETE FROM professors;
DELETE FROM people;

SET FOREIGN_KEY_CHECKS = 1;

-- 1. Personas (profesores 1-5, estudiantes 6-25)
INSERT INTO people (person_id, dni, first_name, last_name, age, email) VALUES
(1,'00000001A','David','Ruiz',50,'druiz@us.es'),
(2,'00000002B','Inma','Hernández',40,'inmahernandez@us.es'),
(3,'00000003C','Fernando','Sola',28,'fsola@us.es'),
(4,'00000004D','Daniel','Ayala',32,'dayala1@us.es'),
(5,'00000005E','Pepe','Calderón',43,'pepecalderon@us.es'),
(6,'10000006F','David','Romero',22,'david.romero@alum.us.es'),
(7,'10000007G','Lucía','Molina',21,'lucia.molina@alum.us.es'),
(8,'10000008H','Hugo','Paredes',20,'hugo.paredes@alum.us.es'),
(9,'10000009J','Sara','Campos',21,'sara.campos@alum.us.es'),
(10,'10000010K','Mario','Galán',22,'mario.galan@alum.us.es'),
(11,'10000011L','Elena','Torres',21,'elena.torres@alum.us.es'),
(12,'10000012M','Rubén','Durán',20,'ruben.duran@alum.us.es'),
(13,'10000013N','Claudia','Soto',23,'claudia.soto@alum.us.es'),
(14,'10000014P','Iván','Cuesta',22,'ivan.cuesta@alum.us.es'),
(15,'10000015Q','Noelia','Rey',21,'noelia.rey@alum.us.es'),
(16,'10000016R','Pablo','Vidal',22,'pablo.vidal@alum.us.es'),
(17,'10000017S','Alicia','Muñoz',21,'alicia.munoz@alum.us.es'),
(18,'10000018T','Sergio','Izquierdo',22,'sergio.izquierdo@alum.us.es'),
(19,'10000019U','Nerea','Saiz',20,'nerea.saiz@alum.us.es'),
(20,'10000020V','Álvaro','León',23,'alvaro.leon@alum.us.es'),
(21,'10000021W','Julia','Benito',21,'julia.benito@alum.us.es'),
(22,'10000022X','Tomás','Rubio',22,'tomas.rubio@alum.us.es'),
(23,'10000023Y','Irene','Salas',21,'irene.salas@alum.us.es'),
(24,'10000024Z','Álex','Delgado',22,'alex.delgado@alum.us.es'),
(25,'10000025A','Paula','Bermejo',21,'paula.bermejo@alum.us.es');

-- 2. Profesores
INSERT INTO professors (professor_id, category) VALUES
(1,'Catedrático'),
(2,'Titular'),
(3,'AyudanteDoctor'),
(4,'Titular'),
(5,'Ayudante');

-- 3. Estudiantes
INSERT INTO students (student_id, access_method) VALUES
(6,'Selectividad'),(7,'Selectividad'),(8,'Selectividad'),(9,'Selectividad'),(10,'Selectividad'),
(11,'Selectividad'),(12,'Selectividad'),(13,'Selectividad'),(14,'Selectividad'),(15,'Selectividad'),
(16,'Selectividad'),(17,'Selectividad'),(18,'Selectividad'),(19,'Selectividad'),(20,'Selectividad'),
(21,'Selectividad'),(22,'Selectividad'),(23,'Selectividad'),(24,'Selectividad'),(25,'Selectividad');

-- 4. Grados
INSERT INTO degrees (degree_id, degree_name, duration_years) VALUES
(1,'Ingeniería del Software',4),
(2,'Ingeniería de Computadores',4),
(3,'Tecnologías Informáticas',4);

-- 5. Asignaturas de Tecnologías Informáticas
INSERT INTO subjects (subject_id, degree_id, subject_name, acronym, credits, course, subject_type) VALUES
(1,3,'Fundamentos de Programación','FP',12,1,'Formación Básica'),
(2,3,'Cálculo Infinitesimal y Numérico','CIN',6,1,'Formación Básica'),
(3,3,'Circuitos Electrónicos Digitales','CED',6,1,'Formación Básica'),
(4,3,'Fundamentos Físicos de la Informática','FFI',6,1,'Formación Básica'),
(5,3,'Introducción a la Matemática Discreta','IMD',6,1,'Formación Básica'),
(6,3,'Administración de Empresas','ADE',6,1,'Formación Básica'),
(7,3,'Álgebra Lineal y Numérica','ALN',6,1,'Formación Básica'),
(8,3,'Estadística','EST',6,1,'Formación Básica'),
(9,3,'Estructura de Computadores','EC',6,1,'Formación Básica'),
(10,3,'Análisis y Diseño de Datos y Algoritmos','ADDA',12,2,'Obligatoria'),
(11,3,'Introducción a la Ingeniería del Software y los Sistemas de Información I','IISSI-1',6,2,'Obligatoria'),
(12,3,'Matemática Discreta','MD',6,2,'Obligatoria'),
(13,3,'Redes de Computadores','RC',6,2,'Obligatoria'),
(14,3,'Arquitectura de Computadores','AC',6,2,'Obligatoria'),
(15,3,'Introducción a la Ingeniería del Software y los Sistemas de Información II','IISSI-2',6,2,'Obligatoria'),
(16,3,'Sistemas Operativos','SO',6,2,'Obligatoria'),
(17,3,'Inteligencia Artificial','IA',6,2,'Obligatoria');

-- 6. Grupos de IISSI-1 (1 de Teoría y 2 de Laboratorio)
INSERT INTO groups (group_id, subject_id, group_name, activity, academic_year) VALUES
(1,11,'T1','Teoría',2024),
(2,11,'L1','Laboratorio',2024),
(3,11,'L2','Laboratorio',2024);

-- 7. Pertenencia a Grupos
INSERT INTO group_enrollments (student_id, group_id) VALUES
(6,1),(7,1),(8,1),(9,1),(10,1),(11,1),(12,1),(13,1),(14,1),(15,1),
(16,1),(17,1),(18,1),(19,1),(20,1),(21,1),(22,1),(23,1),(24,1),(25,1),
(6,2),(7,2),(8,2),(9,2),(10,2),(11,2),(12,2),(13,2),(14,2),(15,2),
(16,3),(17,3),(18,3),(19,3),(20,3),(21,3),(22,3),(23,3),(24,3),(25,3);

-- 8. Calificaciones (Notas)
INSERT INTO grades (grade_id, student_id, group_id, grade_value, exam_call, with_honors) VALUES
(1,6,1,9.8,'Primera',1),
(2,7,1,9.2,'Primera',1),
(3,8,1,5.4,'Primera',0),
(4,9,1,8.0,'Primera',0),
(5,10,1,6.0,'Primera',0),
(6,11,1,5.7,'Primera',0),
(7,12,1,7.0,'Primera',0),
(8,13,1,6.3,'Primera',0),
(9,14,1,5.8,'Primera',0),
(10,15,1,6.1,'Primera',0),
(11,16,1,4.2,'Primera',0),
(12,17,1,3.9,'Primera',0),
(13,18,1,4.5,'Primera',0),
(14,19,1,4.8,'Primera',0),
(15,20,1,4.4,'Primera',0),
(16,21,1,3.5,'Primera',0),
(17,22,1,3.8,'Primera',0),
(18,23,1,4.0,'Primera',0),
(19,24,1,4.3,'Primera',0),
(20,25,1,4.7,'Primera',0),
(21,16,1,6.2,'Segunda',0),
(22,17,1,5.8,'Segunda',0),
(23,18,1,6.4,'Segunda',0),
(24,19,1,5.9,'Segunda',0),
(25,20,1,6.1,'Segunda',0),
(26,21,1,4.6,'Segunda',0),
(27,22,1,4.9,'Segunda',0),
(28,23,1,4.7,'Segunda',0),
(29,24,1,4.4,'Segunda',0),
(30,25,1,4.3,'Segunda',0),
(31,21,1,5.6,'Tercera',0),
(32,22,1,5.9,'Tercera',0),
(33,23,1,5.5,'Tercera',0),
(34,24,1,6.0,'Tercera',0),
(35,25,1,5.7,'Tercera',0);

-- 9. Matrícula en Asignaturas
INSERT INTO subject_enrollments (student_id, subject_id) VALUES
(6,11),(7,11),(8,11),(9,11),(10,11),(11,11),(12,11),(13,11),(14,11),(15,11),
(16,11),(17,11),(18,11),(19,11),(20,11),(21,11),(22,11),(23,11),(24,11),(25,11);

-- 10. Docencia / Asignación Docente
INSERT INTO teaching_loads (professor_id, group_id, credits) VALUES
(1,1,3.0),
(2,1,3.0),
(3,2,3.0),
(5,3,1.5),
(4,3,1.5);
```

---

## 🔍 6. Consultas de Verificación Ejecutadas

### Consulta 1: Listado de Profesores (Herencia `people` + `professors`)
```sql
SELECT p.person_id, p.dni, p.first_name, p.last_name, pr.category 
FROM people p
JOIN professors pr ON p.person_id = pr.professor_id;
```

### Consulta 2: Docencia y Carga Horaria por Asignatura y Grupo
```sql
SELECT s.acronym AS asignatura, g.group_name, g.activity, p.last_name AS profesor, tl.credits
FROM teaching_loads tl
JOIN professors pr ON tl.professor_id = pr.professor_id
JOIN people p ON pr.professor_id = p.person_id
JOIN groups g ON tl.group_id = g.group_id
JOIN subjects s ON g.subject_id = s.subject_id;
```

### Consulta 3: Alumnos con Matrícula de Honor (MH)
```sql
SELECT p.first_name, p.last_name, g.grade_value, g.exam_call, g.with_honors
FROM grades g
JOIN students st ON g.student_id = st.student_id
JOIN people p ON st.student_id = p.person_id
WHERE g.with_honors = 1;
```

---

## 📌 7. Conceptos Clave Aprendidos

1. **`AUTO_INCREMENT`**: Solo puede aplicarse a columnas indexadas (normalmente la clave primaria). Genera valores enteros secuenciales automáticamente.
2. **Claves Primarias Compuestas**: En tablas intermedias N:M (`group_enrollments`, `subject_enrollments`, `teaching_loads`), la PK está formada por el par de claves ajenas `PRIMARY KEY (col1, col2)`, garantizando que no existan tuplas duplicadas.
3. **`SET FOREIGN_KEY_CHECKS = 0 / 1`**: Deshabilita temporalmente las comprobaciones de integridad referencial para permitir borrar o recrear tablas y datos sin verse bloqueado por el orden de dependencias.
