/****************************
 * DELETE
 ****************************/
-- Run setup script.

SELECT *
FROM Demo.Person;

SELECT *
FROM Demo.PersonAddress;

-- Simple delete.
-- FROM is optional
DELETE FROM Demo.PersonAddress
WHERE PersonId = 2
   AND AddressTypeId = 2;

SELECT *
FROM Demo.PersonAddress;

-- Of course, you can delete multiple rows.
-- FROM is optional
DELETE Demo.PersonAddress
WHERE PersonId = 1;

SELECT *
FROM Demo.PersonAddress;

-- Can use subqueries if necessary.
DELETE Demo.PersonAddress
WHERE PersonId = 3
   AND AddressTypeId =
      (
         SELECT T.AddressTypeId
         FROM Demo.AddressType T
         WHERE T.[Name] = 'Work'
      );

SELECT *
FROM Demo.PersonAddress;

-- Can also delete all rows in the table.
-- First, rerun the setup script.
DELETE Demo.PersonAddress;

-- Delete persons where we have no address.
-- Or course this will be all, but another subquery example.
DELETE Demo.Person
WHERE NOT EXISTS
   (
      SELECT *
      FROM Demo.PersonAddress PA
      WHERE PA.PersonId = Person.PersonId
   );

/****************************
 * DELETE with FROM
 ****************************/

-- T-SQL supports non-standard form, allowing the full FROM element.
-- The FROM enables table aliasing.
-- Also, don't be confused by the standard FROM: "DELETE FROM P"
DELETE P
FROM Demo.Person P
WHERE NOT EXISTS
   (
      SELECT *
      FROM Demo.PersonAddress PA
      WHERE PA.PersonId = P.PersonId
   );

-- You can utilize the full FROM element, including
--    joins, derived tables, and CTEs.

-- Let's rerun the setup and use an earlier example rewritten with joins.
DELETE PA
FROM Demo.PersonAddress PA
   INNER JOIN Demo.AddressType T ON T.AddressTypeId = PA.AddressTypeId
WHERE PA.PersonId = 3
   AND T.[Name] = 'Work';


/****************************
 * TRUNCATE
 ****************************/
TRUNCATE TABLE Demo.PersonAddress;

-- It resets the identity value.
SELECT IDENT_CURRENT(N'Demo.PersonAddress');

-- It can only be used on tables with no foreign keys referencing it.
TRUNCATE TABLE Demo.Person;

-- It is minimally logged, which means it's fast!

/****************************
 * UPDATE
 ****************************/
-- Rerun setup.
SELECT *
FROM Demo.PersonAddress;

UPDATE Demo.PersonAddress
SET Line2 = N'Big Bird''s Nest'
WHERE PersonId = 2
   AND AddressTypeId = 2;

SELECT *
FROM Demo.PersonAddress;

-- Of course, you can update multiple rows and/or columns.
UPDATE Demo.PersonAddress
SET
   Line2 = NULL,
   City = N'The Little Apple',
   UpdatedOn = SYSDATETIMEOFFSET()
WHERE PersonId = 1;

SELECT *
FROM Demo.PersonAddress;

-- Can use subqueries if necessary.
UPDATE Demo.PersonAddress
SET
   AddressTypeId =
      (
         SELECT T.AddressTypeId
         FROM Demo.AddressType T
         WHERE T.[Name] = 'Home'
      ),
   UpdatedOn = SYSDATETIMEOFFSET()
WHERE PersonId = 3
   AND AddressTypeId =
      (
         SELECT T.AddressTypeId
         FROM Demo.AddressType T
         WHERE T.[Name] = 'Work'
      );

SELECT *
FROM Demo.PersonAddress;

-- Can also update all rows in the table.
UPDATE Demo.PersonAddress
SET UpdatedOn = SYSDATETIMEOFFSET();

SELECT *
FROM Demo.PersonAddress;


/****************************
 * UPDATE with FROM
 ****************************/

-- Rerun setup.

-- T-SQL supports non-standard form, allowing the full FROM element.
-- The FROM enables table aliasing.
UPDATE PA
SET
   AddressTypeId =
      (
         SELECT T.AddressTypeId
         FROM Demo.AddressType T
         WHERE T.[Name] = 'Home'
      ),
   UpdatedOn = SYSDATETIMEOFFSET()
FROM Demo.PersonAddress PA
   INNER JOIN Demo.Person P ON P.PersonId = PA.PersonId
   INNER JOIN Demo.AddressType OT ON OT.AddressTypeId = PA.AddressTypeId
WHERE P.FirstName = N'Fred'
   AND P.LastName = N'Rogers'
   AND OT.[Name] = 'Work';

-- You can utilize the full FROM element, including
--    joins, derived tables, and CTEs.


/****************************
 * UPDATE with assignment
 ****************************/
DECLARE @UpdatedOn DATETIMEOFFSET;

UPDATE PA
SET
   Line2 = NULL,
   @UpdatedOn = UpdatedOn = SYSDATETIMEOFFSET()
FROM Demo.PersonAddress PA
   INNER JOIN Demo.Person P ON P.PersonId = PA.PersonId
   INNER JOIN Demo.AddressType OT ON OT.AddressTypeId = PA.AddressTypeId
WHERE P.FirstName = N'John'
   AND P.LastName = N'Doe'
   AND OT.[Name] = 'Work';

SELECT @UpdatedOn AS NewUpdatedOn;
