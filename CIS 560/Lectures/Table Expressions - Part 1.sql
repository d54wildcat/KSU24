/****************************
 * Simple use
 ****************************/

-- Derived table of Computer Store Customers.
SELECT *
FROM
      (
         SELECT C.CustomerId, C.CustomerName
         FROM Sales.Customers C
            INNER JOIN Sales.CustomerCategories CC ON CC.CustomerCategoryID = C.CustomerCategoryID
         WHERE CC.CustomerCategoryName = N'Computer Store'
      ) AS ComputerStoreCustomers;

-- Same query with no name.
SELECT *
FROM
      (
         SELECT C.CustomerId, C.CustomerName
         FROM Sales.Customers C
            INNER JOIN Sales.CustomerCategories CC ON CC.CustomerCategoryID = C.CustomerCategoryID
         WHERE CC.CustomerCategoryName = N'Computer Store'
      );

-- Same query with missing column name.
SELECT *
FROM
      (
         SELECT C.CustomerId, C.CustomerName,
            IIF(C.AccountOpenedDate <= '2015-01-01', N'Loyal', N'New')
         FROM Sales.Customers C
            INNER JOIN Sales.CustomerCategories CC ON CC.CustomerCategoryID = C.CustomerCategoryID
         WHERE CC.CustomerCategoryName = N'Computer Store'
      ) AS ComputerStoreCustomers;

-- Same query with duplicate column name.
SELECT *
FROM
      (
         SELECT C.CustomerId, C.CustomerName, CC.CustomerCategoryName,
            IIF(C.AccountOpenedDate <= '2015-01-01', N'Loyal', N'New') AS CustomerCategoryName
         FROM Sales.Customers C
            INNER JOIN Sales.CustomerCategories CC ON CC.CustomerCategoryID = C.CustomerCategoryID
         WHERE CC.CustomerCategoryName = N'Computer Store'
      ) AS ComputerStoreCustomers;

-- Same query with an ORDER BY clause.
SELECT *
FROM
      (
         SELECT C.CustomerId, C.CustomerName
         FROM Sales.Customers C
            INNER JOIN Sales.CustomerCategories CC ON CC.CustomerCategoryID = C.CustomerCategoryID
         WHERE CC.CustomerCategoryName = N'Computer Store'
         ORDER BY C.CustomerID ASC
      ) AS ComputerStoreCustomers;


/**************************************
 * Inline vs. External Column Aliasing
 **************************************/
-- Inline aliasing.
SELECT OrderYear, OrderCount, CustomerCount
FROM
      (
         SELECT YEAR(O.OrderDate) AS OrderYear,
            COUNT(*) AS OrderCount,
            COUNT(DISTINCT O.CustomerID) AS CustomerCount
         FROM Sales.Orders O
         GROUP BY YEAR(O.OrderDate)
      ) AS YearlyOrderCount;

-- External aliasing.
SELECT OrderYear, OrderCount, CustomerCount
FROM
      (
         SELECT YEAR(O.OrderDate),
            COUNT(*),
            COUNT(DISTINCT O.CustomerId)
         FROM Sales.Orders O
         GROUP BY YEAR(O.OrderDate)
      ) AS YearlyOrderCount(OrderYear, OrderCount, CustomerCount);
GO

/***********************
 * Nested derived table
 ***********************/
SELECT CC.OrderYear, CC.CustomerCount
FROM
      (
         SELECT OY.OrderYear,
            COUNT(DISTINCT OY.CustomerId) AS CustomerCount
         FROM
               (
                  SELECT YEAR(O.OrderDate) AS OrderYear,
                     O.CustomerId
                  FROM Sales.Orders O
               ) AS OY
         GROUP BY OY.OrderYear
      ) CC
WHERE CC.CustomerCount > 650;
GO


/*****************************************
 * Multiple references for a derived table
 *****************************************/
SELECT Cur.OrderYear, Cur.CustomerCount AS CurrentCustomerCount,
   Prv.CustomerCount AS PreviousCustomerCount,
   Cur.CustomerCount - Prv.CustomerCount AS CustomerGrowth
FROM
      (
         SELECT YEAR(O.OrderDate) AS OrderYear,
            COUNT(DISTINCT O.CustomerId) AS CustomerCount
         FROM Sales.Orders O
         GROUP BY YEAR(O.OrderDate)
      ) Cur
   LEFT JOIN
      (
         SELECT YEAR(O.OrderDate) AS OrderYear,
            COUNT(DISTINCT O.CustomerId) AS CustomerCount
         FROM Sales.Orders O
         GROUP BY YEAR(O.OrderDate)
      ) Prv ON Cur.OrderYear = Prv.OrderYear + 1
ORDER BY Cur.OrderYear ASC;
GO


-------------------------------------------------------------------------------


/****************************
 * Simple CTE
 ****************************/
DECLARE @CustomerCategoryName NVARCHAR(50) = N'Computer Store';

WITH ComputerStoreCustomers(CustomerID, CustomerName) AS
   (
      SELECT C.CustomerId, C.CustomerName
      FROM Sales.Customers C
         INNER JOIN Sales.CustomerCategories CC ON CC.CustomerCategoryID = C.CustomerCategoryID
      WHERE CC.CustomerCategoryName = @CustomerCategoryName
   )
SELECT C.CustomerID, C.CustomerName
FROM ComputerStoreCustomers C;
GO

-- Note the importance of semicolon.

-- The above is external aliasing.
-- Internal aliasing works too.
WITH ComputerStoreCustomers AS
   (
      SELECT C.CustomerId, C.CustomerName
      FROM Sales.Customers C
         INNER JOIN Sales.CustomerCategories CC ON CC.CustomerCategoryID = C.CustomerCategoryID
      WHERE CC.CustomerCategoryName = N'Computer Store'
   )
SELECT C.CustomerID, C.CustomerName
FROM ComputerStoreCustomers C;


/****************************
 * Multiple CTEs
 ****************************/
WITH OrderYearCte(OrderYear, CustomerId) AS
   (
      SELECT YEAR(O.OrderDate), O.CustomerId
      FROM Sales.Orders O
   ),
CustomerCountCte(OrderYear, CustomerCount) AS
   (
      SELECT OY.OrderYear, COUNT(DISTINCT OY.CustomerId)
      FROM OrderYearCte OY
      GROUP BY OY.OrderYear
   )
SELECT CC.OrderYear, CC.CustomerCount
FROM CustomerCountCte CC
WHERE CC.CustomerCount > 650;
GO


/*********************
 * Multiple references
 *********************/
WITH CustomerCountCte(OrderYear, CustomerCount) AS
   (
      SELECT YEAR(O.OrderDate), COUNT(DISTINCT O.CustomerId)
      FROM Sales.Orders O
      GROUP BY YEAR(O.OrderDate)
   )
SELECT Cur.OrderYear, Cur.CustomerCount AS CurrentCustomerCount,
   Prv.CustomerCount AS PreviousCustomerCount,
   Cur.CustomerCount - Prv.CustomerCount AS CustomerGrowth
FROM CustomerCountCte Cur
   LEFT JOIN CustomerCountCte Prv ON Cur.OrderYear = Prv.OrderYear + 1
ORDER BY Cur.OrderYear ASC;
GO


-------------------------------------------------------------------------------

/****************************
 * Recursive CTEs
 ****************************/

-- NEED to introduce UNION ALL if showing this.

/* Set up table

-- Use your database.
USE johnkeller;

CREATE TABLE HR.Employee
(
   EmployeeID INT NOT NULL,
   FirstName NVARCHAR(32) NOT NULL,
   LastName NVARCHAR(32) NOT NULL,
   ManagerID INT NULL,

   CONSTRAINT [PK_HR_Employee_EmployeeID] PRIMARY KEY CLUSTERED
   (
      EmployeeID ASC
   ),

   CONSTRAINT [FK_HR_Employee_ManagerID_HR_Employee_EmployeeID] FOREIGN KEY
   (
      ManagerID
   )
   REFERENCES HR.Employee
   (
      EmployeeID
   )
);



INSERT HR.Employee(EmployeeID, FirstName, LastName, ManagerID)
VALUES
   (1, N'Jane', N'Smith', NULL),
   (2, N'John', N'Doe', 1),
   (3, N'Scott', N'Jackson', 1),
   (4, N'Ben', N'Johnson', 2),
   (5, N'Hannah', N'Sullivan', 2),
   (6, N'James', N'Swihart', 4),
   (7, N'Zach', N'Thomas', 5),
   (8, N'Sam', N'Jones', 4);
*/

-- Look at the data.
SELECT E.EmployeeId, E.ManagerId, E.FirstName, E.LastName
FROM HR.Employee E;

-- Traverse the structure
WITH EmployeeCte(EmployeeID, ManagerID, FirstName, LastName, [Level]) AS
   (
      -- Anchor member: begin with desired manager.
      SELECT E.EmployeeID, E.ManagerID, E.FirstName, E.LastName, 0
      FROM HR.Employee E
      WHERE E.ManagerID IS NULL
   
      UNION ALL
   
      -- Recursive member: traverse reporting structure.
      SELECT E.EmployeeID, E.ManagerId, E.FirstName, E.LastName, M.[Level] + 1
      FROM EmployeeCte M
         INNER JOIN HR.Employee E ON M.EmployeeID = E.ManagerID
   )
SELECT E.EmployeeID, E.ManagerID, E.FirstName, E.LastName, E.[Level]
FROM EmployeeCte E;
GO


-- More fun with recursive CTE

WITH EmployeeCte(EmployeeID, ManagerID, FirstName, LastName, [Level]) AS
   (
      -- Anchor member: begin with desired manager.
      SELECT E.EmployeeID, E.ManagerID, E.FirstName, E.LastName, 0
      FROM HR.Employee E
      WHERE E.ManagerID IS NULL
   
      UNION ALL
   
      -- Recursive member: traverse reporting structure.
      SELECT E.EmployeeID, E.ManagerID, E.FirstName, E.LastName, M.[Level] + 1
      FROM EmployeeCte M
         INNER JOIN HR.Employee E ON M.EmployeeID = E.ManagerID
   )
SELECT E.EmployeeID, E.ManagerID, REPLICATE(N'   ', E.[Level])
   + E.FirstName + N' ' + E.LastName AS Employee
FROM EmployeeCte E
ORDER BY E.EmployeeID ASC;

-- How can we print the reporting structure?
-- We can't make an assumption on order of EmployeeID.

-- Let's introduce a path for purposes of ordering.
WITH EmployeeCte(EmployeeID, ManagerID, FirstName, LastName, [Level], [Path]) AS
   (
      -- Anchor member: begin with desired manager.
      SELECT E.EmployeeID, E.ManagerID, E.FirstName, E.LastName, 0,
         CAST(E.EmployeeID AS VARCHAR(MAX))
      FROM HR.Employee E
      WHERE E.ManagerID IS NULL
   
      UNION ALL
   
      -- Recursive member: traverse reporting structure.
      SELECT E.EmployeeID, E.ManagerID, E.FirstName, E.LastName, M.[Level] + 1,
         M.[Path] + '.' + CAST(E.EmployeeID AS VARCHAR(10))
      FROM EmployeeCte M
         INNER JOIN HR.Employee E ON M.EmployeeID = E.ManagerID
   )
SELECT E.EmployeeID, E.[Path],
   REPLICATE(N'   ', E.[Level]) + E.LastName + N', ' + E.FirstName AS Employee
FROM EmployeeCte E
ORDER BY E.[Path] ASC;
