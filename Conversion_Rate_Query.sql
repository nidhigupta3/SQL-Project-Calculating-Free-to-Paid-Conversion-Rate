USE db_course_conversions;

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

SELECT
	ROUND(COUNT(first_date_purchased)/COUNT(first_date_watched),2) *100 AS conversion_rate,
	ROUND(SUM(date_diff_reg_watch)/COUNT(date_diff_reg_watch),2) AS av_reg_watch,
	ROUND(SUM(date_diff_watch_purch)/COUNT(date_diff_watch_purch),2) AS av_watch_purch
FROM
(
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
	OR first_date_watched <= first_date_purchased
) a;

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