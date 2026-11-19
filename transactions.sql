-- ============================================================================
-- LAB 7: Gestión de Transacciones SQL (IISSI-1 · Universidad de Sevilla)
-- Archivo: transactions.sql
-- ============================================================================

USE grades_db;

-- ----------------------------------------------------------------------------
-- 1. AUTOCOMMIT y START TRANSACTION
-- ----------------------------------------------------------------------------

-- Ejemplo 1.1: Con AUTOCOMMIT activado (por defecto)
-- START TRANSACTION agrupa las sentencias hasta COMMIT o ROLLBACK
CALL p_populate();
SET AUTOCOMMIT = 1;
START TRANSACTION;
INSERT INTO grades (student_id, group_id, grade_value, exam_call, with_honors) 
    VALUES (6, 1, 4.5, 'Extraordinaria', 0);
INSERT INTO grades (student_id, group_id, grade_value, exam_call, with_honors) 
    VALUES (7, 1, 7.5, 'Extraordinaria', 0);

SELECT @@in_transaction; -- Retorna 1: hay una transacción abierta
ROLLBACK; -- Deshace ambas inserciones

-- Comprobación: no queda ninguna nota tras el ROLLBACK
SELECT * FROM grades WHERE student_id IN (6, 7) AND exam_call = 'Extraordinaria';


-- Ejemplo 1.2: Con AUTOCOMMIT desactivado
-- La transacción empieza sola con la primera sentencia (no hace falta START TRANSACTION)
CALL p_populate();
SET AUTOCOMMIT = 0;
INSERT INTO grades (student_id, group_id, grade_value, exam_call, with_honors) 
    VALUES (6, 1, 4.5, 'Extraordinaria', 0);

SELECT @@in_transaction; -- Retorna 1: la transacción ha empezado sola con el INSERT
ROLLBACK; -- Deshace la inserción
SET AUTOCOMMIT = 1;

-- Comprobación: la nota fue descartada
SELECT * FROM grades WHERE student_id = 6 AND exam_call = 'Extraordinaria';


-- Ejemplo 1.3: Cuidado con START TRANSACTION anidado
-- START TRANSACTION con una transacción ya abierta la confirma (COMMIT implícito) antes de abrir la nueva
CALL p_populate();
SET AUTOCOMMIT = 0;
INSERT INTO grades (student_id, group_id, grade_value, exam_call, with_honors) 
    VALUES (6, 1, 4.5, 'Extraordinaria', 0);

START TRANSACTION; -- ¡Confirma implícitamente la inserción anterior!
ROLLBACK;          -- Solo deshace la transacción nueva (que está vacía)
SET AUTOCOMMIT = 1;

-- Comprobación: La nota SÍ quedó guardada porque el START TRANSACTION la confirmó
SELECT * FROM grades WHERE student_id = 6 AND exam_call = 'Extraordinaria';
