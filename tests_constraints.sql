USE GradesDB;

DELIMITER //
CREATE OR REPLACE PROCEDURE p_populate()
BEGIN
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

    INSERT INTO professors (professor_id, category) VALUES
    (1,'Catedrático'),
    (2,'Titular'),
    (3,'AyudanteDoctor'),
    (4,'Titular'),
    (5,'Ayudante');

    INSERT INTO students (student_id, access_method) VALUES
    (6,'Selectividad'),
    (7,'Selectividad'),
    (8,'Selectividad'),
    (9,'Selectividad'),
    (10,'Selectividad'),
    (11,'Selectividad'),
    (12,'Selectividad'),
    (13,'Selectividad'),
    (14,'Ciclo'),
    (15,'Ciclo'),
    (16,'Ciclo'),
    (17,'Ciclo'),
    (18,'Mayor'),
    (19,'Mayor'),
    (20,'Titulado'),
    (21,'Titulado'),
    (22,'Extranjero'),
    (23,'Extranjero'),
    (24,'Extranjero'),
    (25,'Extranjero');

    INSERT INTO degrees (degree_id, degree_name, duration_years) VALUES
    (1,'Grado en Ingeniería del Software',4),
    (2,'Grado en Ingeniería de Computadores',4),
    (3,'Grado en Tecnologías Informáticas',4);

    INSERT INTO subjects (subject_id, degree_id, subject_name, acronym, credits, course, subject_type) VALUES
    (1,1,'Introducción a los Sistemas de Información','IISSI-1',6,1,'Formación Básica'),
    (2,1,'Diseño y Pruebas','DP',6,2,'Obligatoria'),
    (3,2,'Estructura de Computadores','EC',6,2,'Obligatoria'),
    (4,3,'Redes de Computadores','RC',6,2,'Obligatoria'),
    (5,1,'Gestión del Conocimiento','GC',6,4,'Optativa'),
    (6,2,'Robótica','ROB',6,4,'Optativa'),
    (7,3,'Inteligencia Artificial','IA',6,4,'Optativa'),
    (8,1,'Fundamentos de Programación','FP',12,1,'Formación Básica'),
    (9,2,'Circuitos Electrónicos','CE',6,1,'Formación Básica'),
    (10,3,'Programación Concurrente','PC',6,2,'Obligatoria'),
    (11,1,'Bases de Datos Avanzadas','BDA',6,3,'Obligatoria'),
    (12,2,'Arquitectura de Sistemas','AS',6,3,'Obligatoria'),
    (13,3,'Minería de Datos','MD',6,4,'Optativa'),
    (14,1,'Computación en la Nube','CN',6,4,'Optativa'),
    (15,2,'Cibersegurança de Redes','CR',6,4,'Optativa'),
    (16,3,'Visión por Computador','VC',6,4,'Optativa'),
    (17,1,'Proyecto Fin de Grado','PFG',12,4,'Obligatoria');

    INSERT INTO groups (group_id, subject_id, group_name, activity, academic_year) VALUES
    (1,1,'IISSI1-T1','Teoría',2024),
    (2,1,'IISSI1-L1','Laboratorio',2024),
    (3,1,'IISSI1-L2','Laboratorio',2024);

    INSERT INTO subject_enrollments (student_id, subject_id) VALUES
    (6,1),(7,1),(8,1),(9,1),(10,1),
    (11,1),(12,1),(13,1),(14,1),(15,1),
    (16,1),(17,1),(18,1),(19,1),(20,1);

    INSERT INTO group_enrollments (student_id, group_id) VALUES
    (6,1),(7,1),(8,1),(9,1),(10,1),
    (11,1),(12,1),(13,1),(14,1),(15,1),
    (16,1),(17,1),(18,1),(19,1),(20,1),
    (6,2),(7,2),(8,2),(9,2),(10,2),
    (11,3),(12,3),(13,3),(14,3),(15,3);

    INSERT INTO grades (grade_id, student_id, group_id, grade_value, exam_call, with_honors) VALUES
    (1,6,1,9.80,'Primera',0),
    (2,7,1,7.50,'Primera',0),
    (3,8,1,6.20,'Primera',0),
    (4,9,1,8.90,'Primera',0),
    (5,10,1,5.00,'Primera',0),
    (6,11,1,4.20,'Primera',0),
    (7,12,1,9.10,'Primera',0),
    (8,13,1,7.00,'Primera',0),
    (9,14,1,8.30,'Primera',0),
    (10,15,1,6.70,'Primera',0),
    (11,16,1,5.80,'Primera',0),
    (12,17,1,7.20,'Primera',0),
    (13,18,1,8.00,'Primera',0),
    (14,19,1,9.40,'Primera',0),
    (15,20,1,6.50,'Primera',0),
    (16,6,2,8.50,'Primera',0),
    (17,7,2,7.00,'Primera',0),
    (18,8,2,6.00,'Primera',0),
    (19,9,2,9.00,'Primera',0),
    (20,10,2,5.50,'Primera',0),
    (21,11,1,4.50,'Segunda',0),
    (22,12,1,9.50,'Segunda',0),
    (23,13,1,7.50,'Segunda',0),
    (24,14,1,8.70,'Segunda',0),
    (25,15,1,7.10,'Segunda',0),
    (26,6,1,9.90,'Extraordinaria',0),
    (27,7,1,8.00,'Extraordinaria',0),
    (28,8,1,6.50,'Extraordinaria',0),
    (29,9,1,9.20,'Extraordinaria',0),
    (30,10,1,6.00,'Extraordinaria',0),
    (31,11,3,5.00,'Primera',0),
    (32,12,3,8.80,'Primera',0),
    (33,13,3,7.30,'Primera',0),
    (34,14,3,8.10,'Primera',0),
    (35,15,3,6.90,'Primera',0);

    INSERT INTO teaching_loads (professor_id, group_id, credits) VALUES
    (1,1,3.0),
    (2,2,1.5),
    (3,3,1.5);
END //
DELIMITER ;

CREATE OR REPLACE TABLE test_results (
    test_id VARCHAR(20) PRIMARY KEY,
    test_name VARCHAR(200) NOT NULL,
    test_message VARCHAR(500) NOT NULL,
    test_status ENUM('PASS','FAIL','ERROR') NOT NULL,
    execution_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //
CREATE OR REPLACE PROCEDURE p_log_test(
    IN p_test_id VARCHAR(20),
    IN p_message VARCHAR(500),
    IN p_status ENUM('PASS','FAIL','ERROR')
)
BEGIN
    INSERT INTO test_results(test_id, test_name, test_message, test_status)
    VALUES (p_test_id, SUBSTRING_INDEX(p_message, ':', 1), p_message, p_status);
END //
DELIMITER ;

DELIMITER //
CREATE OR REPLACE PROCEDURE p_test_rn01_mh_requirement()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        CALL p_log_test('RN01', 'RN001: La MH requiere nota >= 9', 'PASS');

    CALL p_populate();

    UPDATE grades SET with_honors = 1 WHERE grade_id = 21;

    CALL p_log_test('RN01', 'ERROR: Se permitió MH con nota inferior a 9', 'FAIL');
END //
DELIMITER ;

DELIMITER //
CREATE OR REPLACE PROCEDURE p_test_rn09_not_null_attributes()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        CALL p_log_test('RN09', 'RN009: Los atributos obligatorios no pueden quedar a NULL', 'PASS');

    CALL p_populate();

    INSERT INTO people (person_id, dni, first_name, last_name, age, email)
        VALUES (103, '20000003C', NULL, 'Campos', 22, 'null@alum.us.es');

    CALL p_log_test('RN09', 'ERROR: Se permitió dejar atributos obligatorios a NULL', 'FAIL');
END //
DELIMITER ;

DELIMITER //
CREATE OR REPLACE PROCEDURE p_test_rn10_subject_credits()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        CALL p_log_test('RN10', 'RN010: Los créditos de una asignatura pueden ser 6 o 12', 'PASS');

    CALL p_populate();

    INSERT INTO subjects (subject_id, degree_id, subject_name, acronym, credits, course, subject_type)
        VALUES (31, 3, 'Asignatura Créditos Inválidos', 'ACI', 8, 2, 'Obligatoria');

    CALL p_log_test('RN10', 'ERROR: Se permitió una asignatura con créditos inválidos', 'FAIL');
END //
DELIMITER ;

DELIMITER //
CREATE OR REPLACE PROCEDURE p_test_rn11_grade_range()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        CALL p_log_test('RN11', 'RN011: La nota debe estar entre 0 y 10', 'PASS');

    CALL p_populate();

    INSERT INTO grades (grade_id, student_id, group_id, grade_value, exam_call, with_honors)
        VALUES (201, 6, 1, 11.0, 'Primera', 0);

    CALL p_log_test('RN11', 'ERROR: Se permitió una nota fuera de rango', 'FAIL');
END //
DELIMITER ;

DELIMITER //
CREATE OR REPLACE PROCEDURE p_test_rn12_people_age()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        CALL p_log_test('RN12', 'RN012: La edad de las personas debe estar entre 16 y 70', 'PASS');

    CALL p_populate();

    INSERT INTO people (person_id, dni, first_name, last_name, age, email)
        VALUES (105, '20000005E', 'Edad', 'Fuera', 80, 'edad@us.es');

    CALL p_log_test('RN12', 'ERROR: Se permitió una edad fuera de rango', 'FAIL');
END //
DELIMITER ;

DELIMITER //
CREATE OR REPLACE PROCEDURE p_test_rn13_degree_years()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        CALL p_log_test('RN13', 'RN013: Los grados deben tener entre 3 y 6 años', 'PASS');

    CALL p_populate();

    INSERT INTO degrees (degree_id, degree_name, duration_years)
        VALUES (10, 'Grado Experimental', 2);

    CALL p_log_test('RN13', 'ERROR: Se permitió un grado con años fuera de rango', 'FAIL');
END //
DELIMITER ;

DELIMITER //
CREATE OR REPLACE PROCEDURE p_test_rn14_dni_format()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        CALL p_log_test('RN14', 'RN014: El DNI debe tener 8 dígitos y una letra', 'PASS');

    CALL p_populate();

    INSERT INTO people (person_id, dni, first_name, last_name, age, email)
        VALUES (106, 'INVALIDO', 'DNI', 'Incorrecto', 30, 'dni@us.es');

    CALL p_log_test('RN14', 'ERROR: Se permitió un DNI con formato inválido', 'FAIL');
END //
DELIMITER ;

DELIMITER //
CREATE OR REPLACE PROCEDURE p_test_rn15_academic_year()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        CALL p_log_test('RN15', 'RN015: El año académico debe estar entre 2000 y 2100', 'PASS');

    CALL p_populate();

    INSERT INTO groups (group_id, subject_id, group_name, activity, academic_year)
        VALUES (20, 12, 'MD-T2025', 'Teoría', 1999);

    CALL p_log_test('RN15', 'ERROR: Se permitió un año académico fuera de rango', 'FAIL');
END //
DELIMITER ;

DELIMITER //
CREATE OR REPLACE PROCEDURE p_test_rn16_course_range()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
        CALL p_log_test('RN16', 'RN016: El curso de una asignatura debe estar entre 1 y 6', 'PASS');

    CALL p_populate();

    INSERT INTO subjects (subject_id, degree_id, subject_name, acronym, credits, course, subject_type)
        VALUES (30, 3, 'Asignatura Fuera de Curso', 'AFC', 6, 0, 'Obligatoria');

    CALL p_log_test('RN16', 'ERROR: Se permitió un curso fuera de rango', 'FAIL');
END //
DELIMITER ;

DELIMITER //
CREATE OR REPLACE PROCEDURE p_run_tests()
BEGIN
    DELETE FROM test_results;

    CALL p_test_rn01_mh_requirement();
    CALL p_test_rn09_not_null_attributes();
    CALL p_test_rn10_subject_credits();
    CALL p_test_rn11_grade_range();
    CALL p_test_rn12_people_age();
    CALL p_test_rn13_degree_years();
    CALL p_test_rn14_dni_format();
    CALL p_test_rn15_academic_year();
    CALL p_test_rn16_course_range();

    SELECT test_id, test_name, test_status, execution_time 
    FROM test_results 
    ORDER BY execution_time, test_id;

    SELECT test_status, COUNT(*) AS total 
    FROM test_results 
    GROUP BY test_status;
END //
DELIMITER ;

CALL p_run_tests();
