# SQL-Project-Calculating-Free-to-Paid-Conversion-Rate

**Introduction**

The project aims to estimate the fraction of students who purchased a subscription after starting a lecture, i.e., the free-to-paid conversion rate among students who have engaged with video content on the 365 platform.

Questions:
1.	What is the approximate free-to-paid conversion rate of students who have watched a lecture on the 365 platform?
2.	What is the approximate average duration between the registration date and when a student has watched a lecture for the first time (date of first-time engagement)?
3.	What is the approximate average duration between the date of first-time engagement and when a student purchases a subscription for the first time (date of first-time purchase)?
4.	How can we interpret these results, and what are their implications?

**Database and Tools**

• MySQL

• MySQL Workbench 8.0 CE

**Project files**

db_course_conversions.sql – the file contains the database for the project.

**Part 1: Create the Subquery**

Import the db_course_conversions database—stored in the db_course_conversions.sql file. Refresh the Schemas section, db_course_conversion database appears in the the list. It has three tables on student_engagement, student_info, and student_purchases. 
Apply the USE db_course_conversion; statement to make it the default (current) database.

![VennDiagram](https://github.com/user-attachments/assets/d27fd0bb-5547-4787-adf2-96f19b76b986)

Then, by appropriately joining and aggregating the tables, create a new result dataset comprising the following columns:

• student_id – (int) the unique identification of a student

• date_registered – (date) the date on which the student registered on the 365 platform

• first_date_watched – (date) the date of the first engagement

• first_date_purchased – (date) the date of first-time purchase (NULL if they have no purchases)

• date_diff_reg_watch – (int) the difference in days between the registration date and the date of first-time engagement

• date_diff_watch_purch – (int) the difference in days between the date of first-time engagement and the date of first-time purchase (NULL if they have no purchases).

1. First, we join the student_engagement table with student_info table. From the Venn diagram, we can see that all the students present in the student_engagement table are present on the student_info table. Hence when we join the two tables, we can retrieve all the details from the engagement dates and registration dates, which is crucial in the next step. We can join the tables on the student_id field.
2. As a next step, we join the result set with student_purchases table to exclude all students who have not watched a lecture. This can be achieved with LEFT JOIN. We create this join on the student_id field.

```sql
USE db_course_conversions;
```
```sql
SELECT
    e.student_id,
    i.date_registered,
FROM
  student_engagement e
JOIN
  student_info i ON e.student_id = i.student_id
LEFT JOIN
  student_purchases p ON i.student_id = p.student_id
```
We can retrieve the first-time engagement and purchase dates from the engagement and purchase tables respectively. We can use the MIN aggregate function to achieve them. When applied to numbers, the function returns the smallest number in the dataset. 

```sql
    MIN(e.date_watched) AS first_date_watched,
    MIN(p.date_purchased) AS first_date_purchased,
```
As the hint suggests, we can use the DATEDIFF function to retrieve the day difference between the two dates. Note that the date that comes later should be placed as the first argument in the function and the one that comes earlier should be the second argument in the function. The DATEDIFF function will also return NULL if one or both dates is/are NULL.

```sql
    DATEDIFF(MIN(e.date_watched), i.date_registered) AS date_diff_reg_watch,
    DATEDIFF(MIN(p.date_purchased), MIN(e.date_watched)) AS date_diff_watch_purch
```

We used the MIN aggregate function to find the earliest engagement date and earliest purchase dates. To find the earliest dates per student, we must group by the student_id field from the student_engagement table.

```sql
 SELECT
    e.student_id,
    i.date_registered,
    MIN(e.date_watched) AS first_date_watched,
    MIN(p.date_purchased) AS first_date_purchased,
    DATEDIFF(MIN(e.date_watched), i.date_registered) AS date_diff_reg_watch,
    DATEDIFF(MIN(p.date_purchased), MIN(e.date_watched)) AS date_diff_watch_purch
FROM
  student_engagement e
JOIN
  student_info i ON e.student_id = i.student_id
LEFT JOIN
  student_purchases p ON i.student_id = p.student_id
GROUP BY e.student_id   
```
As a final step, we should filter the data so that the earliest engagement date is before the earliest purchase date or is on the same day as the earliest purchase date. We also need to include all records whose first_date_purchased column equals NULL to indicate that the student hasn’t made a purchase. We need to combine these two conditions in a HAVING clause. In this case, HAVING is important as opposed to the WHERE clause due to the aggregation function used in previous steps.

```sql
SELECT
    e.student_id,
    i.date_registered,
    MIN(e.date_watched) AS first_date_watched,
    MIN(p.date_purchased) AS first_date_purchased,
    DATEDIFF(MIN(e.date_watched), i.date_registered) AS date_diff_reg_watch,
    DATEDIFF(MIN(p.date_purchased), MIN(e.date_watched)) AS date_diff_watch_purch
FROM
  student_engagement e
JOIN
  student_info i ON e.student_id = i.student_id
LEFT JOIN
  student_purchases p ON i.student_id = p.student_id
GROUP BY e.student_id
HAVING first_date_purchased IS NULL
OR first_date_watched <= first_date_purchased;
```
**Part 2: Create the Main Query**

Surround the subquery created previously in parentheses and give it an alias, a.

```sql
SELECT
    ..
FROM
    ..
GROUP BY
    ..
HAVING ..) a;
```
In this task, we can use the subquery created and retrieve the following three metrics.

This metric measures the proportion of engaged students who choose to benefit from full course access on the 365 platform by purchasing a subscription after watching a lecture. It is calculated as the ratio between:

• The number of students who watched a lecture and purchased a subscription on the same day or later.

• The total number of students who have watched a lecture.

Convert the result to percentages and call the field conversion_rate.

We can calculate the count of the number of occurrences in the first_date_purchased column and divide the result by the number of occurrences in the first_date_watched column. The COUNT function will not account for the NULL values in the former column, giving the number of students who purchased a subscription after watching a lecture. We round the number to two decimal places and multiply it by 100 to retrieve the result in percentages.

```sql
SELECT
ROUND(COUNT(first_date_purchased)/COUNT(first_date_watched),2) *100 AS conversion_rate,

FROM
    (...) a;
```
**Average Duration Between Registration and First-Time Engagement:**

This metric measures the average duration between the date of registration and the date of first-time engagement. This will tell us how long it takes, on average, for a student to watch a lecture after registration. The metric is calculated by finding the ratio between:

• The sum of all such durations.

• The count of these durations, or alternatively, the number of students who have watched a lecture.

Call the field av_reg_watch.

The second metric, av_reg_watch, can be calculated by adding all the records from the days_diff_reg_watch column and dividing the result by the number of records in the same column. This will give the average duration between the date of registration and the date of first-time engagement.

```sql
SELECT
ROUND(COUNT(first_date_purchased)/COUNT(first_date_watched),2) *100 AS conversion_rate,
ROUND(SUM(date_diff_reg_watch)/COUNT(date_diff_reg_watch),2) AS av_reg_watch,

FROM
    (...) a;
```
**Average Duration Between First-Time Engagement and First-Time Purchase:**
This metric measures the average time it takes individuals to subscribe to the platform after viewing a lecture. It is calculated by dividing:

• The sum of all such durations.

• The count of these durations, or alternatively, the number of students who have made a purchase.

Call the field av_watch_purch.

Finally, the third metric is analogously found by summing all records from the days_diff_watch_purch column and dividing the result by the number of records in this column. This will give the average duration between first-time engagement and first-time purchase dates.

```sql
SELECT
ROUND(COUNT(first_date_purchased)/COUNT(first_date_watched),2) *100 AS conversion_rate,
ROUND(SUM(date_diff_reg_watch)/COUNT(date_diff_reg_watch),2) AS av_reg_watch,
ROUND(SUM(date_diff_watch_purch)/COUNT(date_diff_watch_purch),2) AS av_watch_purch

FROM
    (...) a;
```

**Main query**

```sql
-- Select columns to retrieve information on students' engagement with 365 platform

SELECT
    e.student_id,
    i.date_registered,
    MIN(e.date_watched) AS first_date_watched, -- Earliest date the student watched content
    MIN(p.date_purchased) AS first_date_purchased, -- Earliest date the student made a purchase
    
  -- Calculate the difference in days between registration date and the first watch date
    DATEDIFF(MIN(e.date_watched), i.date_registered) AS date_diff_reg_watch, 
    
	-- Calculate the difference in days between the first watch date and the first purchase date
    DATEDIFF(MIN(p.date_purchased), MIN(e.date_watched)) AS date_diff_watch_purch
FROM
	student_engagement e
JOIN
	student_info i ON e.student_id = i.student_id
    
  -- Left join the student_purchases table to get purchase data (if it exists) for each student
	LEFT JOIN
student_purchases p ON i.student_id = p.student_id
GROUP BY e.student_id
HAVING first_date_purchased IS NULL
	OR first_date_watched <= first_date_purchased;

  -- Calculate metrics to analyze student engagement and purchasing behavior
SELECT
	-- Calculate the conversion rate: percentage of students who watched content and made a purchase
	ROUND(COUNT(first_date_purchased)/COUNT(first_date_watched),2) *100 AS conversion_rate,
    
  -- Calculate the average number of days between a student's registration and their first content watch
	ROUND(SUM(date_diff_reg_watch)/COUNT(date_diff_reg_watch),2) AS av_reg_watch,
    
  -- Calculate the average number of days between a student's first content watch and their first purchase
	ROUND(SUM(date_diff_watch_purch)/COUNT(date_diff_watch_purch),2) AS av_watch_purch
FROM
(
SELECT

	-- Select columns to retrieve information on students' engagement with 365 platform
    e.student_id,
    i.date_registered,
    MIN(e.date_watched) AS first_date_watched, -- Earliest date the student watched content
    MIN(p.date_purchased) AS first_date_purchased, -- Earliest date the student made a purchase
    
  -- Calculate the difference in days between registration date and the first watch date
    DATEDIFF(MIN(e.date_watched), i.date_registered) AS date_diff_reg_watch,
    
  -- Calculate the difference in days between the first watch date and the first purchase date
    DATEDIFF(MIN(p.date_purchased), MIN(e.date_watched)) AS date_diff_watch_purch

FROM
	student_engagement e
JOIN
	student_info i ON e.student_id = i.student_id

  -- Left join the student_purchases table to get purchase data (if it exists) for each student
LEFT JOIN 
student_purchases p ON i.student_id = p.student_id
GROUP BY e.student_id

  -- Filter out records where:
	-- 1. A purchase was never made OR 
	-- 2. Content was watched on or before the first purchase
HAVING first_date_purchased IS NULL
	OR first_date_watched <= first_date_purchased
) a;  -- Alias the subquery as 'a' for use in the main query
```

**Part 3: Interpretation**

First, let's consider the conversion rate and compare this metric to industry benchmarks or historical data. The fraction of students who purchase monthly, quarterly, or annual subscriptions from those who watch a lecture is about 11%, for every 100 students who come to the 365 platform, roughly 11 out of them purchase a subscription. 

Second, let's examine the duration between the registration date and date of first-time engagement. A short duration—watching on the same or the next day—could indicate that the registration process and initial platform experience are user-friendly. At the same time, a longer duration may suggest that users are hesitant or facing challenges. The results from the second metric indicate that, on average, it takes students between three and four days to start watching a lecture after registering on the platform.

Third, regarding the time it takes students to convert to paid subscriptions after their first lecture, a shorter span would suggest compelling content or effective up-sell strategies. A longer duration might indicate that students have been waiting for the product to be offered at an exclusive price. The results we retrieved from our SQL analysis show that, on average, it takes students roughly 24 days to purchase a subscription after getting acquainted with the product.
