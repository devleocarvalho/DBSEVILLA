USE GradesDB;

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

SELECT * FROM subjects;

SELECT * FROM subjects WHERE acronym = 'IISSI-1';

SELECT subject_name, credits FROM subjects;

SELECT * FROM subjects WHERE subject_type = 'Obligatoria';

SELECT p.first_name, p.last_name, s.access_method
FROM people p
JOIN students s ON p.person_id = s.student_id;

SELECT p.first_name, p.last_name, pr.category
FROM people p
JOIN professors pr ON p.person_id = pr.professor_id
WHERE pr.category = 'Titular';

SELECT AVG(grade_value) AS average_grade FROM grades;

SELECT SUM(credits) AS total_credits FROM subjects WHERE course = 2;

SELECT COUNT(*) AS total_students FROM students;

SELECT MAX(grade_value) AS max_grade, MIN(grade_value) AS min_grade FROM grades;

SELECT * FROM people WHERE age BETWEEN 20 AND 30;

SELECT p.first_name, p.last_name, s.access_method
FROM people p
JOIN students s ON p.person_id = s.student_id
WHERE s.access_method IN ('Selectividad', 'Titulado');

SELECT DISTINCT subject_type FROM subjects;

SELECT p.first_name, p.last_name, g.grade_value
FROM grades g
JOIN students s ON g.student_id = s.student_id
JOIN people p ON s.student_id = p.person_id
WHERE g.grade_value > (SELECT AVG(grade_value) FROM grades);

SELECT acronym, subject_name FROM subjects WHERE subject_name LIKE '%Información%';

SELECT d.degree_name, s.subject_name
FROM degrees d
LEFT JOIN subjects s ON d.degree_id = s.degree_id;

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
