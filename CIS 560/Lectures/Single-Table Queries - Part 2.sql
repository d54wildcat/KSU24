/**************************************
 * GROUP BY Element - Review
 **************************************/

-- Remember: NULLs are ignored in aggregates.
-- Question: How would I add customer count?
SELECT
   YEAR(O.OrderDate) AS OrderYear,
   COUNT(*) AS OrderCount,
   MIN(O.OrderDate) AS FirstOrderDate,
   MAX(O.OrderDate) AS LastOrderDate
FROM Sales.Orders O
WHERE YEAR(O.OrderDate) = 2015
GROUP BY YEAR(O.OrderDate);


/**************************************
 * HAVING Element
 **************************************/
SELECT YEAR(O.OrderDate) AS OrderYear,
   COUNT(*) AS OrderCount
FROM Sales.Orders O
GROUP BY YEAR(O.OrderDate)
HAVING COUNT(*) > 20000;


/**************************************
 * ORDER BY Element
 **************************************/
SELECT O.OrderID, O.OrderDate, O.CustomerID
FROM Sales.Orders O
ORDER BY O.OrderID ASC;

-- Multiple expressions.
SELECT O.OrderID, O.OrderDate, O.CustomerID
FROM Sales.Orders O
ORDER BY O.OrderDate ASC, O.CustomerID ASC;

/**************************************
 * Processing Order
 **************************************/

-- Notice the position of each element.
-- This positioning is mandatory.
SELECT YEAR(O.OrderDate) AS OrderYear,
   MONTH(O.OrderDate) AS OrderMonth,
   COUNT(*) AS OrderCount
FROM Sales.Orders O
WHERE O.OrderDate >= '2015-01-01'
   AND O.OrderDate < '2017-01-01'
GROUP BY YEAR(O.OrderDate), MONTH(O.OrderDate)
HAVING COUNT(*) > 1000
ORDER BY YEAR(O.OrderDate) ASC, MONTH(O.OrderDate) ASC;



-- Can I use a column alias in the ORDER BY clause?
SELECT YEAR(O.OrderDate) AS OrderYear,
   MONTH(O.OrderDate) AS OrderMonth,
   COUNT(*) AS OrderCount
FROM Sales.Orders O
WHERE O.OrderDate >= '2015-01-01'
   AND O.OrderDate < '2017-01-01'
GROUP BY YEAR(O.OrderDate), MONTH(O.OrderDate)
HAVING COUNT(*) > 1000
ORDER BY YEAR(O.OrderDate) ASC, MONTH(O.OrderDate) ASC;



-- What is wrong with this query?
SELECT O.OrderID, O.OrderDate, O.CustomerID,
   YEAR(O.OrderDate) AS OrderYear
FROM Sales.Orders O
WHERE OrderYear = 2016
ORDER BY OrderYear ASC;


/**************************************
 * SELECT DISTINCT
 **************************************/
SELECT YEAR(O.OrderDate) AS OrderYear, O.CustomerID
FROM Sales.Orders O
ORDER BY OrderYear ASC;

-- Equivalent
SELECT ALL YEAR(O.OrderDate) AS OrderYear, O.CustomerID
FROM Sales.Orders O
ORDER BY OrderYear ASC;

SELECT DISTINCT YEAR(O.OrderDate) AS OrderYear, O.CustomerID
FROM Sales.Orders O
ORDER BY OrderYear ASC;

-- Can sort by an expression NOT in the SELECT
SELECT YEAR(O.OrderDate) AS OrderYear, O.CustomerID
FROM Sales.Orders O
ORDER BY O.OrderID ASC;

-- But not with DISTINCT
SELECT DISTINCT YEAR(O.OrderDate) AS OrderYear, O.CustomerID
FROM Sales.Orders O
ORDER BY O.OrderID ASC;

/**************************************
 * TOP Filter
 **************************************/
SELECT TOP(2)
   YEAR(O.OrderDate) AS OrderYear,
   COUNT(*) AS OrderCount,
   MIN(O.OrderDate) AS FirstOrderDate,
   MAX(O.OrderDate) AS LastOrderDate
FROM Sales.Orders O
GROUP BY YEAR(O.OrderDate);

-- Which 2 did it return?
-- Let's be explicit.
SELECT TOP(2)
   YEAR(O.OrderDate) AS OrderYear,
   COUNT(*) AS OrderCount,
   MIN(O.OrderDate) AS FirstOrderDate,
   MAX(O.OrderDate) AS LastOrderDate
FROM Sales.Orders O
GROUP BY YEAR(O.OrderDate)
ORDER BY OrderCount DESC;

-- WITH TIES
SELECT TOP(10) WITH TIES O.CustomerID, COUNT(*) AS OrderCount
FROM Sales.Orders O
GROUP BY O.CustomerID
ORDER BY OrderCount DESC;

-- TOP alone is non-deterministic
-- WITH TIES option makes it deterministic.

SELECT TOP(10.5) PERCENT O.CustomerID, COUNT(*) AS OrderCount
FROM Sales.Orders O
GROUP BY O.CustomerID
ORDER BY OrderCount DESC;


/**************************************
 * OFFSET-FETCH Filter
 **************************************/
SELECT O.OrderID, O.OrderDate, O.CustomerID
FROM Sales.Orders O
ORDER BY O.OrderID ASC
OFFSET 0 ROWS FETCH NEXT 1000 ROWS ONLY;

SELECT O.OrderID, O.OrderDate, O.CustomerID
FROM Sales.Orders O
ORDER BY O.OrderID ASC
OFFSET 1000 ROWS FETCH NEXT 1000 ROWS ONLY;

-- FETCH is optional.
SELECT O.OrderID, O.OrderDate, O.CustomerID
FROM Sales.Orders O
ORDER BY O.OrderID ASC
OFFSET 50000 ROWS;

