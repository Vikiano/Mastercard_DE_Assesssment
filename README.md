# Mastercard_DE_Assesssment

## Usage Instructions
1. Create `test.py`
```
import sqlite3
import pandas as pd

con = sqlite3.connect('/Users/victorfrancis/Downloads/Data Engineer Test/de_test_db.sqlite')

cur = con.cursor()

df_new = pd.read_sql_query("""
WITH 

t1 AS (
SELECT datetime('now','localtime') AS 'Report DateTime'
),

t2 AS (
  SELECT 
	COUNT(DISTINCT(Name)) AS 'Total Players', 
	COUNT(DISTINCT(Team)) AS 'Total Teams'
FROM 'sqltest_table'
),

t3 AS (
SELECT 
json_group_array(
	json_object('Name', Name, 'Goals', Goals)
) AS  'Top Three Players Stats'
FROM (SELECT Name, SUM(Goals) AS Goals
				FROM 'sqltest_table'
				GROUP BY Name
				ORDER BY Goals DESC
				LIMIT 3)
),

t4 AS (
  SELECT COUNT(*)  AS 'Teams GT 250'
FROM
	(SELECT *
	FROM 'sqltest_table'
	-- WHERE 'Teams GT 250' > 250
	GROUP BY 
		Team
	HAVING SUM(Goals) > 250
	ORDER BY 
		1 DESC) AS Z
)

SELECT *
from t1 join t2 join t3 join t4
""", con)

con.close()

file = "/Users/victorfrancis/Downloads/Data Engineer Test/test_file.csv" 

try:
    df_old = pd.read_csv(file, sep="|")
    df_updated = pd.concat([df_old, df_new])
    df_updated.to_csv(file, sep="|", index=False)

except FileNotFoundError:
    df_new.to_csv(file, sep="|", index=False)
    pass
```
2. Create a cron job using the the cron commands in `cron_file.txt`
```
MAILTO=francisvictor47@gmail.com

0 5 * * 1-5 /Users/victorfrancis/opt/miniconda3/bin/python '/Users/victorfrancis/Downloads/Data Engineer Test/test.py'
```
