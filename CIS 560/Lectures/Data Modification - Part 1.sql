-- Create schema for the demo objects.
CREATE SCHEMA [Demo] AUTHORIZATION [dbo];
GO

/****************************
 * INSERT... VALUES...
 ****************************/
DROP TABLE IF EXISTS Demo.Person;

-- Simple form with constraints.
CREATE TABLE Demo.Person
(
   PersonId INT NOT NULL IDENTITY(1, 1) PRIMARY KEY,
   FirstName NVARCHAR(32) NOT NULL,
   MiddleInitial NCHAR(1) NULL,
   LastName NVARCHAR(32) NOT NULL,
   CreatedOn DATETIMEOFFSET NOT NULL DEFAULT(SYSDATETIMEOFFSET()),

   UNIQUE(LastName, FirstName)
);

DROP TABLE IF EXISTS Demo.Person;

-- Using explicit naming of constraints now.
CREATE TABLE Demo.Person
(
   PersonId INT NOT NULL IDENTITY(1, 1),
   FirstName NVARCHAR(32) NOT NULL,
   MiddleInitial NCHAR(1) NULL,
   LastName NVARCHAR(32) NOT NULL,
   CreatedOn DATETIMEOFFSET NOT NULL
      CONSTRAINT [DF_Demo_Person_CreatedOn] DEFAULT(SYSDATETIMEOFFSET()),

   CONSTRAINT [PK_Demo_Person_PersonId] PRIMARY KEY
   (
      PersonId
   ),

   CONSTRAINT [UK_Demo_Person_LastName_FirstName] UNIQUE
   (
      LastName,
      FirstName
   )
);

-- Which columns am I omitting from the INSERT?
INSERT Demo.Person(FirstName, LastName)
VALUES(N'John', N'Doe');

SELECT *
FROM Demo.Person;

-- PersonID was omitted, but has the IDENTITY property.
-- MiddleInitial was omitted, but has NULL.
-- CreatedOn was omitted, but has a default constraint.

-- Here we will attempt to insert without FirstName.
INSERT Demo.Person(LastName)
VALUES(N'Smith');

-- Attempt to insert with PersonID.
INSERT Demo.Person(PersonID, FirstName, LastName)
VALUES(100, N'Jane', N'Smith');

-- Insert with MiddleInitial and CreatedOn.
INSERT Demo.Person(FirstName, MiddleInitial, LastName, CreatedOn)
VALUES(N'Jane', N'A', N'Smith', '2000-01-01 08:00:00 -06:00');

SELECT *
FROM Demo.Person;

-- Can insert multiple rows.
INSERT Demo.Person(FirstName, LastName)
VALUES
   (N'Joe', N'Robertson'),
   (N'Fred', N'Rogers'),
   (N'Marie', N'Jones');

SELECT *
FROM Demo.Person;

-- Think of this enhanced VALUES clause as a table constructor.
SELECT *
FROM
      (
         VALUES
            (N'Joe', N'Robertson'),
            (N'Fred', N'Rogers'),
            (N'Marie', N'Jones')            
      ) P(FirstName, LastName);

/****************************
 * INSERT... SELECT...
 ****************************/
INSERT Demo.Person(LastName, FirstName)
SELECT P.LastName + N', II', P.FirstName
FROM Demo.Person P;

-- Query can be any SELECT statement.
DROP TABLE IF EXISTS Demo.CustomerOrderCounts;

CREATE TABLE Demo.CustomerOrderCounts
(
   CustomerOrderCountID INT NOT NULL IDENTITY(1, 1),
   CustomerID INT NOT NULL,
   OrderYear SMALLINT NOT NULL,
   OrderMonth TINYINT NOT NULL,
   OrderCount INT NOT NULL,
   Sales NUMERIC(18,2) NOT NULL,

   CONSTRAINT [PK_Demo_CustomerOrderCounts_CustomerOrderCountID] PRIMARY KEY
   (
      CustomerOrderCountID
   ),

   CONSTRAINT [UK_Demo_CustomerOrderCounts_CustomerID_OrderYear_OrderMonth] UNIQUE
   (
      CustomerID,
      OrderYear,
      OrderMonth
   )
);

-- Can use CTEs as well.
WITH SourceCte(CustomerID, OrderYear, OrderMonth, OrderCount, Sales) AS
   (
      SELECT C.CustomerID, YEAR(O.OrderDate), MONTH(O.OrderDate),
         COUNT(DISTINCT O.OrderID), SUM(OL.UnitPrice * OL.Quantity)
      FROM WideWorldImporters.Sales.Customers C
         INNER JOIN WideWorldImporters.Sales.Orders O ON O.CustomerID = C.CustomerID
         INNER JOIN WideWorldImporters.Sales.OrderLines OL ON OL.OrderID = O.OrderID
      GROUP BY C.CustomerID, YEAR(O.OrderDate), MONTH(O.OrderDate)
   )
INSERT Demo.CustomerOrderCounts(
   CustomerID, OrderYear, OrderMonth, OrderCount, Sales)
SELECT S.CustomerID, S.OrderYear, S.OrderMonth, S.OrderCount, S.Sales
FROM SourceCte S;

SELECT *
FROM Demo.CustomerOrderCounts;

/****************************
 * INSERT... EXEC...
 ****************************/
DROP TABLE IF EXISTS Demo.CustomerOrderCounts;

CREATE TABLE Demo.CustomerOrderCounts
(
   CustomerOrderCountID INT NOT NULL IDENTITY(1, 1),
   CustomerID INT NOT NULL,
   OrderYear SMALLINT NOT NULL,
   OrderMonth TINYINT NOT NULL,
   OrderCount INT NOT NULL,
   Sales NUMERIC(18,2) NOT NULL,

   CONSTRAINT [PK_Demo_CustomerOrderCounts_CustomerOrderCountID] PRIMARY KEY
   (
      CustomerOrderCountID
   ),

   CONSTRAINT [UK_Demo_CustomerOrderCounts_CustomerID_OrderYear_OrderMonth] UNIQUE
   (
      CustomerID,
      OrderYear,
      OrderMonth
   )
);
GO

-- Let's create a procedure to pull the results.
/*
CREATE OR ALTER PROCEDURE Demo.RetrieveCustomerOrderCounts
AS

SELECT C.CustomerID,
   YEAR(O.OrderDate) AS OrderYear,
   MONTH(O.OrderDate) AS OrderMonth,
   COUNT(DISTINCT O.OrderID) AS OrderCount,
   SUM(OL.UnitPrice * OL.Quantity) AS Sales
FROM WideWorldImporters.Sales.Customers C
   INNER JOIN WideWorldImporters.Sales.Orders O ON O.CustomerID = C.CustomerID
   INNER JOIN WideWorldImporters.Sales.OrderLines OL ON OL.OrderID = O.OrderID
GROUP BY C.CustomerID, YEAR(O.OrderDate), MONTH(O.OrderDate);
*/


-- Here's how we call the procedure.
EXEC Demo.RetrieveCustomerOrderCounts;

-- The results can also be captured directly into a table.
INSERT Demo.CustomerOrderCounts(
   CustomerID, OrderYear, OrderMonth, OrderCount, Sales)
EXEC Demo.RetrieveCustomerOrderCounts;

/****************************
 * Returning identity values
 ****************************/
DROP TABLE IF EXISTS Demo.Customer;
DROP TABLE IF EXISTS Demo.Person;

CREATE TABLE Demo.Person
(
   PersonId INT NOT NULL IDENTITY(1, 1) PRIMARY KEY,
   FirstName NVARCHAR(32) NOT NULL,
   MiddleInitial NCHAR(1) NULL,
   LastName NVARCHAR(32) NOT NULL,
   CreatedOn DATETIMEOFFSET NOT NULL DEFAULT(SYSDATETIMEOFFSET())
);

CREATE TABLE Demo.Customer
(
   CustomerId INT NOT NULL IDENTITY(1, 1) PRIMARY KEY,
   [Name] NVARCHAR(64) NOT NULL,
   ContactPersonId INT NOT NULL,
   CreatedOn DATETIMEOFFSET NOT NULL DEFAULT(SYSDATETIMEOFFSET()),

   CONSTRAINT [FK_Demo_Customer_Demo_Person] FOREIGN KEY(ContactPersonId)
   REFERENCES Demo.Person(PersonId)
);
GO

INSERT Demo.Person(LastName, FirstName)
VALUES(N'John', N'Doe');

-- Good practice to always use SCOPE_IDENTITY() over @@IDENTITY
--    UNLESS you need to ignore scope.
DECLARE @PersonId INT = SCOPE_IDENTITY();

INSERT Demo.Customer([Name], ContactPersonId)
VALUES(N'JD Enterprises', @PersonId);

SELECT *
FROM Demo.Person;

SELECT *
FROM Demo.Customer;

-- Run this here, then from another session.
SELECT
   SCOPE_IDENTITY() AS [SCOPE_IDENTITY],
   IDENT_CURRENT(N'Demo.Person') AS [IDENT_CURRENT];

/****************************
 * Sequence Objects
 ****************************/
DROP TABLE IF EXISTS Demo.Customer;
DROP TABLE IF EXISTS Demo.Person;

CREATE TABLE Demo.Person
(
   PersonId INT NOT NULL PRIMARY KEY, -- No IDENTITY property
   FirstName NVARCHAR(32) NOT NULL,
   MiddleInitial NCHAR(1) NULL,
   LastName NVARCHAR(32) NOT NULL,
   CreatedOn DATETIMEOFFSET NOT NULL DEFAULT(SYSDATETIMEOFFSET())
);

DROP SEQUENCE IF EXISTS Demo.PersonIdSequence;

CREATE SEQUENCE Demo.PersonIdSequence AS INT
   MINVALUE 1
   START WITH 1
   INCREMENT BY 1
   NO CYCLE;

-- You don't need to insert to get the value.
SELECT NEXT VALUE FOR Demo.PersonIdSequence AS NextValue;

-- Rather than fetching the value AFTER an insert, you can do it before.
DECLARE @NewPersonId INT = NEXT VALUE FOR Demo.PersonIdSequence;

INSERT Demo.Person(PersonId, LastName, FirstName)
VALUES(@NewPersonId, N'John', N'Doe');

-- Or if you don't need the value captured, just call the function directly.
INSERT Demo.Person(PersonId, LastName, FirstName)
VALUES(NEXT VALUE FOR Demo.PersonIdSequence, N'Jane', N'Doe');

SELECT *
FROM Demo.Person;

-- You can use it in select and generate multiple at once.
SELECT P.PersonID, P.FullName,
   NEXT VALUE FOR Demo.PersonIdSequence AS AlternateID
FROM WideWorldImporters.[Application].People P;

-- You can even reference it more than once.
-- Remember the all-at-once evaluation behavior of SQL?
SELECT P.PersonID, P.FullName,
   NEXT VALUE FOR Demo.PersonIdSequence AS AlternateID,
   N'Person ' + CAST(NEXT VALUE FOR Demo.PersonIdSequence AS NVARCHAR(10)) AS MaskedName
FROM WideWorldImporters.[Application].People P;

-- T-SQL allows you to use sequences as default constraints.
DROP TABLE IF EXISTS Demo.Person;

CREATE TABLE Demo.Person
(
   PersonId INT NOT NULL
      CONSTRAINT [PK_Demo_Person_PersonId] PRIMARY KEY
      CONSTRAINT [DF_Demo_Person_PersonId] DEFAULT(NEXT VALUE FOR Demo.PersonIdSequence),
   FirstName NVARCHAR(32) NOT NULL,
   MiddleInitial NCHAR(1) NULL,
   LastName NVARCHAR(32) NOT NULL,
   CreatedOn DATETIMEOFFSET NOT NULL DEFAULT(SYSDATETIMEOFFSET())
);

-- Now like IDENTITY, you don't have to define a value
--    for that column when inserting.
INSERT Demo.Person(LastName, FirstName)
VALUES(N'Doe', N'John');

SELECT *
FROM Demo.Person;

-- T-SQL also allows you to use it with the OVER clause to define an order.
SELECT P.PersonID, P.FullName,
   NEXT VALUE FOR Demo.PersonIdSequence OVER(
      ORDER BY P.FullName ASC) AS AlternateID
FROM WideWorldImporters.[Application].People P
ORDER BY P.PersonID ASC;
