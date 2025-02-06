/*****************************
 * UNION
 *****************************/

-- All email addresses for customers.
SELECT P.EmailAddress
FROM Sales.Customers C
   INNER JOIN [Application].People P ON P.PersonID = C.PrimaryContactPersonID

UNION

SELECT P.EmailAddress
FROM Sales.Customers C
   INNER JOIN [Application].People P ON P.PersonID = C.AlternateContactPersonID
ORDER BY EmailAddress ASC;

-- UNION has an implied DISTINCT operator
-- Compare with UNION ALL


/*****************************
 * INTERSECT
 *****************************/

 -- Email addresses that are both primary and alternate contacts.
SELECT P.EmailAddress
FROM Sales.Customers C
   INNER JOIN [Application].People P ON P.PersonID = C.PrimaryContactPersonID

INTERSECT

SELECT P.EmailAddress
FROM Sales.Customers C
   INNER JOIN [Application].People P ON P.PersonID = C.AlternateContactPersonID
ORDER BY EmailAddress ASC;


-- Work around for INTERSECT ALL
-- ORDER BY (SELECT 0) simply means the order doesn't matter.
SELECT
   ROW_NUMBER() OVER(
      PARTITION BY P.EmailAddress
      ORDER BY (SELECT 0) ASC) AS RowID,
   P.EmailAddress
FROM Sales.Customers C
   INNER JOIN [Application].People P ON P.PersonID = C.PrimaryContactPersonID

INTERSECT

SELECT
   ROW_NUMBER() OVER(
      PARTITION BY P.EmailAddress
      ORDER BY (SELECT 0) ASC) AS RowID,
   P.EmailAddress
FROM Sales.Customers C
   INNER JOIN [Application].People P ON P.PersonID = C.AlternateContactPersonID
ORDER BY EmailAddress ASC;

-- Of course if you don't want to return the RowID,
--    you can use a table expression.
WITH IntersectAllCte(RowID, EmailAddress) AS
   (
      SELECT
         ROW_NUMBER() OVER(
            PARTITION BY P.EmailAddress
            ORDER BY (SELECT 0) ASC) AS RowID,
         P.EmailAddress
      FROM Sales.Customers C
         INNER JOIN [Application].People P ON P.PersonID = C.PrimaryContactPersonID

      INTERSECT

      SELECT
         ROW_NUMBER() OVER(
            PARTITION BY P.EmailAddress
            ORDER BY (SELECT 0) ASC) AS RowID,
         P.EmailAddress
      FROM Sales.Customers C
         INNER JOIN [Application].People P ON P.PersonID = C.AlternateContactPersonID
   )
SELECT IA.EmailAddress
FROM IntersectAllCte IA
ORDER BY IA.EmailAddress ASC;


/*****************************
 * EXCEPT - Difference
 *****************************/
 -- Email addresses that are primary contacts, but not alternate contacts.
SELECT P.EmailAddress
FROM Sales.Customers C
   INNER JOIN [Application].People P ON P.PersonID = C.PrimaryContactPersonID

EXCEPT

SELECT P.EmailAddress
FROM Sales.Customers C
   INNER JOIN [Application].People P ON P.PersonID = C.AlternateContactPersonID
ORDER BY EmailAddress ASC;


-- Work around for EXCEPT ALL
SELECT
   ROW_NUMBER() OVER(
      PARTITION BY P.EmailAddress
      ORDER BY (SELECT 0) ASC) AS RowID,
   P.EmailAddress
FROM Sales.Customers C
   INNER JOIN [Application].People P ON P.PersonID = C.PrimaryContactPersonID

EXCEPT

SELECT
   ROW_NUMBER() OVER(
      PARTITION BY P.EmailAddress
      ORDER BY (SELECT 0) ASC) AS RowID,
   P.EmailAddress
FROM Sales.Customers C
   INNER JOIN [Application].People P ON P.PersonID = C.AlternateContactPersonID
ORDER BY EmailAddress ASC;


-- Of course if you don't want to return the RowID,
--    you can use a table expression.
WITH ExceptAllCte(RowID, EmailAddress) AS
   (
      SELECT
         ROW_NUMBER() OVER(
            PARTITION BY P.EmailAddress
            ORDER BY (SELECT 0) ASC) AS RowID,
         P.EmailAddress
      FROM Sales.Customers C
         INNER JOIN [Application].People P ON P.PersonID = C.PrimaryContactPersonID

      EXCEPT

      SELECT
         ROW_NUMBER() OVER(
            PARTITION BY P.EmailAddress
            ORDER BY (SELECT 0) ASC) AS RowID,
         P.EmailAddress
      FROM Sales.Customers C
         INNER JOIN [Application].People P ON P.PersonID = C.AlternateContactPersonID
   )
SELECT EA.EmailAddress
FROM ExceptAllCte EA
ORDER BY EA.EmailAddress ASC;


/*****************************
 * Precedence
 *****************************/
SELECT B.BrandID, B.[Name]
FROM
      (
         VALUES
            (1, N'Champion'),
            (2, N'Nike'),
            (3, N'Under Armour')
      ) B(BrandID, [Name])

EXCEPT

SELECT B.BrandID, B.[Name]
FROM
      (
         VALUES
            (2, N'Nike'),
            (3, N'Under Armour')
      ) B(BrandID, [Name])

INTERSECT

SELECT B.BrandID, B.[Name]
FROM
      (
         VALUES
            (2, N'Nike'),
            (4, N'Adidas')
      ) B(BrandID, [Name])
ORDER BY B.BrandID ASC

-- Forcing order with parentheses.
(
   SELECT B.BrandID, B.[Name]
   FROM
         (
            VALUES
               (1, N'Champion'),
               (2, N'Nike'),
               (3, N'Under Armour')
         ) B(BrandID, [Name])

   EXCEPT

   SELECT B.BrandID, B.[Name]
   FROM
         (
            VALUES
               (2, N'Nike'),
               (3, N'Under Armour')
         ) B(BrandID, [Name])
)

INTERSECT

SELECT B.BrandID, B.[Name]
FROM
      (
         VALUES
            (2, N'Nike'),
            (4, N'Adidas')
      ) B(BrandID, [Name])
ORDER BY B.BrandID ASC
