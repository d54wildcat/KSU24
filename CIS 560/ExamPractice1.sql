SELECT O.OrderID, O.CustomerID, O.SalespersonPersonID
FROM Sales.Orders O
WHERE O.OrderDate >= '2015-01-15'
    AND O.OrderDate < '2015-01-16'

SELECT O.OrderID, O.OrderDate, O.SalespersonPersonID
FROM Sales.Orders O
WHERE O.OrderDate >= '2015-01-01'
    AND O.OrderDate < '2015-02-01'
    AND O.CustomerID = 50;

SELECT O.SalespersonPersonID, COUNT(*) AS OrderCount,
    MIN(O.OrderDate) AS FirstOrderDate,
    MAX(O.OrderDate) AS LastOrderDate,
    COUNT(O.CustomerID) AS UniqueCustomers
FROM Sales.Orders O
WHERE O.OrderDate >= '2015-01-01'
    AND O.OrderDate < '2016-01-01'
GROUP BY O.SalespersonPersonID;

SELECT
    CAST(O.OrderDate AS DATE) AS OrderDate,
    COUNT(DISTINCT O.CustomerID) AS CustomerCount,
    COUNT(O.OrderID) AS OrderCount
FROM
    Sales.Orders O
WHERE
    O.OrderDate >= '2015-01-01' AND O.OrderDate < '2015-02-01'
GROUP BY
    CAST(O.OrderDate AS DATE)
HAVING
    COUNT(O.OrderID) >= 50
ORDER BY
    OrderDate;

SELECT O.CustomerID, COUNT(*) AS OrderCount,
    MIN(O.OrderDate) AS FirstOrderDate,
    MAX(O.OrderDate) AS LastOrderDate
FROM Sales.Orders O;