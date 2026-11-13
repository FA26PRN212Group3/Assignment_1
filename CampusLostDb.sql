-- CampusLost · PRN212_Assignment 1
-- Chạy toàn bộ file trong SQL Server Management Studio (SSMS).

USE [master];
GO

IF DB_ID(N'CampusLostDb') IS NULL
BEGIN
    CREATE DATABASE [CampusLostDb];
END;
GO

USE [CampusLostDb];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRANSACTION;

    IF OBJECT_ID(N'dbo.Posts', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Posts
        (
            Id int IDENTITY(1, 1) NOT NULL,
            Title nvarchar(100) COLLATE Vietnamese_CI_AS NOT NULL,
            Kind int NOT NULL,
            [Location] nvarchar(120) NOT NULL,
            [Description] nvarchar(500) NOT NULL,
            Contact nvarchar(120) NOT NULL,
            PostedOn datetime2(0) NOT NULL
                CONSTRAINT DF_Posts_PostedOn DEFAULT (SYSUTCDATETIME()),

            CONSTRAINT PK_Posts PRIMARY KEY CLUSTERED (Id),
            CONSTRAINT CK_Posts_Kind CHECK (Kind IN (1, 2)),
            CONSTRAINT CK_Posts_Title_NotBlank
                CHECK (LEN(LTRIM(RTRIM(Title))) > 0),
            CONSTRAINT CK_Posts_Location_NotBlank
                CHECK (LEN(LTRIM(RTRIM([Location]))) > 0),
            CONSTRAINT CK_Posts_Description_NotBlank
                CHECK (LEN(LTRIM(RTRIM([Description]))) > 0),
            CONSTRAINT CK_Posts_Contact_NotBlank
                CHECK (LEN(LTRIM(RTRIM(Contact))) > 0)
        );
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM sys.indexes
        WHERE object_id = OBJECT_ID(N'dbo.Posts', N'U')
          AND name = N'IX_Posts_PostedOn_Id'
    )
    BEGIN
        CREATE NONCLUSTERED INDEX IX_Posts_PostedOn_Id
            ON dbo.Posts (PostedOn DESC, Id DESC);
    END;

    -- Kind = 1: Bị mất. Kind = 2: Nhặt được.
    INSERT INTO dbo.Posts (Title, Kind, [Location], [Description], Contact)
    SELECT seed.Title, seed.Kind, seed.[Location], seed.[Description], seed.Contact
    FROM
    (
        VALUES
            (N'Bình nước xanh', 2, N'Thư viện',
             N'Bình nước ở bàn gần cửa sổ.', N'thuvien@example.com'),
            (N'Thẻ sinh viên', 1, N'Sảnh tòa A',
             N'Thẻ nằm trong bao màu đen.', N'sinhvien@example.com'),
            (N'Tai nghe không dây', 1, N'Phòng B203',
             N'Hộp tai nghe màu trắng có dán hình ngôi sao.', N'tainghe@example.com'),
            (N'Ví da nâu', 1, N'Căn tin',
             N'Ví da nhỏ, bên trong có thẻ giữ xe.', N'vida@example.com'),
            (N'Áo khoác xám', 1, N'Sân bóng rổ',
             N'Áo khoác có mũ, cỡ M.', N'aokhoac@example.com'),
            (N'Sổ tay bìa xanh', 1, N'Phòng tự học',
             N'Bìa xanh đậm, trang đầu ghi lịch học.', N'sotay@example.com'),
            (N'Chùm chìa khóa', 2, N'Bãi giữ xe',
             N'Ba chìa khóa và một móc nhựa đỏ.', N'chiakhoa@example.com'),
            (N'Ô gấp màu đen', 2, N'Hành lang tòa C',
             N'Ô gấp để cạnh ghế chờ tầng hai.', N'ogap@example.com'),
            (N'Bút cảm ứng', 2, N'Phòng máy A305',
             N'Bút màu trắng nằm cạnh bàn phím.', N'butcamung@example.com'),
            (N'Hộp kính xanh đậm', 2, N'Sảnh tòa B',
             N'Hộp kính cứng có khăn lau bên trong.', N'hopkinh@example.com')
    ) AS seed (Title, Kind, [Location], [Description], Contact)
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM dbo.Posts AS post WITH (UPDLOCK, HOLDLOCK)
        WHERE post.Title = seed.Title
          AND post.Kind = seed.Kind
          AND post.[Location] = seed.[Location]
          AND post.[Description] = seed.[Description]
          AND post.Contact = seed.Contact
    );

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;
END CATCH;
GO

-- Danh sách tin sau khi cài đặt
SELECT Id, Title, Kind, [Location], [Description], Contact, PostedOn
FROM dbo.Posts
ORDER BY PostedOn DESC, Id DESC;

-- Kiểm tra tìm theo tên và loại tin
-- Với database mới, truy vấn này trả về tin Bình nước xanh.
SELECT Id, Title, Kind, [Location], PostedOn
FROM dbo.Posts
WHERE Kind = 2 AND CHARINDEX(N'BÌNH', Title) > 0
ORDER BY PostedOn DESC, Id DESC;
GO
