-- Aggregatting Queries 
-- These are the scripts used in the aggregatting queries form

-- Query #1
-- List all coaches from the Big 12 that have coached their current team for more than 5 years.
SELECT C.Name FROM [560_proj_Group09].Coach C
JOIN [560_proj_Group09].Team T ON T.TeamID = C.TeamID
JOIN [560_proj_Group09].Conference CF ON CF.ConferenceID = T.ConferenceID
WHERE CF.Name = N'Big 12' AND C.YearsCoached > 5;

-- Query #2
-- List all guards from X Conference who is a Junior or Senior
SELECT P.[Name] FROM [560_proj_Group09].[Player] P
JOIN [560_proj_Group09].Team T ON P.TeamKey = T.TeamKey
JOIN [560_proj_Group09].Conference C ON C.ConferenceID = T.ConferenceID AND C.Name = N'Big 12' -- 'Big 12' in place for X
WHERE (P.YearInSchool = N'Junior' OR P.YearInSchool = N'Senior')
	AND P.PrimaryPosition = N'G' 
ORDER BY P.YearInSchool ASC;

-- Query #3
-- List all teams that have fewer than 14 players on their roster
SELECT T.SchoolName FROM [560_proj_Group09].Team T
WHERE (
    SELECT COUNT(P.PlayerID) FROM [560_proj_Group09].[Player] P
    WHERE P.TeamKey = T.TeamKey
) < 14;

-- Query #4
-- List all players that are over 6'5 (77 inches.) in X conference (optional: that have a jersey > Y)
SELECT P.[Name], P.Number FROM [560_proj_Group09].[Player] P
    JOIN [560_proj_Group09].[Team] T ON T.TeamKey = P.TeamKey
    JOIN [560_proj_Group09].Conference C ON C.ConferenceID = T.ConferenceID AND C.Name = N'Big 12'
WHERE P.Number > 15 -- '15' in place for Y
AND P.Height > 77;

-- SQL scripts used in SportsDBUI
-- Queries are dynamically generated and called
-- These ones below are the scripts snapshoted from the script parameter in the function MakeDTFromQuery(...)

-- SqlScript Object, defined in Refactor/SqlScript.cs
SELECT @Column From @Table -- properties given
-- optional join statements 
-- optional where statements

-- Selecting in Sport view example: Selecting Basketball 
SELECT a.SchoolName, a.TeamID, a.TeamKey 
FROM [560_proj_Group09].Team a 
JOIN [560_proj_Group09].Sport S ON a.SportName = S.SportName 
JOIN [560_proj_Group09].Conference C ON C.ConferenceID = a.ConferenceID 
WHERE S.SportName = N'Basketball';

-- Setting filter example: filtering by Big12 and Pac12 Teams
SELECT a.SchoolName, a.TeamID, a.TeamKey 
FROM [560_proj_Group09].Team a 
JOIN [560_proj_Group09].Sport S ON a.SportName = S.SportName 
JOIN [560_proj_Group09].Conference C ON C.ConferenceID = a.ConferenceID 
WHERE S.SportName = N'Basketball' AND ( C.ConferenceID = 10  OR C.ConferenceID = 24  ); 

-- Searching for team in team view example: Searching 'Kansas State'
SELECT a.Name, a.PlayerID 
FROM [560_proj_Group09].Player a 
JOIN [560_proj_Group09].Team T ON a.TeamKey = T.TeamKey 
JOIN [560_proj_Group09].Sport S ON T.SportName = S.SportName 
WHERE S.SportName = N'Basketball' AND T.SchoolName = N'Kansas State' ;

-- Get list of conferences to put in team view filter box
SELECT a.ConferenceID, [Name], ShortName 
FROM [560_proj_Group09].[Conference] a

-- Getting the team's conference name
SELECT a.Name 
FROM [560_proj_Group09].Conference a 
WHERE a.ConferenceID = 10;

-- Getting team's coach and years coached
SELECT a.Name 
FROM [560_proj_Group09].Coach a 
WHERE a.TeamID = 112;

SELECT a.YearsCoached 
FROM [560_proj_Group09].Coach a 
WHERE a.TeamID = 112;

-- Get the positions that are on the team to put in the filter box
SELECT a.PrimaryPosition 
FROM [560_proj_Group09].Player a 
WHERE a.TeamKey = N'KANST' 
GROUP BY a.PrimaryPosition;

-- Getting player information to display example: Tylor Perry
SELECT a.Hometown, a.PrimaryPosition, a.YearInSchool, a.Height, a.Weight 
FROM [560_proj_Group09].Player a 
WHERE a.PlayerID = 60024305;

-- Load player info into player info updater example: Tylor Perry
SELECT P.[Name], P.Hometown, P.[Number], P.PrimaryPosition, P.YearInSchool, P.[Weight], P.Height 
FROM [560_proj_Group09].Player P 
WHERE P.PlayerID = 60024305;

-- Update player info in database
UPDATE [560_proj_Group09].Player 
SET Hometown = @Hometown, [Number] = @Number, PrimaryPosition = @PrimaryPosition, YearInSchool = @YearInSchool, [Weight] = @Weight, Height = @Height 
WHERE PlayerID = @PlayerID