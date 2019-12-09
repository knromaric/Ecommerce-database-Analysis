USE MavenFuzzyFactory
GO 

/*
	Gsearch Device-level trends

	-- after biding our gsearch nonbrand desktop campaigns up on 2012-05-19
	-- pull weekly trends for both desktop and mobile
*/

SELECT
	 MIN(CAST(created_at AS DATE)) week_start_date
	,COUNT(DISTINCT (CASE WHEN device_type = 'desktop' THEN website_session_id ELSE NULL END)) desktop_sessions
	,COUNT(DISTINCT (CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END)) mobile_sessions
FROM website_sessions
WHERE created_at < '2012-06-09'
	AND utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand'
GROUP BY YEAR(created_at), DATEPART(WEEK, created_at)
ORDER BY week_start_date;
GO

/*
week_start_date desktop_sessions mobile_sessions
--------------- ---------------- ---------------
2012-03-19      530              345
2012-03-25      586              365
2012-04-01      686              460
2012-04-08      601              378
2012-04-15      397              248
2012-04-22      360              228
2012-04-29      428              258
2012-05-06      420              279
2012-05-13      414              221
2012-05-20      655              188
2012-05-27      581              184
2012-06-03      565              156

*/

