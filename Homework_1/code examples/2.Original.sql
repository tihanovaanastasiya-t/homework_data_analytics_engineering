USE meteo
GO

DECLARE 
    @minId INT = (SELECT min(geopointId) FROM dbo.GeoPoint), -- minimal geopointId
    @maxId INT = (SELECT max(geopointId) FROM dbo.GeoPoint), -- maximal geopointId
    @curId INT,             -- geopointId for current point
    @lat FLOAT,             -- latitude of GeoPoint with maximal temperature difference
    @long FLOAT,            -- longitude of GeoPoint with maximal temperature difference
    @curdif FLOAT,          -- the maximal temperature difference for current GeoPoint
    @maxdif FLOAT = 0.0     -- the maximal temperature difference throughout all points
    
SET @curId = @minId

WHILE (@curId <= @maxId)
BEGIN

    SELECT @curdif = max(m.temperature) - min(m.temperature) 
    FROM dbo.Measurement AS m 
    INNER JOIN dbo.TimePoint AS tp ON m.timePointId = tp.timePointId
    WHERE m.geopointId = @curId AND tp.[month] = 1 AND tp.[day] = 1 AND tp.[hour] = 0 AND tp.[minute] = 0

    IF @curdif > @maxdif
    BEGIN
        SET @maxdif = @curdif

        SELECT @lat = latitude, @long = longitude 
        FROM dbo.GeoPoint
        WHERE geoPointId = @curId
    END
    SET @curId = @curId + 1
END
SELECT @lat AS latitude, @long AS longitude, @maxdif AS mxdt