SET LANGUAGE us_english;
SET STATISTICS TIME ON
SET STATISTICS IO ON;

SELECT tp.[year], tp.[month], tp.[day], tp.[hour], tp.[minute],
    gobj.ascii_name, m.windSpeed, m.windDirection, m.temperature
FROM dbo.Measurement AS m
    JOIN dbo.CloudType AS ct ON ct.cloudTypeId = m.cloudTypeId
    JOIN dbo.TimePoint AS  tp ON tp.timePointId = m.timePointId
    JOIN dbo.GeoObjectGeoPoint  AS gogp ON gogp.geopointId = m.geoPointId
    JOIN dbo.Geoobject AS gobj ON gobj.geoobjectId = gogp.geoobjectId
WHERE ct.[name] = 'Cirrus'
    AND tp.[year] = 2022 AND (tp.[hour] >= 22 OR tp.[hour] <= 6) AND tp.[minute] = 0
    AND m.windSpeed >= 10.0 AND m.temperature <= 5.0
    AND gogp.position = 1;

SET STATISTICS TIME OFF
SET STATISTICS IO  OFF;

SELECT o.name, i.*
FROM sys.objects o
JOIN sys.indexes i ON i.object_id = o.object_id
WHERE o.name IN ('Measurement','CloudType','TimePoint','GeoObjectGeoPoint','Geoobject')
ORDER BY o.name;

CREATE NONCLUSTERED INDEX ix_Measurement_WindSpeed_Temp
ON Measurement (windSpeed, temperature)
INCLUDE (timePointId, geoPointId, cloudTypeId, windDirection);

CREATE NONCLUSTERED INDEX ix_Geoobject_ascii_name
ON Geoobject (geoobjectId)
INCLUDE (ascii_name);

CREATE NONCLUSTERED INDEX ix_TimePoint_Minute_Year_Hour
ON TimePoint (minute, year, hour)
INCLUDE (month, day, timePointId);

CREATE NONCLUSTERED INDEX ix_GeoobjectGeopointi_position
ON GeoobjectGeopoint (position, geopointId)
INCLUDE (geoobjectId);

SELECT
    OBJECT_NAME(i.object_id) AS TableName,
    i.name, ips.index_level,
    ips.avg_page_space_used_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(), null, null, null, 'detailed') AS ips
JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE i.name IN (
    'ix_Measurement_WindSpeed_Temp',
    'ix_GeoobjectGeopointi_position',
    'ix_TimePoint_Minute_Year_Hour',
    'ix_Geoobject_ascii_name'
);

