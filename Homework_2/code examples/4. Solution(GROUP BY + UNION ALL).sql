USE meteo
GO

--SET STATISTICS TIME ON;
SELECT
        city_name, [year], [month], [day],
        AVG (temperature) AS averageTemperature
FROM dbo.view_TemperatureMeasurement
GROUP BY city_name, [year], [month], [day]
UNION ALL
SELECT
        city_name, [year], [month], NULL,
        AVG (temperature) AS averageTemperature
FROM dbo.view_TemperatureMeasurement
GROUP BY city_name, [year], [month]
UNION ALL
SELECT
        city_name, [year], NULL, NULL,
        AVG (temperature) AS averageTemperature
FROM dbo.view_TemperatureMeasurement
GROUP BY city_name, [year]
UNION ALL
SELECT
        city_name, NULL, NULL, NULL,
        AVG (temperature) AS averageTemperature
FROM dbo.view_TemperatureMeasurement
GROUP BY city_name
UNION ALL
SELECT
        NULL, NULL, NULL, NULL,
        AVG (temperature) AS averageTemperature
FROM dbo.view_TemperatureMeasurement;
 --SET STATISTICS TIME OFF