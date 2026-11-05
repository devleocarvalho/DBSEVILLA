USE grades_db;

DELIMITER //

CREATE OR REPLACE PROCEDURE p_delete_student_grades(
    IN p_student_dni CHAR(9)
)
BEGIN
    DECLARE v_student_id INT;

    SELECT student_id INTO v_student_id
    FROM people p
    JOIN students s ON s.student_id = p.person_id
    WHERE p.dni = p_student_dni;

    DELETE FROM grades WHERE student_id = v_student_id;
END //

CREATE OR REPLACE PROCEDURE p_delete_all_data()
BEGIN

    DELETE FROM grades;
    DELETE FROM teaching_loads;
    DELETE FROM students_groups;
    DELETE FROM students_subjects;
    DELETE FROM groups;
    DELETE FROM subjects;
    DELETE FROM students;
    DELETE FROM professors;
    DELETE FROM degrees;
    DELETE FROM people;
END //

CREATE OR REPLACE PROCEDURE p_student_average(
    IN p_student_id INT,
    OUT p_average DECIMAL(4,2)
)
BEGIN
    SELECT AVG(grade_value) INTO p_average
    FROM grades
    WHERE student_id = p_student_id;
END //

CREATE OR REPLACE PROCEDURE p_boost_group_grades(
    IN p_group_id INT,
    IN p_exam_call VARCHAR(20)
)
BEGIN
    DECLARE v_affected_rows INT;
    DECLARE v_group_name VARCHAR(40);

    SELECT group_name INTO v_group_name
    FROM groups
    WHERE group_id = p_group_id;

    UPDATE grades

    SET grade_value = LEAST(grade_value * 1.15, 10.0)
    WHERE group_id = p_group_id
      AND exam_call = p_exam_call
      AND grade_value BETWEEN 4.5 AND 8.0;

    SET v_affected_rows = ROW_COUNT();

    SELECT v_group_name AS group_name,
           v_affected_rows AS updated_grades;
END //

CREATE OR REPLACE PROCEDURE p_assign_honors(
    IN p_group_id INT,
    IN p_exam_call VARCHAR(20)
)
BEGIN
    DECLARE v_total_students INT;
    DECLARE v_max_honors INT;

    SELECT COUNT(*) INTO v_total_students
    FROM students_groups
    WHERE group_id = p_group_id;

    SET v_max_honors = FLOOR(v_total_students * 0.05);

    IF v_max_honors = 0 THEN
        SELECT CONCAT('No se pueden asignar matrículas de honor: ',
                      'el 5% de ', v_total_students,
                      ' estudiantes matriculados es 0') AS mensaje;
    ELSE

        UPDATE grades
        SET with_honors = 0
        WHERE group_id = p_group_id
          AND exam_call = p_exam_call;

        UPDATE grades
        SET with_honors = 1
        WHERE grade_id IN (
            SELECT selected_grades.grade_id
            FROM (
                SELECT grade_id
                FROM grades
                WHERE group_id = p_group_id
                  AND exam_call = p_exam_call
                  AND grade_value >= 9.0
                ORDER BY grade_value DESC
                LIMIT v_max_honors
            ) AS selected_grades
        );
    END IF;
END //

CREATE OR REPLACE PROCEDURE p_insert_degree_subject(
    IN p_degree_name VARCHAR(80),
    IN p_degree_years TINYINT,
    IN p_subject_name VARCHAR(120),
    IN p_subject_acronym VARCHAR(12),
    IN p_subject_credits TINYINT,
    IN p_subject_course TINYINT,
    IN p_subject_type VARCHAR(30)
)
BEGIN
    DECLARE v_new_degree_id INT;

    INSERT INTO degrees (degree_name, duration_years)
    VALUES (p_degree_name, p_degree_years);

    SET v_new_degree_id = LAST_INSERT_ID();

    INSERT INTO subjects (degree_id, subject_name, acronym, credits, course, subject_type)
    VALUES (v_new_degree_id, p_subject_name, p_subject_acronym,
            p_subject_credits, p_subject_course, p_subject_type);
END //

CREATE OR REPLACE PROCEDURE p_insert_degree_subject_transactional(
    IN p_degree_name VARCHAR(80),
    IN p_degree_years TINYINT,
    IN p_subject_name VARCHAR(120),
    IN p_subject_acronym VARCHAR(12),
    IN p_subject_credits TINYINT,
    IN p_subject_course TINYINT,
    IN p_subject_type VARCHAR(30)
)
BEGIN

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    CALL p_insert_degree_subject(p_degree_name, p_degree_years,
                                 p_subject_name, p_subject_acronym,
                                 p_subject_credits, p_subject_course, p_subject_type);

    COMMIT;
END //

DELIMITER ;
