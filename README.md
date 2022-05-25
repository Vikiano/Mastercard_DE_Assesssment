# Mastercard_DE_Assesssment (Solution by **Victor Francis**)

## Problem Overview

### Scenario
The Analytics Team has described for you a series of SQL queries that they regularly run
against our data store to pull aggregate information. They use these queries to create daily
reports and/or perform ad-hoc investigations.
Your task is to automate this process by creating a system which automatically extracts the
information on a regular basis, and dumps that information to a local csv file.
The queries themselves are described below, as is the format of the csv’s expected output.
Feel free to use whatever tooling/language you feel is most appropriate to the task.

### Target Queries
1. How many players are in the table?
2. How many teams are there?
3. Who are the top 3 players who scored the most goals in order and how many goals?
4. How many teams had more than 250 goals from all their team players combined?

## My Solution
### Usage Instructions
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
2. Create a cron job using `crontab -e`.  

3. Edit and paste the commands in `cron_file.txt`
```
MAILTO=francisvictor47@gmail.com

0 5 * * 1-5 /Users/victorfrancis/opt/miniconda3/bin/python '/Users/victorfrancis/Downloads/Data Engineer Test/test.py'
```

## Snapshot of Output

- In this output, the cronjob is configured to run for every minute, which is different from the expectation to run at 5am Monday to Friday, so I can display an output as I only have a 24-hour window to make this solution. The proper schedule has been coded in the `cron_file.txt` in this repo.

|Report DateTime    |Total Players|Total Teams|Top Three Players Stats                                                                                   |Teams GT 250|
|-------------------|-------------|-----------|----------------------------------------------------------------------------------------------------------|------------|
|2022-05-25 05:49:00|880          |30         |[{"Name":"Alex Ovechkin","Goals":53},{"Name":"Steven Stamkos","Goals":43},{"Name":"Rick Nash","Goals":42}]|5           |
|2022-05-25 05:50:00|880          |30         |[{"Name":"Alex Ovechkin","Goals":53},{"Name":"Steven Stamkos","Goals":43},{"Name":"Rick Nash","Goals":42}]|5           |
|2022-05-25 05:51:00|880          |30         |[{"Name":"Alex Ovechkin","Goals":53},{"Name":"Steven Stamkos","Goals":43},{"Name":"Rick Nash","Goals":42}]|5           |
|2022-05-25 05:52:00|880          |30         |[{"Name":"Alex Ovechkin","Goals":53},{"Name":"Steven Stamkos","Goals":43},{"Name":"Rick Nash","Goals":42}]|5           |
|2022-05-25 05:53:00|880          |30         |[{"Name":"Alex Ovechkin","Goals":53},{"Name":"Steven Stamkos","Goals":43},{"Name":"Rick Nash","Goals":42}]|5           |
|2022-05-25 05:54:00|880          |30         |[{"Name":"Alex Ovechkin","Goals":53},{"Name":"Steven Stamkos","Goals":43},{"Name":"Rick Nash","Goals":42}]|5           |
|2022-05-25 06:04:00|880          |30         |[{"Name":"Alex Ovechkin","Goals":53},{"Name":"Steven Stamkos","Goals":43},{"Name":"Rick Nash","Goals":42}]|5           |
