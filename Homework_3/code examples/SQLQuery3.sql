SET STATISTICS IO ON;
SET STATISTICS TIME ON;
    SELECT tp.[year], tp.[month], tp.[day], tp.[hour], tp.[minute],
    gobj.ascii_name, m.windSpeed, m.windDirection, m.temperature
FROM dbo.Measurement AS m     WITH ( INDEX (IX_Measurement_Wind_Temp2))
    JOIN dbo.CloudType AS ct ON ct.cloudTypeId = m.cloudTypeId
    JOIN dbo.TimePoint  AS tp WITH ( INDEX (IX_TimePoint_Year_Minute_Hour2 )) ON tp.timePointId = m.timePointId 
    JOIN dbo.GeoObjectGeoPoint AS gogp WITH ( INDEX (IX_GeoobjectGeopointi_position_Temp2)) ON gogp.geopointId = m.geoPointId
    JOIN dbo.Geoobject AS gobj ON gobj.geoobjectId = gogp.geoobjectId
WHERE ct.[name] = 'Cirrus'
    AND tp.[year] = 2022 AND (tp.[hour] >= 22 OR tp.[hour] <= 6) AND tp.[minute] = 0
    AND m.windSpeed >= 10.0 AND m.temperature <= 5.0
    AND gogp.position = 1;
 SET STATISTICS TIME OFF;
 
 SET STATISTICS IO  OFF;

SET STATISTICS TIME ON

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



SET STATISTICS TIME OFF




						   