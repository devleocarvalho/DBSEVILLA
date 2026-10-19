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
CREATE OR REPLACE VIEW v_professors AS
SELECT p.person_id, p.dni, p.first_name, p.last_name, p.age, p.email, pr.category
FROM people p
JOIN professors pr ON p.person_id = pr.professor_id;

CREATE OR REPLACE VIEW v_students AS
SELECT p.person_id, p.dni, p.first_name, p.last_name, p.age, p.email, s.access_method
FROM people p
JOIN students s ON p.person_id = s.student_id;

CREATE OR REPLACE VIEW v_grades_with_honors AS
SELECT g.grade_id, p.first_name, p.last_name, s.subject_name, gr.group_name, g.grade_value, g.exam_call
FROM grades g
JOIN students st ON g.student_id = st.student_id
JOIN people p ON st.student_id = p.person_id
JOIN groups gr ON g.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id
WHERE g.with_honors = 1;

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
SELECT * FROM subjects;

SELECT * FROM subjects WHERE acronym = 'IISSI-1';

SELECT subject_name, credits FROM subjects;

SELECT * FROM subjects WHERE subject_type = 'Obligatoria';
```

### Bloque B: Combinaciones (`JOIN`)
```sql
SELECT p.first_name, p.last_name, s.access_method
FROM people p
JOIN students s ON p.person_id = s.student_id;

SELECT p.first_name, p.last_name, pr.category
FROM people p
JOIN professors pr ON p.person_id = pr.professor_id
WHERE pr.category = 'Titular';

SELECT d.degree_name, s.subject_name
FROM degrees d
LEFT JOIN subjects s ON d.degree_id = s.degree_id;
```

### Bloque C: Funciones de Agregación
```sql
SELECT AVG(grade_value) AS average_grade FROM grades;

SELECT SUM(credits) AS total_credits FROM subjects WHERE course = 2;

SELECT COUNT(*) AS total_students FROM students;

SELECT MAX(grade_value) AS max_grade, MIN(grade_value) AS min_grade FROM grades;
```

### Bloque D: Operadores `BETWEEN`, `IN`, `LIKE` y `DISTINCT`
```sql
SELECT first_name, last_name, age FROM people WHERE age BETWEEN 20 AND 30;

SELECT p.first_name, p.last_name, s.access_method
FROM people p
JOIN students s ON p.person_id = s.student_id
WHERE s.access_method IN ('Selectividad', 'Titulado');

SELECT acronym, subject_name FROM subjects WHERE subject_name LIKE '%Información%';

SELECT DISTINCT subject_type FROM subjects;
```

### Bloque E: Agrupaciones con `GROUP BY` y Filtro de Grupos con `HAVING`
> [!IMPORTANT]
> **Diferencia entre WHERE y HAVING:**
> * `WHERE`: Se evalúa fila por fila **antes** de realizar la agrupación. No admite funciones agregadas (`WHERE AVG(nota) > 5` es un error de sintaxis).
> * `HAVING`: Se evalúa sobre el resultado consolidado del grupo **después** de agrupar. Permite condiciones sobre agregados (`HAVING AVG(grade_value) >= 5.0`).

```sql
SELECT access_method, COUNT(*) AS total_alumnos
FROM students
GROUP BY access_method;

SELECT group_id, AVG(grade_value) AS nota_media
FROM grades
GROUP BY group_id;

SELECT group_id, AVG(grade_value) AS nota_media
FROM grades
GROUP BY group_id
HAVING AVG(grade_value) >= 5.0;

SELECT p.first_name, p.last_name, SUM(tl.credits) AS total_creditos
FROM teaching_loads tl
JOIN professors pr ON tl.professor_id = pr.professor_id
JOIN people p ON pr.professor_id = p.person_id
GROUP BY tl.professor_id, p.first_name, p.last_name
HAVING SUM(tl.credits) > 3.0;
```

### Bloque F: Ordenación y Paginación (`ORDER BY`, `LIMIT`, `OFFSET`)
```sql
SELECT p.last_name, p.first_name, p.email
FROM people p
JOIN students s ON p.person_id = s.student_id
ORDER BY p.last_name ASC, p.first_name ASC;

SELECT p.first_name, p.last_name, g.grade_value
FROM grades g
JOIN students s ON g.student_id = s.student_id
JOIN people p ON s.student_id = p.person_id
WHERE g.exam_call = 'Primera'
ORDER BY g.grade_value DESC
LIMIT 5;

SELECT person_id, dni, last_name, first_name
FROM people
ORDER BY person_id
LIMIT 10 OFFSET 10;
```

### Bloque G: Subconsultas
```sql
SELECT p.first_name, p.last_name, g.grade_value
FROM grades g
JOIN students s ON g.student_id = s.student_id
JOIN people p ON s.student_id = p.person_id
WHERE g.grade_value > (SELECT AVG(grade_value) FROM grades);
```

---

## 📌 5. Conclusión del Lab 3

Con el dominio de **`SELECT`**, combinaciones **`JOIN`**, funciones de resumen y filtros agrupados **`HAVING`**, la base de datos `GradesDB` ya es capaz de resolver todos los requisitos funcionales de consulta del sistema universitario (**RF003 a RF008**).


1. Estudiantes que nunca han suspendido (todas sus notas ≥ 5)
SELECT st.student_id, st.first_name, st.last_name
FROM v_students st
JOIN grades g ON st.student_id = g.student_id
GROUP BY st.student_id, st.first_name, st.last_name
HAVING MIN(g.grade_value) >= 5;

-- 2. Profesores que solo imparten teoría (no laboratorios)
SELECT pr.professor_id, pr.first_name, pr.last_name
FROM v_professors pr
JOIN teaching_loads tl ON pr.professor_id = tl.professor_id
JOIN groups gr ON tl.group_id = gr.group_id
GROUP BY pr.professor_id, pr.first_name, pr.last_name
HAVING SUM(gr.activity = 'L') = 0;

-- 3. Asignaturas sin grupos creados (usar LEFT JOIN)
SELECT s.subject_id, s.subject_name
FROM subjects s
LEFT JOIN groups gr ON s.subject_id = gr.subject_id
WHERE gr.group_id IS NULL;

-- 4. Nota media de cada grado en el año 2024
SELECT d.degree_name, AVG(g.grade_value) AS average_grade
FROM degrees d
JOIN subjects s ON d.degree_id = s.degree_id
JOIN groups gr ON s.subject_id = gr.subject_id
JOIN grades g ON gr.group_id = g.group_id
WHERE gr.academic_year = 2024
GROUP BY d.degree_id, d.degree_name;

-- 5. Estudiantes con la mejor nota de cada asignatura
SELECT s.subject_name, st.first_name, st.last_name, g.grade_value
FROM subjects s
JOIN groups gr ON s.subject_id = gr.subject_id
JOIN grades g ON gr.group_id = g.group_id
JOIN v_students st ON g.student_id = st.student_id
WHERE g.grade_value = (
    SELECT MAX(g2.grade_value)
    FROM groups gr2
    JOIN grades g2 ON gr2.group_id = g2.group_id
    WHERE gr2.subject_id = s.subject_id
);

-- 6. Grupos ordenados por número de estudiantes matriculados
SELECT gr.group_id, gr.group_name, COUNT(ge.student_id) AS total_students
FROM groups gr
LEFT JOIN group_enrollments ge ON gr.group_id = ge.group_id
GROUP BY gr.group_id, gr.group_name
ORDER BY total_students DESC;

-- 7. Profesores con carga docente superior a 15 créditos
SELECT pr.professor_id, pr.first_name, pr.last_name, SUM(tl.credits) AS total_credits
FROM v_professors pr
JOIN teaching_loads tl ON pr.professor_id = tl.professor_id
GROUP BY pr.professor_id, pr.first_name, pr.last_name
HAVING SUM(tl.credits) > 15;

-- 8. Año académico con más matrículas de honor
SELECT gr.academic_year, COUNT(*) AS total_honors
FROM grades g
JOIN groups gr ON g.group_id = gr.group_id
WHERE g.with_honors = 1
GROUP BY gr.academic_year
ORDER BY total_honors DESC
LIMIT 1;

-- 9. Asignaturas con mayor dispersión de notas (STD o VARIANCE)
SELECT s.subject_name, STDDEV(g.grade_value) AS dispersion
FROM subjects s
JOIN groups gr ON s.subject_id = gr.subject_id
JOIN grades g ON gr.group_id = g.group_id
GROUP BY s.subject_id, s.subject_name
ORDER BY dispersion DESC;

 10. Estudiantes matriculados en todas las asignaturas de primer curso
SELECT st.student_id, st.first_name, st.last_name
FROM v_students st
JOIN group_enrollments ge ON st.student_id = ge.student_id
JOIN groups gr ON ge.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id
WHERE s.course = 1
GROUP BY st.student_id, st.first_name, st.last_name
HAVING COUNT(DISTINCT s.subject_id) = (
    SELECT COUNT(*)
    FROM subjects
    WHERE course = 1
);
