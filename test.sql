WITH

t1 AS (
SELECT datetime('now','localtime') AS 'Report DateTime'
),

t2 AS (
  SELECT 
	COUNT(DISTINCT(Name)) AS 'Total Players', 
	COUNT(DISTINCT(Team)) AS 'Total Teams'
FROM sqltest_table 
),

t3 AS (
SELECT 
json_group_array(
	json_object('Name', Name, 'Goals', Goals)
) AS  'Top Three Players Stats'
FROM (SELECT Name, SUM(Goals) AS Goals
				FROM sqltest_table
				GROUP BY Name
				ORDER BY Goals DESC
				LIMIT 3)
),

t4 AS (
  SELECT COUNT(*)  AS 'Teams GT 250'
FROM
	(SELECT *
	FROM sqltest_table
	-- WHERE 'Teams GT 250' > 250
	GROUP BY 
		Team
	HAVING SUM(Goals) > 250
	ORDER BY 
		1 DESC) AS Z
)

SELECT *
FROM t1 JOIN t2 JOIN t3 JOIN t4
;