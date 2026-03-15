USE meteo
GO

--SET STATISTICS TIME ON;
WITH tp as (
SELECT tp.timePointId, gp.latitude, gp.longitude, m.temperature, m.geoPointId FROM TimePoint tp
INNER JOIN Measurement m on m.timePointId = tp.timePointId
INNER JOIN GeoPoint gp on gp.geoPointId=m.geoPointId
WHERE tp.month = 1 and day = 1 and tp.hour = 0 and tp.minute = 0), -- temperature measurements for 00:00 on January 1st
    res as (
SELECT tp.latitude, tp.longitude, max(tp.temperature) - min(tp.temperature) as diff, -- difference between mininum and maximum of temperature in the same point
      rank() OVER (ORDER BY max(tp.temperature) - min(tp.temperature) desc) as rank -- rank by difference in descending order
FROM tp
GROUP BY tp.geoPointId,tp.latitude, tp.longitude)
SELECT latitude, longitude, round(diff, 2) AS mxdt FROM res
WHERE rank = 1;-- only the top GeoPoint (maximum difference)
 --SET STATISTICS TIME OFF