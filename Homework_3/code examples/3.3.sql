
IF OBJECT_ID('tempdb..#RawLines') IS NOT NULL DROP TABLE #RawLines;

CREATE TABLE #RawLines (
    Line NVARCHAR(MAX)
);

BULK INSERT #RawLines
FROM 'C:\data\countries_for_import.csv'
WITH (
    ROWTERMINATOR = '0x0A',
    FIELDTERMINATOR = '\t',
    CODEPAGE = '65001',
    DATAFILETYPE = 'char'
);


ALTER TABLE #RawLines
ADD Id INT IDENTITY(1,1);


ALTER TABLE #RawLines
ADD BlockId INT;

WITH Blocks AS (
    SELECT *,
        BlockIdCalc = SUM(
            CASE
                WHEN Line IS NULL  THEN 1
                ELSE 0
            END
        ) OVER (ORDER BY Id)
    FROM #RawLines
)
UPDATE r
SET BlockId = b.BlockIdCalc
FROM #RawLines r
JOIN Blocks b
    ON r.Id = b.Id;


SELECT Id, BlockId, Line  FROM  #RawLines;


ALTER TABLE #RawLines
ADD Prefix NVARCHAR(20);

UPDATE #RawLines
SET Prefix = CASE
                WHEN LEFT(Line, 8) = 'Language' THEN 'Language'
                WHEN LEFT(Line, 8) = 'Neighbor' THEN 'Neighbor'
                WHEN Line IS NOT NULL AND LTRIM(RTRIM(Line)) <> '' THEN 'Country'
                ELSE NULL
             END;


SELECT Id, BlockId, Prefix, Line  FROM  #RawLines;


IF OBJECT_ID('tempdb..#RawLinesSplit') IS NOT NULL DROP TABLE #RawLinesSplit;

CREATE TABLE #RawLinesSplit (
    Id INT,
    BlockId INT,
    Prefix NVARCHAR(20),
    C1 NVARCHAR(200),
    C2 NVARCHAR(200),
    C3 NVARCHAR(200),
    C4 NVARCHAR(200),
    C5 NVARCHAR(200),
    C6 NVARCHAR(200),
    C7 NVARCHAR(200)
);

WITH Split AS (
    SELECT
        r.Id,
        r.BlockId,
        r.Prefix,
        value AS ColValue,
        ROW_NUMBER() OVER(PARTITION BY r.Id ORDER BY (SELECT NULL)) AS ColNum
    FROM #RawLines r
    CROSS APPLY STRING_SPLIT(r.Line, CHAR(9))
)
INSERT INTO #RawLinesSplit(Id, BlockId, Prefix, C1, C2, C3, C4, C5, C6, C7)
SELECT
    Id,
    BlockId,
    Prefix,
    MAX(CASE WHEN ColNum = 1 THEN ColValue END) AS C1,
    MAX(CASE WHEN ColNum = 2 THEN ColValue END) AS C2,
    MAX(CASE WHEN ColNum = 3 THEN ColValue END) AS C3,
    MAX(CASE WHEN ColNum = 4 THEN ColValue END) AS C4,
    MAX(CASE WHEN ColNum = 5 THEN ColValue END) AS C5,
    MAX(CASE WHEN ColNum = 6 THEN ColValue END) AS C6,
    MAX(CASE WHEN ColNum = 7 THEN ColValue END) AS C7
FROM Split
GROUP BY Id, BlockId, Prefix
ORDER BY Id;


SELECT *
FROM #RawLinesSplit
ORDER BY Id;


WITH CountryISO AS (
    SELECT BlockId, C1 AS ISO2
    FROM #RawLinesSplit
    WHERE Prefix='Country'
)
UPDATE r
SET C1 = c.ISO2
FROM #RawLinesSplit r
JOIN CountryISO c
    ON r.BlockId = c.BlockId
WHERE r.Prefix IN ('Language','Neighbor');

SELECT Prefix, C1, C2, C3, C4, C5, C6, C7
FROM #RawLinesSplit
ORDER BY Id;