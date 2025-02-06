/**************************************
 * Self-contained Scalar-valued Subquery
 **************************************/
-- Capturing in a variable.
DECLARE @LastOrderID INT =
   (
      SELECT MAX(O.OrderID)
      FROM Sales.Orders O
   );

SELECT O.OrderID, O.OrderDate, C.CustomerID, C.CustomerName
FROM Sales.Orders O
   INNER JOIN Sales.Customers C ON C.CustomerID = O.CustomerID
WHERE O.OrderID = @LastOrderID;

-- The below is logically equivalent.
SELECT O.OrderID, O.OrderDate, C.CustomerID, C.CustomerName
FROM Sales.Orders O
   INNER JOIN Sales.Customers C ON C.CustomerID = O.CustomerID
WHERE O.OrderID =
   (
      SELECT MAX(O.OrderID)
      FROM Sales.Orders O
   );

-- Using the subquery in the select.
DECLARE @CustomerID INT = 1058;

SELECT C.CustomerID, C.CustomerName,
   (
      SELECT COUNT(*)
      FROM Sales.Orders O
      WHERE O.CustomerID = @CustomerID
   ) AS OrderCount
FROM Sales.Customers C
WHERE C.CustomerID = @CustomerID;

-- What if there are no results in a scalar-valued subquery?
DECLARE @CustomerName NVARCHAR(100) =
   (
      SELECT C.CustomerName
      FROM Sales.Customers C
      WHERE C.CustomerID = 10000
   );

SELECT @CustomerName AS CustomerName;

-- Equivalent
-- This may look odd, but simple query with a subquery.
SELECT
   (
      SELECT C.CustomerName
      FROM Sales.Customers C
      WHERE C.CustomerID = 10000
   ) AS CustomerName;


-- Customers placing orders on a given date.
-- What are the results for 2015-05-31?  Why?
-- What are the results for 2015-05-30?  Why?
DECLARE @OrderDate DATE = '2015-05-31';

SELECT C.CustomerID, C.CustomerName
FROM Sales.Customers C
WHERE C.CustomerID =
   (
      SELECT O.CustomerID
      FROM Sales.Orders O
      WHERE O.OrderDate = @OrderDate
   );


-- Simply use the IN predicate indicating we expect multiple values.
-- Now we have a self-contained multi-valued subquery.
SELECT C.CustomerID, C.CustomerName
FROM Sales.Customers C
WHERE C.CustomerID IN
   (
      SELECT O.CustomerID
      FROM Sales.Orders O
      WHERE O.OrderDate = '2015-05-30'
   );

-- Another Example
-- Which sales persons have sold the "chocolate bar" USB drive?
SELECT P.PersonID, P.FullName
FROM [Application].People P
WHERE P.PersonID IN
   (
      SELECT O.SalespersonPersonID
      FROM Warehouse.StockItems SI
         INNER JOIN Sales.OrderLines OL ON OL.StockItemID = SI.StockItemID
         INNER JOIN Sales.Orders O ON O.OrderID = OL.OrderID
      WHERE SI.StockItemName = N'USB food flash drive - chocolate bar'
   );