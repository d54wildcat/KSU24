-- Question: 1 Write a query to return sales information for each customer who placed an order in 2015.

/*Your solution should use a derived table to calculate the OrderCount and Sales for each CustomerID.
Result Columns

    CustomerID – The ID of the customer as it exists in Sales.Customers.
    CustomerName – The name of the customer as it exists in Sales.Customers.
    AccountOpenedDate – The date the account opened as it exists in Sales.Customers.
    CustomerCategoryName – The name of the customer category as it exists in Sales.CustomerCategories.
    OrderCount – The number of orders place in 2015 by each customer.
    Sales – The total sales for each customer in 2015. Sales are calculated using the Quantity and UnitPrice from Sales.OrderLines.

Implementation Requirements

    A derived table should be used with only three columns: CustomerID, OrderCount, and Sales. Each table in the solution should be referenced only once. That is, there is no need for the derived table and the outer query to reference the same table(s).
    The results should be sorted with the customer having the highest sales first.
*/
SELECT
    C.CustomerID,
    C.CustomerName,
    C.AccountOpenedDate,
    CC.CustomerCategoryName,
    DT.OrderCount,
    DT.Sales
FROM
    (
        SELECT
            O.CustomerID,
            COUNT(DISTINCT O.OrderID) AS OrderCount, -- Adjusted to count distinct orders
            SUM(OL.Quantity * OL.UnitPrice) AS Sales
        FROM
            Sales.Orders AS O
        INNER JOIN Sales.OrderLines AS OL ON O.OrderID = OL.OrderID
        WHERE
            YEAR(O.OrderDate) = 2015
        GROUP BY
            O.CustomerID
    ) AS DT
INNER JOIN Sales.Customers AS C ON DT.CustomerID = C.CustomerID
INNER JOIN Sales.CustomerCategories AS CC ON C.CustomerCategoryID = CC.CustomerCategoryID
ORDER BY
    DT.Sales DESC;
-- Question: 2
WITH OrderTotals AS (
    SELECT
        O.OrderID,
        O.OrderDate,
        SUM(OL.Quantity * OL.UnitPrice) AS OrderTotal
    FROM
        Sales.Orders AS O
    INNER JOIN Sales.OrderLines AS OL ON O.OrderID = OL.OrderID
    WHERE
        O.CustomerID = 90
    GROUP BY
        O.OrderID, O.OrderDate
)

SELECT
    OT.OrderID,
    OT.OrderDate,
    OT.OrderTotal,
    SUM(OT.OrderTotal) OVER (PARTITION BY YEAR(OT.OrderDate) ORDER BY OT.OrderID 
                             ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS YtdTotal,
    DATEDIFF(DAY, LAG(OT.OrderDate) OVER (ORDER BY OT.OrderID), OT.OrderDate) AS DaysSincePreviousOrder
FROM
    OrderTotals AS OT
ORDER BY
    OT.OrderID ASC;
-- Question 3
WITH SalespersonSales AS (
    SELECT
        O.SalespersonPersonID,
        P.FullName,
        YEAR(O.OrderDate) AS OrderYear,
        SUM(OL.Quantity * OL.UnitPrice) AS YearlySales
    FROM
        Sales.Orders AS O
    JOIN Sales.OrderLines AS OL ON O.OrderID = OL.OrderID
    JOIN Application.People AS P ON O.SalespersonPersonID = P.PersonID
    GROUP BY
        O.SalespersonPersonID,
        P.FullName,
        YEAR(O.OrderDate)
),
RankedSales AS (
    SELECT
        SS.SalespersonPersonID,
        SS.FullName,
        SS.OrderYear,
        SS.YearlySales,
        RANK() OVER (PARTITION BY SS.OrderYear ORDER BY SS.YearlySales DESC) AS YearlySalesRank,
        RANK() OVER (ORDER BY SS.YearlySales DESC) AS OverallSalesRank
    FROM
        SalespersonSales AS SS
)

SELECT
    RS.SalespersonPersonID,
    RS.FullName,
    RS.OrderYear,
    RS.YearlySales,
    RS.YearlySalesRank,
    RS.OverallSalesRank
FROM
    RankedSales AS RS
ORDER BY
    RS.OrderYear ASC,
    RS.YearlySalesRank ASC;
--Question 4
WITH CityRecords AS (
    SELECT
        DISTINCT C.CityID,
        'Customer' AS RecordType
    FROM
        Sales.Customers CU
    JOIN Application.Cities C ON CU.PostalCityID = C.CityID
    UNION -- Removes duplicates between the sets
    SELECT
        DISTINCT C.CityID,
        'Supplier' AS RecordType
    FROM
        Purchasing.Suppliers S
    JOIN Application.Cities C ON S.PostalCityID = C.CityID
)

SELECT
    C.CityName,
    SP.StateProvinceName,
    CR.RecordType
FROM
    CityRecords CR
JOIN Application.Cities C ON CR.CityID = C.CityID
JOIN Application.StateProvinces SP ON C.StateProvinceID = SP.StateProvinceID



