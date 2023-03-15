--- Delete rows from anss_update when rows in anss_update have a more recent update time
DELETE FROM anss_update
WHERE EXISTS ( SELECT 1 FROM anss WHERE anss.id = anss_update.id AND anss.updated >= anss_update.updated ) 
