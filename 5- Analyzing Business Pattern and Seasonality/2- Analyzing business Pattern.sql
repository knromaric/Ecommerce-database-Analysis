USE MavenFuzzyFactory
GO 

/*=================================================================================================================
				 ANALYZE THE BUSINESS PATTERN (the management want to add live chat support)
	Analyze the average website session volume, by hour of day and by day of week
===================================================================================================================*/

SELECT hr
	, CAST(AVG(CASE WHEN wkday = 1 THEN count_sessions*1.0 ELSE NULL END) AS decimal(3,1))  mon
	, CAST(AVG(CASE WHEN wkday = 2 THEN count_sessions*1.0 ELSE NULL END) AS decimal(3,1)) tue
	, CAST(AVG(CASE WHEN wkday = 3 THEN count_sessions*1.0 ELSE NULL END) AS decimal(3,1)) wed
	, CAST(AVG(CASE WHEN wkday = 4 THEN count_sessions*1.0 ELSE NULL END) AS decimal(3,1)) thu
	, CAST(AVG(CASE WHEN wkday = 5 THEN count_sessions*1.0 ELSE NULL END) AS decimal(3,1)) fri
	, CAST(AVG(CASE WHEN wkday = 6 THEN count_sessions*1.0 ELSE NULL END) AS decimal(3,1)) sat
	, CAST(AVG(CASE WHEN wkday = 7 THEN count_sessions*1.0 ELSE NULL END) AS decimal(3,1)) sun
FROM (
	SELECT 
		CAST(created_at AS DATE) created_date
		,DATEPART(WEEKDAY,created_at) wkday
		,DATEPART(HOUR, created_at) hr
		,COUNT(DISTINCT website_session_id) AS count_sessions
	FROM website_sessions 
	WHERE created_at BETWEEN '20120915' AND '20121115'
	GROUP BY  CAST(created_at AS DATE)
			, DATEPART(WEEKDAY,created_at)
			, DATEPART(HOUR, created_at)) session_by_weekday_hour
GROUP BY hr;
GO

