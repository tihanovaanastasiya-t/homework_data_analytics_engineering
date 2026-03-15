
SELECT *
FROM dbo.Language
WHERE languageId IS NULL;  -- returns 0 rows

SELECT languageId, COUNT(*)
FROM dbo.Language
GROUP BY languageId
HAVING COUNT(*) > 1;  -- returns 0 rows

WITH Language2 AS (
    SELECT languageId,
           LEAD(languageId) OVER (ORDER BY languageId) AS nextID,
           LEAD(languageId) OVER (ORDER BY languageId) - languageId AS gap
    FROM dbo.Language
)
SELECT *
FROM Language2
WHERE gap > 1;  -- returns 0 rows


SELECT *
FROM Language
WHERE ISO_code IS NULL
   OR LEN(ISO_code) != 3
   OR ISO_code LIKE '%[^a-z]%';  -- returns 0 rows

SELECT ISO_code, COUNT(*)
FROM dbo.Language
GROUP BY ISO_code
HAVING COUNT(*) > 1;  -- returns 0 rows

SELECT *
FROM Language
WHERE LEN(ISO_code2) != 2
   OR ISO_code2 LIKE '%[^a-z]%'; -- returns 0 rows

SELECT ISO_code2, COUNT(*)
FROM dbo.Language
WHERE ISO_code2 is not NULL
GROUP BY ISO_code2
HAVING COUNT(*) > 1;  -- returns 0 rows

SELECT COUNT(languageId) FROM Language;  -- 7925

SELECT ROUND(COUNT(languageId)/7925.0 * 100, 2)
FROM Language
WHERE ISO_code2 IS NULL;  -- 97.67%

SELECT *
FROM Language
WHERE languageFamily IS NULL; -- returns 0 rows

SELECT *
FROM Language
WHERE languageFamily NOT IN (0, 1); -- returns 0 rows

SELECT *
FROM Language
WHERE name LIKE '%languages%'
  AND languageFamily = 'false'; -- returns 0 rows

SELECT languageFamily,
       ROUND(COUNT(languageId)/7925.0 * 100, 2)
FROM Language
GROUP BY languageFamily;

SELECT *
FROM Language
WHERE name IS NULL; -- returns 0 rows

SELECT name
FROM Language
GROUP BY name
HAVING COUNT(*) > 1; -- returns 0 rows

WITH lenName AS (
    SELECT MAX(LEN(name)) AS maxLen,
           MIN(LEN(name)) AS minLen
    FROM Language
)
SELECT *
FROM Language
WHERE LEN(name) = (SELECT maxLen FROM lenName)
   OR LEN(name) = (SELECT minLen FROM lenName)
ORDER BY LEN(name);

SELECT *
FROM Language
WHERE name LIKE '%[^A-Za-z]%';

SELECT *
FROM Language
WHERE name LIKE '%[^A-Za-z ''-().,;0-9]%';

IF OBJECT_ID('dbo.TempIsoSet3') IS NOT NULL DROP TABLE dbo.TempIsoSet3;

CREATE TABLE dbo.TempIsoSet3 (
    Id NVARCHAR(10),
    Part2b NVARCHAR(10),
    Part2t NVARCHAR(10),
    Part1 NVARCHAR(10),
    Scope NVARCHAR(10),
    Language_Type NVARCHAR(10),
    Ref_Name NVARCHAR(200),
    Comment NVARCHAR(200)
);

BULK INSERT dbo.TempIsoSet3
FROM 'C:\data\iso-639-3.tab'
WITH (
    FIELDTERMINATOR = '\t',
    ROWTERMINATOR = '0x0a',
    FIRSTROW = 2,
    CODEPAGE = '65001',
    TABLOCK
);


select * from dbo.TempIsoSet3;

select * from dbo.TempIsoSet5;

IF OBJECT_ID('dbo.TempIsoSet5') IS NOT NULL DROP TABLE dbo.TempIsoSet5;

CREATE TABLE dbo.TempIsoSet5 (
    URI NVARCHAR(200),
    code NVARCHAR(10),
    Label_English NVARCHAR(200),
    Label_French NVARCHAR(200)
);

BULK INSERT dbo.TempIsoSet5
FROM 'C:\data\iso639-5.tsv'
WITH (
    FIELDTERMINATOR = '\t',
    ROWTERMINATOR = '0x0A',
    FIRSTROW = 2,
    CODEPAGE = '65001'
);

WITH iso AS (
    SELECT code AS id, Label_English AS name, NULL AS iso_code2, 'true' AS languageFamily -- because Set 5 contains language families and groups
    FROM TempIsoSet5
    UNION
    SELECT id, Ref_Name AS name, Part1 AS iso_code2, 'false' AS languageFamily
    FROM TempIsoSet3
)
SELECT *
FROM Language l
LEFT JOIN iso ON l.ISO_code = iso.id
WHERE l.iso_code2 != iso.iso_code2
ORDER BY id; -- returns 0 rows, meaning all iso_code2 values match.

WITH iso AS (
    SELECT code as id , Label_English as name, NULL as ISO_code2, 'true' as languageFamily
    FROM TempIsoSet5
    UNION
    SELECT id as id, Ref_Name as name, Part1 as ISO_code2, 'false' as languageFamily
    FROM TempIsoSet3
)
SELECT *
FROM Language l
LEFT JOIN iso ON l.ISO_code = iso.id
WHERE l.languageFamily <> iso.languageFamily
ORDER BY id;-- returns 0 rows, meaning all languageFamily values match.

WITH iso AS (
    SELECT code as id , Label_English as name, NULL as ISO_code2, 'true' as languageFamily
    FROM TempIsoSet5
    UNION
    SELECT Id as id, Ref_Name as name, Part1 as ISO_code2, 'false' as languageFamily
    FROM TempIsoSet3
)
SELECT *
FROM Language l
LEFT JOIN iso ON l.ISO_code = iso.id
WHERE iso.id IS NULL
ORDER BY l.ISO_code;


WITH iso AS (
    SELECT code as id , Label_English as name, NULL as ISO_code2, 'true' as languageFamily
    FROM TempIsoSet5
    UNION
    SELECT id as id, Ref_Name as name, Part1 as ISO_code2, 'false' as languageFamily
    FROM TempIsoSet3
), fix AS (
SELECT l.ISO_code, l.name
FROM Language l
LEFT JOIN iso ON l.ISO_code = iso.id
WHERE iso.id IS NULL
AND l.ISO_code != 'him')
UPDATE l
SET deprecated = 1
FROM Language l
INNER JOIN fix on fix.ISO_code=l.ISO_code



WITH iso AS (
    SELECT code as id , Label_English as name, NULL as ISO_code2, 'true' as languageFamily
    FROM TempIsoSet5
    UNION
    SELECT id as id, Ref_Name as name, Part1 as ISO_code2, 'false' as languageFamily
    FROM TempIsoSet3
)
SELECT iso.id, iso.languageFamily, iso.iso_code2, iso.name
FROM iso
LEFT JOIN Language l ON l.ISO_code = iso.id
WHERE l.ISO_code IS NULL
ORDER BY l.ISO_code;

WITH iso AS (
    SELECT code as id , Label_English as name, NULL as ISO_code2, 'true' as languageFamily
    FROM TempIsoSet5
    UNION
    SELECT id as id, Ref_Name as name, Part1 as ISO_code2, 'false' as languageFamily
    FROM TempIsoSet3
)
 INSERT INTO Language (ISO_code, languageFamily, ISO_code2, name,  deprecated )
 (
SELECT iso.id, iso.languageFamily, iso.iso_code2, iso.name,'false' as deprecated
FROM iso
LEFT JOIN Language l ON l.ISO_code = iso.id
WHERE l.ISO_code IS NULL);

WITH iso as (
    SELECT code as id , Label_English as name, NULL as ISO_code2, 'true' as languageFamily
    FROM TempIsoSet5
    UNION
    SELECT id as id, Ref_Name as name, Part1 as ISO_code2, 'false' as languageFamily
    FROM TempIsoSet3
)
SELECT l.ISO_code, l.languageFamily, l.iso_code2, l.name, iso.name as iso_name FROM iso  INNER JOIN Language l on l.ISO_code=iso.id
         WHERE iso.name != l.name
ORDER BY l.ISO_code;

ALTER TABLE Language
ADD name_fix NVARCHAR(200);

UPDATE Language
SET name_fix = name;

WITH iso AS (
    SELECT code as id , Label_English as name, NULL as ISO_code2, 'true' as languageFamily
    FROM TempIsoSet5
    UNION
    SELECT id as id, Ref_Name as name, Part1 as ISO_code2, 'false' as languageFamily
    FROM TempIsoSet3
),
fix AS (
    SELECT l.ISO_code, iso.name
    FROM Language l
    LEFT JOIN iso ON l.ISO_code = iso.id
    WHERE l.name <> iso.name
)
UPDATE l
SET l.name_fix = fix.name
FROM Language l
JOIN fix ON fix.ISO_code = l.ISO_code;