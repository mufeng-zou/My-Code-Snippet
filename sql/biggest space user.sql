SELECT
a3.name,
SUM ( CASE WHEN (ps.index_id < 2) THEN row_count ELSE 0 END ) AS [rows],
SUM (ps.reserved_page_count) AS reserved,
SUM (CASE WHEN (ps.index_id < 2) THEN (ps.in_row_data_page_count + ps.lob_used_page_count + ps.row_overflow_used_page_count)
ELSE (ps.lob_used_page_count + ps.row_overflow_used_page_count) END
) AS data,
SUM (ps.used_page_count) AS used
FROM sys.dm_db_partition_stats ps
INNER JOIN sys.all_objects a2 ON ( ps.object_id = a2.object_id )
INNER JOIN sys.schemas a3 ON (a2.schema_id = a3.schema_id)
WHERE a2.type <> N'S' and a2.type <> N'IT' 
GROUP BY a3.name
order by reserved desc