# ✅ LAB 2: Restricciones en Tablas (Integridad, CHECK, UNIQUE y Borrado en Cascada)

Este documento resume los fundamentos, las reglas de nomenclatura, los comandos DDL/DML y los casos de prueba ejecutados en el **Lab 2 (IISSI-1 - Universidad de Sevilla)**.

---

## 🎯 1. Objetivos del Laboratorio

* Aprender a blindar la base de datos implementando **Restricciones de Integridad Declarativas**.
* Dominar la sintaxis de **`CHECK`** para validar rangos numéricos, listas de valores permitidos, expresiones regulares y condiciones lógicas.
* Implementar **`UNIQUE`** para definir claves alternativas e impedir duplicados.
* Aprender la manipulación de datos existentes con **`UPDATE`** y **`DELETE`**.
* Comprender la **Integridad Referencial en el Borrado** (`RESTRICT`, `CASCADE`, `SET NULL`).

---

## 🏷️ 2. Convención de Nomenclatura Oficial (IISSI-1)

Para identificar con claridad qué regla se viola cuando MariaDB lanza un error, se sigue este estándar:

| Prefijo | Significado | Ejemplo |
| :--- | :--- | :--- |
| **`rnNN_`** | Implementa una Regla de Negocio numerada del catálogo | `rn12_people_age`, `rn14_people_dni`, `rn10_subjects_credits` |
| **`ck_`** | Validación de dominio (tipo enumerado o valor positivo) | `ck_professors_category`, `ck_groups_activity`, `ck_teaching_loads_credits` |
| **`rn_uq_`** | Restricción de unicidad (clave alternativa) | `rn_uq_people_dni`, `rn_uq_degrees_name`, `rn_uq_groups_name` |

---

## 💻 3. Código SQL de Restricciones (`createdb.sql`)

Todas estas restricciones se añadieron a la base de datos `GradesDB` mediante instrucciones `ALTER TABLE`:

```sql
ALTER TABLE people
    ADD CONSTRAINT rn12_people_age CHECK (age BETWEEN 16 AND 70),
    ADD CONSTRAINT rn14_people_dni CHECK (dni REGEXP '^[0-9]{8}[A-Za-z]$'),
    ADD CONSTRAINT rn_uq_people_dni UNIQUE (dni),
    ADD CONSTRAINT rn_uq_people_email UNIQUE (email);

ALTER TABLE professors
    ADD CONSTRAINT ck_professors_category CHECK (
        category IN ('Ayudante','AyudanteDoctor','Titular','Catedrático')
    );

ALTER TABLE students
    ADD CONSTRAINT ck_students_access_method CHECK (
        access_method IN ('Selectividad','Ciclo','Mayor','Titulado','Extranjero')
    );

ALTER TABLE degrees
    ADD CONSTRAINT rn13_degree_duration CHECK (duration_years BETWEEN 3 AND 6),
    ADD CONSTRAINT rn_uq_degrees_name UNIQUE (degree_name);

ALTER TABLE subjects
    ADD CONSTRAINT rn10_subjects_credits CHECK (credits IN (6, 12)),
    ADD CONSTRAINT rn16_subjects_course CHECK (course BETWEEN 1 AND 6),
    ADD CONSTRAINT ck_subjects_type CHECK (
        subject_type IN ('Formación Básica','Obligatoria','Optativa')
    ),
    ADD CONSTRAINT rn_uq_subjects_name UNIQUE (subject_name),
    ADD CONSTRAINT rn_uq_subjects_acronym UNIQUE (acronym);

ALTER TABLE groups
    ADD CONSTRAINT rn15_groups_year CHECK (academic_year BETWEEN 2000 AND 2100),
    ADD CONSTRAINT ck_groups_activity CHECK (
        activity IN ('Teoría','Laboratorio')
    ),
    ADD CONSTRAINT rn_uq_groups_name UNIQUE (subject_id, group_name, academic_year);

ALTER TABLE teaching_loads
    ADD CONSTRAINT ck_teaching_loads_credits CHECK (credits > 0);

ALTER TABLE grades
    ADD CONSTRAINT rn11_grades_value CHECK (grade_value BETWEEN 0 AND 10),
    ADD CONSTRAINT rn01_grades_with_honors CHECK (
        with_honors = 0 OR grade_value >= 9
    ),
    ADD CONSTRAINT rn18_grades_exam_call CHECK (
        exam_call IN ('Primera','Segunda','Tercera','Extraordinaria')
    );
```

---

## 🗑️ 4. Integridad Referencial en Borrado (`ON DELETE`)

¿Qué sucede con los datos dependientes cuando se borra un registro padre?

| Opción | Comportamiento | Uso en nuestro sistema |
| :--- | :--- | :--- |
| **`RESTRICT`** *(Por defecto)* | Impide el borrado si existen hijos que referencian al registro. | Se mantiene en `degrees ➔ subjects`: no se puede borrar un Grado si tiene asignaturas. |
| **`CASCADE`** | Borra automáticamente todos los registros dependientes. | Se aplica en `subjects ➔ groups`: al borrar una asignatura, sus grupos desaparecen en cascada. |
| **`SET NULL`** | Pone a `NULL` la clave ajena de los hijos (solo si la columna lo permite). | No aplicable aquí porque todas nuestras claves ajenas son `NOT NULL`. |

### Definición en `groups`:
```sql
CREATE TABLE groups (
    group_id INT AUTO_INCREMENT,
    subject_id INT NOT NULL,
    group_name VARCHAR(40) NOT NULL,
    activity VARCHAR(15) NOT NULL,
    academic_year YEAR NOT NULL,
    PRIMARY KEY (group_id),
    FOREIGN KEY (subject_id) REFERENCES subjects(subject_id) ON DELETE CASCADE
);
```

---

## ✏️ 5. Modificación y Borrado de Datos (`UPDATE` y `DELETE`)

### Sintaxis y Buenas Prácticas:
> [!WARNING]
> En entornos de producción y en MariaDB, **nunca ejecutes un `UPDATE` o `DELETE` sin la cláusula `WHERE`**, a menos que realmente desees alterar o vaciar toda la tabla.

```sql
UPDATE people 
SET email = 'nuevo.email@us.es' 
WHERE person_id = 1;

UPDATE professors 
SET category = 'Titular' 
WHERE category = 'AyudanteDoctor';

DELETE FROM grades 
WHERE grade_value < 5.0;
```

---

## 🧪 6. Pruebas de Validación Ejecutadas (Casos Negativos)

Las siguientes operaciones fueron probadas para verificar que MariaDB rechaza los datos erróneos:

```sql
INSERT INTO people (dni, first_name, last_name, age, email)
VALUES ('99999999Z', 'Juan', 'Test', 15, 'juan@test.es');

INSERT INTO grades (student_id, group_id, grade_value, exam_call, with_honors)
VALUES (6, 1, 8.5, 'Primera', 1);

INSERT INTO subjects (degree_id, subject_name, acronym, credits, course, subject_type)
VALUES (1, 'Asignatura Rara', 'RAR', 8, 1, 'Obligatoria');

INSERT INTO people (dni, first_name, last_name, age, email)
VALUES ('12345678', 'Pedro', 'SinLetra', 25, 'pedro@us.es');
```

---

## 📌 7. Conclusión del Lab 2

El esquema relacional `GradesDB` ahora cuenta con una capa de seguridad declarativa completa. Ninguna fila con valores fuera de los límites legales o con duplicados no autorizados puede ser insertada o modificada.
