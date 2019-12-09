USE MavenFuzzyFactory
GO 

/*
	(tracking source trending after some bid changestra)
	Pull gsearch nonbrand trended session volume by week 
*/	

SELECT
	 MIN(CAST(created_at AS DATE)) WeekStartDate 
	,COUNT(DISTINCT website_session_id) numberOfSessions
FROM website_sessions
WHERE created_at < '2012-05-10'
	AND utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand'
GROUP BY YEAR(created_at), DATEPART(WEEK, created_at);
