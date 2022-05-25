with 

t1 as (
SELECT datetime('now','localtime') AS 'Report DateTime'
),

t2 as (
  SELECT 
	COUNT(DISTINCT(Name)) AS 'Total Players', 
	COUNT(DISTINCT(Team)) AS 'Total Teams'
FROM sqltest_table 
),

t3 as (
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

t4 as (
  SELECT COUNT(*)  AS 'Teams GT 250'
FROM
	(SELECT *
	FROM sqltest_table
	-- WHERE 'Teams GT 250' > 250
	GROUP BY 
		Team
	HAVING SUM(Goals) > 250
	ORDER BY 
		1 DESC) As Z
)

select *
from t1 join t2 join t3 join t4
-- on t1.rn = t2.rn