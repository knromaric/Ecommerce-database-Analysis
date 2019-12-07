USE MavenFuzzyFactory
GO 


/*=============================================================================
		LANDING PAGE TREND ANALYSIS
	Paid search nonbrand traffic landing on /home and /lander-1,
	trended weekly
===============================================================================*/
-- finding the first instance of /lander-1 to set analysis timeframe
SELECT MIN(created_at) AS first_create_at
	, MIN(website_pageview_id) AS first_pageview_id
FROM website_pageviews
WHERE pageview_url = '/lander-1'
	AND created_at IS NOT NULL; -- first_created_at = '2012-06-19 08:35:54.000' and first_pageview_id = 23504
GO


SELECT wp.website_session_id
	, MIN(website_pageview_id) AS first_page_id
INTO #first_page_table2
FROM website_pageviews wp
	INNER JOIN website_sessions ws
		ON wp.website_session_id = ws.website_session_id
		AND ws.created_at < '2012-08-31'
		AND wp.website_pageview_id > 23504
		AND ws.utm_source = 'gsearch'
		AND ws.utm_campaign = 'nonbrand'
GROUP BY wp.website_session_id;
GO

SELECT wp.pageview_url
	, created_at
	,fpt.website_session_id
INTO #all_landing_page2
FROM #first_page_table2 fpt
	LEFT JOIN website_pageviews wp 
		ON wp.website_pageview_id = fpt.first_page_id
WHERE wp.pageview_url IN ('/home', '/lander-1');
GO

SELECT alp.website_session_id
	,alp.pageview_url
	,COUNT(wp.website_pageview_id) AS count_page_viewed
INTO #sessions_with_one_page_only2
FROM #all_landing_page2 alp
	LEFT JOIN website_pageviews wp
		ON wp.website_session_id=alp.website_session_id
GROUP BY alp.website_session_id
	,alp.pageview_url
HAVING COUNT(wp.website_pageview_id) = 1;
GO 

SELECT MIN(CAST(alp.created_at AS DATE)) as week_start_date
	, CAST(CAST(COUNT(DISTINCT spo.website_session_id) AS DECIMAL)/COUNT(DISTINCT alp.website_session_id) AS DECIMAL(5,4)) AS bounce_rate
	, COUNT(DISTINCT (CASE WHEN alp.pageview_url = '/home' THEN alp.website_session_id ELSE NULL END)) as home_sessions
	, COUNT(DISTINCT (CASE WHEN alp.pageview_url = '/lander-1' THEN alp.website_session_id ELSE NULL END)) as lander_sessions
FROM #all_landing_page2 alp
	LEFT JOIN #sessions_with_one_page_only2 spo 
		ON alp.website_session_id = spo.website_session_id
GROUP BY YEAR(alp.created_at), DATEPART(WEEK, alp.created_at)
ORDER BY week_start_date;
GO