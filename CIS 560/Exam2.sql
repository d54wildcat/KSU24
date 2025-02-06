
--Question 1
    WITH ProjectSummary AS{
        SELECT 
        p.UserID,
        p.ProjectName,
        Count(t.TaskID) as TaskCount
        COALESCE(SUM(CASE WHEN t.IsCompleted THEN 1 ELSE 0 END), 0) * 100.0 / COUNT(t.TaskID) as PercentComplete
        FROM
            Project p 
        LEFT JOIN
            Task t ON p.ProjectID = t.ProjectID
        WHERE
            p.CreationDate >= '2024-01-01 05:00:00'
        GROUP BY
            p.UserID, p.ProjectName
    }
    SELECT
        ps.ProjectName,
        u.UserName,
        ps.TaskCount,
        ps.PercentComplete
        RANK() OVER (ORDER BY ps.PercentComplete DESC) as ProjectRank
    FROM
        ProjectSummary ps
    JOIN
        USER u ON ps.UserID = u.UserID
    ORDER BY
        ProjectRank ASC;

--Question 2

CREATE TABLE Tasks.Project
{
    ProjectID INT IDENTITY(1,1) PRIMARY KEY,
    ProjectName NVARCHAR(50) NOT NULL UNIQUE,
    UserID INT NOT NULL,
    CreatedOn DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIME(),
    UpdatedOn DATETIMEOFFSET NOT NULL DEFAULT SYSDATETIME();
    FOREIGN KEY (UserID) REFERENCES Tasks.User(UserID)
}
--Question 3--

CREATE PROCEDURE Tasks.ExtendDueDates
    @ProjectID INT,
    @DaysToAdd SMALLINT
AS
BEGIN  
    UPDATE Tasks.Task
    SET DueDate = DATEADD(DAY, @DaysToAdd, DueDate),
        UpdatedOn = SYSDATETIME()
    WHERE ProjectID = @ProjectID AND CompletedON IS NULL;
END;


--Question 4--
/*4a - {Feature}+ = {F, P, S}
4b - {Product}+ = {P, T}
4c - {Team}+ = {T}
4d - {Team, Feature}+ = {T, F, RD, P, S}
4e - {ReleaseDate}+ = {RD}
4f- {F}* -> {P, S} is a violation because {Feature} is not a superkey
{P} -> {T} is a violation because {P} is not a superkey
4g- R1{Feature, Product, Status} With Feature as the Key
R3{Product, Team} With Product as the Key
R4{Product, Feature, ReleaseDate} With {Product, Feature} as the Key
4h- R1: {Feature
    R3: {Product}
    R4: {Product, Feature}
*/
