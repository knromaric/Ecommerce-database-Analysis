USE MavenFuzzyFactory;
GO

/*=========================================================
		ANALYZING LANDING PAGE TEST
		evaluate the bounce rate of the 2 groups
		just look at the time period where /lander-1
		was getting traffic.
==========================================================*/

-- finding the first instance of /lander-1 to set analysis timeframe
SELECT MIN(created_at) AS first_create_at
	, MIN(website_pageview_id) AS first_pageview_id
FROM website_pageviews
WHERE pageview_url = '/lander-1'
	AND created_at IS NOT NULL; -- first_created_at = '2012-06-19 08:35:54.000' and first_pageview_id = 23504

-- Compare the bounce rate of /homepage vs /lander1 page

SELECT wp.website_session_id
	, MIN(website_pageview_id) AS first_page_id
INTO #first_page_table1
FROM website_pageviews wp
	INNER JOIN website_sessions ws
		ON wp.website_session_id = ws.website_session_id
		AND ws.created_at < '2012-07-28'
		AND wp.website_pageview_id > 23504
		AND ws.utm_source = 'gsearch'
		AND ws.utm_campaign = 'nonbrand'
GROUP BY wp.website_session_id;
GO

SELECT wp.pageview_url
	,fpt.website_session_id
INTO #all_landing_page1
FROM #first_page_table1 fpt
	LEFT JOIN website_pageviews wp 
		ON wp.website_pageview_id = fpt.first_page_id
WHERE wp.pageview_url IN ('/home', '/lander-1');
GO

SELECT alp.website_session_id
	,alp.pageview_url
	,COUNT(wp.website_pageview_id) AS count_page_viewed
INTO #sessions_with_one_page_only1
FROM #all_landing_page1 alp
	LEFT JOIN website_pageviews wp
		ON wp.website_session_id=alp.website_session_id
GROUP BY alp.website_session_id
	,alp.pageview_url
HAVING COUNT(wp.website_pageview_id) = 1;
GO 

SELECT alp.pageview_url as landing_page
	, COUNT(DISTINCT alp.website_session_id) as total_sessions
	, COUNT(DISTINCT spo.website_session_id) as bounced_sessions
	, CAST(CAST(COUNT(DISTINCT spo.website_session_id) AS DECIMAL)/COUNT(DISTINCT alp.website_session_id) AS DECIMAL(5,4)) AS bounce_rate
FROM #all_landing_page1 alp
	LEFT JOIN #sessions_with_one_page_only1 spo 
		ON alp.website_session_id = spo.website_session_id
GROUP BY alp.pageview_url
GO

/*
landing_page                                  total_sessions  bounced_sessions    bounce_rate
-------------------------------------------------- -------------- ---------------- ---------------------------------------
/home                                              2241           1308                0.5837
/lander-1                                          2295           1219                0.5312

*/

