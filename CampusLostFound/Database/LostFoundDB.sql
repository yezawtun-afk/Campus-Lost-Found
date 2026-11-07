/* ============================================================
   Campus Lost & Found Portal - database setup script
   ------------------------------------------------------------
   Run this once before starting the website. It will:
     1. Drop and recreate the "LostFoundDB" database.
     2. Create the Items and Reports tables (with the FK cascade).
     3. Insert 12 realistic sample items + one report row each.
   ============================================================ */

USE master;
GO

IF DB_ID('LostFoundDB') IS NOT NULL
BEGIN
    ALTER DATABASE LostFoundDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE LostFoundDB;
END
GO

CREATE DATABASE LostFoundDB;
GO

USE LostFoundDB;
GO

/* ------------------------------------------------------------
   Table: Items - one row per reported item (lost, found or claimed)
   ------------------------------------------------------------ */
CREATE TABLE dbo.Items
(
    ItemID       INT            IDENTITY(1,1) NOT NULL,
    ItemName     NVARCHAR(100)  NOT NULL,
    Description  NVARCHAR(500)  NULL,
    Category     NVARCHAR(50)   NOT NULL,
    Location     NVARCHAR(100)  NOT NULL,
    DateReported DATE           NOT NULL CONSTRAINT DF_Items_DateReported DEFAULT (CAST(GETDATE() AS DATE)),
    Status       NVARCHAR(20)   NOT NULL,
    ImagePath    NVARCHAR(200)  NULL,
    ContactInfo  NVARCHAR(100)  NULL,
    CONSTRAINT PK_Items PRIMARY KEY CLUSTERED (ItemID),
    CONSTRAINT CK_Items_Status CHECK (Status IN ('Lost', 'Found', 'Claimed'))
);
GO

/* ------------------------------------------------------------
   Table: Reports - who reported which item, and how
   Deleting an item automatically deletes its report rows.
   ------------------------------------------------------------ */
CREATE TABLE dbo.Reports
(
    ReportID      INT          IDENTITY(1,1) NOT NULL,
    ItemID        INT          NOT NULL,
    ReporterName  NVARCHAR(100) NOT NULL,
    StudentStaffID NVARCHAR(30) NOT NULL,
    ReportType    NVARCHAR(10) NOT NULL,
    ReportDate    DATE         NOT NULL CONSTRAINT DF_Reports_ReportDate DEFAULT (CAST(GETDATE() AS DATE)),
    CONSTRAINT PK_Reports PRIMARY KEY CLUSTERED (ReportID),
    CONSTRAINT FK_Reports_Items FOREIGN KEY (ItemID)
        REFERENCES dbo.Items (ItemID) ON DELETE CASCADE,
    CONSTRAINT CK_Reports_ReportType CHECK (ReportType IN ('Lost', 'Found'))
);
GO

/* Helpful index for the search page. */
CREATE INDEX IX_Items_Category_Status ON dbo.Items (Category, Status);
GO

/* ------------------------------------------------------------
   Sample items (12). Each ImagePath points at a JPG in Images/items.
   ------------------------------------------------------------ */
INSERT INTO dbo.Items (ItemName, Description, Category, Location, DateReported, Status, ImagePath, ContactInfo)
VALUES
('Brown Leather Wallet',
 'Brown bifold leather wallet with a university library card and about RM 40 inside. Small scratch on the front flap.',
 'Personal Belongings', 'Library - 2nd Floor', DATEADD(DAY, -1, CAST(GETDATE() AS DATE)), 'Lost',
 '~/Images/items/wallet1.jpg', 'aisha.rahman@campus.edu'),

('Black Slim Card Wallet',
 'Slim black card wallet found on a cafeteria table. Contains a few bank cards but no cash. Handed to Security Office.',
 'Personal Belongings', 'Cafeteria', DATEADD(DAY, -2, CAST(GETDATE() AS DATE)), 'Found',
 '~/Images/items/wallet2.jpg', 'security.office@campus.edu'),

('Silver Ultrabook Laptop',
 '14-inch silver ultrabook in a grey sleeve, left in lecture room A204 after the 10 a.m. class.',
 'Electronic Devices', 'Block A - Room A204', DATEADD(DAY, -3, CAST(GETDATE() AS DATE)), 'Found',
 '~/Images/items/laptop1.jpg', 'security.office@campus.edu'),

('Introduction to Data Structures Textbook',
 'Navy blue hardcover textbook, third edition. Name written in pencil on the inside cover.',
 'Books', 'Library - Study Area', DATEADD(DAY, -4, CAST(GETDATE() AS DATE)), 'Lost',
 '~/Images/items/textbook1.jpg', '+60 12-345 6789'),

('Student ID Card - Faculty of Engineering',
 'Student ID card with a navy lanyard, found near the badminton courts. Photo and student number are visible on the card.',
 'Student Cards', 'Sports Hall', DATEADD(DAY, -5, CAST(GETDATE() AS DATE)), 'Found',
 '~/Images/items/studentcard1.jpg', 'security.office@campus.edu'),

('Student ID Card - Lanyard Attached',
 'Student ID card on a coral lanyard, last used at the cafeteria self-service counter around lunch time.',
 'Student Cards', 'Cafeteria', DATEADD(DAY, -6, CAST(GETDATE() AS DATE)), 'Lost',
 '~/Images/items/studentcard2.jpg', 'daniel.tan@campus.edu'),

('Bundle of Keys with Steel Ring',
 'Three keys on a steel ring with a small blue tag: one room key, one padlock key and one car key.',
 'Accessories', 'Block A - Reception', DATEADD(DAY, -7, CAST(GETDATE() AS DATE)), 'Found',
 '~/Images/items/keys1.jpg', 'security.office@campus.edu'),

('White Wireless Earbuds',
 'White wireless earbuds in an open charging case, left on a bench beside the indoor court.',
 'Electronic Devices', 'Sports Hall', DATEADD(DAY, -8, CAST(GETDATE() AS DATE)), 'Lost',
 '~/Images/items/earphones1.jpg', '+60 19-876 5432'),

('Navy Steel Water Bottle',
 'Matte navy 750 ml stainless steel water bottle with a small dent near the base. Found in the reading room.',
 'Personal Belongings', 'Library - Reading Room', DATEADD(DAY, -9, CAST(GETDATE() AS DATE)), 'Found',
 '~/Images/items/bottle1.jpg', 'library.desk@campus.edu'),

('Navy Canvas Backpack',
 'Navy canvas backpack with brown leather straps. Contains notebooks and a pencil case, no laptop inside.',
 'Personal Belongings', 'Cafeteria', DATEADD(DAY, -10, CAST(GETDATE() AS DATE)), 'Lost',
 '~/Images/items/backpack1.jpg', 'mei.ling@campus.edu'),

('Scientific Calculator',
 'Black scientific calculator with a blank dark screen, found on a desk in the examination hall after the morning paper.',
 'Electronic Devices', 'Block A - Exam Hall', DATEADD(DAY, -12, CAST(GETDATE() AS DATE)), 'Found',
 '~/Images/items/calculator1.jpg', 'exam.unit@campus.edu'),

('Black Framed Sunglasses',
 'Black framed sunglasses with a soft cloth case. Owner has already collected them from the Security Office.',
 'Accessories', 'Sports Hall', DATEADD(DAY, -14, CAST(GETDATE() AS DATE)), 'Claimed',
 '~/Images/items/sunglasses1.jpg', 'security.office@campus.edu');
GO

/* ------------------------------------------------------------
   One matching Reports row per item (uses SCOPE_IDENTITY-free join
   on ItemName so the script stays simple and re-runnable).
   ------------------------------------------------------------ */
INSERT INTO dbo.Reports (ItemID, ReporterName, StudentStaffID, ReportType, ReportDate)
SELECT i.ItemID, v.ReporterName, v.StudentStaffID, v.ReportType, i.DateReported
FROM dbo.Items AS i
INNER JOIN (VALUES
    ('Brown Leather Wallet',                        'Aisha Rahman',   'STU2023-0412', 'Lost'),
    ('Black Slim Card Wallet',                      'Farid Iskandar', 'STF2019-0087', 'Found'),
    ('Silver Ultrabook Laptop',                     'Nurul Huda',     'STF2020-0143', 'Found'),
    ('Introduction to Data Structures Textbook',    'Daniel Tan',     'STU2024-1188', 'Lost'),
    ('Student ID Card - Faculty of Engineering',    'Jia Wei Lim',    'STF2021-0215', 'Found'),
    ('Student ID Card - Lanyard Attached',          'Daniel Tan',     'STU2024-1188', 'Lost'),
    ('Bundle of Keys with Steel Ring',              'Siti Aminah',    'STF2022-0311', 'Found'),
    ('White Wireless Earbuds',                      'Mei Ling',       'STU2022-0755', 'Lost'),
    ('Navy Steel Water Bottle',                     'Hafiz Zulkifli', 'STF2023-0092', 'Found'),
    ('Navy Canvas Backpack',                        'Mei Ling',       'STU2022-0755', 'Lost'),
    ('Scientific Calculator',                       'Exam Unit',      'STF2018-0004', 'Found'),
    ('Black Framed Sunglasses',                     'Arun Kumar',     'STU2021-0930', 'Found')
) AS v (ItemName, ReporterName, StudentStaffID, ReportType)
    ON v.ItemName = i.ItemName;
GO

/* Quick check: should return 12 items and 12 reports. */
SELECT (SELECT COUNT(*) FROM dbo.Items)   AS TotalItems,
       (SELECT COUNT(*) FROM dbo.Reports) AS TotalReports;
GO
