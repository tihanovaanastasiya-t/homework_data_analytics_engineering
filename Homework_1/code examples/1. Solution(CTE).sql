USE meteo
GO

--SET STATISTICS TIME ON;
WITH shcc AS (SELECT sc.geoobjectId, COUNT(sc.countryId) AS number_of_shared_country
              FROM SharedCountry sc
              GROUP BY sc.geoobjectId
              HAVING COUNT(sc.countryId) > 1),  --  Geoobjects which are shared between at least 2 countries
	 gcs AS (SELECT gobj.geoobjectId, gobj.national_name, gcs.geonameSubclassId, gcs.name  AS geonameSubclass,shcc.number_of_shared_country
            FROM GeonameClass gc
            INNER JOIN GeonameSubclass gcs ON gcs.geonameClassId = gc.geonameClassId
            INNER JOIN Geoobject gobj on gobj.geonameSubclassId = gcs.geonameSubclassId
            INNER JOIN shcc on shcc.geoobjectId = gobj.geoobjectId
            WHERE gc.code = 'T' and gcs.name LIKE 'mountain%') -- Shared Geoobjects that are related to a GeonameSubclass containing 'mountain' and GeonameClass with code 'T'
 SELECT gcs.national_name, gcs.geonameSubclass, gcs.number_of_shared_country,c.name from    gcs
 INNER JOIN SharedCountry sc on  sc.geoobjectId = gcs.geoobjectId
 INNER JOIN Country c on c.countryId = sc.countryId
 ORDER BY national_name;
 --SET STATISTICS TIME OFF