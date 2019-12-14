USE MavenFuzzyFactory
GO 

/*=================================================================================================================
			ANALYZE EXPANDED CHANNEL PORTFOLIO MANAGEMENT
	Pull weekly trended sesssion volume since the company launched a second paid search channel "bsearch"
	around August 22.
===================================================================================================================*/

SELECT CAST(MIN(created_at) AS DATE) AS week_start_date
	,COUNT(DISTINCT website_session_id) AS total_sessions
	,COUNT( DISTINCT CASE WHEN utm_source='gsearch' THEN website_session_id ELSE NULL END) AS  gsearch_sessions
	,COUNT( DISTINCT CASE WHEN utm_source='bsearch' THEN website_session_id ELSE NULL END) AS  bsearch_sessions
FROM website_sessions ws
WHERE created_at > '2012-08-22' 
	AND created_at < '2012-11-29'
	AND utm_campaign = 'nonbrand'
GROUP BY YEAR(created_at), DATEPART(WEEK,created_at) 
ORDER BY week_start_date
GO