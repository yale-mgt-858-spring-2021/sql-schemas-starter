# 

Ahoy! We're going to create a schema for school 🎓🏫. The schema will have
students, faculty, classes, grades, departments and such. You'll have to
make tables for each of these and those tables will have columns that must
be of certain types with certain constraints. It will be fun 😃.

It's also going to be a tough assignment! It will be different from all
the other assignments because there will be just a single `answer.sql`
file that you fill in. You'll have a bunch of `CREATE TABLE` statements
in there and other stuff.

Finally, there's *so many requirements* on this homework that there is
*bound to be* updates, particularly due to requirements that unclear.
So, please check the class website and slack for updates. Also, I hope
to release the grading code...but it's going to take me a bit to 
package it up.

Well...here we go. Accept [this GitHub Classroom invite](https://classroom.github.com/a/evwjW2B9)
and then tell me the URL of your repo through the class website.

* The class homework PostgreSQL database includes a schema with your name
  and you have full write permissions on it. I have one called `bald_chicken`.
  *I want you to create all your tables for this assignment in that schema.*
  But, I don't want you to prefix your tables when you create them. So, please
  don't do `CREATE TABLE bald_chicken.enrollments`. Instead, please make sure that
  `bald_chicken` (or whatever...*your* nickname) is in your `search_path` in your
  PostgreSQL client. Then, when you do `CREATE TABLE enrollments`, it will create
  that table in the first writable schema: your nickname schema. But, please make
  sure you're not setting `search_path` in your `answer.sql` file. That would be
  a pain for me 🤣.
* Add a tabled called `departments` in the schema with your class nickname (e.g., `bald_chicken`).  It should have at least three columns: `id`, `name`, and `abbreviation`.
* `id` should be an [`IDENTITY` primary key](https://www.postgresqltutorial.com/postgresql-identity-column/)
  generated by default always. (Here's a freebie, it's `id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY`.)
  Here's a good point for me to tell you that you should make your code
  "idempotent" such that running it multiple times is fine and doesn't
  give rise to errors. So, when you create the `departments` table, it's best to do
  it [like I do in the solutions](https://gist.github.com/kljensen/a9494d036180deb1a766293249e56db9),
  where you drop the table first. 
* `name` and `abbreviation` should be text. They may not be null and
  must be unique. See [PostgreSQL constraints](https://www.postgresql.org/docs/9.4/ddl-constraints.html).
  `name` should be fewer than 100 characters.
* `abbreviation` must be upper case and either three or four letters in length. You can `CHECK` this
   a few different ways. If you want to use a regex, this one is good: `'^[A-Z]{3,4}$'`. You could
   also check `UPPER(abbreviation) = abbreviation` 😎.
* Add the following departments to the database
  (I should mention 
  at this point that my tests are run only at the end of your code so you can 
  do data entry like this at the end, after creating your schema, if you want
  to do so. It doesn't matter.)
  * `Management`, `MGT`
  * `Computer Science`, `CPSC`
  * `Drama`, `DRAM`
* Add a table called `roles` with at least two columns: `id` and `name`.
  * `id` should be an `IDENTITY` primary key
    generated by default always.
  * `name` should be text. It may not be null and
    it must be unique. It should be lowercase and be more than zero but fewer than 25 characters.
* Create a role with name "faculty" and role with name "student".
* Add a `users` table.  The table should have the following columns
  * `name`, a text field that may not be null and must have a length of
    more than 0 characters and fewer than 100.
  * `netid`, a text primary key. Must have a length greater than 2 and fewer than 10 characters
    and must be all lower case letters and numbers. It must begin with a letter.
    The regex I used in my solutions is `'^[a-z][a-z0-9]{2,9}$')`.
  * `email`, a text field that may not be null, must be a valid email address,
    and must be unique. It should be more than zero but fewer than 100 characters.
    Here is what [my email column in the solutions](https://gist.github.com/kljensen/8a140ab947ed09db0563a62f55f53a22) looks like.
  * `updated_at` of type `timestamp with time zone` (that's `timestamptz`) which may not be null and defaults to `NOW()`.
  * `role_id`, a foreign key to the `id` column in the `roles` table that
    may not be null. (Unless I say otherwise, you don't need to add any condition
    to handle [cascading deletes or updates](https://kb.objectrocket.com/postgresql/how-to-use-the-postgresql-delete-cascade-1369)
    on foreign keys.
    There are _no tests of cascading deletes or updates_ in the grading code.)
* Create a [trigger](https://www.postgresqltutorial.com/postgresql-triggers/) that will 
  set the `updated_at` column of a row in users to `now()` whenever the row is updated.
  As with table creation, make sure this is idempotent. Use `CREATE OR REPLACE FUNCTION` and
  `DROP TRIGGER IF EXISTS` (Google it 😎) accomplish that, otherwise you're going to 
  get errors when you rerun your `answer.sql` SQL. This is a [common pattern](https://x-team.com/blog/automatic-timestamps-with-postgresql/).
* Please add the following students to the user table. (Please try to do this "properly",
  by not hard-coding the `role_id`, you might think about using 
  the so-called "insert into select" form 
  to accomplish the `INSERT`. But, I'm not going to check how you do it 😉.)
  * Kwame Abara, `ka234`, `kwame.abara@yale.edu`
  * Hua Zhi Ruo, `hzr98`, `zhirho.hua@yale.edu`
  * Magnus Hansen, `mh99`, `magnus.hansen@yale.edu`
  * Saanvi Ahuja, `ska299`, `saanvi.ahuja@yale.edu`
  * Isabella Torres, `ift12`, `isabella.torres@yale.edu`
* Please add the following faculty to the user table
  * Kyle Jensen, `klj39`, `kyle.jensen@yale.edu`
  * Judy Chevalier, `jc288`, `judith.chevalier@yale.edu`
  * Huang Zeqiong, `zh44`, `zeqiong.huang@yale.edu`
* Add a `terms` table. The table should have three columns.
  * `id` should be an `IDENTITY` primary key
    generated by default always.
  * `label` should be of type `TEXT` and not null, more than three
    and fewer than 20 characters in length.
  * `dates` of type `DATERANGE` that may not be null. (Checkout the [daterange](https://www.postgresql.org/docs/9.3/rangetypes.html) 
    rangetype documentation)
  * The table should have a so-called ["exclusion constraint"](https://www.postgresql.org/docs/9.1/sql-createtable.html)
    such that no two terms have `dates` that overlap. (I should remind you
    at this point that this is just an example database. Obviously, we have
    terms at Yale that do overlap, like Spring and Spring II! 
    A better example use of a exclusion constraint would be something like
    an AirBnb rental. Or, I could have asked you to design a table that
    holds student schedules and you could have used an exclusion constraint
    to prohibit students from being in two classes that meet at the same
    time. You could even say something like "student classes need to be
    15 minutes apart". All that said, I thought this example was enough
    to familiarize you with the concept.)
* Add the following `terms` to the database. It does not matter if the last
  date is included or not (you know...open set, closed set...it doesn't matter
  because I won't test on the margins of your ranges).
  * "Spring 2021", 2021-01-19 - 2021-05-13
  * "Fall 2021", 2021-08-01 - 2021-12-13
* Create a `courses` table with the following columns
  * `id` should be an `IDENTITY` primary key
    generated by default always.
  * `department_id` a foreign key to `departments(id)`, not null.
  * `number` an INT, not null, greater than 99 and less than 1000.
  * `name` TEXT greater than 5 characters and fewer than 100, not null
  * `faculty_netid` a foreign key to a `users(netid)` not null.
  * `term_id` a foreign key to a `terms(id)` not null
* Ensure that a course can only be offered once per term. That is, 
  `term_id`, `department_id`, and `number` should be jointly unique
  using a constraint on the table.
* Add the following courses, again, please don't assume that you know
  numeric primary keys 🤓. That is, when do you do the insert, you shouldn't
  assume you know the primary key for the "Spring 2021" term is "5" or whatever.
  * "Apps, Programming, and Entrepreneurship", "CPSC-213" taught in "Spring 2021" by "klj39"  (Kyle)
  * "Strategic Management of Nonprofit Organizations", "MGT-527" taught in "Fall 2021" by  "jc288" (Judy)
* Add a table `enrollments` with the following colums
  * `id` should be an `IDENTITY` primary key
    generated by default always.
  * `course_id` a foreign key to `courses(id)`, not null
  * `student_netid` a foreign key to `users(netid)`, not null
  * `grade`, a TEXT field, either null or A-F with +/- except, at Yale, there's no A+, F+, or F-.
    You can write this `CHECK` long form easily using `OR`s, or you can use a regex. I used
    this `CHECK` in the solutions: `(grade ~ '[ABCDF][+-]?' AND grade !~ '(A\+|F\+|F\-)')`.
* Ensure that a student can only be added to a course once. That is, `student_netid` and `course_id`
  should be unique using a constraint on the table.
* Add the following students to Kyle's course
  * Kwame Abara, `ka234`, grade "A"
  * Hua Zhi Ruo, `hzr98`, grade "A"
* Add the following students to Judy's course
  * Hua Zhi Ruo, `hzr98`, grade "A"
  * Magnus Hansen, `mh99`, grade "A" (There are only A's at Yale 😜✊)
* Create a view called `roster` that joins the necessary tables to
  show a summary of which students are registered for what courses. Order the
  results by term dates, department, course number, and student name.
  `SELECT * FROM roster` should return the following results. The
  _order of the rows does not matter_.

  ```
  │    term     │    department    │ course_number │     name      │         email          │
  ├─────────────┼──────────────────┼───────────────┼───────────────┼────────────────────────┤
  │ Spring 2021 │ Computer Science │           213 │ Hua Zhi Ruo   │ zhirho.hua@yale.edu    │
  │ Spring 2021 │ Computer Science │           213 │ Kwame Abara   │ kwame.abara@yale.edu   │
  │ Fall 2021   │ Management       │           527 │ Hua Zhi Ruo   │ zhirho.hua@yale.edu    │
  │ Fall 2021   │ Management       │           527 │ Magnus Hansen │ magnus.hansen@yale.edu │
  ```

## Edits

### Thu Apr  8 13:39:20 EDT 2021
  
* Double check all the places where I say "fewer than X" characters. The solutions use
  `<` and `>` and not `<=` and `>=`.
* Fix misspelling: `timestampz` should be `timestamptz`.
* Add note about foreign key update/delete cascading.
* Note that the `daterange` for `terms` can be inclusive or exclusive of the
  ends. It doesn't matter.
* Added all the regexes that I used to the problem statement so people don't spend
  hours Googling regexes. You can Google other stuff for hours 🤣!

### Thu Apr  8 14:37:00 EDT 2021
* Course `name` not null

### Sun Apr 11 14:16:09 EDT 2021
* Add link to example trigger function for timestamps
  



## Suggested order

We suggest you complete the questions in the following order

- [ ] 00-schema-test


As you complete questions, you can mark them as complete
in this Markdown file,  but you don't have to do so.
See [this example](https://github.blog/2014-04-28-task-lists-in-all-markdown-documents/).

