--
-- Autor: David Ruiz
-- Fecha: Octubre de 2026
-- Descripción: Función para calcular la nota media de un estudiante
-- Se incluye en: iissi1/labs/L5 (completo y en fragmentos)
--

USE grades_db;

-- Devuelve la nota media del alumno (0 si no tiene notas)
DELIMITER //
CREATE OR REPLACE FUNCTION f_student_average(
    p_student_id INT
) RETURNS DECIMAL(4,2)
BEGIN
    DECLARE v_average DECIMAL(4,2) DEFAULT 0;

    -- Sin notas, AVG devuelve NULL: COALESCE lo cambia por 0
    SELECT COALESCE(AVG(grade_value), 0) INTO v_average
    FROM grades
    WHERE student_id = p_student_id;

    RETURN v_average;
END //
DELIMITER ;
