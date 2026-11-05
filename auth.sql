USE grades_db;

CREATE OR REPLACE TABLE credentials (
  person_id INT PRIMARY KEY,
  password  VARCHAR(128) NOT NULL,
  role      VARCHAR(10),
  CONSTRAINT fk_credentials_person FOREIGN KEY (person_id)
    REFERENCES people (person_id) ON DELETE CASCADE,
  CONSTRAINT ck_credentials_rnf01_role CHECK (role IN ('admin', 'teacher', 'student'))
);

INSERT INTO credentials (person_id, password) VALUES
  (1, 'druiz'),
  (2, 'inmahernandez'),
  (3, 'fsola'),
  (4, 'dayala1'),
  (5, 'pepecalderon'),
  (6, 'david.romero'),
  (7, 'lucia.molina'),
  (8, 'hugo.paredes'),
  (9, 'sara.campos'),
  (10, 'mario.galan'),
  (11, 'elena.torres'),
  (12, 'ruben.duran'),
  (13, 'claudia.soto'),
  (14, 'ivan.cuesta'),
  (15, 'noelia.rey'),
  (16, 'pablo.vidal'),
  (17, 'alicia.munoz'),
  (18, 'sergio.izquierdo'),
  (19, 'nerea.saiz'),
  (20, 'alvaro.leon'),
  (21, 'julia.benito'),
  (22, 'tomas.rubio'),
  (23, 'irene.salas'),
  (24, 'alex.delgado'),
  (25, 'paula.bermejo');

UPDATE credentials SET role = 'student'
  WHERE person_id IN (SELECT student_id FROM students);

UPDATE credentials SET role = 'teacher'
  WHERE person_id IN (SELECT professor_id FROM professors);

UPDATE credentials SET role = 'admin' WHERE person_id = 1;
