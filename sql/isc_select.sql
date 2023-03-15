-- EVENTID,TYPE,AUTHOR,DATE,LAT,LON,DEPTH,DEPFIX,ORIGAUTHOR,magTYPE,mag
SELECT
  X(geom), Y(geom), Z(geom),
  CASE lower(magType)
    -- Weatherill, 2016
    WHEN 'ms' THEN
      CASE
        WHEN mag >= 3.5 AND mag <= 6 THEN
          0.616 * mag + 2.369
        WHEN mag > 6.47 AND mag <= 8.0 THEN
          0.994 * mag + 0.1
        ELSE mag
      END
    -- Weatherill, 2016
    WHEN 'mb' THEN
      CASE
        WHEN mag >= 3.5 AND mag <= 7.0 THEN
          1.084 * mag - 0.142
        ELSE mag
      END
    ELSE mag
  END,
  CAST(time as VARCHAR),
  id
FROM iscseis
WHERE
  X(geom) is NOT NULL AND
  Y(geom) is NOT NULL AND
  Z(geom) is NOT NULL AND
  mag IS NOT NULL AND
  time IS NOT NULL AND
  id IS NOT NULL
