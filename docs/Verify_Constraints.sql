USE RaceDay;
GO

SELECT
    o.type_desc AS ConstraintType,
    COUNT(*) AS Total
FROM sys.objects AS o
JOIN sys.tables AS t
    ON o.parent_object_id = t.object_id
WHERE o.type IN ('PK', 'F', 'UQ', 'C', 'D')
GROUP BY o.type_desc
ORDER BY o.type_desc;