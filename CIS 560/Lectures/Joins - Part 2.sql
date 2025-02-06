/**************************************
 * OUTER JOIN
 **************************************/
-- Shows there are 663 customers.
SELECT COUNT(*) AS CustomerCount
FROM Sales.Customers;

-- Shows there are 2 buying groups.
SELECT *
FROM Sales.BuyingGroups BG;


-- How many rows with this CROSS JOIN?
SELECT C.CustomerID, C.CustomerName, C.BuyingGroupID, BG.BuyingGroupID, BG.BuyingGroupName
FROM Sales.Customers C
   CROSS JOIN Sales.BuyingGroups BG
ORDER BY C.CustomerID ASC;


-- How many rows with this INNER JOIN?
SELECT C.CustomerID, C.CustomerName, BG.BuyingGroupID, BG.BuyingGroupName
FROM Sales.Customers C
   INNER JOIN Sales.BuyingGroups BG ON BG.BuyingGroupID = C.BuyingGroupID
ORDER BY C.CustomerID ASC;


-- Change it to a LEFT JOIN.
SELECT C.CustomerID, C.CustomerName, BG.BuyingGroupID, BG.BuyingGroupName
FROM Sales.Customers C
   LEFT JOIN Sales.BuyingGroups BG ON BG.BuyingGroupID = C.BuyingGroupID
ORDER BY C.CustomerID ASC;

-- Which ones were added?
-- This is ONE way to identify a missing relationship.
SELECT C.CustomerID, C.CustomerName, BG.BuyingGroupID, BG.BuyingGroupName
FROM Sales.Customers C
   LEFT JOIN Sales.BuyingGroups BG ON BG.BuyingGroupID = C.BuyingGroupID
WHERE BG.BuyingGroupID IS NULL
ORDER BY C.CustomerID ASC;

-- Another Example: CustomerCount by Buying Group
SELECT C.BuyingGroupID,
   ISNULL(BG.BuyingGroupName, N'(No Buying Group)') AS BuyingGroupName,
   COUNT(*) AS CustomerCount
FROM Sales.Customers C
   LEFT JOIN Sales.BuyingGroups BG ON BG.BuyingGroupID = C.BuyingGroupID
GROUP BY C.BuyingGroupID, BG.BuyingGroupName
ORDER BY C.BuyingGroupID ASC;

-- Let's see how many customers for each customer category.
-- Do you think this is correct?
SELECT CC.CustomerCategoryID, CC.CustomerCategoryName,
   COUNT(*) AS CustomerCount
FROM Sales.Customers C
   RIGHT JOIN Sales.CustomerCategories CC ON CC.CustomerCategoryID = C.CustomerCategoryID
GROUP BY CC.CustomerCategoryID, CC.CustomerCategoryName
ORDER BY CC.CustomerCategoryID ASC;


-- We have some categories unused by a customer.
SELECT CC.CustomerCategoryID, CC.CustomerCategoryName, C.CustomerID
FROM Sales.Customers C
   RIGHT JOIN Sales.CustomerCategories CC ON CC.CustomerCategoryID = C.CustomerCategoryID
WHERE C.CustomerID IS NULL
ORDER BY CC.CustomerCategoryID ASC;

-- How do we correct our query to show zeros?
SELECT CC.CustomerCategoryID, CC.CustomerCategoryName,
   COUNT(*) AS CustomerCount
FROM Sales.Customers C
   RIGHT JOIN Sales.CustomerCategories CC ON CC.CustomerCategoryID = C.CustomerCategoryID
GROUP BY CC.CustomerCategoryID, CC.CustomerCategoryName
ORDER BY CC.CustomerCategoryID ASC;



-- Solution
SELECT CC.CustomerCategoryID, CC.CustomerCategoryName,
   COUNT(C.CustomerID) AS CustomerCount
FROM Sales.Customers C
   RIGHT JOIN Sales.CustomerCategories CC ON CC.CustomerCategoryID = C.CustomerCategoryID
GROUP BY CC.CustomerCategoryID, CC.CustomerCategoryName
ORDER BY CC.CustomerCategoryID ASC;

-- Now let's flip it with a LEFT JOIN.
-- This is an equivalent query.
SELECT CC.CustomerCategoryID, CC.CustomerCategoryName,
   COUNT(C.CustomerID) AS CustomerCount
FROM Sales.CustomerCategories CC
   LEFT JOIN Sales.Customers C ON C.CustomerCategoryID = CC.CustomerCategoryID
GROUP BY CC.CustomerCategoryID, CC.CustomerCategoryName
ORDER BY CC.CustomerCategoryID ASC;


-- FULL OUTER JOIN
-- StockItems has a nullable foreign key to Colors
-- So we have stock items without a color
--    and we have colors unused by stock items.
SELECT C.ColorID, C.ColorName, SI.StockItemID, SI.StockItemName
FROM Warehouse.Colors C
   FULL JOIN Warehouse.StockItems SI ON SI.ColorID = C.ColorID
ORDER BY C.ColorID ASC, SI.StockItemID ASC;

-- Class Exercise
-- How can we change the below query to return
--    ALL customers along with their order count and total sales
--    for 2015?
-- Remember, there are 663 customers.
SELECT C.CustomerID, C.CustomerName,
   COUNT(DISTINCT O.OrderID) AS OrderCount,
   SUM(OL.Quantity * OL.UnitPrice) AS Sales
FROM Sales.Customers C
   INNER JOIN Sales.Orders O ON O.CustomerID = C.CustomerID
   INNER JOIN Sales.OrderLines OL ON OL.OrderID = O.OrderID
WHERE O.OrderDate BETWEEN '2015-01-01' AND '2015-12-31'
GROUP BY C.CustomerID, C.CustomerName
ORDER BY Sales DESC;



-- Solution
SELECT C.CustomerID, C.CustomerName,
   COUNT(DISTINCT O.OrderID) AS OrderCount,
   ISNULL(SUM(OL.Quantity * OL.UnitPrice), 0.00) AS Sales
FROM Sales.Customers C
   LEFT JOIN Sales.Orders O ON O.CustomerID = C.CustomerID
      AND O.OrderDate BETWEEN '2015-01-01' AND '2015-12-31'
   LEFT JOIN Sales.OrderLines OL ON OL.OrderID = O.OrderID
GROUP BY C.CustomerID, C.CustomerName
ORDER BY Sales DESC;
