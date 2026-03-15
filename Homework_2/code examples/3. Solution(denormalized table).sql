USE meteo
GO

SELECT 
    m.geoPointId,
    m.timePointId,
    gob.geoObjectId,
    gob.national_name AS city_name,
    c.countryId AS country_id,
    c.name AS country_name,
    tp.[year],
    tp.[month],
    tp.[day],
    tp.[hour],
    tp.minute,
    m.cloudTypeId,
    m.relativeHumidity,
    m.pressure,
    m.fillFlagId,
    m.temperature,
    m.windDirection,
    m.windSpeed
INTO dbo.FactMeasurement
FROM dbo.Measurement AS m
INNER JOIN dbo.GeoObjectGeoPoint AS gogp ON gogp.geoPointId = m.geoPointId
INNER JOIN dbo.GeoObject AS gob ON gob.geoObjectId = gogp.geoObjectId
INNER JOIN dbo.Country AS c ON c.countryId = gob.countryId
INNER JOIN dbo.TimePoint AS tp ON tp.timePointId = m.timePointId;

ALTER TABLE dbo.FactMeasurement
ADD CONSTRAINT pk_FactMeasurement PRIMARY KEY (timePointId, geoObjectId);

CREATE INDEX idx_FactMeasurement_City
ON dbo.FactMeasurement (geoObjectId);

CREATE INDEX idx_FactMeasurement_Country
ON dbo.FactMeasurement (country_id);

CREATE INDEX idx_FactMeasurement_Date
ON dbo.FactMeasurement (year, month, day);

CREATE INDEX idx_FactMeasurement_CityName
ON dbo.FactMeasurement (city_name);