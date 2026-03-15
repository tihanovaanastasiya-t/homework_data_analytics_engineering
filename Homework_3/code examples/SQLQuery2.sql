 SET LANGUAGE us_english;
SET STATISTICS TIME ON
SET STATISTICS IO ON;

SELECT tp.[year], tp.[month], tp.[day], tp.[hour], tp.[minute],
    gobj.ascii_name, m.windSpeed, m.windDirection, m.temperature
FROM dbo.Measurement AS m
    JOIN dbo.CloudType AS ct ON ct.cloudTypeId = m.cloudTypeId
    JOIN dbo.TimePoint AS tp ON tp.timePointId = m.timePointId
    JOIN dbo.GeoObjectGeoPoint AS gogp ON gogp.geopointId = m.geoPointId
    JOIN dbo.Geoobject AS gobj ON gobj.geoobjectId = gogp.geoobjectId
WHERE ct.[name] = 'Cirrus'
    AND tp.[year] = 2022 AND (tp.[hour] >= 22 OR tp.[hour] <= 6) AND tp.[minute] = 0
    AND m.windSpeed >= 10.0 AND m.temperature <= 5.0
    AND gogp.position = 1;

SET STATISTICS TIME OFF
 SET STATISTICS IO  OFF;

---280

SELECT o.name,i.* from sys.objects o
INNER JOIN sys.indexes i on i.object_id= o.object_id
WHERE  o.name in ('Measurement', 'CloudType', 'TimePoint', 'GeoObjectGeoPoint', 'Geoobject')
ORDER BY o.name;

UPDATE STATISTICS dbo.Measurement WITH FULLSCAN;
UPDATE STATISTICS dbo.TimePoint WITH FULLSCAN;
UPDATE STATISTICS dbo.GeoObjectGeoPoint WITH FULLSCAN;
UPDATE STATISTICS dbo.GeoObject WITH FULLSCAN;
UPDATE STATISTICS dbo.CloudType WITH FULLSCAN;

DBCC FREEPROCCACHE;



CREATE NONCLUSTERED INDEX ix_Measurement_WindSpeed_Temp
ON Measurement (windSpeed, temperature)
INCLUDE (timePointId, geoPointId, cloudTypeId, windDirection);