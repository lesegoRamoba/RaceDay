/*
RaceDay - Part 1, Section C
Student: Lesego Ramoba | ST10490519

Run the ENTIRE file in SSMS (no text selected), using a login permitted
 to create databases and tables. Requires SQL Server, not MySQL.
Creates RaceDay if absent. Refuses to overwrite any existing user tables.
No databases, tables or existing records are deleted by this script.

Expected sample counts: Roles 2, Users 4, Events 3, Categories 6,
Enrolments 6, Results 2. Dates are relative to the execution date.
Matches the six-entity RaceDay ERD, including its constraint notes.
AI assistance: ChatGPT assisted with drafting and checking this script.
Execution in SQL Server must be verified before submission.
*/
USE master;
GO
IF DB_ID(N'RaceDay') IS NULL
BEGIN
    EXEC(N'CREATE DATABASE RaceDay;');
END;
GO
USE RaceDay;
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;

-- Keep all schema creation and seeding in this one guarded batch.
IF DB_NAME() <> N'RaceDay'
    THROW 51000, 'Wrong database context. Stop and connect to RaceDay.', 1;

IF EXISTS (SELECT 1 FROM sys.tables WHERE is_ms_shipped = 0)
    THROW 51001, 'RaceDay already contains tables. Nothing was overwritten. Do not rerun the creation script on a populated database.', 1;

BEGIN TRY
    BEGIN TRANSACTION;

    -- 1. Roles
    CREATE TABLE dbo.Roles
    (
        RoleID INT IDENTITY(1,1) NOT NULL,
        RoleName NVARCHAR(20) NOT NULL,
        CONSTRAINT PK_Roles PRIMARY KEY (RoleID),
        CONSTRAINT UQ_Roles_RoleName UNIQUE (RoleName),
        CONSTRAINT CK_Roles_RoleName CHECK (RoleName IN (N'Organiser', N'Participant'))
    );

    -- 2. Users: account/profile data for both roles.
    CREATE TABLE dbo.Users
    (
        UserID INT IDENTITY(1,1) NOT NULL,
        RoleID INT NOT NULL,
        FirstName NVARCHAR(100) NOT NULL,
        LastName NVARCHAR(100) NOT NULL,
        Email NVARCHAR(256) NOT NULL,
        PasswordHash NVARCHAR(512) NOT NULL,
        DateOfBirth DATE NOT NULL,
        PhoneNumber NVARCHAR(20) NULL,
        ProfilePictureUrl NVARCHAR(2048) NULL,
        CreatedAt DATETIME2(0) NOT NULL
            CONSTRAINT DF_Users_CreatedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_Users PRIMARY KEY (UserID),
        CONSTRAINT UQ_Users_Email UNIQUE (Email),
        CONSTRAINT FK_Users_Roles FOREIGN KEY (RoleID)
            REFERENCES dbo.Roles(RoleID) ON DELETE NO ACTION
    );

    -- 3. Events: the API checks that OrganiserID belongs to an Organiser.
    CREATE TABLE dbo.Events
    (
        EventID INT IDENTITY(1,1) NOT NULL,
        OrganiserID INT NOT NULL,
        EventName NVARCHAR(200) NOT NULL,
        Description NVARCHAR(2000) NOT NULL,
        EventDate DATETIME2(0) NOT NULL,
        Location NVARCHAR(300) NOT NULL,
        DistanceKm DECIMAL(6,2) NOT NULL,
        EventType NVARCHAR(10) NOT NULL,
        BannerImageUrl NVARCHAR(2048) NULL,
        CONSTRAINT PK_Events PRIMARY KEY (EventID),
        CONSTRAINT FK_Events_Organiser FOREIGN KEY (OrganiserID)
            REFERENCES dbo.Users(UserID) ON DELETE NO ACTION,
        CONSTRAINT CK_Events_DistanceKm CHECK (DistanceKm > 0),
        CONSTRAINT CK_Events_EventType CHECK (EventType IN (N'Run', N'Walk', N'Cycle'))
    );

    -- 4. Categories: either age bounds OR a distance, never mixed.
    CREATE TABLE dbo.Categories
    (
        CategoryID INT IDENTITY(1,1) NOT NULL,
        EventID INT NOT NULL,
        CategoryName NVARCHAR(100) NOT NULL,
        CategoryType NVARCHAR(10) NOT NULL,
        MinAge INT NULL,
        MaxAge INT NULL,
        DistanceKm DECIMAL(6,2) NULL,
        CONSTRAINT PK_Categories PRIMARY KEY (CategoryID),
        CONSTRAINT FK_Categories_Events FOREIGN KEY (EventID)
            REFERENCES dbo.Events(EventID) ON DELETE NO ACTION,
        CONSTRAINT UQ_Categories_Event_Name UNIQUE (EventID, CategoryName),
        CONSTRAINT UQ_Categories_Event_Category UNIQUE (EventID, CategoryID),
        CONSTRAINT CK_Categories_CategoryType CHECK (CategoryType IN (N'Age', N'Distance')),
        CONSTRAINT CK_Categories_ValidDefinition CHECK
        (
            (
                CategoryType = N'Age'
                AND DistanceKm IS NULL
                AND (MinAge IS NOT NULL OR MaxAge IS NOT NULL)
                AND (MinAge IS NULL OR MinAge >= 0)
                AND (MaxAge IS NULL OR MaxAge >= 0)
                AND (MinAge IS NULL OR MaxAge IS NULL OR MinAge <= MaxAge)
            )
            OR
            (
                CategoryType = N'Distance'
                AND DistanceKm IS NOT NULL AND DistanceKm > 0
                AND MinAge IS NULL AND MaxAge IS NULL
            )
        )
    );

    -- 5. Enrolments: resolves the Participant/Event many-to-many relationship.
    CREATE TABLE dbo.Enrolments
    (
        EnrolmentID INT IDENTITY(1,1) NOT NULL,
        ParticipantID INT NOT NULL,
        EventID INT NOT NULL,
        CategoryID INT NOT NULL,
        EnrolmentStatus NVARCHAR(20) NOT NULL
            CONSTRAINT DF_Enrolments_Status DEFAULT N'Confirmed',
        EnrolledAt DATETIME2(0) NOT NULL
            CONSTRAINT DF_Enrolments_EnrolledAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_Enrolments PRIMARY KEY (EnrolmentID),
        CONSTRAINT FK_Enrolments_Participant FOREIGN KEY (ParticipantID)
            REFERENCES dbo.Users(UserID) ON DELETE NO ACTION,
        CONSTRAINT FK_Enrolments_Events FOREIGN KEY (EventID)
            REFERENCES dbo.Events(EventID) ON DELETE NO ACTION,
        CONSTRAINT FK_Enrolments_EventCategory FOREIGN KEY (EventID, CategoryID)
            REFERENCES dbo.Categories(EventID, CategoryID) ON DELETE NO ACTION,
        CONSTRAINT UQ_Enrolments_Participant_Event UNIQUE (ParticipantID, EventID),
        CONSTRAINT CK_Enrolments_Status CHECK
            (EnrolmentStatus IN (N'Pending', N'Confirmed', N'Cancelled'))
    );

    -- 6. Results: an enrolment can have zero or one result.
    CREATE TABLE dbo.Results
    (
        ResultID INT IDENTITY(1,1) NOT NULL,
        EnrolmentID INT NOT NULL,
        FinishTimeSeconds INT NOT NULL,
        FinishingPosition INT NOT NULL,
        IsPublished BIT NOT NULL
            CONSTRAINT DF_Results_IsPublished DEFAULT 0,
        RecordedAt DATETIME2(0) NOT NULL
            CONSTRAINT DF_Results_RecordedAt DEFAULT SYSUTCDATETIME(),
        CONSTRAINT PK_Results PRIMARY KEY (ResultID),
        CONSTRAINT UQ_Results_Enrolment UNIQUE (EnrolmentID),
        CONSTRAINT FK_Results_Enrolments FOREIGN KEY (EnrolmentID)
            REFERENCES dbo.Enrolments(EnrolmentID) ON DELETE NO ACTION,
        CONSTRAINT CK_Results_FinishTime CHECK (FinishTimeSeconds >= 0),
        CONSTRAINT CK_Results_Position CHECK (FinishingPosition > 0)
    );

    -- Seed dates: two future events and one completed event.
    DECLARE @Today DATETIME2(0) = CONVERT(DATE, SYSUTCDATETIME());
    DECLARE @RunDate DATETIME2(0) = DATEADD(HOUR, 5, DATEADD(DAY, 30, @Today));
    DECLARE @WalkDate DATETIME2(0) = DATEADD(HOUR, 6, DATEADD(DAY, 45, @Today));
    DECLARE @CycleDate DATETIME2(0) = DATEADD(HOUR, 5, DATEADD(DAY, -14, @Today));
    DECLARE @AccountCreated DATETIME2(0) = DATEADD(DAY, -90, @Today);
    DECLARE @OldEntryDate DATETIME2(0) = DATEADD(DAY, -30, @Today);

    INSERT INTO dbo.Roles (RoleName)
    VALUES (N'Organiser'), (N'Participant');

    -- Four independently salted PBKDF2 hashes in Identity V3 format.
    -- These are demonstration records, not usable login accounts:
    -- random source passwords were discarded. Register real demo accounts
    -- through the Part 2 API or set their passwords using its password hasher.
    -- No plaintext password is stored in any database column.
    INSERT INTO dbo.Users
        (RoleID, FirstName, LastName, Email, PasswordHash, DateOfBirth,
         PhoneNumber, ProfilePictureUrl, CreatedAt)
    VALUES
        (1, N'Thabo', N'Molefe', N'thabo.organiser@example.com',
         N'AQAAAAIAAzRQAAAAEEUx48W/APWx9g/FUvc3zj6qPR5w1aAM9UUzq1fIxfDwLih98vZZwSQOgkEX4OcD4w==', '19850312', NULL, NULL, @AccountCreated),
        (1, N'Naledi', N'Khumalo', N'naledi.organiser@example.com',
         N'AQAAAAIAAzRQAAAAEKshIx6+m4UVL7gYvM/fP/6pfgJa9L+Bkp7QDimv6KzXp5P7VXqsZVS2U5wVGSJLsg==', '19900724', NULL, NULL, @AccountCreated),
        (2, N'Lerato', N'Mokoena', N'lerato.participant@example.com',
         N'AQAAAAIAAzRQAAAAEI8dRrZdumF6EEa4DMJ/2LbLTkLcHTx4/4ryfTSAiduazVdoMorA1rCxcoSEr6F2ww==', '19980514', NULL, NULL, @AccountCreated),
        (2, N'Sipho', N'Dlamini', N'sipho.participant@example.com',
         N'AQAAAAIAAzRQAAAAEDCYcI0hsNj6LqcQ9SzSM8KWqJSK6+ZJm38G9YhMbR+iJ05MVh+4lLI+fJ6hvRk98w==', '20020218', NULL, NULL, @AccountCreated);

    INSERT INTO dbo.Events
        (OrganiserID, EventName, Description, EventDate, Location,
         DistanceKm, EventType, BannerImageUrl)
    VALUES
        (1, N'Soshanguve Community Run',
         N'A community road run with a 10 km option and an age-based Senior category.',
         @RunDate, N'Soshanguve, Pretoria, South Africa', 10.00, N'Run', NULL),
        (2, N'Pretoria Charity Walk',
         N'A charity walk with a 5 km option and an age-based Senior category.',
         @WalkDate, N'Pretoria, Gauteng, South Africa', 5.00, N'Walk', NULL),
        (1, N'Centurion Community Cycle',
         N'A completed community cycling event with recorded participant results.',
         @CycleDate, N'Centurion, Gauteng, South Africa', 20.00, N'Cycle', NULL);

    INSERT INTO dbo.Categories
        (EventID, CategoryName, CategoryType, MinAge, MaxAge, DistanceKm)
    VALUES
        (1, N'10 km', N'Distance', NULL, NULL, 10.00),
        (1, N'Senior', N'Age', 20, NULL, NULL),
        (2, N'5 km', N'Distance', NULL, NULL, 5.00),
        (2, N'Senior', N'Age', 20, NULL, NULL),
        (3, N'20 km', N'Distance', NULL, NULL, 20.00),
        (3, N'Senior', N'Age', 20, NULL, NULL);

    -- Use the Confirmed and current-timestamp defaults for these entries.
    INSERT INTO dbo.Enrolments (ParticipantID, EventID, CategoryID)
    VALUES (3, 1, 1), (4, 1, 2);

    INSERT INTO dbo.Enrolments
        (ParticipantID, EventID, CategoryID, EnrolmentStatus)
    VALUES (3, 2, 3, N'Pending'), (4, 2, 4, N'Cancelled');

    -- Historical entries precede the completed event.
    INSERT INTO dbo.Enrolments
        (ParticipantID, EventID, CategoryID, EnrolledAt)
    VALUES (3, 3, 5, @OldEntryDate), (4, 3, 5, @OldEntryDate);

    INSERT INTO dbo.Results
        (EnrolmentID, FinishTimeSeconds, FinishingPosition, IsPublished, RecordedAt)
    VALUES
        (5, 3100, 1, 1, DATEADD(HOUR, 4, @CycleDate)),
        (6, 3350, 2, 1, DATEADD(HOUR, 4, @CycleDate));

    -- Verify the expected sample totals before committing the transaction.
    IF (SELECT COUNT(*) FROM dbo.Roles) <> 2
        OR (SELECT COUNT(*) FROM dbo.Users) <> 4
        OR (SELECT COUNT(*) FROM dbo.Events) <> 3
        OR (SELECT COUNT(*) FROM dbo.Categories) <> 6
        OR (SELECT COUNT(*) FROM dbo.Enrolments) <> 6
        OR (SELECT COUNT(*) FROM dbo.Results) <> 2
        THROW 51002, 'Unexpected sample-data count. Changes will be rolled back.', 1;

    COMMIT TRANSACTION;
    PRINT 'RaceDay database tables and sample data created successfully.';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;
    THROW;
END CATCH;

-- Report 1: expected totals (2, 4, 3, 6, 6, 2).
SELECT N'Roles' AS TableName, COUNT(*) AS TotalRows FROM dbo.Roles
UNION ALL SELECT N'Users', COUNT(*) FROM dbo.Users
UNION ALL SELECT N'Events', COUNT(*) FROM dbo.Events
UNION ALL SELECT N'Categories', COUNT(*) FROM dbo.Categories
UNION ALL SELECT N'Enrolments', COUNT(*) FROM dbo.Enrolments
UNION ALL SELECT N'Results', COUNT(*) FROM dbo.Results;

-- Report 2: verify that both roles have two sample users.
SELECT r.RoleName, COUNT(u.UserID) AS UserCount
FROM dbo.Roles AS r
LEFT JOIN dbo.Users AS u ON u.RoleID = r.RoleID
GROUP BY r.RoleName
ORDER BY r.RoleName;

-- Report 3: enrolments with the correct event, category and participant.
SELECT en.EnrolmentID,
       CONCAT(u.FirstName, N' ', u.LastName) AS Participant,
       ev.EventName, c.CategoryName, en.EnrolmentStatus
FROM dbo.Enrolments AS en
JOIN dbo.Users AS u ON u.UserID = en.ParticipantID
JOIN dbo.Events AS ev ON ev.EventID = en.EventID
JOIN dbo.Categories AS c
    ON c.EventID = en.EventID AND c.CategoryID = en.CategoryID
ORDER BY ev.EventName, Participant;

-- Report 4: published results and finishers in the same event/category.
SELECT ev.EventName, c.CategoryName,
       CONCAT(u.FirstName, N' ', u.LastName) AS Participant,
       rs.FinishTimeSeconds, rs.FinishingPosition,
       COUNT(*) OVER (PARTITION BY en.EventID, en.CategoryID) AS TotalFinishers
FROM dbo.Results AS rs
JOIN dbo.Enrolments AS en ON en.EnrolmentID = rs.EnrolmentID
JOIN dbo.Users AS u ON u.UserID = en.ParticipantID
JOIN dbo.Events AS ev ON ev.EventID = en.EventID
JOIN dbo.Categories AS c
    ON c.EventID = en.EventID AND c.CategoryID = en.CategoryID
WHERE rs.IsPublished = 1
ORDER BY ev.EventDate DESC, c.CategoryName, rs.FinishingPosition;
GO
