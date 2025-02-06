DROP TABLE IF EXISTS Demo.PersonAddressChange;
DROP TABLE IF EXISTS Demo.PersonAddress;
DROP TABLE IF EXISTS Demo.AddressType;
DROP TABLE IF EXISTS Demo.PersonHistory;
DROP TABLE IF EXISTS Demo.Person;

CREATE TABLE Demo.Person
(
   PersonId INT NOT NULL IDENTITY(1, 1) PRIMARY KEY,
   FirstName NVARCHAR(32) NOT NULL,
   MiddleInitial NCHAR(1) NULL,
   LastName NVARCHAR(32) NOT NULL,
   CreatedOn DATETIMEOFFSET NOT NULL DEFAULT(SYSDATETIMEOFFSET()),
   UpdatedOn DATETIMEOFFSET NOT NULL DEFAULT(SYSDATETIMEOFFSET()),

   CONSTRAINT [UK_Demo_Person_FirstName_LastName] UNIQUE
   (
      FirstName ASC,
      LastName ASC
   )
);

CREATE TABLE Demo.AddressType
(
   AddressTypeId TINYINT NOT NULL PRIMARY KEY,
   [Name] VARCHAR(8) NOT NULL UNIQUE
);

CREATE TABLE Demo.PersonAddress
(
   PersonAddressId INT NOT NULL IDENTITY(1, 1) PRIMARY KEY,
   PersonId INT NOT NULL,
   AddressTypeId TINYINT NOT NULL,
   Line1 NVARCHAR(32) NOT NULL,
   Line2 NVARCHAR(32) NULL,
   City NVARCHAR(64) NOT NULL,
   StateCode CHAR(2) NOT NULL,
   ZipCode CHAR(5) NOT NULL,
   CreatedOn DATETIMEOFFSET NOT NULL DEFAULT(SYSDATETIMEOFFSET()),
   UpdatedOn DATETIMEOFFSET NOT NULL DEFAULT(SYSDATETIMEOFFSET()),

   CONSTRAINT [UK_Demo_PersonAddress_PersonId_AddressTypeId] UNIQUE
   (
      PersonId ASC,
      AddressTypeId ASC
   ),

   CONSTRAINT [FK_Demo_PersonAddress_Demo_Person] FOREIGN KEY(PersonId)
   REFERENCES Demo.Person(PersonId),

   CONSTRAINT [FK_Demo_PersonAddress_Demo_AddressType] FOREIGN KEY(AddressTypeId)
   REFERENCES Demo.AddressType(AddressTypeId)
);

CREATE TABLE Demo.PersonAddressChange
(
   PersonAddressChangeId INT NOT NULL IDENTITY(1, 1) PRIMARY KEY,
   PersonId INT NOT NULL,
   AddressTypeId TINYINT NOT NULL,
   Operation NVARCHAR(8) NOT NULL,
   CreatedOn DATETIMEOFFSET NOT NULL DEFAULT(SYSDATETIMEOFFSET())
);

INSERT Demo.AddressType(AddressTypeId, [Name])
VALUES
   (1, 'Home'),
   (2, 'Work'),
   (3, 'School'),
   (4, 'Other');

INSERT Demo.Person(FirstName, LastName)
VALUES
   (N'John', N'Doe'),
   (N'Joe', N'Robertson'),
   (N'Fred', N'Rogers'),
   (N'Marie', N'Jones');

INSERT Demo.PersonAddress(PersonId, AddressTypeId, Line1, Line2, City, StateCode, ZipCode)
SELECT P.PersonId, T.AddressTypeId, S.Line1, S.Line2, S.City, S.StateCode, S.ZipCode
FROM
      (
         VALUES
            (N'John', N'Doe', 'Home', N'6587 Some St.', N'Apt. A', N'Manhattan', 'KS', '66502'),
            (N'John', N'Doe', 'Work', N'1298 Main St.', N'White van in the alley', N'Manhattan', 'KS', '66502'),
            (N'Joe', N'Robertson', 'Home', N'6462 Smooth Dr.', NULL, N'New York City', 'NY', '67890'),
            (N'Joe', N'Robertson', 'Work', N'123 Sesame St.', NULL, N'PBS Zone', 'NY', '12345'),
            (N'Fred', N'Rogers', 'Work', N'234 Neighborhood Way', NULL, N'Neighborhood', 'NY', '12345'),
            (N'Marie', N'Jones', 'Work', N'1298 Snowy Dr.', N'Cold Zone', N'North Pole', 'AK', '98799')
      ) S(FirstName, LastName, AddressType, Line1, Line2, City, StateCode, ZipCode)
   INNER JOIN Demo.Person P ON P.FirstName = S.FirstName
      AND P.LastName = S.LastName
   INNER JOIN Demo.AddressType T ON T.[Name] = S.AddressType;
