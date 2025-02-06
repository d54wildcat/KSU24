/****************************
 * MERGE
 ****************************/
-- Run setup script.
WITH SourceCte(PersonId, AddressTypeId, Line1, Line2, City, StateCode, ZipCode) AS
   (
      SELECT P.PersonId, T.AddressTypeId, NA.Line1, NA.Line2, NA.City, NA.StateCode, NA.ZipCode
      FROM
            (
               VALUES
                  (N'Marie', N'Jones', 'Work', N'PO Box 123', NULL, N'Sunny Hill', 'AZ', '78901'),
                  (N'Marie', N'Jones', 'Home', N'98132 Sunshine Dr.', NULL, N'Sunny Hill', 'AZ', '78902')
            ) NA(FirstName, LastName, AddressType, Line1, Line2, City, StateCode, ZipCode)
         INNER JOIN Demo.Person P ON P.FirstName = NA.FirstName
            AND P.LastName = NA.LastName
         INNER JOIN Demo.AddressType T ON T.[Name] = NA.AddressType
   )
MERGE Demo.PersonAddress PA
USING SourceCte S ON S.PersonId = PA.PersonId
   AND S.AddressTypeId = PA.AddressTypeId
WHEN MATCHED THEN
   UPDATE
   SET
      Line1 = S.Line1,
      Line2 = S.Line2,
      City = S.City,
      StateCode = S.StateCode,
      ZipCode = S.ZipCode,
      UpdatedOn = SYSDATETIMEOFFSET()
WHEN NOT MATCHED THEN
   INSERT(PersonId, AddressTypeId, Line1, Line2, City, StateCode, ZipCode)
   VALUES(S.PersonId, S.AddressTypeId, S.Line1, S.Line2, S.City, S.StateCode, S.ZipCode);
GO

SELECT P.FirstName, P.LastName, T.[Name] AS AddressType,
   PA.Line1, PA.Line2, PA.City, PA.StateCode, PA.ZipCode,
   PA.CreatedOn, PA.UpdatedOn
FROM Demo.Person P
   INNER JOIN Demo.PersonAddress PA ON PA.PersonId = P.PersonId
   INNER JOIN Demo.AddressType T ON T.AddressTypeId = PA.AddressTypeId
ORDER BY P.PersonId ASC, T.AddressTypeId ASC;


-- PLEASE NOTE: The ON predicate of the USING clause just matches,
--    or determines there isn't a match. It does NOT FILTER, such it does with joins.

-- Using a predicate.
-- Let's only update a row (and it's UpdatedOn) if a value truly changed.
WITH SourceCte(PersonId, AddressTypeId, Line1, Line2, City, StateCode, ZipCode) AS
   (
      SELECT P.PersonId, T.AddressTypeId, NA.Line1, NA.Line2, NA.City, NA.StateCode, NA.ZipCode
      FROM
            (
               VALUES
                  (N'Marie', N'Jones', 'Work', N'PO Box 123', NULL, N'Sunny Hill', 'AZ', '78901'),
                  (N'Marie', N'Jones', 'Home', N'98132 Sunshine Dr.', NULL, N'Sunny Hill', 'AZ', '78902')
            ) NA(FirstName, LastName, AddressType, Line1, Line2, City, StateCode, ZipCode)
         INNER JOIN Demo.Person P ON P.FirstName = NA.FirstName
            AND P.LastName = NA.LastName
         INNER JOIN Demo.AddressType T ON T.[Name] = NA.AddressType
   )
MERGE Demo.PersonAddress T
USING SourceCte S ON S.PersonId = T.PersonId
   AND S.AddressTypeId = T.AddressTypeId
WHEN MATCHED
      AND (S.Line1 <> T.Line1
         OR S.Line2 <> T.Line2
         OR S.City <> T.City
         OR S.StateCode <> T.StateCode
         OR S.ZipCode <> T.ZipCode) THEN
   UPDATE
   SET
      Line1 = S.Line1,
      Line2 = S.Line2,
      City = S.City,
      StateCode = S.StateCode,
      ZipCode = S.ZipCode,
      UpdatedOn = SYSDATETIMEOFFSET()
WHEN NOT MATCHED THEN
   INSERT(PersonId, AddressTypeId, Line1, Line2, City, StateCode, ZipCode)
   VALUES(S.PersonId, S.AddressTypeId, S.Line1, S.Line2, S.City, S.StateCode, S.ZipCode);
GO


-- Is the above correct?
-- The below is exactly the same except Line2 was provided for first row.
-- How many rows should be modified?
-- How do we fix it?
WITH SourceCte(PersonId, AddressTypeId, Line1, Line2, City, StateCode, ZipCode) AS
   (
      SELECT P.PersonId, T.AddressTypeId, NA.Line1, NA.Line2, NA.City, NA.StateCode, NA.ZipCode
      FROM
            (
               VALUES
                  (N'Marie', N'Jones', 'Work', N'PO Box 123', 'Suite A', N'Sunny Hill', 'AZ', '78901'),
                  (N'Marie', N'Jones', 'Home', N'98132 Sunshine Dr.', NULL, N'Sunny Hill', 'AZ', '78902')
            ) NA(FirstName, LastName, AddressType, Line1, Line2, City, StateCode, ZipCode)
         INNER JOIN Demo.Person P ON P.FirstName = NA.FirstName
            AND P.LastName = NA.LastName
         INNER JOIN Demo.AddressType T ON T.[Name] = NA.AddressType
   )
MERGE Demo.PersonAddress T
USING SourceCte S ON S.PersonId = T.PersonId
   AND S.AddressTypeId = T.AddressTypeId
WHEN MATCHED
      AND (S.Line1 <> T.Line1
         OR S.Line2 <> T.Line2
         OR S.City <> T.City
         OR S.StateCode <> T.StateCode
         OR S.ZipCode <> T.ZipCode) THEN
   UPDATE
   SET
      Line1 = S.Line1,
      Line2 = S.Line2,
      City = S.City,
      StateCode = S.StateCode,
      ZipCode = S.ZipCode,
      UpdatedOn = SYSDATETIMEOFFSET()
WHEN NOT MATCHED THEN
   INSERT(PersonId, AddressTypeId, Line1, Line2, City, StateCode, ZipCode)
   VALUES(S.PersonId, S.AddressTypeId, S.Line1, S.Line2, S.City, S.StateCode, S.ZipCode);
GO

-- Here's one fix. We are fortunate there is only one nullable column.
WITH SourceCte(PersonId, AddressTypeId, Line1, Line2, City, StateCode, ZipCode) AS
   (
      SELECT P.PersonId, T.AddressTypeId, NA.Line1, NA.Line2, NA.City, NA.StateCode, NA.ZipCode
      FROM
            (
               VALUES
                  (N'Marie', N'Jones', 'Work', N'PO Box 123', 'Suite A', N'Sunny Hill', 'AZ', '78901'),
                  (N'Marie', N'Jones', 'Home', N'98132 Sunshine Dr.', NULL, N'Sunny Hill', 'AZ', '78902')
            ) NA(FirstName, LastName, AddressType, Line1, Line2, City, StateCode, ZipCode)
         INNER JOIN Demo.Person P ON P.FirstName = NA.FirstName
            AND P.LastName = NA.LastName
         INNER JOIN Demo.AddressType T ON T.[Name] = NA.AddressType
   )
MERGE Demo.PersonAddress T
USING SourceCte S ON S.PersonId = T.PersonId
   AND S.AddressTypeId = T.AddressTypeId
WHEN MATCHED
      AND (S.Line1 <> T.Line1
         OR S.Line2 <> T.Line2
         OR S.Line2 IS NULL AND T.Line2 IS NOT NULL
         OR S.Line2 IS NOT NULL AND T.Line2 IS NULL
         OR S.City <> T.City
         OR S.StateCode <> T.StateCode
         OR S.ZipCode <> T.ZipCode) THEN
   UPDATE
   SET
      Line1 = S.Line1,
      Line2 = S.Line2,
      City = S.City,
      StateCode = S.StateCode,
      ZipCode = S.ZipCode,
      UpdatedOn = SYSDATETIMEOFFSET()
WHEN NOT MATCHED THEN
   INSERT(PersonId, AddressTypeId, Line1, Line2, City, StateCode, ZipCode)
   VALUES(S.PersonId, S.AddressTypeId, S.Line1, S.Line2, S.City, S.StateCode, S.ZipCode);
GO

-- A cleaner approach.
WITH SourceCte(PersonId, AddressTypeId, Line1, Line2, City, StateCode, ZipCode) AS
   (
      SELECT P.PersonId, T.AddressTypeId, NA.Line1, NA.Line2, NA.City, NA.StateCode, NA.ZipCode
      FROM
            (
               VALUES
                  (N'Marie', N'Jones', 'Work', N'PO Box 123', NULL, N'Sunny Hill', 'AZ', '78901'),
                  (N'Marie', N'Jones', 'Home', N'98132 Sunshine Dr.', NULL, N'Sunny Hill', 'AZ', '78902')
            ) NA(FirstName, LastName, AddressType, Line1, Line2, City, StateCode, ZipCode)
         INNER JOIN Demo.Person P ON P.FirstName = NA.FirstName
            AND P.LastName = NA.LastName
         INNER JOIN Demo.AddressType T ON T.[Name] = NA.AddressType
   )
MERGE Demo.PersonAddress T
USING SourceCte S ON S.PersonId = T.PersonId
   AND S.AddressTypeId = T.AddressTypeId
WHEN MATCHED AND NOT EXISTS
      (
         SELECT S.Line1, S.Line2, S.City, S.StateCode, S.ZipCode
         INTERSECT
         SELECT T.Line1, T.Line2, T.City, T.StateCode, T.ZipCode
      ) THEN
   UPDATE
   SET
      Line1 = S.Line1,
      Line2 = S.Line2,
      City = S.City,
      StateCode = S.StateCode,
      ZipCode = S.ZipCode,
      UpdatedOn = SYSDATETIMEOFFSET()
WHEN NOT MATCHED THEN
   INSERT(PersonId, AddressTypeId, Line1, Line2, City, StateCode, ZipCode)
   VALUES(S.PersonId, S.AddressTypeId, S.Line1, S.Line2, S.City, S.StateCode, S.ZipCode);
GO

/****************************
 * OUTPUT
 ****************************/
-- Rerun setup.

-- Same query as above, but with OUTPUT.
WITH SourceCte(PersonId, AddressTypeId, Line1, Line2, City, StateCode, ZipCode) AS
   (
      SELECT P.PersonId, T.AddressTypeId, NA.Line1, NA.Line2, NA.City, NA.StateCode, NA.ZipCode
      FROM
            (
               VALUES
                  (N'Marie', N'Jones', 'Work', N'PO Box 123', NULL, N'Sunny Hill', 'AZ', '78901'),
                  (N'Marie', N'Jones', 'Home', N'98132 Sunshine Dr.', NULL, N'Sunny Hill', 'AZ', '78902')
            ) NA(FirstName, LastName, AddressType, Line1, Line2, City, StateCode, ZipCode)
         INNER JOIN Demo.Person P ON P.FirstName = NA.FirstName
            AND P.LastName = NA.LastName
         INNER JOIN Demo.AddressType T ON T.[Name] = NA.AddressType
   )
MERGE Demo.PersonAddress PA
USING SourceCte S ON S.PersonId = PA.PersonId
   AND S.AddressTypeId = PA.AddressTypeId
WHEN MATCHED THEN
   UPDATE
   SET
      Line1 = S.Line1,
      Line2 = S.Line2,
      City = S.City,
      StateCode = S.StateCode,
      ZipCode = S.ZipCode,
      UpdatedOn = SYSDATETIMEOFFSET()
WHEN NOT MATCHED THEN
   INSERT(PersonId, AddressTypeId, Line1, Line2, City, StateCode, ZipCode)
   VALUES(S.PersonId, S.AddressTypeId, S.Line1, S.Line2, S.City, S.StateCode, S.ZipCode)
OUTPUT $action AS Operation, INSERTED.PersonId, INSERTED.AddressTypeId,
   INSERTED.Line1 AS InsertedLine1, INSERTED.Line2 AS InsertedLine2,
   INSERTED.City AS InsertedCity, INSERTED.StateCode AS InsertedStateCode, INSERTED.ZipCode AS InsertedZipCode,
   DELETED.Line1 AS DeletedLine1, DELETED.Line2 AS DeletedLine2,
   DELETED.City AS DeletedCity, DELETED.StateCode AS DeletedStateCode, DELETED.ZipCode AS DeletedZipCode;

-- Rerun setup.

-- Look at table Demo.PersonAddressChange

-- Same query as above, but with OUTPUT/INTO.
WITH SourceCte(PersonId, AddressTypeId, Line1, Line2, City, StateCode, ZipCode) AS
   (
      SELECT P.PersonId, T.AddressTypeId, NA.Line1, NA.Line2, NA.City, NA.StateCode, NA.ZipCode
      FROM
            (
               VALUES
                  (N'Marie', N'Jones', 'Work', N'PO Box 123', NULL, N'Sunny Hill', 'AZ', '78901'),
                  (N'Marie', N'Jones', 'Home', N'98132 Sunshine Dr.', NULL, N'Sunny Hill', 'AZ', '78902')
            ) NA(FirstName, LastName, AddressType, Line1, Line2, City, StateCode, ZipCode)
         INNER JOIN Demo.Person P ON P.FirstName = NA.FirstName
            AND P.LastName = NA.LastName
         INNER JOIN Demo.AddressType T ON T.[Name] = NA.AddressType
   )
MERGE Demo.PersonAddress PA
USING SourceCte S ON S.PersonId = PA.PersonId
   AND S.AddressTypeId = PA.AddressTypeId
WHEN MATCHED THEN
   UPDATE
   SET
      Line1 = S.Line1,
      Line2 = S.Line2,
      City = S.City,
      StateCode = S.StateCode,
      ZipCode = S.ZipCode,
      UpdatedOn = SYSDATETIMEOFFSET()
WHEN NOT MATCHED THEN
   INSERT(PersonId, AddressTypeId, Line1, Line2, City, StateCode, ZipCode)
   VALUES(S.PersonId, S.AddressTypeId, S.Line1, S.Line2, S.City, S.StateCode, S.ZipCode)
OUTPUT $action AS Operation, INSERTED.PersonId, INSERTED.AddressTypeId
INTO Demo.PersonAddressChange(Operation, PersonId, AddressTypeId);

SELECT *
FROM Demo.PersonAddressChange;
