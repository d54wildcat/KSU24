-- Create the schema if it does not already exist
IF SCHEMA_ID(N'Accounts') IS NULL
   EXEC(N'CREATE SCHEMA [Accounts];');
GO

-- Drop tables if they exist
IF OBJECT_ID(N'Accounts.[Transaction]', N'U') IS NOT NULL
    DROP TABLE Accounts.[Transaction];
GO

IF OBJECT_ID(N'Accounts.Account', N'U') IS NOT NULL
    DROP TABLE Accounts.Account;
GO

IF OBJECT_ID(N'Accounts.AccountHolder', N'U') IS NOT NULL
    DROP TABLE Accounts.AccountHolder;
GO

-- Create tables
CREATE TABLE Accounts.AccountHolder (
    AccountHolderId INT IDENTITY PRIMARY KEY,
    Email NVARCHAR(128) UNIQUE NOT NULL,
    FirstName NVARCHAR(32) NOT NULL CHECK (LEN(FirstName) > 0),
    LastName NVARCHAR(32) NOT NULL CHECK (LEN(LastName) > 0),
    CreatedOn DATETIMEOFFSET DEFAULT SYSDATETIME(),
    UpdatedOn DATETIMEOFFSET DEFAULT SYSDATETIME()
);

CREATE TABLE Accounts.Account (
    AccountId INT IDENTITY PRIMARY KEY,
    AccountHolderId INT,
    AccountNumber INT UNIQUE,
    Nickname NVARCHAR(32) UNIQUE,
    CreatedOn DATETIMEOFFSET DEFAULT SYSDATETIME(),
    UpdatedOn DATETIMEOFFSET DEFAULT SYSDATETIME(),
    ClosedOn DATETIMEOFFSET NULL,
    FOREIGN KEY (AccountHolderId) REFERENCES Accounts.AccountHolder(AccountHolderId)
);

CREATE TABLE Accounts.[Transaction] (
    TransactionId INT IDENTITY PRIMARY KEY,
    AccountId INT,
    Description NVARCHAR(256),
    Amount DECIMAL(12, 2),
    CreatedOn DATETIMEOFFSET DEFAULT SYSDATETIME(),
    FOREIGN KEY (AccountId) REFERENCES Accounts.Account(AccountId)
);
