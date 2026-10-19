-- =========================================================================
-- BANCO DE DADOS: GradesDB (IISSI-1 - Universidad de Sevilla)
-- ARQUIVO: queries.sql
-- OBJETIVO: Consultas SQL e Treinamento com Fórmulas em Álgebra Relacional
-- =========================================================================
--
-- GUIA DE NOTAÇÃO EM ÁLGEBRA RELACIONAL (Padrão Acadêmico):
--   σ_{condição}(R)              : Seleção (filtro de tuplas / WHERE)
--   π_{atributos}(R)             : Projeção (seleção de colunas / SELECT DISTINCT)
--   ρ_{Novo}(R)                  : Renomeação de relação ou atributo (AS alias)
--   R ⨝_{condição} S             : Junção Theta / Condicional (INNER JOIN ... ON)
--   R ⨝ S                        : Junção Natural (Natural Join)
--   R ⟕_{condição} S             : Junção Externa Esquerda (LEFT OUTER JOIN)
--   R × S                        : Produto Cartesiano (FROM R, S)
--   R ∪ S, R ∩ S, R − S          : União, Interseção, Diferença de Conjuntos
--   R ÷ S                        : Divisão Relacional (consultas do tipo "para todos")
--   γ_{agrupamento, funções}(R)  : Agrupamento e Agregação (GROUP BY + COUNT/AVG/SUM/MAX/MIN)
--   σ_{cond_agregada}(γ(...))    : Filtro pós-agrupamento (HAVING)
--   τ_{critério}(R)              : Ordenação (ORDER BY)
--   λ_{n}(R) ou λ_{n, offset}(R) : Limitação e Deslocamento (LIMIT n OFFSET offset)
--
-- =========================================================================

USE GradesDB;

-- =========================================================================
-- BLOCO 1: CONSULTAS BÁSICAS, PROJEÇÃO E SELEÇÃO SIMPLES (RF004)
-- =========================================================================

-- -------------------------------------------------------------------------
-- Consulta 1: Listar todas as disciplinas cadastradas (todas as colunas).
-- Álgebra Relacional:
--   subjects
-- Explicação:
--   Retorna a relação inteira 'subjects' sem operadores de seleção ou projeção.
-- -------------------------------------------------------------------------
SELECT * FROM subjects;

-- -------------------------------------------------------------------------
-- Consulta 2: Buscar a disciplina com acrônimo específico ('IISSI-1').
-- Álgebra Relacional:
--   σ_{acronym = 'IISSI-1'}(subjects)
-- Explicação:
--   Operador de Seleção (σ) filtrando tuplas onde o atributo acronym é 'IISSI-1'.
-- -------------------------------------------------------------------------
SELECT * FROM subjects s WHERE s.acronym = 'IISSI-1';

-- -------------------------------------------------------------------------
-- Consulta 3: Projetar apenas o nome e o acrônimo de todas as disciplinas.
-- Álgebra Relacional:
--   π_{subject_name, acronym}(subjects)
-- Explicação:
--   Operador de Projeção (π) selecionando exclusivamente os atributos desejados.
-- -------------------------------------------------------------------------
SELECT s.subject_name, s.acronym FROM subjects s;

-- -------------------------------------------------------------------------
-- Consulta 4: Nome, acrônimo e tipo de disciplinas do tipo 'Formación Básica'.
-- Álgebra Relacional:
--   π_{subject_name, acronym, subject_type}(σ_{subject_type = 'Formación Básica'}(subjects))
-- Explicação:
--   Primeiro filtra as disciplinas básicas com Seleção (σ), depois projeta as colunas com Projeção (π).
-- -------------------------------------------------------------------------
SELECT s.subject_name, s.acronym, s.subject_type FROM subjects s WHERE s.subject_type = 'Formación Básica';


-- =========================================================================
-- BLOCO 2: COMBINAÇÕES DE TABELAS (JOIN) E VISTAS BÁSICAS (RF003, RF005)
-- =========================================================================

-- -------------------------------------------------------------------------
-- Consulta 5: Nome, sobrenome e via de acesso dos alunos de 'Selectividad'.
-- Álgebra Relacional:
--   π_{p.first_name, p.last_name, st.access_method}(
--       (σ_{st.access_method = 'Selectividad'}(students)) ⨝_{st.student_id = p.person_id} people
--   )
-- Passo a passo:
--   R1 ← σ_{access_method = 'Selectividad'}(students)
--   R2 ← R1 ⨝_{student_id = person_id} people
--   Resultado ← π_{first_name, last_name, access_method}(R2)
-- -------------------------------------------------------------------------
SELECT p.first_name, p.last_name, st.access_method
FROM students st
JOIN people p ON st.student_id = p.person_id
WHERE st.access_method = 'Selectividad';

-- -------------------------------------------------------------------------
-- Consulta 6: Nome, sobrenome e categoria dos professores com categoria 'Catedrático'.
-- Álgebra Relacional:
--   π_{p.first_name, p.last_name, pr.category}(
--       (σ_{pr.category = 'Catedrático'}(professors)) ⨝_{pr.professor_id = p.person_id} people
--   )
-- Passo a passo:
--   R1 ← σ_{category = 'Catedrático'}(professors)
--   R2 ← R1 ⨝_{professor_id = person_id} people
--   Resultado ← π_{first_name, last_name, category}(R2)
-- -------------------------------------------------------------------------
SELECT p.first_name, p.last_name, pr.category
FROM professors pr
JOIN people p ON pr.professor_id = p.person_id
WHERE pr.category = 'Catedrático';

-- -------------------------------------------------------------------------
-- Consulta 7: Definição da Vista de Professores (v_professors).
-- Álgebra Relacional:
--   v_professors ← π_{pr.professor_id, pr.category, p.person_id, p.dni, p.first_name, p.last_name, p.age, p.email}(
--       professors ⨝_{pr.professor_id = p.person_id} people
--   )
-- -------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_professors AS
SELECT pr.professor_id, pr.category, p.person_id, p.dni, p.first_name, p.last_name, p.age, p.email
FROM professors pr
JOIN people p ON pr.professor_id = p.person_id;

-- -------------------------------------------------------------------------
-- Consulta 8: Definição da Vista de Estudantes (v_students).
-- Álgebra Relacional:
--   v_students ← π_{st.student_id, st.access_method, p.person_id, p.dni, p.first_name, p.last_name, p.age, p.email}(
--       students ⨝_{st.student_id = p.person_id} people
--   )
-- -------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_students AS
SELECT st.student_id, st.access_method, p.person_id, p.dni, p.first_name, p.last_name, p.age, p.email
FROM students st
JOIN people p ON st.student_id = p.person_id;


-- =========================================================================
-- BLOCO 3: FUNÇÕES DE AGREGAÇÃO GLOBAIS (AVG, SUM, COUNT, MAX, MIN)
-- =========================================================================

-- -------------------------------------------------------------------------
-- Consulta 9: Nota média dos estudantes do grupo com ID = 1.
-- Álgebra Relacional (Álgebra Estendida - Operador de Agregação γ):
--   γ_{AVG(grade_value) → average_grade}(σ_{group_id = 1}(grades))
-- Explicação:
--   Filtra as notas do grupo 1 e aplica a função agregada de média aritmética.
-- -------------------------------------------------------------------------
SELECT AVG(g.grade_value) AS average_grade
FROM grades g
WHERE g.group_id = 1;

-- -------------------------------------------------------------------------
-- Consulta 10: Soma total dos créditos das disciplinas do grau com ID = 3.
-- Álgebra Relacional:
--   γ_{SUM(credits) → total_credits}(σ_{degree_id = 3}(subjects))
-- -------------------------------------------------------------------------
SELECT SUM(s.credits) AS total_credits
FROM subjects s
WHERE s.degree_id = 3;

-- -------------------------------------------------------------------------
-- Consulta 11: Contagem total de estudantes registrados.
-- Álgebra Relacional:
--   γ_{COUNT(*) → total_students}(students)
-- -------------------------------------------------------------------------
SELECT COUNT(*) AS total_students
FROM students;

-- -------------------------------------------------------------------------
-- Consulta 12: Contagem de turmas (grupos) agrupados pelo tipo de atividade.
-- Álgebra Relacional:
--   γ_{activity, COUNT(*) → total_groups}(groups)
-- Explicação:
--   O atributo 'activity' à esquerda de γ define o agrupamento (GROUP BY).
-- -------------------------------------------------------------------------
SELECT activity, COUNT(*) AS total_groups
FROM groups
GROUP BY activity;

-- -------------------------------------------------------------------------
-- Consulta 13: Maior nota cadastrada no sistema.
-- Álgebra Relacional:
--   γ_{MAX(grade_value) → max_grade}(grades)
-- -------------------------------------------------------------------------
SELECT MAX(g.grade_value) AS max_grade
FROM grades g;

-- -------------------------------------------------------------------------
-- Consulta 14: Menor nota cadastrada no sistema.
-- Álgebra Relacional:
--   γ_{MIN(grade_value) → min_grade}(grades)
-- -------------------------------------------------------------------------
SELECT MIN(g.grade_value) AS min_grade
FROM grades g;


-- =========================================================================
-- BLOCO 4: OPERADORES DE INTERVALO, PERTENÇA, DISTINÇÃO E PADRÃO
--          (BETWEEN, IN, DISTINCT, LIKE)
-- =========================================================================

-- -------------------------------------------------------------------------
-- Consulta 15: Notas menores que 5 (reprovados) ou maiores que 9 (excelentes).
-- Álgebra Relacional:
--   π_{grade_id, grade_value, exam_call}(σ_{grade_value < 5 ∨ grade_value > 9}(grades))
-- -------------------------------------------------------------------------
SELECT g.grade_id, g.grade_value, g.exam_call
FROM grades g
WHERE g.grade_value < 5 OR g.grade_value > 9;

-- -------------------------------------------------------------------------
-- Consulta 16: Notas compreendidas entre 5 e 7 (inclusive).
-- Álgebra Relacional:
--   π_{grade_id, grade_value, exam_call}(σ_{grade_value ≥ 5 ∧ grade_value ≤ 7}(grades))
-- -------------------------------------------------------------------------
SELECT g.grade_id, g.grade_value, g.exam_call
FROM grades g
WHERE g.grade_value BETWEEN 5 AND 7;

-- -------------------------------------------------------------------------
-- Consulta 17: Disciplinas cuja carga de créditos seja 6 ou 12.
-- Álgebra Relacional:
--   π_{subject_name, credits}(σ_{credits = 6 ∨ credits = 12}(subjects))
-- -------------------------------------------------------------------------
SELECT s.subject_name, s.credits
FROM subjects s
WHERE s.credits IN (6, 12);

-- -------------------------------------------------------------------------
-- Consulta 18: Pessoas com idade entre 20 e 30 anos (inclusive).
-- Álgebra Relacional:
--   π_{first_name, last_name, age}(σ_{age ≥ 20 ∧ age ≤ 30}(people))
-- -------------------------------------------------------------------------
SELECT p.first_name, p.last_name, p.age
FROM people p
WHERE p.age BETWEEN 20 AND 30;

-- -------------------------------------------------------------------------
-- Consulta 19: Nomes distintos de grupos cadastrados.
-- Álgebra Relacional:
--   π_{group_name}(groups)
-- Explicação:
--   Na álgebra relacional pura formal, a projeção (π) elimina duplicatas por definição de conjunto.
-- -------------------------------------------------------------------------
SELECT DISTINCT g.group_name
FROM groups g;

-- -------------------------------------------------------------------------
-- Consulta 20: Tipos distintos de disciplinas existentes.
-- Álgebra Relacional:
--   π_{subject_type}(subjects)
-- -------------------------------------------------------------------------
SELECT DISTINCT s.subject_type
FROM subjects s;

-- -------------------------------------------------------------------------
-- Consulta 21: Anos acadêmicos distintos dos grupos, em ordem decrescente.
-- Álgebra Relacional:
--   τ_{academic_year DESC}(π_{academic_year}(groups))
-- Explicação:
--   O operador τ (tau) representa a ordenação (ORDER BY) na álgebra relacional estendida.
-- -------------------------------------------------------------------------
SELECT DISTINCT g.academic_year
FROM groups g
ORDER BY g.academic_year DESC;

-- -------------------------------------------------------------------------
-- Consulta 22: Maior nota obtida pelo aluno com student_id = 6.
-- Álgebra Relacional:
--   γ_{MAX(grade_value) → max_grade}(σ_{student_id = 6}(grades))
-- -------------------------------------------------------------------------
SELECT MAX(g.grade_value) AS max_grade
FROM grades g
WHERE g.student_id = 6;

-- -------------------------------------------------------------------------
-- Consulta 23: Alunos matriculados em grupos do ano acadêmico de 2024 (Subconsulta IN).
-- Álgebra Relacional (Semijunção ⋉ ou Junção com Projeção):
--   π_{student_id}(group_enrollments ⨝_{ge.group_id = g.group_id} (σ_{academic_year = 2024}(groups)))
-- Equivalente com semijunção:
--   group_enrollments ⋉_{ge.group_id = g.group_id} (σ_{academic_year = 2024}(groups))
-- Passo a passo:
--   R1 ← σ_{academic_year = 2024}(groups)
--   R2 ← group_enrollments ⨝_{ge.group_id = R1.group_id} R1
--   Resultado ← π_{student_id}(R2)
-- -------------------------------------------------------------------------
SELECT DISTINCT ge.student_id
FROM group_enrollments ge
WHERE ge.group_id IN (
    SELECT g.group_id
    FROM groups g
    WHERE g.academic_year = 2024
);

-- -------------------------------------------------------------------------
-- Consulta 24: Disciplinas com créditos superiores à média geral de créditos.
-- Álgebra Relacional (Subconsulta Escalar via Produto Cartesiano ×):
--   π_{subject_name, credits}(
--       σ_{credits > avg_cred}(subjects × (γ_{AVG(credits) → avg_cred}(subjects)))
--   )
-- Passo a passo:
--   Media ← γ_{AVG(credits) → avg_cred}(subjects)
--   R1 ← subjects × Media
--   R2 ← σ_{credits > avg_cred}(R1)
--   Resultado ← π_{subject_name, credits}(R2)
-- -------------------------------------------------------------------------
SELECT s.subject_name, s.credits
FROM subjects s
WHERE s.credits > (
    SELECT AVG(credits)
    FROM subjects
);

-- -------------------------------------------------------------------------
-- Consulta 25: Pessoas cujo DNI termina com a letra 'A'.
-- Álgebra Relacional:
--   π_{first_name, last_name, dni}(σ_{dni LIKE '%A'}(people))
-- -------------------------------------------------------------------------
SELECT p.first_name, p.last_name, p.dni
FROM people p
WHERE p.dni LIKE '%A';

-- -------------------------------------------------------------------------
-- Consulta 26: Disciplinas cujo nome começa com 'Fundamentos'.
-- Álgebra Relacional:
--   π_{subject_name}(σ_{subject_name LIKE 'Fundamentos%'}(subjects))
-- -------------------------------------------------------------------------
SELECT s.subject_name
FROM subjects s
WHERE s.subject_name LIKE 'Fundamentos%';

-- -------------------------------------------------------------------------
-- Consulta 27: Pessoas cujo primeiro nome tem exatamente 5 letras.
-- Álgebra Relacional:
--   π_{first_name, last_name}(σ_{first_name LIKE '_____'}(people))
-- -------------------------------------------------------------------------
SELECT p.first_name, p.last_name
FROM people p
WHERE p.first_name LIKE '_____';

-- -------------------------------------------------------------------------
-- Consulta 28: Grupos ofertados no ano acadêmico de 2024.
-- Álgebra Relacional:
--   π_{group_name, activity, academic_year}(σ_{academic_year = 2024}(groups))
-- -------------------------------------------------------------------------
SELECT g.group_name, g.activity, g.academic_year
FROM groups g
WHERE g.academic_year = 2024;

-- -------------------------------------------------------------------------
-- Consulta 29: Grupos entre 2020 e 2023 ordenados cronologicamente.
-- Álgebra Relacional:
--   τ_{academic_year ASC}(π_{group_name, activity, academic_year}(
--       σ_{academic_year ≥ 2020 ∧ academic_year ≤ 2023}(groups)
--   ))
-- -------------------------------------------------------------------------
SELECT g.group_name, g.activity, g.academic_year
FROM groups g
WHERE g.academic_year BETWEEN 2020 AND 2023
ORDER BY g.academic_year;


-- =========================================================================
-- BLOCO 5: VISTAS AVANÇADAS DO SISTEMA ACADÊMICO
-- =========================================================================

-- -------------------------------------------------------------------------
-- Consulta 30: Vista de notas com Matrícula de Honra (v_grades_with_honors).
-- Álgebra Relacional:
--   v_grades_with_honors ← π_{grade_id, student_id, group_id, grade_value, exam_call}(
--       σ_{with_honors = 1}(grades)
--   )
-- -------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_grades_with_honors AS
SELECT g.grade_id, g.student_id, g.group_id, g.grade_value, g.exam_call
FROM grades g
WHERE g.with_honors = 1;

-- -------------------------------------------------------------------------
-- Consulta 31: Vista detalhada de notas de alunos (v_student_grades).
-- Álgebra Relacional:
--   R1 ← people ⨝_{person_id = student_id} students
--   R2 ← R1 ⨝_{students.student_id = grades.student_id} grades
--   R3 ← R2 ⨝_{grades.group_id = groups.group_id} groups
--   R4 ← R3 ⨝_{groups.subject_id = subjects.subject_id} subjects
--   v_student_grades ← π_{person_id, first_name, last_name, dni, grade_value, exam_call,
--                         with_honors, group_name, activity, academic_year, subject_name,
--                         acronym, credits}(R4)
-- -------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_student_grades AS
SELECT p.person_id, p.first_name, p.last_name, p.dni,
       g.grade_value, g.exam_call, g.with_honors,
       gr.group_name, gr.activity, gr.academic_year,
       s.subject_name, s.acronym, s.credits
FROM people p
JOIN students st ON p.person_id = st.student_id
JOIN grades g ON st.student_id = g.student_id
JOIN groups gr ON g.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id;

-- -------------------------------------------------------------------------
-- Consulta 32: Vista de cargas docentes de professores (v_professor_loads).
-- Álgebra Relacional:
--   R1 ← people ⨝_{person_id = professor_id} professors
--   R2 ← R1 ⨝_{professors.professor_id = teaching_loads.professor_id} teaching_loads
--   R3 ← R2 ⨝_{teaching_loads.group_id = groups.group_id} groups
--   R4 ← R3 ⨝_{groups.subject_id = subjects.subject_id} subjects
--   v_professor_loads ← π_{person_id, first_name, last_name, category,
--                          tl.credits → teaching_credits, group_name, activity,
--                          academic_year, subject_name, acronym}(R4)
-- -------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_professor_loads AS
SELECT p.person_id, p.first_name, p.last_name, pr.category,
       tl.credits AS teaching_credits,
       gr.group_name, gr.activity, gr.academic_year,
       s.subject_name, s.acronym
FROM people p
JOIN professors pr ON p.person_id = pr.professor_id
JOIN teaching_loads tl ON pr.professor_id = tl.professor_id
JOIN groups gr ON tl.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id;

-- -------------------------------------------------------------------------
-- Consulta 33: Vista de alunos matriculados por grau acadêmico (v_degree_students).
-- Álgebra Relacional:
--   R1 ← degrees ⨝_{degrees.degree_id = subjects.degree_id} subjects
--   R2 ← R1 ⨝_{subjects.subject_id = groups.subject_id} groups
--   R3 ← R2 ⨝_{groups.group_id = group_enrollments.group_id} group_enrollments
--   R4 ← R3 ⨝_{group_enrollments.student_id = students.student_id} students
--   R5 ← R4 ⨝_{students.student_id = people.person_id} people
--   v_degree_students ← π_{degree_id, degree_name, person_id, first_name, last_name, access_method, academic_year}(R5)
-- -------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_degree_students AS
SELECT DISTINCT d.degree_id, d.degree_name,
       p.person_id, p.first_name, p.last_name,
       st.access_method, gr.academic_year
FROM degrees d
JOIN subjects s ON d.degree_id = s.degree_id
JOIN groups gr ON s.subject_id = gr.subject_id
JOIN group_enrollments ge ON gr.group_id = ge.group_id
JOIN students st ON ge.student_id = st.student_id
JOIN people p ON st.student_id = p.person_id;

-- -------------------------------------------------------------------------
-- Consulta 34: Total de matrículas de honra concedidas (usando a vista).
-- Álgebra Relacional:
--   γ_{COUNT(*) → total_honors}(v_grades_with_honors)
-- -------------------------------------------------------------------------
SELECT COUNT(*) AS total_honors
FROM v_grades_with_honors;

-- -------------------------------------------------------------------------
-- Consulta 35: Média de notas por estudante a partir da vista consolidada.
-- Álgebra Relacional:
--   γ_{person_id, first_name, last_name, AVG(grade_value) → average_grade}(v_student_grades)
-- -------------------------------------------------------------------------
SELECT v.first_name, v.last_name, AVG(v.grade_value) AS average_grade
FROM v_student_grades v
GROUP BY v.person_id, v.first_name, v.last_name;


-- =========================================================================
-- BLOCO 6: ORDENAÇÃO (ORDER BY) E PAGINAÇÃO (LIMIT / OFFSET)
-- =========================================================================

-- -------------------------------------------------------------------------
-- Consulta 36: Listar notas em ordem crescente.
-- Álgebra Relacional:
--   τ_{grade_value ASC}(π_{grade_id, student_id, grade_value, exam_call}(grades))
-- -------------------------------------------------------------------------
SELECT g.grade_id, g.student_id, g.grade_value, g.exam_call
FROM grades g
ORDER BY g.grade_value ASC;

-- -------------------------------------------------------------------------
-- Consulta 37: Listar notas em ordem decrescente.
-- Álgebra Relacional:
--   τ_{grade_value DESC}(π_{grade_id, student_id, grade_value, exam_call}(grades))
-- -------------------------------------------------------------------------
SELECT g.grade_id, g.student_id, g.grade_value, g.exam_call
FROM grades g
ORDER BY g.grade_value DESC;

-- -------------------------------------------------------------------------
-- Consulta 38: As 5 maiores notas registradas no sistema (TOP 5).
-- Álgebra Relacional:
--   λ_{5}(τ_{grade_value DESC}(π_{grade_id, student_id, grade_value, exam_call}(grades)))
-- Explicação:
--   λ_{n} representa a operação de restrição/limite aos n primeiros registros ordenados.
-- -------------------------------------------------------------------------
SELECT g.grade_id, g.student_id, g.grade_value, g.exam_call
FROM grades g
ORDER BY g.grade_value DESC
LIMIT 5;

-- -------------------------------------------------------------------------
-- Consulta 39: Alunos aprovados (nota ≥ 5) em ordem alfabética de sobrenome e nome.
-- Álgebra Relacional:
--   τ_{last_name ASC, first_name ASC}(
--       π_{st.first_name, st.last_name, g.grade_value, g.exam_call}(
--           (σ_{grade_value ≥ 5}(grades)) ⨝_{g.student_id = st.student_id} v_students
--       )
--   )
-- -------------------------------------------------------------------------
SELECT st.first_name, st.last_name, g.grade_value, g.exam_call
FROM grades g
JOIN v_students st ON g.student_id = st.student_id
WHERE g.grade_value >= 5
ORDER BY st.last_name ASC, st.first_name ASC;

-- -------------------------------------------------------------------------
-- Consulta 40: Paginação: Página 2 das maiores notas (registros do 6º ao 10º).
-- Álgebra Relacional:
--   λ_{5, offset=5}(τ_{grade_value DESC}(π_{grade_id, student_id, grade_value}(grades)))
-- -------------------------------------------------------------------------
SELECT g.grade_id, g.student_id, g.grade_value
FROM grades g
ORDER BY g.grade_value DESC
LIMIT 5 OFFSET 5;

-- -------------------------------------------------------------------------
-- Consulta 41: Paginação: Página 3 das maiores notas (registros do 11º ao 15º).
-- Álgebra Relacional:
--   λ_{5, offset=10}(τ_{grade_value DESC}(π_{grade_id, student_id, grade_value}(grades)))
-- -------------------------------------------------------------------------
SELECT g.grade_id, g.student_id, g.grade_value
FROM grades g
ORDER BY g.grade_value DESC
LIMIT 5 OFFSET 10;

-- -------------------------------------------------------------------------
-- Consulta 42: Grupos ordenados por ano acadêmico decrescente e nome crescente.
-- Álgebra Relacional:
--   τ_{academic_year DESC, group_name ASC}(π_{group_name, activity, academic_year}(groups))
-- -------------------------------------------------------------------------
SELECT g.group_name, g.activity, g.academic_year
FROM groups g
ORDER BY g.academic_year DESC, g.group_name ASC;


-- =========================================================================
-- BLOCO 7: COMBINAÇÕES COMPLEXAS MULTI-TABELA (JOINs)
-- =========================================================================

-- -------------------------------------------------------------------------
-- Consulta 43: Estudantes e os respectivos grupos e atividades matriculados.
-- Álgebra Relacional:
--   π_{st.first_name, st.last_name, gr.group_name, gr.activity, gr.academic_year}(
--       v_students ⨝_{st.student_id = ge.student_id} group_enrollments ⨝_{ge.group_id = gr.group_id} groups
--   )
-- Passo a passo:
--   R1 ← v_students ⨝_{st.student_id = ge.student_id} group_enrollments
--   R2 ← R1 ⨝_{ge.group_id = gr.group_id} groups
--   Resultado ← π_{first_name, last_name, group_name, activity, academic_year}(R2)
-- -------------------------------------------------------------------------
SELECT st.first_name, st.last_name, gr.group_name, gr.activity, gr.academic_year
FROM v_students st
JOIN group_enrollments ge ON st.student_id = ge.student_id
JOIN groups gr ON ge.group_id = gr.group_id;

-- -------------------------------------------------------------------------
-- Consulta 44: Disciplinas com seus respectivos graus acadêmicos, ordenados por curso.
-- Álgebra Relacional:
--   τ_{degree_name ASC, course ASC}(
--       π_{degree_name, subject_name, acronym, credits, course, subject_type}(
--           degrees ⨝_{degrees.degree_id = subjects.degree_id} subjects
--       )
--   )
-- -------------------------------------------------------------------------
SELECT d.degree_name, s.subject_name, s.acronym, s.credits, s.course, s.subject_type
FROM degrees d
JOIN subjects s ON d.degree_id = s.degree_id
ORDER BY d.degree_name, s.course;

-- -------------------------------------------------------------------------
-- Consulta 45: Notas dos estudantes com nome da disciplina e ano acadêmico.
-- Álgebra Relacional:
--   R1 ← grades ⨝_{g.student_id = st.student_id} v_students
--   R2 ← R1 ⨝_{g.group_id = gr.group_id} groups
--   R3 ← R2 ⨝_{gr.subject_id = s.subject_id} subjects
--   Resultado ← π_{first_name, last_name, subject_name, acronym, grade_value, exam_call, academic_year}(R3)
-- -------------------------------------------------------------------------
SELECT st.first_name, st.last_name, s.subject_name, s.acronym,
       g.grade_value, g.exam_call, gr.academic_year
FROM grades g
JOIN v_students st ON g.student_id = st.student_id
JOIN groups gr ON g.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id;

-- -------------------------------------------------------------------------
-- Consulta 46: Carga docente detalhada de cada professor por grupo e disciplina.
-- Álgebra Relacional:
--   R1 ← v_professors ⨝_{pr.professor_id = tl.professor_id} teaching_loads
--   R2 ← R1 ⨝_{tl.group_id = gr.group_id} groups
--   R3 ← R2 ⨝_{gr.subject_id = s.subject_id} subjects
--   Resultado ← π_{first_name, last_name, category, subject_name, group_name, activity,
--                  tl.credits → teaching_credits}(R3)
-- -------------------------------------------------------------------------
SELECT pr.first_name, pr.last_name, pr.category,
       s.subject_name, gr.group_name, gr.activity,
       tl.credits AS teaching_credits
FROM v_professors pr
JOIN teaching_loads tl ON pr.professor_id = tl.professor_id
JOIN groups gr ON tl.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id;

-- -------------------------------------------------------------------------
-- Consulta 47: Disciplinas em que cada aluno está matriculado, sem repetições.
-- Álgebra Relacional:
--   τ_{last_name ASC, subject_name ASC}(
--       π_{first_name, last_name, subject_name, acronym, academic_year}(
--           v_students ⨝ group_enrollments ⨝ groups ⨝ subjects
--       )
--   )
-- -------------------------------------------------------------------------
SELECT DISTINCT st.first_name, st.last_name,
       s.subject_name, s.acronym, gr.academic_year
FROM v_students st
JOIN group_enrollments ge ON st.student_id = ge.student_id
JOIN groups gr ON ge.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id
ORDER BY st.last_name, s.subject_name;

-- -------------------------------------------------------------------------
-- Consulta 48: Junção externa (LEFT JOIN) listando todos os alunos e notas (inclui alunos sem nota).
-- Álgebra Relacional (Operador de Junção Externa Esquerda ⟕):
--   π_{st.first_name, st.last_name, g.grade_value, g.exam_call}(
--       v_students ⟕_{st.student_id = g.student_id} grades
--   )
-- Explicação:
--   O operador ⟕ preserva todas as tuplas de 'v_students', completando com nulos quando não há nota em 'grades'.
-- -------------------------------------------------------------------------
SELECT st.first_name, st.last_name, g.grade_value, g.exam_call
FROM v_students st
LEFT JOIN grades g ON st.student_id = g.student_id;


-- =========================================================================
-- BLOCO 8: AGRUPAMENTO (GROUP BY) E FILTROS DE GRUPO (HAVING)
-- =========================================================================

-- -------------------------------------------------------------------------
-- Consulta 49: Média de notas e contagem de avaliações por estudante.
-- Álgebra Relacional:
--   R1 ← v_students ⨝_{st.student_id = g.student_id} grades
--   Resultado ← γ_{st.student_id, st.first_name, st.last_name,
--                  AVG(grade_value) → average_grade, COUNT(*) → total_grades}(R1)
-- -------------------------------------------------------------------------
SELECT st.first_name, st.last_name,
       AVG(g.grade_value) AS average_grade,
       COUNT(*) AS total_grades
FROM v_students st
JOIN grades g ON st.student_id = g.student_id
GROUP BY st.student_id, st.first_name, st.last_name;

-- -------------------------------------------------------------------------
-- Consulta 50: Quantidade de estudantes agrupados por método de acesso.
-- Álgebra Relacional:
--   γ_{access_method, COUNT(*) → total_students}(students)
-- -------------------------------------------------------------------------
SELECT st.access_method, COUNT(*) AS total_students
FROM students st
GROUP BY st.access_method;

-- -------------------------------------------------------------------------
-- Consulta 51: Quantidade de disciplinas por grau acadêmico.
-- Álgebra Relacional:
--   R1 ← degrees ⨝_{degrees.degree_id = subjects.degree_id} subjects
--   Resultado ← γ_{d.degree_id, d.degree_name, COUNT(*) → total_subjects}(R1)
-- -------------------------------------------------------------------------
SELECT d.degree_name, COUNT(*) AS total_subjects
FROM degrees d
JOIN subjects s ON d.degree_id = s.degree_id
GROUP BY d.degree_id, d.degree_name;

-- -------------------------------------------------------------------------
-- Consulta 52: Quantidade de turmas/grupos criados para cada disciplina.
-- Álgebra Relacional:
--   R1 ← subjects ⨝_{s.subject_id = gr.subject_id} groups
--   Resultado ← γ_{s.subject_id, s.subject_name, s.acronym, COUNT(*) → total_groups}(R1)
-- -------------------------------------------------------------------------
SELECT s.subject_name, s.acronym, COUNT(*) AS total_groups
FROM subjects s
JOIN groups gr ON s.subject_id = gr.subject_id
GROUP BY s.subject_id, s.subject_name, s.acronym;

-- -------------------------------------------------------------------------
-- Consulta 53: Média de notas e total de avaliações por convocatória de exame.
-- Álgebra Relacional:
--   γ_{exam_call, AVG(grade_value) → average_grade, COUNT(*) → total_grades}(grades)
-- -------------------------------------------------------------------------
SELECT g.exam_call, AVG(g.grade_value) AS average_grade, COUNT(*) AS total_grades
FROM grades g
GROUP BY g.exam_call;

-- -------------------------------------------------------------------------
-- Consulta 54: Média e total de notas por disciplina e convocatória.
-- Álgebra Relacional:
--   R1 ← grades ⨝ groups ⨝ subjects
--   R2 ← γ_{s.subject_id, s.subject_name, g.exam_call,
--          AVG(grade_value) → average_grade, COUNT(*) → total_grades}(R1)
--   Resultado ← τ_{subject_name ASC, exam_call ASC}(π_{subject_name, exam_call, average_grade, total_grades}(R2))
-- -------------------------------------------------------------------------
SELECT s.subject_name, g.exam_call,
       AVG(g.grade_value) AS average_grade,
       COUNT(*) AS total_grades
FROM grades g
JOIN groups gr ON g.group_id = gr.group_id
JOIN subjects s ON gr.subject_id = s.subject_id
GROUP BY s.subject_id, s.subject_name, g.exam_call
ORDER BY s.subject_name, g.exam_call;

-- -------------------------------------------------------------------------
-- Consulta 55: Quantidade de alunos únicos matriculados por ano acadêmico.
-- Álgebra Relacional:
--   R1 ← groups ⨝_{gr.group_id = ge.group_id} group_enrollments
--   R2 ← γ_{academic_year, COUNT(DISTINCT student_id) → total_students}(R1)
--   Resultado ← τ_{academic_year DESC}(R2)
-- -------------------------------------------------------------------------
SELECT gr.academic_year, COUNT(DISTINCT ge.student_id) AS total_students
FROM groups gr
JOIN group_enrollments ge ON gr.group_id = ge.group_id
GROUP BY gr.academic_year
ORDER BY gr.academic_year DESC;

-- -------------------------------------------------------------------------
-- Consulta 56: Carga horária total de créditos lecionados por professor.
-- Álgebra Relacional:
--   R1 ← v_professors ⨝_{pr.professor_id = tl.professor_id} teaching_loads
--   Resultado ← γ_{pr.professor_id, pr.first_name, pr.last_name, pr.category,
--                  SUM(credits) → total_credits}(R1)
-- -------------------------------------------------------------------------
SELECT pr.first_name, pr.last_name, pr.category,
       SUM(tl.credits) AS total_credits
FROM v_professors pr
JOIN teaching_loads tl ON pr.professor_id = tl.professor_id
GROUP BY pr.professor_id, pr.first_name, pr.last_name, pr.category;

-- -------------------------------------------------------------------------
-- Consulta 57: Estudantes com média de notas superior a 7 (Cláusula HAVING).
-- Álgebra Relacional (Agrupamento com Seleção Pós-Agregação):
--   R1 ← v_students ⨝_{st.student_id = g.student_id} grades
--   R2 ← γ_{st.student_id, st.first_name, st.last_name, AVG(grade_value) → average_grade}(R1)
--   Resultado ← π_{first_name, last_name, average_grade}(σ_{average_grade > 7}(R2))
-- Explicação:
--   A cláusula HAVING equivale a uma Seleção (σ) aplicada após o agrupamento γ.
-- -------------------------------------------------------------------------
SELECT st.first_name, st.last_name,
       AVG(g.grade_value) AS average_grade
FROM v_students st
JOIN grades g ON st.student_id = g.student_id
GROUP BY st.student_id, st.first_name, st.last_name
HAVING AVG(g.grade_value) > 7;

-- -------------------------------------------------------------------------
-- Consulta 58: Disciplinas com mais de 3 turmas criadas (HAVING).
-- Álgebra Relacional:
--   R1 ← subjects ⨝_{s.subject_id = gr.subject_id} groups
--   R2 ← γ_{s.subject_id, s.subject_name, COUNT(*) → total_groups}(R1)
--   Resultado ← π_{subject_name, total_groups}(σ_{total_groups > 3}(R2))
-- -------------------------------------------------------------------------
SELECT s.subject_name, COUNT(*) AS total_groups
FROM subjects s
JOIN groups gr ON s.subject_id = gr.subject_id
GROUP BY s.subject_id, s.subject_name
HAVING COUNT(*) > 3;

-- -------------------------------------------------------------------------
-- Consulta 59: Grupos com mais de 15 alunos matriculados (HAVING).
-- Álgebra Relacional:
--   R1 ← groups ⨝_{gr.group_id = ge.group_id} group_enrollments
--   R2 ← γ_{gr.group_id, gr.group_name, gr.activity, COUNT(*) → total_students}(R1)
--   Resultado ← π_{group_name, activity, total_students}(σ_{total_students > 15}(R2))
-- -------------------------------------------------------------------------
SELECT gr.group_name, gr.activity, COUNT(*) AS total_students
FROM groups gr
JOIN group_enrollments ge ON gr.group_id = ge.group_id
GROUP BY gr.group_id, gr.group_name, gr.activity
HAVING COUNT(*) > 15;

-- -------------------------------------------------------------------------
-- Consulta 60: Disciplinas cuja nota média geral é maior que 5.5 (HAVING).
-- Álgebra Relacional:
--   R1 ← subjects ⨝ groups ⨝ grades
--   R2 ← γ_{s.subject_id, s.subject_name, AVG(grade_value) → average_grade, COUNT(*) → total_grades}(R1)
--   Resultado ← π_{subject_name, average_grade, total_grades}(σ_{average_grade > 5.5}(R2))
-- -------------------------------------------------------------------------
SELECT s.subject_name,
       AVG(g.grade_value) AS average_grade,
       COUNT(*) AS total_grades
FROM subjects s
JOIN groups gr ON s.subject_id = gr.subject_id
JOIN grades g ON gr.group_id = g.group_id
GROUP BY s.subject_id, s.subject_name
HAVING AVG(g.grade_value) > 5.5;

-- -------------------------------------------------------------------------
-- Consulta 61: TOP 3 disciplinas com mais alunos em 2024.
-- Álgebra Relacional:
--   R1 ← subjects ⨝ (σ_{academic_year = 2024}(groups)) ⨝ group_enrollments
--   R2 ← γ_{s.subject_id, s.subject_name, COUNT(DISTINCT student_id) → total_students}(R1)
--   R3 ← τ_{total_students DESC, subject_name ASC}(π_{subject_name, total_students}(R2))
--   Resultado ← λ_{3}(R3)
-- -------------------------------------------------------------------------
SELECT s.subject_name,
       COUNT(DISTINCT ge.student_id) AS total_students
FROM subjects s
JOIN groups gr ON s.subject_id = gr.subject_id
JOIN group_enrollments ge ON gr.group_id = ge.group_id
WHERE gr.academic_year = 2024
GROUP BY s.subject_id, s.subject_name
ORDER BY total_students DESC, s.subject_name ASC
LIMIT 3;

-- -------------------------------------------------------------------------
-- Consulta 62: Estudantes com mais de 1 Matrícula de Honra conquistada.
-- Álgebra Relacional:
--   R1 ← v_students ⨝_{st.student_id = g.student_id} (σ_{with_honors = 1}(grades))
--   R2 ← γ_{st.student_id, st.first_name, st.last_name, COUNT(*) → total_honors}(R1)
--   Resultado ← π_{first_name, last_name, total_honors}(σ_{total_honors > 1}(R2))
-- -------------------------------------------------------------------------
SELECT st.first_name, st.last_name,
       COUNT(*) AS total_honors
FROM v_students st
JOIN grades g ON st.student_id = g.student_id
WHERE g.with_honors = 1
GROUP BY st.student_id, st.first_name, st.last_name
HAVING COUNT(*) > 1;

-- -------------------------------------------------------------------------
-- Consulta 63: Total de alunos matriculados por grau acadêmico em 2024.
-- Álgebra Relacional:
--   R1 ← degrees ⨝ subjects ⨝ (σ_{academic_year = 2024}(groups)) ⨝ group_enrollments
--   R2 ← γ_{d.degree_id, d.degree_name, COUNT(DISTINCT student_id) → total_students}(R1)
--   Resultado ← τ_{total_students DESC}(π_{degree_name, total_students}(R2))
-- -------------------------------------------------------------------------
SELECT d.degree_name,
       COUNT(DISTINCT ge.student_id) AS total_students
FROM degrees d
JOIN subjects s ON d.degree_id = s.degree_id
JOIN groups gr ON s.subject_id = gr.subject_id
JOIN group_enrollments ge ON gr.group_id = ge.group_id
WHERE gr.academic_year = 2024
GROUP BY d.degree_id, d.degree_name
ORDER BY COUNT(DISTINCT ge.student_id) DESC;

-- -------------------------------------------------------------------------
-- Consulta 64: Maior nota alcançada por cada estudante, em ordem decrescente.
-- Álgebra Relacional:
--   R1 ← v_students ⨝_{st.student_id = g.student_id} grades
--   R2 ← γ_{st.student_id, st.first_name, st.last_name, MAX(grade_value) → max_grade}(R1)
--   Resultado ← τ_{max_grade DESC}(π_{first_name, last_name, max_grade}(R2))
-- -------------------------------------------------------------------------
SELECT st.first_name, st.last_name,
       MAX(g.grade_value) AS max_grade
FROM v_students st
JOIN grades g ON st.student_id = g.student_id
GROUP BY st.student_id, st.first_name, st.last_name
ORDER BY MAX(g.grade_value) DESC;

-- -------------------------------------------------------------------------
-- Consulta 65: Professores que lecionam em mais de um grupo diferente.
-- Álgebra Relacional:
--   R1 ← v_professors ⨝_{pr.professor_id = tl.professor_id} teaching_loads
--   R2 ← γ_{pr.professor_id, pr.first_name, pr.last_name, COUNT(DISTINCT group_id) → total_groups}(R1)
--   Resultado ← π_{first_name, last_name, total_groups}(σ_{total_groups > 1}(R2))
-- -------------------------------------------------------------------------
SELECT pr.first_name, pr.last_name,
       COUNT(DISTINCT tl.group_id) AS total_groups
FROM v_professors pr
JOIN teaching_loads tl ON pr.professor_id = tl.professor_id
GROUP BY pr.professor_id, pr.first_name, pr.last_name
HAVING COUNT(DISTINCT tl.group_id) > 1;

-- -------------------------------------------------------------------------
-- Consulta 66: Disciplinas pertencentes a graus com mais de 15 disciplinas.
-- Álgebra Relacional (Subconsulta IN com HAVING):
--   GrausMais15 ← π_{degree_id}(σ_{total > 15}(γ_{degree_id, COUNT(*) → total}(subjects)))
--   R1 ← subjects ⨝_{s.degree_id = d.degree_id} degrees
--   Resultado ← π_{subject_name, degree_name}(R1 ⨝_{d.degree_id = GrausMais15.degree_id} GrausMais15)
-- -------------------------------------------------------------------------
SELECT DISTINCT s.subject_name, d.degree_name
FROM subjects s
JOIN degrees d ON s.degree_id = d.degree_id
WHERE d.degree_id IN (
    SELECT degree_id
    FROM subjects
    GROUP BY degree_id
    HAVING COUNT(*) > 15
);


-- =========================================================================
-- BLOCO 9: DESAFIOS AVANÇADOS DO LAB 3 (SEÇÃO 5 DO GUIA TEÓRICO)
-- =========================================================================

-- -------------------------------------------------------------------------
-- Desafio 1: Estudantes que nunca foram reprovados (todas as notas ≥ 5).
-- Álgebra Relacional (via Agregação MIN):
--   R1 ← v_students ⨝_{st.student_id = g.student_id} grades
--   R2 ← γ_{st.student_id, st.first_name, st.last_name, MIN(grade_value) → min_nota}(R1)
--   Resultado ← π_{student_id, first_name, last_name}(σ_{min_nota ≥ 5}(R2))
-- Alternativa por Diferença de Conjuntos (−):
--   EstudantesComNotas ← π_{student_id, first_name, last_name}(v_students ⨝ grades)
--   EstudantesReprovados ← π_{student_id, first_name, last_name}(v_students ⨝ (σ_{grade_value < 5}(grades)))
--   Resultado ← EstudantesComNotas − EstudantesReprovados
-- -------------------------------------------------------------------------
SELECT st.student_id, st.first_name, st.last_name
FROM v_students st
JOIN grades g ON st.student_id = g.student_id
GROUP BY st.student_id, st.first_name, st.last_name
HAVING MIN(g.grade_value) >= 5;

-- -------------------------------------------------------------------------
-- Desafio 2: Professores que só lecionam teoria (nenhum grupo de laboratório).
-- Álgebra Relacional (Diferença de Conjuntos −):
--   ProfTeoria ← π_{professor_id, first_name, last_name}(
--       v_professors ⨝ teaching_loads ⨝ (σ_{activity = 'Teoría'}(groups))
--   )
--   ProfLab ← π_{professor_id, first_name, last_name}(
--       v_professors ⨝ teaching_loads ⨝ (σ_{activity = 'Laboratorio'}(groups))
--   )
--   Resultado ← ProfTeoria − ProfLab
-- -------------------------------------------------------------------------
SELECT pr.professor_id, pr.first_name, pr.last_name
FROM v_professors pr
JOIN teaching_loads tl ON pr.professor_id = tl.professor_id
JOIN groups gr ON tl.group_id = gr.group_id
GROUP BY pr.professor_id, pr.first_name, pr.last_name
HAVING SUM(gr.activity = 'Laboratorio') = 0;

-- -------------------------------------------------------------------------
-- Desafio 3: Disciplinas sem nenhum grupo criado (Anti-Junção / LEFT JOIN com IS NULL).
-- Álgebra Relacional:
--   Resultado ← π_{subject_id, subject_name}(σ_{group_id IS NULL}(subjects ⟕ groups))
-- Equivalente por Diferença (−):
--   Todas ← π_{subject_id, subject_name}(subjects)
--   ComGrupo ← π_{subject_id, subject_name}(subjects ⨝ groups)
--   Resultado ← Todas − ComGrupo
-- -------------------------------------------------------------------------
SELECT s.subject_id, s.subject_name
FROM subjects s
LEFT JOIN groups gr ON s.subject_id = gr.subject_id
WHERE gr.group_id IS NULL;

-- -------------------------------------------------------------------------
-- Desafio 4: Nota média de cada grau acadêmico no ano de 2024.
-- Álgebra Relacional:
--   R1 ← degrees ⨝ subjects ⨝ (σ_{academic_year = 2024}(groups)) ⨝ grades
--   Resultado ← γ_{d.degree_id, d.degree_name, AVG(grade_value) → average_grade}(R1)
-- -------------------------------------------------------------------------
SELECT d.degree_name, AVG(g.grade_value) AS average_grade
FROM degrees d
JOIN subjects s ON d.degree_id = s.degree_id
JOIN groups gr ON s.subject_id = gr.subject_id
JOIN grades g ON gr.group_id = g.group_id
WHERE gr.academic_year = 2024
GROUP BY d.degree_id, d.degree_name;

-- -------------------------------------------------------------------------
-- Desafio 5: Alunos com a maior nota de cada disciplina (Subconsulta Correlacionada).
-- Álgebra Relacional:
--   MaxPorAsig ← γ_{gr.subject_id, MAX(grade_value) → max_nota}(groups ⨝ grades)
--   TodasNotas ← π_{s.subject_id, s.subject_name, st.first_name, st.last_name, g.grade_value}(
--       subjects ⨝ groups ⨝ grades ⨝ v_students
--   )
--   Resultado ← π_{subject_name, first_name, last_name, grade_value}(
--       TodasNotas ⨝_{TodasNotas.subject_id = MaxPorAsig.subject_id ∧ grade_value = max_nota} MaxPorAsig
--   )
-- -------------------------------------------------------------------------
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

-- -------------------------------------------------------------------------
-- Desafio 6: Grupos ordenados pelo total de alunos matriculados (LEFT JOIN).
-- Álgebra Relacional:
--   R1 ← groups ⟕_{gr.group_id = ge.group_id} group_enrollments
--   R2 ← γ_{gr.group_id, gr.group_name, COUNT(ge.student_id) → total_students}(R1)
--   Resultado ← τ_{total_students DESC}(R2)
-- -------------------------------------------------------------------------
SELECT gr.group_id, gr.group_name, COUNT(ge.student_id) AS total_students
FROM groups gr
LEFT JOIN group_enrollments ge ON gr.group_id = ge.group_id
GROUP BY gr.group_id, gr.group_name
ORDER BY total_students DESC;

-- -------------------------------------------------------------------------
-- Desafio 7: Professores com carga docente superior a 15 créditos (HAVING).
-- Álgebra Relacional:
--   R1 ← v_professors ⨝_{pr.professor_id = tl.professor_id} teaching_loads
--   R2 ← γ_{pr.professor_id, pr.first_name, pr.last_name, SUM(credits) → total_credits}(R1)
--   Resultado ← π_{professor_id, first_name, last_name, total_credits}(σ_{total_credits > 15}(R2))
-- -------------------------------------------------------------------------
SELECT pr.professor_id, pr.first_name, pr.last_name, SUM(tl.credits) AS total_credits
FROM v_professors pr
JOIN teaching_loads tl ON pr.professor_id = tl.professor_id
GROUP BY pr.professor_id, pr.first_name, pr.last_name
HAVING SUM(tl.credits) > 15;

-- -------------------------------------------------------------------------
-- Desafio 8: Ano acadêmico com maior número de Matrículas de Honra.
-- Álgebra Relacional:
--   R1 ← (σ_{with_honors = 1}(grades)) ⨝_{g.group_id = gr.group_id} groups
--   R2 ← γ_{academic_year, COUNT(*) → total_honors}(R1)
--   Resultado ← λ_{1}(τ_{total_honors DESC}(R2))
-- -------------------------------------------------------------------------
SELECT gr.academic_year, COUNT(*) AS total_honors
FROM grades g
JOIN groups gr ON g.group_id = gr.group_id
WHERE g.with_honors = 1
GROUP BY gr.academic_year
ORDER BY total_honors DESC
LIMIT 1;

-- -------------------------------------------------------------------------
-- Desafio 9: Disciplinas com maior dispersão de notas (STDDEV).
-- Álgebra Relacional:
--   R1 ← subjects ⨝ groups ⨝ grades
--   R2 ← γ_{s.subject_id, s.subject_name, STDDEV(grade_value) → dispersion}(R1)
--   Resultado ← τ_{dispersion DESC}(π_{subject_name, dispersion}(R2))
-- -------------------------------------------------------------------------
SELECT s.subject_name, STDDEV(g.grade_value) AS dispersion
FROM subjects s
JOIN groups gr ON s.subject_id = gr.subject_id
JOIN grades g ON gr.group_id = g.group_id
GROUP BY s.subject_id, s.subject_name
ORDER BY dispersion DESC;

-- -------------------------------------------------------------------------
-- Desafio 10: Estudantes matriculados em TODAS as disciplinas de 1º curso.
-- Álgebra Relacional (Divisão Relacional Clássica ÷):
--   Asignaturas1Curso ← π_{subject_id}(σ_{course = 1}(subjects))
--   Matriculas1Curso ← π_{student_id, subject_id}(
--       group_enrollments ⨝ groups ⨝ (σ_{course = 1}(subjects))
--   )
--   AlunosComTodas ← Matriculas1Curso ÷ Asignaturas1Curso
--   Resultado ← π_{student_id, first_name, last_name}(AlunosComTodas ⨝ v_students)
-- Explicação:
--   A Divisão Relacional (R ÷ S) resolve consultas com quantificador universal "para todo / todas".
-- -------------------------------------------------------------------------
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