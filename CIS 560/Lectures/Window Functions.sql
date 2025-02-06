/*****************************
 * Benefits
 *****************************/
-- Here we are grouping to orders, but what if we wanted order total
--    while preserving the order line rows for a LineTotal and StockItemID.
SELECT O.OrderID, SUM(OL.Quantity * OL.UnitPrice) AS OrderTotal
FROM Sales.Orders O
   INNER JOIN Sales.OrderLines OL ON OL.OrderID = O.OrderID
WHERE O.OrderDate = '2015-01-01'
GROUP BY O.OrderID
ORDER BY O.OrderID ASC;


-- We can use subqueries, but we can have repeated filters or
--    duplication with multiple subqueries.
SELECT O.CustomerID, O.OrderID, OL.StockItemID, OL.UnitPrice * OL.Quantity AS LinePrice,
   (
      SELECT SUM(OLT.UnitPrice * OLT.Quantity)
      FROM Sales.OrderLines OLT
      WHERE OLT.OrderID = O.OrderID
   ) AS OrderTotal,
   (
      SELECT SUM(OLCT.UnitPrice * OLCT.Quantity)
      FROM Sales.Orders OCT
         INNER JOIN Sales.OrderLines OLCT ON OLCT.OrderID = OCT.OrderID
      WHERE OCT.CustomerID = O.CustomerID
         AND OCT.OrderDate = '2015-01-01'
   ) AS CustomerTotal
FROM Sales.Orders O
   INNER JOIN Sales.OrderLines OL ON OL.OrderID = O.OrderID
WHERE O.OrderDate = '2015-01-01'
ORDER BY O.CustomerID ASC, O.OrderID ASC;


/*****************************
 * Ranking Window Functions
 *****************************/
WITH OrderTotalCte(OrderId, OrderTotal) AS
   (
      SELECT O.OrderID, SUM(OL.Quantity * OL.UnitPrice)
      FROM Sales.Orders O
         INNER JOIN Sales.OrderLines OL ON OL.OrderID = O.OrderID
      WHERE O.OrderDate = '2015-01-01'
      GROUP BY O.OrderID
   )
SELECT OT.OrderID, OT.OrderTotal,
   ROW_NUMBER() OVER(ORDER BY OT.OrderTotal DESC) AS [RowNumber],
   RANK() OVER(ORDER BY OT.OrderTotal DESC) AS [Rank],
   DENSE_RANK() OVER(ORDER BY OT.OrderTotal DESC) AS [DenseRank],
   NTILE(4) OVER(ORDER BY OT.OrderTotal DESC) AS [Quartile]
FROM OrderTotalCte OT
ORDER BY OT.OrderTotal DESC;


-- Look at rows 40-41, 47-48
-- Are these functions deterministic?

-- What comes first in processing order, grouping or window functions?

-- So the CTE isn't necessary.
SELECT O.OrderID,
   SUM(OL.Quantity * OL.UnitPrice) AS OrderTotal,
   ROW_NUMBER() OVER(ORDER BY SUM(OL.Quantity * OL.UnitPrice) DESC) AS [RowNumber],
   RANK() OVER(ORDER BY SUM(OL.Quantity * OL.UnitPrice) DESC) AS [Rank],
   DENSE_RANK() OVER(ORDER BY SUM(OL.Quantity * OL.UnitPrice) DESC) AS [DenseRank],
   NTILE(4) OVER(ORDER BY SUM(OL.Quantity * OL.UnitPrice) DESC) AS [Quartile]
FROM Sales.Orders O
   INNER JOIN Sales.OrderLines OL ON OL.OrderID = O.OrderID
WHERE O.OrderDate = '2015-01-01'
GROUP BY O.OrderID
ORDER BY OrderTotal DESC;

-- Can also use partitioning.
WITH SalesPersonDailyTotalCte(SalespersonPersonID, OrderDate, SalesTotal) AS
   (
      SELECT O.SalespersonPersonID, O.OrderDate, SUM(OL.Quantity * OL.UnitPrice)
      FROM Sales.Orders O
         INNER JOIN Sales.OrderLines OL ON OL.OrderID = O.OrderID
      WHERE O.OrderDate BETWEEN '2015-01-04' AND '2015-01-10'
      GROUP BY O.SalespersonPersonID, O.OrderDate
   )
SELECT DT.OrderDate, DT.SalespersonPersonID, DT.SalesTotal,
   RANK() OVER(
      PARTITION BY DT.OrderDate
      ORDER BY DT.SalesTotal DESC) AS SalesPersonRank
FROM SalesPersonDailyTotalCte DT
ORDER BY DT.OrderDate ASC, DT.SalesTotal DESC;


/*****************************
 * Offset Window Functions
 *****************************/

-- LAG and LEAD
WITH OrderTotalCte(OrderId, CustomerID, OrderTotal) AS
   (
      SELECT O.OrderID, O.CustomerID,
         SUM(OL.Quantity * OL.UnitPrice)
      FROM Sales.Orders O
         INNER JOIN Sales.OrderLines OL ON OL.OrderID = O.OrderID
      WHERE O.OrderDate BETWEEN '2015-01-04' AND '2015-01-10'
      GROUP BY O.OrderID, O.CustomerID
   )
SELECT OT.CustomerID, OT.OrderId, OT.OrderTotal,
   LAG(OT.OrderTotal, 1) OVER(
      PARTITION BY OT.CustomerID
      ORDER BY OT.OrderID ASC) AS PreviousValue,
   LAG(OT.OrderTotal, 2) OVER(
      PARTITION BY OT.CustomerID
      ORDER BY OT.OrderID ASC) AS Previous2Value,
   LEAD(OT.OrderTotal, 1) OVER(
      PARTITION BY OT.CustomerID
      ORDER BY OT.OrderID ASC) AS NextValue,
   LEAD(OT.OrderTotal, 2) OVER(
      PARTITION BY OT.CustomerID
      ORDER BY OT.OrderID ASC) AS Next2Value
FROM OrderTotalCte OT
ORDER BY OT.CustomerID ASC, OT.OrderId ASC;


-- FIRST_VALUE and LAST_VALUE
-- Notice the window framing.
WITH OrderTotalCte(OrderId, CustomerID, OrderTotal) AS
   (
      SELECT O.OrderID, O.CustomerID,
         SUM(OL.Quantity * OL.UnitPrice)
      FROM Sales.Orders O
         INNER JOIN Sales.OrderLines OL ON OL.OrderID = O.OrderID
      WHERE O.OrderDate BETWEEN '2015-01-04' AND '2015-01-10'
      GROUP BY O.OrderID, O.CustomerID
   )
SELECT OT.CustomerID, OT.OrderId, OT.OrderTotal,
   FIRST_VALUE(OT.OrderTotal) OVER(
      PARTITION BY OT.CustomerID
      ORDER BY OT.OrderID ASC
      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS FirstValue,
   LAST_VALUE(OT.OrderTotal) OVER(
      PARTITION BY OT.CustomerID
      ORDER BY OT.OrderID ASC
      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS LastValue
FROM OrderTotalCte OT
ORDER BY OT.CustomerID ASC, OT.OrderId ASC;



/*****************************
 * Aggregate Window Functions
 *****************************/
WITH OrderTotalCte(OrderId, SalespersonPersonID, OrderTotal) AS
   (
      SELECT O.OrderID, O.SalespersonPersonID, SUM(OL.Quantity * OL.UnitPrice)
      FROM Sales.Orders O
         INNER JOIN Sales.OrderLines OL ON OL.OrderID = O.OrderID
      WHERE O.OrderDate = '2016-01-01'
      GROUP BY O.OrderID, O.SalespersonPersonID
   )
SELECT OT.SalespersonPersonID, OT.OrderID, OT.OrderTotal,
   COUNT(*) OVER() AS TotalOrderCount,
   COUNT(*) OVER(PARTITION BY OT.SalespersonPersonID) AS SalespersonOrderCount,
   SUM(OT.OrderTotal) OVER() AS TotalSales,
   SUM(OT.OrderTotal) OVER(PARTITION BY OT.SalespersonPersonID) AS SalespersonSales
FROM OrderTotalCte OT
ORDER BY OT.SalespersonPersonID ASC;

-- Notice the empty OVER clause, defining the window to include ALL rows.


-- Of course, then you can use these aggregates in expressions,
--    such as percentages.
WITH OrderTotalCte(OrderId, SalespersonPersonID, OrderTotal) AS
   (
      SELECT O.OrderID, O.SalespersonPersonID, SUM(OL.Quantity * OL.UnitPrice)
      FROM Sales.Orders O
         INNER JOIN Sales.OrderLines OL ON OL.OrderID = O.OrderID
      WHERE O.OrderDate = '2016-01-01'
      GROUP BY O.OrderID, O.SalespersonPersonID
   )
SELECT OT.SalespersonPersonID, OT.OrderID, OT.OrderTotal,
   SUM(OT.OrderTotal) OVER() AS TotalSales,
   SUM(OT.OrderTotal) OVER(PARTITION BY OT.SalespersonPersonID) AS SalespersonSales,
   100 * OT.OrderTotal / SUM(OT.OrderTotal) OVER(PARTITION BY OT.SalespersonPersonID) AS PercentageOfSalesPersonSales,
   100 * OT.OrderTotal / SUM(OT.OrderTotal) OVER() AS PercentageOfTotalSales
FROM OrderTotalCte OT
ORDER BY OT.SalespersonPersonID ASC, OT.OrderId ASC;


-- With window framing.
WITH OrderTotalCte(OrderId, SalespersonPersonID, OrderTotal) AS
   (
      SELECT O.OrderID, O.SalespersonPersonID, SUM(OL.Quantity * OL.UnitPrice)
      FROM Sales.Orders O
         INNER JOIN Sales.OrderLines OL ON OL.OrderID = O.OrderID
      WHERE O.OrderDate = '2016-01-01'
      GROUP BY O.OrderID, O.SalespersonPersonID
   )
SELECT OT.SalespersonPersonID, OT.OrderID, OT.OrderTotal,
   SUM(OT.OrderTotal) OVER(
      PARTITION BY OT.SalespersonPersonID
      ORDER BY OT.OrderID ASC
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS SalespersonRunningTotal,
   SUM(OT.OrderTotal) OVER(
      PARTITION BY OT.SalespersonPersonID
      ORDER BY OT.OrderID ASC
      ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING) AS SalespersonRunningTotalExcludingCurrent,
   SUM(OT.OrderTotal) OVER(
      ORDER BY OT.SalespersonPersonID ASC, OT.OrderID ASC
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningTotal
FROM OrderTotalCte OT
ORDER BY OT.SalespersonPersonID ASC, OT.OrderId ASC;

-- MTD, YTD totals
WITH DailyTotalCte(OrderDate, OrderYear, OrderMonth, Total) AS
   (
      SELECT O.OrderDate, YEAR(O.OrderDate), MONTH(O.OrderDate),
         SUM(OL.Quantity * OL.UnitPrice)
      FROM Sales.Orders O
         INNER JOIN Sales.OrderLines OL ON OL.OrderID = O.OrderID
      GROUP BY O.OrderDate
   )
SELECT DT.OrderDate, DT.Total,
   SUM(DT.Total) OVER(
      PARTITION BY DT.OrderYear, DT.OrderMonth
      ORDER BY DT.OrderDate ASC
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS MtdSales,
   SUM(DT.Total) OVER(
      PARTITION BY DT.OrderYear
      ORDER BY DT.OrderDate ASC
      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS YtdSales
FROM DailyTotalCte DT
ORDER BY DT.OrderDate ASC;
