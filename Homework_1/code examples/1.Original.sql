USE meteo
GO

--SET STATISTICS TIME ON
SELECT gobj.national_name, 
    (SELECT [name] FROM dbo.GeonameSubclass AS gsc WHERE gsc.geonameSubclassId = gobj.geonameSubclassId) AS kind_of_mountains,
    (SELECT count(*) FROM dbo.SharedCountry AS sc WHERE sc.geoobjectId = gobj.geoobjectId) AS number_of_shared_country,
    c.[name] AS shared_country
FROM dbo.Geoobject AS gobj
LEFT JOIN dbo.SharedCountry AS sc ON sc.geoobjectId = gobj.geoobjectId
LEFT JOIN dbo.Country AS c ON sc.countryId = c.countryId
WHERE gobj.geonameSubclassId IN 
    (
        SELECT gsc.geonameSubclassId
        FROM dbo.GeonameClass AS gc
        JOIN dbo.GeonamesubClass AS gsc ON gc.geonameClassId = gsc.geonameClassId
        WHERE gc.code = 'T' AND gsc.[name] LIKE '%mountain%'
    )
    AND
    (SELECT count(*) FROM dbo.SharedCountry AS sc WHERE sc.geoobjectId = gobj.geoobjectId) > 1
ORDER BY gobj.national_name
--SET STATISTICS TIME OFF
