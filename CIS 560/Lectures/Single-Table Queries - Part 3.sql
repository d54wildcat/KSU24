/**************************************
 * Predicate Operators
 **************************************/
-- IN
SELECT O.OrderID, O.OrderDate, O.CustomerID
FROM Sales.Orders O
WHERE O.CustomerID IN (3,16,147);

-- Equivalent expression
SELECT O.OrderID, O.OrderDate, O.CustomerID
FROM Sales.Orders O
WHERE O.CustomerID = 3
   OR O.CustomerID = 16
   OR O.CustomerID = 147;

-- BETWEEN
SELECT O.OrderID, O.OrderDate, O.CustomerID
FROM Sales.Orders O
WHERE O.OrderDate BETWEEN '2016-01-01' AND '2016-01-31';

-- LIKE
SELECT C.*
FROM Sales.Customers C
WHERE C.CustomerName LIKE N'Tailspin%'

SELECT *
FROM Sales.Customers C
WHERE C.CustomerName LIKE N'% Toys %'

SELECT C.CustomerID, C.CustomerName, C.PhoneNumber
FROM Sales.Customers C
WHERE C.PhoneNumber NOT LIKE N'(215) [0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]';

-- Also single character wildcard, N'_', supported
-- And ranges/sets are supported: N'[0-9A-Z][0123]'
-- And not in range: [^ABC]


/**************************************
 * Collations
 **************************************/

-- LIKE
SELECT C.*
FROM Sales.Customers C
WHERE C.CustomerName LIKE N'Tailspin%'

-- Case sensitivity depends on the collation.
-- Note the collation of eacch character column.
-- Part of the collation determines case sensitivity and accent sensitivity.
EXEC sys.sp_help N'Sales.Customers';

-- Same results because of case-insensitive collation
SELECT C.*
FROM Sales.Customers C
WHERE C.CustomerName LIKE N'tailspin%'

-- Query for collation names.
SELECT *
FROM sys.fn_helpcollations() c
WHERE c.[name] LIKE N'Latin1[_]%';

-- We can change the collation to case-sensitive.
SELECT C.*
FROM Sales.Customers C
WHERE C.CustomerName LIKE N'tailspin%' COLLATE Latin1_General_BIN;


/**************************************
 * Operator Precedence
 **************************************/
-- AND has higher precedence than OR
SELECT *
FROM Sales.Orders O
WHERE O.CustomerID = 1 AND O.SalespersonPersonID = 16
   OR O.CustomerID = 2 AND O.SalespersonPersonID = 15;

-- Equivalent
SELECT *
FROM Sales.Orders O
WHERE (O.CustomerID = 1 AND O.SalespersonPersonID = 16)
   OR (O.CustomerID = 2 AND O.SalespersonPersonID = 15);

-- Multiplication comes before addition.
SELECT 5 + 10 * 2;

-- Equivalent
SELECT 5 + (10 * 2);

/**************************************
 * CASE
 **************************************/
-- Simple form
SELECT S.StateProvinceCode, S.StateProvinceName, S.SalesTerritory,
   CASE S.StateProvinceCode
      WHEN N'AK' THEN N'Crazy Far'
      WHEN N'KS' THEN N'THE Place To Be'
      WHEN N'PR' THEN N'U.S. Territory'
      WHEN N'VI' THEN N'U.S. Territory'
      ELSE S.SalesTerritory -- What if we omit the ELSE?
   END AS NewTerritoryName
FROM [Application].StateProvinces S
ORDER BY S.StateProvinceCode ASC;

-- Searched form
SELECT S.StateProvinceCode, S.StateProvinceName, S.SalesTerritory,
   CASE
      WHEN S.StateProvinceCode = N'AK' THEN N'Crazy Far'
      WHEN S.StateProvinceCode = N'KS' THEN N'THE Place To Be'
      WHEN S.SalesTerritory = N'External' THEN N'U.S. Territory'
      ELSE S.SalesTerritory -- What if we omit the ELSE?
   END AS NewTerritoryName
FROM [Application].StateProvinces S
ORDER BY S.StateProvinceCode ASC;

-- Common need #1
SELECT O.OrderID, O.Comments AS OriginalComments,
   CASE
      WHEN O.Comments IS NOT NULL THEN O.Comments
      ELSE N'(No comments)' -- Does not need to be a literal
   END AS Comments
FROM Sales.Orders O;

-- Convenient replacement
SELECT O.OrderID, O.Comments AS OriginalComments,
   ISNULL(O.Comments, N'(No comments)') AS Comments
FROM Sales.Orders O;

-- What if you needed more options?
SELECT O.OrderID, O.Comments AS OriginalComments,
   CASE
      WHEN O.Comments IS NOT NULL THEN O.Comments
      WHEN O.InternalComments IS NOT NULL THEN O.InternalComments
      ELSE N'(No comments)'
   END AS Comments
FROM Sales.Orders O;

-- Equivalent
SELECT O.OrderID, O.Comments AS OriginalComments,
   COALESCE(O.Comments, O.InternalComments, N'(No comments)') AS Comments
FROM Sales.Orders O;

-- Another common pattern
SELECT P.PersonID, P.IsSalesperson,
   CASE
      WHEN P.IsSalesperson = 1 THEN N'In Sales Department'
      ELSE N'Not Sales'
   END SalesStatus
FROM [Application].People P
WHERE P.IsEmployee = 1;

-- Equivalent with IIF
SELECT P.PersonID, P.IsSalesperson,
   IIF(P.IsSalesperson = 1, N'In Sales Department', N'Not Sales') AS SalesStatus
FROM [Application].People P
WHERE P.IsEmployee = 1;

/************************************
 * Variables and Data Type Conversion
 ************************************/
DECLARE @IntValue INT = 12312;
SELECT CAST(@IntValue AS VARCHAR(10)) IntAsVarchar;


-- Using CONVERT
DECLARE @Now DATETIMEOFFSET = SYSDATETIME();

SELECT
   CONVERT(NCHAR(10), @Now, 101) AS [U.S. Format],
   CONVERT(NCHAR(8), @Now, 112) AS [ISO Format];


-- Let's use variables in a query.
DECLARE @SalespersonPersonID INT = 15;

SELECT O.OrderDate,
   COUNT(*) AS OrderCount,
   COUNT(DISTINCT O.CustomerID) AS CustomerCount
FROM Sales.Orders O
WHERE O.SalespersonPersonID = @SalespersonPersonID
GROUP BY O.OrderDate
ORDER BY O.OrderDate ASC;
GO

DECLARE
   @FirstDate DATE = '2016-01-01',
   @LastDate DATE = '2016-01-31';

SELECT O.OrderDate,
   COUNT(*) AS OrderCount,
   COUNT(DISTINCT O.CustomerID) AS CustomerCount
FROM Sales.Orders O
WHERE O.OrderDate BETWEEN @FirstDate AND @LastDate
GROUP BY O.OrderDate
ORDER BY O.OrderDate ASC;
GO

-- Notice the use of GO as a batch separator.


/***********************
 * Character Data Types
 ***********************/

-- Declaration Lengths
DECLARE
   @nchar NCHAR = N'abc',
   @nvarchar NVARCHAR = N'abc';
   
SELECT LEN(@nchar) AS [@nchar length], @nchar AS [@nchar value];
SELECT LEN(@nvarchar) AS [@nvarchar length], @nvarchar AS [@nvarchar value];

-- Be careful of truncation.
DECLARE @MyVariable NVARCHAR(30) = N'This string is longer than thirty characters.';

SELECT LEN(@MyVariable) AS [Length], @MyVariable AS [Value];
GO

-- When inserting/updating in a table, though, it will raise an error.
DECLARE @MyTable TABLE
(
   MyValue NVARCHAR(30)
);

INSERT @MyTable(MyValue)
VALUES(N'This string is longer than thirty characters.');
GO


/***********************
 * String Functions
 ***********************/

-- A few function examples
-- CONCAT function similar to concatenation operator (+),
--    but replaces nulls with an empty value.
SELECT C.CountryName, UPPER(C.CountryName) AS UpperCaseCountryName,
   C.CountryName + N', ' + C.Continent AS CountryContinent,
   CONCAT(C.CountryName, N', ', C.Continent) AS CountryContinent2
FROM [Application].Countries C;

SELECT C.CountryName, C.IsoAlpha3Code,
   SUBSTRING(C.IsoAlpha3Code, 1, 1) AS C1,
   SUBSTRING(C.IsoAlpha3Code, 2, 1) AS C2,
   SUBSTRING(C.IsoAlpha3Code, 3, 1) AS C3
FROM [Application].Countries C;


/**************************
 * Date and Time Data Types
 **************************/

-- DATE and TIME
DECLARE @Now DATETIMEOFFSET = SYSDATETIMEOFFSET();

-- DATETIMEOFFSET is equivalent to DATETIMEOFFSET(7).

DECLARE
   @Date DATE = @Now,
   @TimeNoFractional TIME(0) = @Now,
   @TimeWithMilliseconds TIME(3) = @Now,
   @TimeFullScale TIME(7) = @Now; -- Scale of 7 is default

SELECT @Now AS [FullScale],
   @Date AS [Date],
   @TimeNoFractional AS [TimeNoFractional],
   @TimeWithMilliseconds AS [TimeWithMilliseconds],
   @TimeFullScale AS [TimeFullScale];
GO

-- DATETIME2
DECLARE @Now DATETIMEOFFSET = SYSDATETIMEOFFSET();

DECLARE
   @DateTime2NoFractional DATETIME2(0) = @Now,
   @DateTime2FullScale DATETIME2 = @Now;

SELECT
   @DateTime2NoFractional AS [DateTime2NoFractional],
   @DateTime2FullScale AS [DateTime2FullScale];

-- Implicit conversion behavior.
DECLARE @Date DATE = SYSDATETIME();
DECLARE @DateTime2 DATETIME2 = @Date;

SELECT @Date AS [Date], @DateTime2 AS [DateTime2];
GO

-- Default date value is not always obvious.
DECLARE @Time TIME(0) = SYSDATETIME();
DECLARE @DateTime2 DATETIME2(0) = @Time;

SELECT @Time AS [Time], @DateTime2 AS [DateTime2];
GO

-- Default time zone.
DECLARE @DateTime2 DATETIME2(0) = SYSDATETIME();
DECLARE @DateTimeOffset DATETIMEOFFSET(0) = @DateTime2;

SELECT @DateTime2 AS [DateTime2], @DateTimeOffset AS [DateTimeOffset];


-- Corrected.
SELECT TODATETIMEOFFSET(@DateTime2, '-05:00') AS WithCorrectOffset;

-- Examples of functions
DECLARE @Now DATETIMEOFFSET = SYSDATETIMEOFFSET();

SELECT DATEPART(YEAR, SYSDATETIMEOFFSET()) AS YearDatePartFunction, YEAR(SYSDATETIMEOFFSET()) AS YearFunction;
SELECT DATEPART(MONTH, SYSDATETIMEOFFSET()) AS MonthDatePartFunction, MONTH(SYSDATETIMEOFFSET()) AS MonthFunction;
SELECT DATEPART(DAY, SYSDATETIMEOFFSET()) AS DayDatePartFunction, DAY(SYSDATETIMEOFFSET()) AS DayFunction;
GO

-- Date names
DECLARE @Now DATETIMEOFFSET = SYSDATETIMEOFFSET();

SELECT DATENAME(WEEKDAY, @Now) AS DayOfWeekName, DATENAME(MONTH, @Now) AS [MonthName];
GO

-- DATEADD
DECLARE @Now DATETIMEOFFSET = SYSDATETIMEOFFSET();

SELECT @Now AS [Now], DATEADD(MONTH, 1, @Now) AS OneMonthFromNow;
GO

-- DATEDIFF
DECLARE
   @Date1 DATE = '2017-12-31',
   @Date2 DATE = '2018-01-01';

SELECT @Date1 AS Date1, @Date2 AS Date2,
   DATEDIFF(DAY, @Date1, @Date2) AS DifferenceInDays,
   DATEDIFF(MONTH, @Date1, @Date2) AS DifferenceInMonths,
   DATEDIFF(YEAR, @Date1, @Date2) AS DifferenceInYears
GO
