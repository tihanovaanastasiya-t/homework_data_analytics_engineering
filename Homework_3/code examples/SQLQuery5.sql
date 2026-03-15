SELECT
    OBJECT_NAME(i.object_id) AS TableName,
    i.name, ips.index_level,
    ips.avg_page_space_used_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(), null, null, null, 'detailed') AS ips
JOIN sys.indexes i ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE i.name IN ('ix_Measurement_WindSpeed_Temp', 'ix_GeoobjectGeopointi_position', 'ix_TimePoint_Minute_Year_Hour', 'ix_Geoobject_ascii_name');

SELECT o.name, i.*
FROM sys.objects o
JOIN sys.indexes i ON i.object_id = o.object_id
WHERE o.name IN ('Measurement','CloudType','TimePoint','GeoObjectGeoPoint','Geoobject')
ORDER BY o.name;