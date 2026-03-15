USE meteo
GO

--SET STATISTICS TIME ON;
WITH geo as (
SELECT gobj.national_name,gcs.name  AS kind_of_mountains,
        count(sc.countryId) OVER ( PARTITION BY gobj.geoobjectId) as number_of_shared_country,  -- calculate how many countries 'share' the current Geoobjects
         c.name as shared_country  FROM SharedCountry sc
INNER JOIN dbo.Country C ON C.countryId = sc.countryId
INNER JOIN Geoobject gobj on gobj.geoobjectId = sc.geoobjectId
INNER JOIN GeonameSubclass gcs on gcs.geonameSubclassId = gobj.geonameSubclassId
INNER JOIN GeonameClass gc on gc. geonameClassId=gcs.geonameClassId
WHERE gc.code = 'T') -- GeonameClass with code 'T'
SELECT * FROM geo
    where number_of_shared_country > 1 -- shared only between at least two countries
    and kind_of_mountains LIKE 'mountain%'
ORDER BY national_name   
 --SET STATISTICS TIME OFF