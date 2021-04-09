

-- Start transaction and plan the tests.
BEGIN;

\set ON_ERROR_ROLLBACK 1
\set ON_ERROR_STOP false

SELECT plan(90);

-- Execute and silently ignore all exceptions
CREATE OR REPLACE FUNCTION yolo_execute (stmt TEXT )
RETURNS VOID AS $$
BEGIN
    EXECUTE stmt;
EXCEPTION WHEN others THEN
END
$$ LANGUAGE plpgsql;


------------------------
-- DEPARTMENTS
------------------------

SELECT has_table(
    'departments',
    'the "departments" table exists'
);

SELECT col_is_pk(
    'departments',
    'id',
    'departments `id` column is a primary key'
);

SELECT col_not_null(
    'departments',
    name
) FROM (VALUES ('id'), ('name'), ('abbreviation')) as columns(name);


SELECT col_is_unique( 'departments', ARRAY['name' ] );
SELECT col_is_unique( 'departments', ARRAY['abbreviation' ] );



SELECT yolo_execute(
    $$DELETE FROM departments WHERE name = 'foobar123'$$
);

SELECT throws_like(
    format($$
        INSERT INTO departments (name, abbreviation) VALUES ('foobar123', '%s');
    $$, abbrev),
    '%check%',
    format($$department abbreviation should not accept invalid value "%s"$$, abbrev)
) from (values ('F'), ('f'), ('ffff'), ('FFFFFF'), ('sdf82'), ('3'), (''), ('fff'), ('FFFFF') ) as bad_abbreviations(abbrev);

SELECT yolo_execute(
    $$DELETE FROM departments WHERE abbreviation = 'FOOX'$$
);
SELECT throws_like(
    format($$
        INSERT INTO departments (name, abbreviation) VALUES ('%s', 'FOOX');
    $$, val),
    '%check%',
    format($$department name should not accept invalid value "%s"$$, val)
) from (values (''), (repeat('x', 101))) as bad_values(val);

SELECT lives_ok(
    $$
        INSERT INTO departments(name, abbreviation) VALUES ('Foo bar', 'FOO');
    $$,
    $$the departments table should accept valid new department ('Foo bar', 'FOO')$$
);


SELECT set_eq(
    $$
        SELECT count(*) FROM departments WHERE abbreviation IN ('MGT', 'CPSC', 'DRAM')
    $$,
    ARRAY[3],
    'the departments table includes MGT, CPSC, and DRAM'
);

------------------------
-- ROLES
------------------------

SELECT col_not_null(
    'roles',
    'name',
    'roles `name` column may not be NULL'
);


SELECT has_table(
    'roles',
    'the "roles" tables exists'
);

SELECT col_is_pk(
    'roles',
    'id',
    'roles `id` column is a primary key'
);

SELECT col_not_null(
    'roles',
    name
) FROM (VALUES ('id'), ('name')) as columns(name);


SELECT col_is_unique( 'roles', ARRAY['name' ] );



SELECT throws_like(
    format($$
        INSERT INTO roles (name) VALUES ('%s');
    $$, val),
    '%check%',
    format($$roles name should not accept invalid value "%s"$$, val)
) from (values (''), ('FOO'), (repeat('x', 26))) as bad_values(val);

SELECT set_eq(
    $$
        SELECT count(*) FROM roles WHERE name IN ('faculty', 'student')
    $$,
    ARRAY[2],
    'the roles table includes faculty and students'
);


------------------------
-- USERS
------------------------

SELECT has_table(
    'users'
);

SELECT col_is_pk(
    'users',
    'netid'
);

SELECT col_not_null(
    'users',
    'name'
);

SELECT fk_ok(
    'users',
    'role_id',
    'roles',
    'id'
);

SELECT col_not_null(
    'users',
    'role_id'
);

SELECT yolo_execute(
    $$DELETE FROM users WHERE netid='foo234'$$
);

SELECT throws_like(
    format($$
        INSERT INTO users(role_id, name, email, netid)
        select
            id,
            'Kyle foo',
            '%s',
            'foo234'
        from
        roles where name='student'
    $$, val),
    '%check%',
    format($$users(email) should not accept invalid value "%s"$$, val)
) from (values (''), ('FOO'), ('foo@bar'), ('@badmail'), ('kyle@' || repeat('x', 100) || '.com')) as bad_values(val);


SELECT yolo_execute(
    $$DELETE FROM users WHERE netid='foo234'$$
);
SELECT throws_like(
    format($$
        INSERT INTO users(role_id, name, email, netid)
        select
            id,
            'Kyle foo',
            'kyle@bar.com',
            '%s'
        from
        roles where name='student'
    $$, val),
    '%check%',
    format($$users(netid) should not accept invalid value "%s"$$, val)
) from (values (''), ('FOO'), (repeat('x', 11)), ('@badmail'), ('kyle@' || repeat('x', 100) || '.com')) as bad_values(val);


SELECT set_eq(
    $$
        SELECT netid
        FROM users u
        JOIN roles r
        ON u.role_id = r.id
        WHERE netid IN ('ka234', 'hzr98', 'mh99', 'ska299');
    $$,
    ARRAY['ka234', 'hzr98', 'mh99', 'ska299'],
    'the users tables has our four students'
);

SELECT set_eq(
    $$
        SELECT netid
        FROM users u
        JOIN roles r
        ON u.role_id = r.id
        WHERE netid IN ('klj39', 'jc288', 'zh44');
    $$,
    ARRAY[ 'klj39', 'jc288', 'zh44' ],
    'the users tables has our three faculty'
);

SELECT col_type_is(
    'users',
    'updated_at',
    'timestamp with time zone'
);

SELECT col_not_null(
    'users',
    'updated_at'
);

SELECT set_eq(
    $$
        WITH timestamps AS (
            UPDATE
                users
            SET
                email = email
            RETURNING
                updated_at
        )
        SELECT
            timestamps.updated_at = now()
        FROM
            timestamps;
    $$,
    ARRAY[ TRUE ],
    'users.updated_at is automatically changed via a trigger upon update'
);

------------------------
-- TERMS
------------------------


SELECT has_table(
    'terms'
);

SELECT col_is_pk(
    'terms',
    'id'
);

SELECT col_not_null(
    'terms',
    'label'
);

SELECT col_not_null(
    'terms',
    'dates'
);


SELECT throws_like(
    format($$
        INSERT INTO terms(label, dates)
        VALUES
            ('%s',
            daterange('1841/01/01', '1841/06/01', '[]'))
    $$, val),
    '%check%',
    format($$terms(label) should not accept invalid value "%s"$$, val)
) from (values (''), (repeat('x', 21))) as bad_values(val);

SELECT yolo_execute(
    $$DELETE FROM terms
    WHERE dates && daterange('1888/01/01', '1888/12/31', '[]')$$
);

SELECT throws_like(
    $$
        INSERT INTO terms(label, dates)
        VALUES 
            ('foo bar 1', daterange('1888/01/01', '1888/07/31', '[]')) ,
            ('foo bar 1', daterange('1888/04/01', '1888/12/31', '[]'))
    $$,
    '%constraint%',
    'terms(date) does not permit overlaps in dates'
);

SELECT lives_ok(
    $$
        INSERT INTO terms(label, dates)
        VALUES 
            ('Spring 1888', daterange('1888/01/01', '1888/07/31', '[]'))
    $$,
    $$terms(label, dates) accepts valid row ('Spring 1888', daterange('1888/01/01', '1888/07/31', '[]'))$$
);

SELECT yolo_execute(
    $$DELETE FROM terms
    WHERE dates && daterange('1888/01/01', '1888/12/31', '[]')$$
);

SELECT set_eq(
    $$
        SELECT label from terms where label IN ('Spring 2021', 'Fall 2021')
    $$,
    ARRAY['Spring 2021', 'Fall 2021'],
    'terms includes rows for Spring 2021 and Fall 2021'
);

------------------------
-- COURSES
------------------------


SELECT has_table(
    'courses'
);

SELECT col_is_pk(
    'courses',
    'id'
);

SELECT col_not_null(
    'courses',
    col
) from (values
    ('department_id'),
    ('number'),
    ('name'),
    ('term_id')
) as cols(col);


SELECT fk_ok(
    'courses',
    col,
    fk_table,
    fk_table_col
) from (values
    ('department_id', 'departments', 'id'),
    ('faculty_netid', 'users', 'netid'),
    ('term_id', 'terms', 'id')
) as fks(col, fk_table, fk_table_col);


SELECT col_is_unique( 'courses', ARRAY['term_id', 'department_id', 'number'] );


SELECT yolo_execute(
    $$DELETE FROM courses WHERE "number" = 759$$
);

SELECT throws_like(
    format($$
        INSERT INTO
            courses (term_id, department_id, faculty_netid, name, "number")
        VALUES (
            (select id from terms ORDER BY RANDOM() LIMIT 1),
            (select id from departments ORDER BY RANDOM() LIMIT 1),
            (select netid from users ORDER BY RANDOM() LIMIT 1),
            '%s',
            759
        );
    $$, name),
    '%check%',
    format($$courses(name) should not accept invalid value "%s"$$, name)
) from (values ('fffff'), (repeat('F', 101)) ) as bad_name(name);


SELECT throws_like(
    format($$
        INSERT INTO
            courses (term_id, department_id, faculty_netid, name, "number")
        VALUES (
            (select id from terms ORDER BY RANDOM() LIMIT 1),
            (select id from departments ORDER BY RANDOM() LIMIT 1),
            (select netid from users ORDER BY RANDOM() LIMIT 1),
            'New course name',
            %s
        );
    $$, num),
    '%check%',
    format($$courses(number) should not accept invalid value "%s"$$, num)
) from (values (1001), (0), (-15), (95) ) as bad_numbers(num);


------------------------
-- ENROLLMENTS
------------------------


SELECT has_table(
    'enrollments'
);

SELECT col_is_pk(
    'enrollments',
    'id'
);

SELECT col_not_null(
    'enrollments',
    col
) from (values
    ('student_netid'),
    ('course_id')
) as cols(col);


SELECT fk_ok(
    'enrollments',
    col,
    fk_table,
    fk_table_col
) from (values
    ('student_netid', 'users', 'netid'),
    ('course_id', 'courses', 'id')
) as fks(col, fk_table, fk_table_col);


SELECT col_is_unique( 'enrollments', ARRAY['student_netid', 'course_id'] );

SELECT throws_like(
    format($$
        INSERT INTO
            enrollments (course_id, student_netid, grade)
        VALUES (
            (select id from courses ORDER BY RANDOM() LIMIT 1),
            (select netid from users ORDER BY RANDOM() LIMIT 1),
            '%s'
        );
    $$, grade),
    '%check%',
    format($$enrollments(grade) should not accept invalid value "%s"$$, grade)
) from (values ('A+'), ('F-'), ('F+'), ('b'), ('Z'), ('ZZZZ'), ('Q+')) as bad_grades(grade);


SELECT set_has(
    $$
    SELECT
        student_netid
    FROM
        enrollments
        JOIN courses ON courses.id = course_id
    WHERE
        grade = 'A'
        AND (faculty_netid = 'klj39'
            AND student_netid IN ('hzr98', 'ka234'))
        OR (faculty_netid = 'jc288'
            AND student_netid IN ('hzr98', 'mh99'));
    $$,
    $$select * from (values ('ka234'), ('hzr98'), ('mh99') ) as netids(student_netid)$$,
    $$Kwami and Zhi Rho are in Kyle's class; Zhi Rho and Magnus are in Judy's class$$
);

-- Finish the tests and clean up.
SELECT * FROM finish();
ROLLBACK;
