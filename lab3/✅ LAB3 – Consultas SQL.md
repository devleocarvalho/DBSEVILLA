# ✅ LAB 3: Consultas SQL (Extracción, Análisis, Agregación y Vistas)

Este documento resume los fundamentos teóricos, la sintaxis SQL de **DQL (Data Query Language)**, los operadores, las uniones (`JOIN`), las agrupaciones (`GROUP BY`, `HAVING`) y las vistas creadas en el **Lab 3 (IISSI-1 - Universidad de Sevilla)** sobre la base de datos **`GradesDB`**.

---

## 🎯 1. Objetivos del Laboratorio

* Dominar la sintaxis fundamental de consultas con **`SELECT`** y **`WHERE`**.
* Filtrar datos mediante operadores relacionales, lógicos (`AND`, `OR`), de rango (`BETWEEN`), de pertenencia (`IN`) y patrones de texto (`LIKE`).
* Realizar combinaciones de tablas con **`INNER JOIN`** y **`LEFT JOIN`** para consultar modelos 1:N y N:M.
* Implementar **Vistas (`VIEW`)** como mecanismos de abstracción y reutilización.
* Utilizar **funciones de agregación** (`COUNT`, `SUM`, `AVG`, `MAX`, `MIN`).
* Organizar resultados en grupos mediante **`GROUP BY`** y filtrar agrupaciones con **`HAVING`**.
* Controlar la ordenación y la paginación con **`ORDER BY`**, **`LIMIT`** y **`OFFSET`**.
* Construir **subconsultas** correlacionadas e independientes.

---

## 📚 2. Fundamentos Teóricos de las Consultas SQL

### Orden Lógico de Ejecución de una Consulta SQL
Aunque escribimos `SELECT` al principio, el motor MariaDB ejecuta las cláusulas en el siguiente orden estricto:

```
1. FROM / JOIN     ➔ Determina y combina las tablas de origen.
2. WHERE           ➔ Filtra filas individuales antes de agrupar.
3. GROUP BY        ➔ Agrupa las filas filtradas por una o más columnas.
4. HAVING          ➔ Filtra los grupos resultantes según condiciones agregadas.
5. SELECT          ➔ Proyecta las columnas, expresiones y alias solicitados.
6. DISTINCT        ➔ Elimina filas duplicadas de la proyección.
7. ORDER BY        ➔ Ordena el conjunto final (ASC / DESC).
8. LIMIT / OFFSET  ➔ Restringe la cantidad y desplazamiento de filas a devolver.
```

---

## 🔍 3. Catálogo de Vistas Creadas en el Laboratorio

Las vistas son consultas guardadas en el catálogo de MariaDB que se comportan como tablas virtuales de solo lectura (o actualizables bajo ciertas condiciones):

```sql
-- 1. Vista de Profesores (combina people y professors)
CREATE OR REPLACE VIEW v_professors AS
SELECT p.person_id, p.dni, p.first_name, p.last_name, p.age, p.email, pr.category
FROM people p
JOIN professors pr ON p.person_id = pr.professor_id;

-- 2. Vista de Alumnos (combina people y students)
CREATE OR REPLACE VIEW v_students AS
SELECT p.person_id, p.dni, p.first_name, p.last_name, p.age, p.email, s.access_method
FROM people p
JOIN students s ON p.person_id = s.student_id;

-- 3. Vista de Notas con Matrícula de Honor (MH)
CREATE OR REPLACE VIEW v_grades_with_honors AS
SELECT g.grade_id, p.first_name, p.last_name, s.subject_name, gr.group_name, g.grade_value, g.exam_call
FROM grades g
JOIN students st ON g.student_id = st.student_id
JOIN people p ON st.student_id = p.person_id
JOIN groups gr ON g.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id
WHERE g.with_honors = 1;

-- 4. Vista de Cargas Docentes Detalladas
CREATE OR REPLACE VIEW v_professor_loads AS
SELECT p.first_name, p.last_name, pr.category, s.acronym, g.group_name, g.activity, tl.credits
FROM teaching_loads tl
JOIN professors pr ON tl.professor_id = pr.professor_id
JOIN people p ON pr.professor_id = p.person_id
JOIN groups g ON tl.group_id = g.group_id
JOIN subjects s ON g.subject_id = s.subject_id;
```

---

## 📊 4. Bloques de Consultas del Laboratorio

### Bloque A: Consultas Básicas y Proyección
```sql
-- Todas las asignaturas
SELECT * FROM subjects;

-- Asignatura con acrónimo específico (Filtro exacto)
SELECT * FROM subjects WHERE acronym = 'IISSI-1';

-- Proyección de columnas específicas (nombre y créditos)
SELECT subject_name, credits FROM subjects;

-- Asignaturas obligatorias
SELECT * FROM subjects WHERE subject_type = 'Obligatoria';
```

### Bloque B: Combinaciones (`JOIN`)
```sql
-- Estudiantes con datos personales y método de acceso (RF003)
SELECT p.first_name, p.last_name, s.access_method
FROM people p
JOIN students s ON p.person_id = s.student_id;

-- Profesores titulares
SELECT p.first_name, p.last_name, pr.category
FROM people p
JOIN professors pr ON p.person_id = pr.professor_id
WHERE pr.category = 'Titular';

-- LEFT JOIN: Grados y sus asignaturas (incluye grados aunque no tengan asignaturas aún)
SELECT d.degree_name, s.subject_name
FROM degrees d
LEFT JOIN subjects s ON d.degree_id = s.degree_id;
```

### Bloque C: Funciones de Agregación
```sql
-- Nota media general del centro (RF007 global)
SELECT AVG(grade_value) AS average_grade FROM grades;

-- Suma de créditos de asignaturas de segundo curso
SELECT SUM(credits) AS total_credits FROM subjects WHERE course = 2;

-- Conteo total de alumnos registrados
SELECT COUNT(*) AS total_students FROM students;

-- Nota máxima y nota mínima registrada
SELECT MAX(grade_value) AS max_grade, MIN(grade_value) AS min_grade FROM grades;
```

### Bloque D: Operadores `BETWEEN`, `IN`, `LIKE` y `DISTINCT`
```sql
-- Personas con edad comprendida entre 20 y 30 años
SELECT first_name, last_name, age FROM people WHERE age BETWEEN 20 AND 30;

-- Alumnos que accedieron por Selectividad o Titulado
SELECT p.first_name, p.last_name, s.access_method
FROM people p
JOIN students s ON p.person_id = s.student_id
WHERE s.access_method IN ('Selectividad', 'Titulado');

-- Asignaturas cuyo nombre contiene la palabra 'Información'
SELECT acronym, subject_name FROM subjects WHERE subject_name LIKE '%Información%';

-- Tipos únicos de asignaturas existentes sin duplicados
SELECT DISTINCT subject_type FROM subjects;
```

### Bloque E: Agrupaciones con `GROUP BY` y Filtro de Grupos con `HAVING`
> [!IMPORTANT]
> **Diferencia entre WHERE y HAVING:**
> * `WHERE`: Se evalúa fila por fila **antes** de realizar la agrupación. No admite funciones agregadas (`WHERE AVG(nota) > 5` es un error de sintaxis).
> * `HAVING`: Se evalúa sobre el resultado consolidado del grupo **después** de agrupar. Permite condiciones sobre agregados (`HAVING AVG(grade_value) >= 5.0`).

```sql
-- Número de alumnos por cada método de acceso
SELECT access_method, COUNT(*) AS total_alumnos
FROM students
GROUP BY access_method;

-- Nota media obtenida por cada grupo
SELECT group_id, AVG(grade_value) AS nota_media
FROM grades
GROUP BY group_id;

-- Grupos cuya nota media sea aprobada (>= 5.0)
SELECT group_id, AVG(grade_value) AS nota_media
FROM grades
GROUP BY group_id
HAVING AVG(grade_value) >= 5.0;

-- Profesores con más de 3 créditos de carga docente total
SELECT p.first_name, p.last_name, SUM(tl.credits) AS total_creditos
FROM teaching_loads tl
JOIN professors pr ON tl.professor_id = pr.professor_id
JOIN people p ON pr.professor_id = p.person_id
GROUP BY tl.professor_id, p.first_name, p.last_name
HAVING SUM(tl.credits) > 3.0;
```

### Bloque F: Ordenación y Paginación (`ORDER BY`, `LIMIT`, `OFFSET`)
```sql
-- Alumnos ordenados alfabéticamente por apellidos y nombre (RF003)
SELECT p.last_name, p.first_name, p.email
FROM people p
JOIN students s ON p.person_id = s.student_id
ORDER BY p.last_name ASC, p.first_name ASC;

-- Top 5 mejores notas de primera convocatoria
SELECT p.first_name, p.last_name, g.grade_value
FROM grades g
JOIN students s ON g.student_id = s.student_id
JOIN people p ON s.student_id = p.person_id
WHERE g.exam_call = 'Primera'
ORDER BY g.grade_value DESC
LIMIT 5;

-- Paginación: Página 2 (filas de la 11 a la 20)
SELECT person_id, dni, last_name, first_name
FROM people
ORDER BY person_id
LIMIT 10 OFFSET 10;
```

### Bloque G: Subconsultas
```sql
-- Alumnos cuya nota sea superior a la media general
SELECT p.first_name, p.last_name, g.grade_value
FROM grades g
JOIN students s ON g.student_id = s.student_id
JOIN people p ON s.student_id = p.person_id
WHERE g.grade_value > (SELECT AVG(grade_value) FROM grades);
```

---

## 📌 5. Conclusión del Lab 3

Con el dominio de **`SELECT`**, combinaciones **`JOIN`**, funciones de resumen y filtros agrupados **`HAVING`**, la base de datos `GradesDB` ya es capaz de resolver todos los requisitos funcionales de consulta del sistema universitario (**RF003 a RF008**).
