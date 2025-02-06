/****************************
 * Views
 ****************************/
USE CIS560;
GO

-- Create schema if you haven't yet.
CREATE SCHEMA Demo AUTHORIZATION dbo;
GO

CREATE OR ALTER VIEW Demo.UnitedStates
AS

SELECT S.StateProvinceCode, S.StateProvinceName
FROM WideWorldImporters.[Application].Countries C
   INNER JOIN WideWorldImporters.[Application].StateProvinces S ON S.CountryID = C.CountryID
WHERE C.IsoAlpha3Code = N'USA';
GO


SELECT US.StateProvinceCode, US.StateProvinceName
FROM Demo.UnitedStates US;
GO


/******************************
 * Inline Table-Valued Function
 ******************************/
CREATE OR ALTER FUNCTION Demo.StateProvincesForCountry
(
   @CountryIsoAlpha3Code NVARCHAR(3)
)
RETURNS TABLE
AS
RETURN
   (
      SELECT S.StateProvinceCode, S.StateProvinceName
      FROM WideWorldImporters.[Application].Countries C
         INNER JOIN WideWorldImporters.[Application].StateProvinces S ON S.CountryID = C.CountryID
      WHERE C.IsoAlpha3Code = @CountryIsoAlpha3Code
   );
GO

SELECT S.StateProvinceCode, S.StateProvinceName
FROM Demo.StateProvincesForCountry(N'USA') S;
GO

-- Cleanup.
DROP FUNCTION IF EXISTS Demo.StateProvincesForCountry;
GO

/********************************************
 * Remember they are logical constructs only!
 ********************************************/
CREATE OR ALTER VIEW Demo.UnitedStatesCities
AS

SELECT S.StateProvinceCode, S.StateProvinceName, CT.CityID, CT.CityName
FROM WideWorldImporters.[Application].Countries C
   INNER JOIN WideWorldImporters.[Application].StateProvinces S ON S.CountryID = C.CountryID
   INNER JOIN WideWorldImporters.[Application].Cities CT ON CT.StateProvinceID = S.StateProvinceID
WHERE C.IsoAlpha3Code = N'USA';
GO

-- Now let's look at a query plan for our original view.
-- How many joins do we see here?
-- How many tables are there in this simple query?
SELECT US.StateProvinceCode, US.StateProvinceName
FROM Demo.UnitedStates US
ORDER BY US.StateProvinceCode ASC;

-- Let's look at a query plan for a single join of views.
-- How many joins do we see here?
-- How many tables are there in this simple query?
SELECT US.StateProvinceCode, US.StateProvinceName, C.CityName
FROM Demo.UnitedStates US
   INNER JOIN Demo.UnitedStatesCities C ON C.StateProvinceCode = US.StateProvinceCode
ORDER BY US.StateProvinceCode ASC, C.CityName ASC;

-- Cleanup
DROP VIEW IF EXISTS Demo.UnitedStatesCities;

DROP VIEW IF EXISTS Demo.UnitedStates;
GO

USE WideWorldImporters;
GO

/******************************************************************************
 * The APPLY Operator
 ******************************************************************************/
-- Remember how we pulled the last OrderID for each customer?
SELECT C.CustomerID, C.CustomerName,
   (
      SELECT MAX(OrderID)
      FROM Sales.Orders O
      WHERE O.CustomerID = C.CustomerID
   ) AS LastOrderID
FROM Sales.Customers C
ORDER BY C.CustomerID ASC;


-- What if we want the last order's OrderDate along with the LastOrderID?


-- We can do two correlated scalar-valued subqueries?
-- OR we can do a derived table, but still need two references.
SELECT C.CustomerID, C.CustomerName, OD.OrderID, OD.OrderDate
FROM Sales.Customers C
   INNER JOIN
      (
         SELECT O.CustomerID, MAX(O.OrderID) AS LastOrderID
         FROM Sales.Orders O
         GROUP BY O.CustomerID
      ) AS OID ON OID.CustomerID = C.CustomerID
   INNER JOIN Sales.Orders OD ON OD.OrderID = OID.LastOrderID
ORDER BY C.CustomerID ASC, OD.OrderID DESC;

-- With APPLY, we can do a correlated table-valued subquery and pull both columns.
SELECT C.CustomerID, C.CustomerName, LO.OrderID, LO.OrderDate
FROM Sales.Customers C
   CROSS APPLY
      (
         -- Switched to a TOP rather than MAX
         SELECT TOP(1) O.OrderID, O.OrderDate
         FROM Sales.Orders O
         WHERE O.CustomerID = C.CustomerID
         ORDER BY O.OrderID DESC
      ) AS LO
ORDER BY C.CustomerID ASC, LO.OrderID DESC;


-- How could we return all customers along with
--    their most recent order of 2015 only?
SELECT C.CustomerID, C.CustomerName, LO.OrderID, LO.OrderDate
FROM Sales.Customers C
   CROSS APPLY
      (
         SELECT TOP(1) O.OrderID, O.OrderDate
         FROM Sales.Orders O
         WHERE O.CustomerID = C.CustomerID
            AND O.OrderDate BETWEEN '2015-01-01' AND '2015-12-31'
         ORDER BY O.OrderID DESC
      ) AS LO
ORDER BY C.CustomerID ASC, LO.OrderID DESC;


-- Am I missing any customers?
-- What if a customer never placed an order in 2015?


-- What if I want more than 1 order per customer?
