USE MavenFuzzyFactory
GO 

/*=================================================================================================================
			ANALYZE THE IMPACT OF BID CHANGES 
	Pull Weekly sessions volume for gsearch and bsearch nonbrand, broken down by device since november 4th?
	Include comparison metric to show bsearch as a percent of gsearch of each device
===================================================================================================================*/

SELECT CAST(MIN(created_at) AS DATE) week_start_date
	,COUNT(DISTINCT CASE WHEN utm_source='gsearch' AND device_type='desktop' THEN website_session_id ELSE NULL END) g_dtop_sessions
	,COUNT(DISTINCT CASE WHEN utm_source='bsearch' AND device_type='desktop' THEN website_session_id ELSE NULL END) b_dtop_sessions
	,COUNT(DISTINCT CASE WHEN utm_source='bsearch' AND device_type='desktop' THEN website_session_id ELSE NULL END)*1.0 / COUNT(DISTINCT CASE WHEN utm_source='gsearch' AND device_type='desktop' THEN website_session_id ELSE NULL END) b_pct_of_g_dtop
	,COUNT(DISTINCT CASE WHEN utm_source='gsearch' AND device_type='mobile' THEN website_session_id ELSE NULL END) g_mob_sessions
	,COUNT(DISTINCT CASE WHEN utm_source='bsearch' AND device_type='mobile' THEN website_session_id ELSE NULL END) b_mob_sessions
	,COUNT(DISTINCT CASE WHEN utm_source='bsearch' AND device_type='mobile' THEN website_session_id ELSE NULL END)*1.0 /  COUNT(DISTINCT CASE WHEN utm_source='gsearch' AND device_type='mobile' THEN website_session_id ELSE NULL END) b_pct_g_mob
FROM website_sessions 
WHERE created_at >= '2012-11-04'
	AND created_at <'2012-12-22'
	AND utm_campaign='nonbrand'
GROUP BY YEAR(created_at), DATEPART(WEEK, created_at)
ORDER BY week_start_date