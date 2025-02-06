-- Comments can use "--" for single line.  T-SQL version of "//" in C#.

/*
   Comments can also be multi-line using slash-asterisk.
   Reverse it to asterisk-slash to close your comment block.
*/

-- If you haven't made a DB yet, uncomment the line below!
-- CREATE DATABASE [CIS560];
-- Change database.
USE CIS560; -- Remember to use YOUR database here, or just use the drop-down list.
GO

-- Syntax
-- Semicolon is the statement terminator.
-- Square brackets are for delimiting irregular identifiers.
--    You can also use double quotes which is the SQL standard.

-- Create schema for the demo objects.
CREATE SCHEMA [Demo] AUTHORIZATION [dbo];
GO

/**************************************
 * Basic columns
 **************************************/
DROP TABLE IF EXISTS Demo.School;

/* Remember, columns are a set.
   Each column must have:
   - Unique name
   - Data type
   - Nullability
*/
CREATE TABLE Demo.School
(
   [Name] NVARCHAR(64),
   YearEstablished SMALLINT,
   Nickname NVARCHAR(32),
   Colors NVARCHAR(128),
   City NVARCHAR(64),
   StateCode NCHAR(2)
);

INSERT Demo.School([Name], YearEstablished, Nickname, Colors, City, StateCode)
VALUES
   (N'Kansas State University', 1863, N'Wildcats', N'Royal Purple', N'Manhattan', N'KS'),
   (N'University of Kansas', 1865, N'Jayhawks', N'Crimson, Blue', N'Lawrence', N'KS'),
   (N'University of Oklahoma', 1914, N'Sooners', N'Crimson, Cream', N'Norman', N'OK'),
   (N'Oklahoma State University', 1890, N'Cowboys', N'Orange, Black', N'Stillwater', N'OK'),
   (N'Iowa State University', 1858, N'Cyclones', N'Cardinal, Gold', N'Ames', N'IA'),
   (N'University of Iowa', 1847, N'Hawkeyes', N'Black, Gold', N'Iowa City', N'IA'),
   (N'University of Missouri', 1839, N'Tigers', N'Black, MU Gold', N'Columbia', N'MO'),
   (N'University of Nebraska', 1869, N'Cornhuskers', N'Scarlet, Cream', N'Lincoln', N'NE');

-- Basic SELECT statement.
-- * means all columns.
-- DO NOT USE * in your solutions!
SELECT *
FROM Demo.School;


/**************************************
 * Omitting columns on INSERT
 **************************************/
DROP TABLE IF EXISTS Demo.School;

CREATE TABLE Demo.School
(
   [Name] NVARCHAR(64),
   YearEstablished SMALLINT,
   Nickname NVARCHAR(32),
   Colors NVARCHAR(128),
   Website NVARCHAR(128), -- Not in the INSERT below.
   City NVARCHAR(64),
   StateCode NCHAR(2)
);

INSERT Demo.School([Name], YearEstablished, Nickname, Colors, City, StateCode)
VALUES
   (N'Kansas State University', 1863, N'Wildcats', N'Royal Purple', N'Manhattan', N'KS'),
   (N'University of Kansas', 1865, N'Jayhawks', N'Crimson, Blue', N'Lawrence', N'KS'),
   (N'University of Oklahoma', 1914, N'Sooners', N'Crimson, Cream', N'Norman', N'OK'),
   (N'Oklahoma State University', 1890, N'Cowboys', N'Orange, Black', N'Stillwater', N'OK'),
   (N'Iowa State University', 1858, N'Cyclones', N'Cardinal, Gold', N'Ames', N'IA'),
   (N'University of Iowa', 1847, N'Hawkeyes', N'Black, Gold', N'Iowa City', N'IA'),
   (N'University of Missouri', 1839, N'Tigers', N'Black, MU Gold', N'Columbia', N'MO'),
   (N'University of Nebraska', 1869, N'Cornhuskers', N'Scarlet, Cream', N'Lincoln', N'NE');

-- What will the value of Website be?
SELECT *
FROM Demo.School;


/********************************************
CONSTRAINTS
 
Declarative rules that the DBMS will enforce

The DBMS checks every time:
- New data will be added
- Data is modified
- In some cases, when data is deleted

Any operation that violates a constraint fails and returns an error.
********************************************/

/**************************************
 * Making values mandatory
 **************************************/
DROP TABLE IF EXISTS Demo.School;

CREATE TABLE Demo.School
(
   [Name] NVARCHAR(64),
   YearEstablished SMALLINT,
   Nickname NVARCHAR(32),
   Colors NVARCHAR(128),
   Website NVARCHAR(128) NOT NULL, -- Still not in the INSERT below.
   City NVARCHAR(64),
   StateCode NCHAR(2)
);

INSERT Demo.School([Name], YearEstablished, Nickname, Colors, City, StateCode)
VALUES
   (N'Kansas State University', 1863, N'Wildcats', N'Royal Purple', N'Manhattan', N'KS'),
   (N'University of Kansas', 1865, N'Jayhawks', N'Crimson, Blue', N'Lawrence', N'KS'),
   (N'University of Oklahoma', 1914, N'Sooners', N'Crimson, Cream', N'Norman', N'OK'),
   (N'Oklahoma State University', 1890, N'Cowboys', N'Orange, Black', N'Stillwater', N'OK'),
   (N'Iowa State University', 1858, N'Cyclones', N'Cardinal, Gold', N'Ames', N'IA'),
   (N'University of Iowa', 1847, N'Hawkeyes', N'Black, Gold', N'Iowa City', N'IA'),
   (N'University of Missouri', 1839, N'Tigers', N'Black, MU Gold', N'Columbia', N'MO'),
   (N'University of Nebraska', 1869, N'Cornhuskers', N'Scarlet, Cream', N'Lincoln', N'NE');
GO

-- What exists in the table?
SELECT *
FROM Demo.School;


/**************************************
 * Let's make all columns NOT NULL
 **************************************/
DROP TABLE IF EXISTS Demo.School;

CREATE TABLE Demo.School
(
   [Name] NVARCHAR(64) NOT NULL,
   YearEstablished SMALLINT NOT NULL,
   Nickname NVARCHAR(32) NOT NULL,
   Colors NVARCHAR(128) NOT NULL,
   City NVARCHAR(64) NOT NULL,
   StateCode NCHAR(2) NOT NULL
);

INSERT Demo.School([Name], YearEstablished, Nickname, Colors, City, StateCode)
VALUES
   (N'Kansas State University', 1863, N'Wildcats', N'Royal Purple', N'Manhattan', N'KS'),
   (N'University of Kansas', 1865, N'Jayhawks', N'Crimson, Blue', N'Lawrence', N'KS'),
   (N'University of Oklahoma', 1914, N'Sooners', N'Crimson, Cream', N'Norman', N'OK'),
   (N'Oklahoma State University', 1890, N'Cowboys', N'Orange, Black', N'Stillwater', N'OK'),
   (N'Iowa State University', 1858, N'Cyclones', N'Cardinal, Gold', N'Ames', N'IA'),
   (N'University of Iowa', 1847, N'Hawkeyes', N'Black, Gold', N'Iowa City', N'IA'),
   (N'University of Missouri', 1839, N'Tigers', N'Black, MU Gold', N'Columbia', N'MO'),
   (N'University of Nebraska', 1869, N'Cornhuskers', N'Scarlet, Cream', N'Lincoln', N'NE');

-- All should be good.
SELECT *
FROM Demo.School;


/**************************************
 * Let's introduce a PRIMARY KEY
 **************************************/
DROP TABLE IF EXISTS Demo.School;

CREATE TABLE Demo.School
(
   SchoolId INT NOT NULL PRIMARY KEY,
   [Name] NVARCHAR(64) NOT NULL,
   YearEstablished SMALLINT NOT NULL,
   Nickname NVARCHAR(32) NOT NULL,
   Colors NVARCHAR(128) NOT NULL,
   City NVARCHAR(64) NOT NULL,
   StateCode NCHAR(2) NOT NULL
);

INSERT Demo.School(SchoolId, [Name], YearEstablished, Nickname, Colors, City, StateCode)
VALUES
   (1, N'Kansas State University', 1863, N'Wildcats', N'Royal Purple', N'Manhattan', N'KS'),
   (2, N'University of Kansas', 1865, N'Jayhawks', N'Crimson, Blue', N'Lawrence', N'KS'),
   (3, N'University of Oklahoma', 1914, N'Sooners', N'Crimson, Cream', N'Norman', N'OK'),
   (4, N'Oklahoma State University', 1890, N'Cowboys', N'Orange, Black', N'Stillwater', N'OK'),
   (5, N'Iowa State University', 1858, N'Cyclones', N'Cardinal, Gold', N'Ames', N'IA'),
   (6, N'University of Iowa', 1847, N'Hawkeyes', N'Black, Gold', N'Iowa City', N'IA'),
   (7, N'University of Missouri', 1839, N'Tigers', N'Black, MU Gold', N'Columbia', N'MO'),
   (8, N'University of Nebraska', 1869, N'Cornhuskers', N'Scarlet, Cream', N'Lincoln', N'NE'),
   (8, N'University of Nebraska', 0, N'Mavericks', N'Black, Crimson', N'Omaha', N'NE');

-- What's in the table.
SELECT *
FROM Demo.School;

INSERT Demo.School(SchoolId, [Name], YearEstablished, Nickname, Colors, City, StateCode)
VALUES
   (1, N'Kansas State University', 1863, N'Wildcats', N'Royal Purple', N'Manhattan', N'KS'),
   (2, N'University of Kansas', 1865, N'Jayhawks', N'Crimson, Blue', N'Lawrence', N'KS'),
   (3, N'University of Oklahoma', 1914, N'Sooners', N'Crimson, Cream', N'Norman', N'OK'),
   (4, N'Oklahoma State University', 1890, N'Cowboys', N'Orange, Black', N'Stillwater', N'OK'),
   (5, N'Iowa State University', 1858, N'Cyclones', N'Cardinal, Gold', N'Ames', N'IA'),
   (6, N'University of Iowa', 1847, N'Hawkeyes', N'Black, Gold', N'Iowa City', N'IA'),
   (7, N'University of Missouri', 1839, N'Tigers', N'Black, MU Gold', N'Columbia', N'MO'),
   (8, N'University of Nebraska', 1869, N'Cornhuskers', N'Scarlet, Cream', N'Lincoln', N'NE'),
   (9, N'University of Nebraska', 0, N'Mavericks', N'Black, Crimson', N'Omaha', N'NE');

-- Should have 9 rows.
SELECT *
FROM Demo.School;

/********************************************
UNIQUE CONSTRAINTS

Enforces uniqueness like a PRIMARY KEY.
Unlike a PRIMARY KEY:
- Can have more than one.
- Will allow NULLs.

********************************************/

/**************************************
 * Let's introduce a UNIQUE KEY
 **************************************/
DROP TABLE IF EXISTS Demo.School;

CREATE TABLE Demo.School
(
   SchoolId INT NOT NULL PRIMARY KEY,
   [Name] NVARCHAR(64) NOT NULL UNIQUE,
   YearEstablished SMALLINT NOT NULL,
   Nickname NVARCHAR(32) NOT NULL,
   Colors NVARCHAR(128) NOT NULL,
   City NVARCHAR(64) NOT NULL,
   StateCode NCHAR(2) NOT NULL
);

INSERT Demo.School(SchoolId, [Name], YearEstablished, Nickname, Colors, City, StateCode)
VALUES
   (1, N'Kansas State University', 1863, N'Wildcats', N'Royal Purple', N'Manhattan', N'KS'),
   (2, N'University of Kansas', 1865, N'Jayhawks', N'Crimson, Blue', N'Lawrence', N'KS'),
   (3, N'University of Oklahoma', 1914, N'Sooners', N'Crimson, Cream', N'Norman', N'OK'),
   (4, N'Oklahoma State University', 1890, N'Cowboys', N'Orange, Black', N'Stillwater', N'OK'),
   (5, N'Iowa State University', 1858, N'Cyclones', N'Cardinal, Gold', N'Ames', N'IA'),
   (6, N'University of Iowa', 1847, N'Hawkeyes', N'Black, Gold', N'Iowa City', N'IA'),
   (7, N'University of Missouri', 1839, N'Tigers', N'Black, MU Gold', N'Columbia', N'MO'),
   (8, N'University of Nebraska', 1869, N'Cornhuskers', N'Scarlet, Cream', N'Lincoln', N'NE'),
   (9, N'University of Nebraska', 0, N'Mavericks', N'Black, Crimson', N'Omaha', N'NE');

INSERT Demo.School(SchoolId, [Name], YearEstablished, Nickname, Colors, City, StateCode)
VALUES
   (1, N'Kansas State University', 1863, N'Wildcats', N'Royal Purple', N'Manhattan', N'KS'),
   (2, N'University of Kansas', 1865, N'Jayhawks', N'Crimson, Blue', N'Lawrence', N'KS'),
   (3, N'University of Oklahoma', 1914, N'Sooners', N'Crimson, Cream', N'Norman', N'OK'),
   (4, N'Oklahoma State University', 1890, N'Cowboys', N'Orange, Black', N'Stillwater', N'OK'),
   (5, N'Iowa State University', 1858, N'Cyclones', N'Cardinal, Gold', N'Ames', N'IA'),
   (6, N'University of Iowa', 1847, N'Hawkeyes', N'Black, Gold', N'Iowa City', N'IA'),
   (7, N'University of Missouri', 1839, N'Tigers', N'Black, MU Gold', N'Columbia', N'MO'),
   (8, N'University of Nebraska-Lincoln', 1869, N'Cornhuskers', N'Scarlet, Cream', N'Lincoln', N'NE'),
   (9, N'University of Nebraska-Omaha', 0, N'Mavericks', N'Black, Crimson', N'Omaha', N'NE');

/********************************************
CHECK CONSTRAINTS

Can force domain ranges (0 to 100)
Can check for discrete values (�Yes�, �No�, �Maybe�)
Comparison between two columns: EndDate >= StartDate
Any predicate using the columns of the table.
********************************************/

/**************************************
 * Let's introduce a CHECK CONSTRAINT
 **************************************/
DROP TABLE IF EXISTS Demo.School;

CREATE TABLE Demo.School
(
   SchoolId INT NOT NULL PRIMARY KEY,
   [Name] NVARCHAR(64) NOT NULL UNIQUE,
   YearEstablished SMALLINT NOT NULL CHECK(YearEstablished BETWEEN 1000 AND 9999),
   Nickname NVARCHAR(32) NOT NULL,
   Colors NVARCHAR(128) NOT NULL,
   City NVARCHAR(64) NOT NULL,
   StateCode NCHAR(2) NOT NULL
);

INSERT Demo.School(SchoolId, [Name], YearEstablished, Nickname, Colors, City, StateCode)
VALUES
   (1, N'Kansas State University', 1863, N'Wildcats', N'Royal Purple', N'Manhattan', N'KS'),
   (2, N'University of Kansas', 1865, N'Jayhawks', N'Crimson, Blue', N'Lawrence', N'KS'),
   (3, N'University of Oklahoma', 1914, N'Sooners', N'Crimson, Cream', N'Norman', N'OK'),
   (4, N'Oklahoma State University', 1890, N'Cowboys', N'Orange, Black', N'Stillwater', N'OK'),
   (5, N'Iowa State University', 1858, N'Cyclones', N'Cardinal, Gold', N'Ames', N'IA'),
   (6, N'University of Iowa', 1847, N'Hawkeyes', N'Black, Gold', N'Iowa City', N'IA'),
   (7, N'University of Missouri', 1839, N'Tigers', N'Black, MU Gold', N'Columbia', N'MO'),
   (8, N'University of Nebraska-Lincoln', 1869, N'Cornhuskers', N'Scarlet, Cream', N'Lincoln', N'NE'),
   (9, N'University of Nebraska-Omaha', 0, N'Mavericks', N'Black, Crimson', N'Omaha', N'NE');

INSERT Demo.School(SchoolId, [Name], YearEstablished, Nickname, Colors, City, StateCode)
VALUES
   (1, N'Kansas State University', 1863, N'Wildcats', N'Royal Purple', N'Manhattan', N'KS'),
   (2, N'University of Kansas', 1865, N'Jayhawks', N'Crimson, Blue', N'Lawrence', N'KS'),
   (3, N'University of Oklahoma', 1914, N'Sooners', N'Crimson, Cream', N'Norman', N'OK'),
   (4, N'Oklahoma State University', 1890, N'Cowboys', N'Orange, Black', N'Stillwater', N'OK'),
   (5, N'Iowa State University', 1858, N'Cyclones', N'Cardinal, Gold', N'Ames', N'IA'),
   (6, N'University of Iowa', 1847, N'Hawkeyes', N'Black, Gold', N'Iowa City', N'IA'),
   (7, N'University of Missouri', 1839, N'Tigers', N'Black, MU Gold', N'Columbia', N'MO'),
   (8, N'University of Nebraska-Lincoln', 1869, N'Cornhuskers', N'Scarlet, Cream', N'Lincoln', N'NE'),
   (9, N'University of Nebraska-Omaha', 1908, N'Mavericks', N'Black, Crimson', N'Omaha', N'NE');

/******************************************
 * DEFAULT CONSTRAINTS
 *    and auto-assigned values
 ******************************************/
DROP TABLE IF EXISTS Demo.School;

CREATE TABLE Demo.School
(
   SchoolId INT NOT NULL IDENTITY(1, 1) PRIMARY KEY, -- Use Identity property
   [Name] NVARCHAR(64) NOT NULL UNIQUE,
   YearEstablished SMALLINT NOT NULL CHECK(YearEstablished BETWEEN 1000 AND 9999),
   Nickname NVARCHAR(32) NOT NULL,
   City NVARCHAR(64) NOT NULL,
   StateCode NCHAR(2) NOT NULL,
   CreatedOn DATETIMEOFFSET NOT NULL DEFAULT(SYSDATETIMEOFFSET()) -- Default constraint
);

-- There is NO SchoolId or CreatedOn provided.
INSERT Demo.School([Name], YearEstablished, Nickname, City, StateCode)
VALUES
   (N'Kansas State University', 1863, N'Wildcats', N'Manhattan', N'KS'),
   (N'University of Kansas', 1865, N'Jayhawks', N'Lawrence', N'KS'),
   (N'University of Oklahoma', 1914, N'Sooners', N'Norman', N'OK'),
   (N'Oklahoma State University', 1890, N'Cowboys', N'Stillwater', N'OK'),
   (N'Iowa State University', 1858, N'Cyclones', N'Ames', N'IA'),
   (N'University of Iowa', 1847, N'Hawkeyes', N'Iowa City', N'IA'),
   (N'University of Missouri', 1839, N'Tigers', N'Columbia', N'MO'),
   (N'University of Nebraska-Lincoln', 1869, N'Cornhuskers', N'Lincoln', N'NE');

-- See the values.
SELECT *
FROM Demo.School;

-- We CAN provide a value for a column with a default constraint.
INSERT Demo.School([Name], YearEstablished, Nickname, City, StateCode, CreatedOn)
VALUES
   (N'University of Nebraska-Omaha', 1908, N'Mavericks', N'Omaha', N'NE', '2020-01-01 00:00:00 -06:00');

SELECT *
FROM Demo.School;

-- You aren't supposed to provide a value for an identity column.
-- You can, but requires an option to be turned on.
INSERT Demo.School(SchoolId, [Name], YearEstablished, Nickname, City, StateCode)
VALUES
   (10, N'A new school', 2018, N'Outlaws', N'Lawrence', N'KS');

-- Rather than IDENTITY, you can use a sequence object.
-- Sequences are standard, and are setup using DEFAULT CONSTRAINTS.
DROP TABLE IF EXISTS Demo.School;
DROP SEQUENCE IF EXISTS Demo.SchoolId;

CREATE SEQUENCE Demo.SchoolId
AS INT
   MINVALUE 1
   INCREMENT BY 1
   NO CYCLE;

CREATE TABLE Demo.School
(
   SchoolId INT NOT NULL PRIMARY KEY
      DEFAULT(NEXT VALUE FOR Demo.SchoolId),
   [Name] NVARCHAR(64) NOT NULL UNIQUE,
   YearEstablished SMALLINT NOT NULL CHECK(YearEstablished BETWEEN 1000 AND 9999),
   Nickname NVARCHAR(32) NOT NULL,
   City NVARCHAR(64) NOT NULL,
   StateCode NCHAR(2) NOT NULL,
   CreatedOn DATETIMEOFFSET NOT NULL DEFAULT(SYSDATETIMEOFFSET()) -- Default constraint
);

INSERT Demo.School([Name], YearEstablished, Nickname, City, StateCode)
VALUES
   (N'Kansas State University', 1863, N'Wildcats', N'Manhattan', N'KS'),
   (N'University of Kansas', 1865, N'Jayhawks', N'Lawrence', N'KS'),
   (N'University of Oklahoma', 1914, N'Sooners', N'Norman', N'OK'),
   (N'Oklahoma State University', 1890, N'Cowboys', N'Stillwater', N'OK'),
   (N'Iowa State University', 1858, N'Cyclones', N'Ames', N'IA'),
   (N'University of Iowa', 1847, N'Hawkeyes', N'Iowa City', N'IA'),
   (N'University of Missouri', 1839, N'Tigers', N'Columbia', N'MO'),
   (N'University of Nebraska-Lincoln', 1869, N'Cornhuskers', N'Lincoln', N'NE');

SELECT *
FROM Demo.School;


/********************************************
FOREIGN KEY CONSTRAINTS

Enforces referential integrity.

Rules
- The referenced columns must be either the PRIMARY KEY or any UNIQUE KEY.
- The referencing columns must match the type of the referenced columns.

The constraint works both directions.
- Referencing table is checked when foreign key value is inserted.
- Referencing table is checked when foreign key value is updated.
- The referenced table is checked when a value is deleted.
********************************************/

/******************************************
 * Let's introduce a FOREIGN KEY CONSTRAINT
 ******************************************/
DROP TABLE IF EXISTS Demo.School;
DROP TABLE IF EXISTS Demo.Conference;

CREATE TABLE Demo.Conference
(
   Nickname NVARCHAR(32) NOT NULL PRIMARY KEY,
   [Name] NVARCHAR(64) NOT NULL UNIQUE,
   YearFounded SMALLINT NOT NULL,
   Members TINYINT NOT NULL
);

CREATE TABLE Demo.School
(
   SchoolId INT NOT NULL PRIMARY KEY,
   [Name] NVARCHAR(64) NOT NULL UNIQUE,
   YearEstablished SMALLINT NOT NULL CHECK(YearEstablished BETWEEN 1000 AND 9999),
   Nickname NVARCHAR(32) NOT NULL,
   Colors NVARCHAR(128) NOT NULL,
   City NVARCHAR(64) NOT NULL,
   StateCode NCHAR(2) NOT NULL,
   Conference NVARCHAR(32) NOT NULL FOREIGN KEY REFERENCES Demo.Conference(Nickname)
);

INSERT Demo.Conference(Nickname, [Name], YearFounded, Members)
VALUES
   (N'ACC', N'Atlantic Coast Conference', 1953, 15),
   (N'Big Ten', N'Big Ten Conference', 1896, 14),
   (N'Big 12', N'Big 12 Conference', 1996, 10),
   (N'Pac-12', N'Pac-12 Conference', 1959, 12),
   (N'SEC', N'Southeastern Conference', 1932, 14);

INSERT Demo.School(SchoolId, [Name], YearEstablished, Nickname, Colors, City, StateCode, Conference)
VALUES
   (1, N'Kansas State University', 1863, N'Wildcats', N'Royal Purple', N'Manhattan', N'KS', N'Big 12'),
   (2, N'University of Kansas', 1865, N'Jayhawks', N'Crimson, Blue', N'Lawrence', N'KS', N'Big 12'),
   (3, N'University of Oklahoma', 1914, N'Sooners', N'Crimson, Cream', N'Norman', N'OK', N'Big 12'),
   (4, N'Oklahoma State University', 1890, N'Cowboys', N'Orange, Black', N'Stillwater', N'OK', N'Big 12'),
   (5, N'Iowa State University', 1858, N'Cyclones', N'Cardinal, Gold', N'Ames', N'IA', N'Big 12'),
   (6, N'University of Iowa', 1847, N'Hawkeyes', N'Black, Gold', N'Iowa City', N'IA', N'Big Ten'),
   (7, N'University of Missouri', 1839, N'Tigers', N'Black, MU Gold', N'Columbia', N'MO', N'SEC'),
   (8, N'University of Nebraska-Lincoln', 1869, N'Cornhuskers', N'Scarlet, Cream', N'Lincoln', N'NE', N'Big Ten');

-- Insert University of Nebraska-Omaha, different league.
INSERT Demo.School(SchoolId, [Name], YearEstablished, Nickname, Colors, City, StateCode, Conference)
VALUES
   (9, N'University of Nebraska-Omaha', 1908, N'Mavericks', N'Black, Crimson', N'Omaha', N'NE', N'Summit');

INSERT Demo.Conference(Nickname, [Name], YearFounded, Members)
VALUES
   (N'Summit', N'The Summit League', 1982, 9);

-- Now it should work.
INSERT Demo.School(SchoolId, [Name], YearEstablished, Nickname, Colors, City, StateCode, Conference)
VALUES
   (9, N'University of Nebraska-Omaha', 1908, N'Mavericks', N'Black, Crimson', N'Omaha', N'NE', N'Summit');

SELECT *
FROM Demo.School;

-- Updates are checked too.
UPDATE Demo.School
SET Conference = N'Big Twelve'
WHERE SchoolId = 1;

-- Let's remove our new league.
DELETE Demo.Conference
WHERE Nickname = N'Summit';
