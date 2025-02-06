/*
    Question 1:
*/
SELECT P.ProjectName,
    SUM(P.TaskID) AS TaskCount,
    MAX(P.CompletedDate) AS LastCompletedDate,
    SUM(IIF(T.CompletedDate IS > T.DueDate)) AS CompletedLateCount,
    ISNULL(SUM(T.CompletedDate)) AS CompletedCount
FROM Project P
    INNER JOIN User U on U.UserID = P.UserID
    INNER JOIN Task T on T.CreatedDate = P.CreatedDate
WHERE P.Email = N'johndoe@ksu.edu'
GROUP BY P.ProjectName
ORDER BY P.ProjectName ASC;
/*
    Question 2:
*/
SELECT U.UserName,
    SUM(P.ProjectID) AS ProjectCount,
    SUM(T.TaskID) AS TaskCount,
    ISNULL(SUM(T.CompletedDate)) AS CompletedCount,
FROM User U
    INNER JOIN Project P on P.UserID = U.UserID
    INNER JOIN Task T on T.CreatedDate = P.CreatedDate
WHERE SUM (U.CreatedDate) IS > SUM(U.CompletedDate)
GROUP BY U.UserName
ORDER BY U.TaskCount DeSC, U.CompletedCount ASC;
/*
    Question 3:
*/
SELECT U.UserName,
    P.ProjectName AS ProjectName
FROM Project P
    WHERE EXISTS
    (
        SELECT *
        FROM Task T
        WHERE T.CompletedDate >= '2024-01-01'
    )
GROUP BY U.UserName, P.ProjectName
/*
    Question 4:
*/
SELECT P.ProjectName
FROM Project P
    INNER Join Task T on T.ProjectID = P.ProjectID
    INNER JOIN User U on U.UserID = P.UserID
WHERE U.Email = N'janedoe@ksu.edu'
AND EXISTS(
        SELECT 
        SUM(SUM(T.CreatedDate) - SUM(T.CompletedDate)) AS IncompleteTaskCount
        FROM Task T 
    )
GROUP BY P.ProjectName
ORDER BY IncompleteTaskCount DESC;


    
