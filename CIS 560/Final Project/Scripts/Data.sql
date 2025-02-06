-- Queries used in BasketballAPI/BasketballDataImporter.cs

-- Player Insert
INSERT INTO [560_proj_Group09].Player (PlayerID, [Name], PrimaryPosition, Hometown, TeamKey, [Number], YearInSchool, [Weight], Height) 
VALUES (@PlayerID, @Name, @PrimaryPosition, @Hometown, @TeamKey, @Number, @YearInSchool, @Weight, @Height);

-- Conference Insert
INSERT INTO [560_proj_Group09].Conference ([Name], ShortName) 
VALUES (@ConferenceName, @ShortName);
SELECT SCOPE_IDENTITY();

-- Coach Insert
INSERT INTO [560_proj_Group09].Coach ([Name], Hometown, YearsCoached, TeamID) 
VALUES (@CoachName, @Hometown, @YearsCoached, @TeamID);
SELECT SCOPE_IDENTITY();

-- School Insert
INSERT INTO [560_proj_Group09].School (SchoolName) 
VALUES (@SchoolName);

-- Sport Insert
INSERT INTO [560_proj_Group09].Sport (SportName) 
VALUES (@SportName);

-- Team Insert
SET IDENTITY_INSERT [560_proj_Group09].Team ON
INSERT INTO [560_proj_Group09].Team (TeamID, SportName, SchoolName, TeamKey, ConferenceID)
VALUES (@TeamID, @SportName, @SchoolName, @TeamKey, @ConferenceID);

-- Check if Table exists example - Player
SELECT COUNT(*) FROM [560_proj_Group09].Player WHERE [Name] = @Name AND PrimaryPosition = @PrimaryPosition AND Hometown = @Hometown