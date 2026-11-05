# DBSEVILLA - Prácticas de Bases de Datos (IISSI-1)

Repositorio de laboratorios y proyectos de la asignatura **Introducción a la Ingeniería del Software y los Sistemas de Información I (IISSI-1)** de la **Universidad de Sevilla**.

---

## 📁 Estructura del Repositorio

* **`lab0/`**: Requisitos iniciales del sistema académico:
  * Catálogo de requisitos de información (RI001–RI006).
  * Reglas de negocio (RN001–RN017).
  * Requisitos funcionales (RF001–RF008) y no funcionales (RNF001).
  * Documento: [Lab 0 - Respuestas y Reglas](lab0/✅%20LAB0%20–%20Respostas%20completas%20e%20explicadas.md).
* **`lab1/`**: Creación de esquema físico y carga inicial:
  * Scripts DDL (`create_db.sql`) y DML (`populate_db.sql`).
  * Tablas intermedias: `students_groups` y `students_subjects`.
  * Base de datos: `grades_db`.
  * Documento: [Lab 1 - Esquema relacional y datos](lab1/✅%20LAB1%20–%20Esquema%20relacional%20y%20carga%20de%20datos.md).
* **`lab2/`**: Restricciones de integridad y seguridad de datos:
  * Restricciones `CHECK`, `UNIQUE`, tipos enumerados y borrado en cascada `ON DELETE CASCADE`.
  * Documento: [Lab 2 - Restricciones en tablas](lab2/✅%20LAB2%20–%20Restricciones%20en%20tablas.md).
* **`lab3/`**: Consultas SQL simples y avanzadas:
  * Consultas `SELECT`, filtros `WHERE`, uniones `JOIN`, agrupaciones `GROUP BY` y vistas `VIEW`.
  * Consultas completas en `queries.sql` y datos adicionales en `populate_db2.sql`.
* **`lab4/`**: Procedimientos almacenados y tests automatizados:
  * Procedimientos en `procedures.sql` y batería de pruebas declarativas en `tests_constraints.sql`.
  * Documento: [Lab 4 - Procedimientos y tests](lab4/✅%20LAB4%20–%20Procedimientos%20almacenados%20y%20Tests%20SQL.md).
* **`lab5/`**: Funciones y triggers SQL (Reglas de negocio procedurales):
  * Funciones en `functions.sql`, triggers en `triggers.sql` y batería completa de pruebas en `tests.sql`.
  * Documento: [Lab 5 - Funciones y triggers](lab5/✅%20LAB5%20–%20Funciones%20y%20triggers.md).
* **`lab6/`**: Framework Silence y APIs RESTful:
  * Instalación y configuración de Silence, seguridad RNF01 (`auth.sql`, `grants.sql`), usuarios/roles y endpoints personalizados.
  * Documento: [Lab 6 - Framework Silence](lab6/✅%20LAB6%20–%20Framework%20Silence.md).
* **`load_db.sql`**: Script orquestador maestro para cargar toda la base de datos en orden y ejecutar la suite de tests.
