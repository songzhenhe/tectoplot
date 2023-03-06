SELECT
  X(geom), Y(geom), Z(geom),
  CASE lower(magType)
    -- Weatherill, 2016
    WHEN 'mw' THEN
      1.021 * mag - 0.091
    -- Weatherill, 2016
    WHEN 'ms' THEN
      CASE
        WHEN mag >= 3.5 AND mag <= 6.47 THEN
          0.723 * mag + 1.798
        WHEN mag > 6.47 AND mag <= 8.0 THEN
          1.005 * mag - 0.026
        ELSE mag
      END
    -- Weatherill, 2016
    WHEN 'msz' THEN
      CASE
        WHEN mag >= 3.5 AND mag <= 6.47 THEN
          0.707 * mag + 1.933
        WHEN mag > 6.47 AND mag <= 8.0 THEN
          0.950 * mag + 0.359
        ELSE mag
      END
    -- Weatherill, 2016
    WHEN 'mb' THEN
      CASE
        WHEN mag >= 3.5 AND mag <= 7.0 THEN
          1.159 * mag - 0.659
        ELSE mag
      END
    -- Mereu, 2020
    WHEN 'ml' THEN
      0.62 * mag + 1.09
    ELSE mag
  END,
  CAST(time as VARCHAR),
  id
FROM anss
WHERE
  X(geom) is NOT NULL AND
  Y(geom) is NOT NULL AND
  Z(geom) is NOT NULL AND
  mag IS NOT NULL AND
  time IS NOT NULL AND
  id IS NOT NULL
