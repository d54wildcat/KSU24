/*************************************
 * Correlated Scalar Subquery
 *************************************/

-- Example in WHERE
-- Return last order for each customer.
SELECT O.CustomerId, O.OrderID, O.OrderDate, O.SalespersonPersonID
FROM Sales.Orders O
WHERE O.OrderID =
   (
      SELECT MAX(CO.OrderID)
      FROM Sales.Orders CO
      WHERE CO.CustomerID = O.CustomerID
   )
ORDER BY O.CustomerID ASC;


-- Example in SELECT
-- Return all customers along with the OrderID of their last order.
SELECT C.CustomerID, C.CustomerName,
   (
      SELECT MAX(O.OrderID)
      FROM Sales.Orders O
      WHERE O.CustomerID = C.CustomerID
   ) AS LastOrderID
FROM Sales.Customers C;


-- CLASS EXERCISE - Use a subquery to solve.
-- Show all customers with the number of orders placed in 2015.
-- We want CustomerID, CustomerName, and 2015OrderCount.






-- Note the difference with COUNT from other aggregates.

-- CLASS EXERCISE - Use a subquery to solve.
-- Show all customers with the total sales in 2015.
-- We want CustomerID, CustomerName, and 2015Sales.



/******************************************************************************
 * Correlated Multi-Value Subquery.
 ******************************************************************************/

-- Usually queries solved with multi-valued subqueries takes one of two forms:
-- Form 1: Self-contained
-- Return customers who placed an order in 2015.
-- Uses self-contained multi-valued subquery.
SELECT C.CustomerID, C.CustomerName
FROM Sales.Customers C
WHERE C.CustomerID IN
   (
      SELECT O.CustomerID
      FROM Sales.Orders O
      WHERE O.OrderDate BETWEEN '2015-01-01' AND '2015-12-31'
   );

-- Form 2: Correlated with EXISTS predicate
-- Can be rewritten nicely using EXISTS predicate
SELECT C.CustomerID, C.CustomerName
FROM Sales.Customers C
WHERE EXISTS
   (
      SELECT *
      FROM Sales.Orders O
      WHERE O.CustomerID = C.CustomerID
         AND O.OrderDate BETWEEN '2015-01-01' AND '2015-12-31'
   );

-- Same solution using a JOIN
SELECT DISTINCT C.CustomerID, C.CustomerName
FROM Sales.Customers C
   INNER JOIN Sales.Orders O ON O.CustomerID = C.CustomerID
WHERE O.OrderDate BETWEEN '2015-01-01' AND '2015-12-31';

-- How do we see all customers who did NOT place an order in 2015?
-- Using a JOIN?
SELECT C.CustomerID, C.CustomerName
FROM Sales.Customers C
   LEFT JOIN Sales.Orders O ON O.CustomerID = C.CustomerID
      AND O.OrderDate BETWEEN '2015-01-01' AND '2015-12-31'
WHERE O.OrderID IS NULL;

-- Using a subquery?
-- Here's the original:
SELECT C.CustomerID, C.CustomerName
FROM Sales.Customers C
WHERE EXISTS
   (
      SELECT *
      FROM Sales.Orders O
      WHERE O.CustomerID = C.CustomerID
         AND O.OrderDate BETWEEN '2015-01-01' AND '2015-12-31'
   );


-- EXISTS predicate uses true two-valued boolean logic.
-- DeliveryMethods not used by suppliers.
SELECT DM.DeliveryMethodID, DM.DeliveryMethodName
FROM [Application].DeliveryMethods DM
   LEFT JOIN Purchasing.Suppliers S ON S.DeliveryMethodID = DM.DeliveryMethodID
WHERE S.SupplierID IS NULL;

-- Another way to write it with NOT IN.  Is this working?
SELECT DM.DeliveryMethodID, DM.DeliveryMethodName
FROM [Application].DeliveryMethods DM
WHERE DM.DeliveryMethodID NOT IN
   (
      SELECT S.DeliveryMethodID
      FROM Purchasing.Suppliers S
   );

-- Another attempt, but with NOT EXISTS.
SELECT DM.DeliveryMethodID, DM.DeliveryMethodName
FROM [Application].DeliveryMethods DM
WHERE NOT EXISTS
   (
      SELECT *
      FROM Purchasing.Suppliers S
      WHERE S.DeliveryMethodID = DM.DeliveryMethodID
   );

/****************************
 * More examples
 ****************************/
-- Another example of a correlated subquery.
-- Percent of daily total for each order.
SELECT O.OrderID, O.OrderDate,
   SUM(OL.Quantity * OL.UnitPrice) AS OrderTotal,
   100.0 * SUM(OL.Quantity * OL.UnitPrice) /
      (
         SELECT SUM(RTOL.Quantity * RTOL.UnitPrice)
         FROM Sales.Orders RTO
            INNER JOIN Sales.OrderLines RTOL ON RTOL.OrderID = RTO.OrderID
         WHERE RTO.OrderDate = O.OrderDate
      ) AS PercentOfDailyTotal
FROM Sales.Orders O
   INNER JOIN Sales.OrderLines OL ON OL.OrderID = O.OrderID
WHERE O.OrderDate BETWEEN '2015-01-01' AND '2015-12-31'
GROUP BY O.OrderID, O.OrderDate
ORDER BY O.OrderDate ASC, PercentOfDailyTotal DESC;



-- Another example of a correlated subquery.
-- Running total for customer and year.
SELECT C.CustomerID, C.CustomerName, O.OrderID, O.OrderDate,
   SUM(OL.Quantity * OL.UnitPrice) AS OrderTotal,
   (
      SELECT SUM(RTOL.Quantity * RTOL.UnitPrice)
      FROM Sales.Orders RTO
         INNER JOIN Sales.OrderLines RTOL ON RTOL.OrderID = RTO.OrderID
      WHERE RTO.CustomerID = C.CustomerID
         AND RTO.OrderID <= O.OrderID
         AND YEAR(RTO.OrderDate) = YEAR(O.OrderDate)
   ) AS YtdRunningTotalForCustomer
FROM Sales.Customers C
   INNER JOIN Sales.Orders O ON O.CustomerID = C.CustomerID
   INNER JOIN Sales.OrderLines OL ON OL.OrderID = O.OrderID
GROUP BY C.CustomerID, C.CustomerName, O.OrderID, O.OrderDate
ORDER BY C.CustomerID ASC, O.OrderID ASC;

-- Be careful with aliases in subqueries.
-- It's a good practice to not reuse aliases.


/************************
 * Solutions
 ************************/
SELECT C.CustomerID, C.CustomerName,
   (
      SELECT COUNT(*)
      FROM Sales.Orders O
      WHERE O.CustomerID = C.CustomerID
         AND O.OrderDate BETWEEN '2015-01-01' AND '2015-12-31'
   ) AS [2015OrderCount]
FROM Sales.Customers C
ORDER BY [2015OrderCount] DESC;

SELECT C.CustomerID, C.CustomerName,
   (
      SELECT SUM(OL.Quantity * OL.UnitPrice)
      FROM Sales.Orders O
         INNER JOIN Sales.OrderLines OL ON OL.OrderID = O.OrderID
      WHERE O.CustomerID = C.CustomerID
         AND O.OrderDate BETWEEN '2015-01-01' AND '2015-12-31'
   ) AS [2015Sales]
FROM Sales.Customers C
ORDER BY [2015Sales] DESC;
