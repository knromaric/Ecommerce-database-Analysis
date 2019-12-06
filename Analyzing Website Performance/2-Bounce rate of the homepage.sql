USE MavenFuzzyFactory
GO

/*========================================================
	 Bounce rates for traffic landing on the homepage
=========================================================*/

-- first page view id per session
SELECT wp.website_session_id
	,MIN(wp.website_pageview_id) min_pv_id 
INTO #first_pageview
FROM website_pageviews wp
	INNER JOIN website_sessions ws 
		ON wp.website_session_id = ws.website_session_id
		AND ws.created_at < '2012-06-14'
GROUP BY wp.website_session_id

-- finding the landing page url
SELECT  wp.pageview_url as landing_page
	, fp.website_session_id
INTO #session_landing_page
FROM #first_pageview fp
	LEFT JOIN website_pageviews wp 
		ON fp.min_pv_id = wp.website_pageview_id
WHERE wp.pageview_url = '/home';

-- count bounced pageviews only (COUNT page views per sessions)

SELECT slp.landing_page
	,slp.website_session_id
	,COUNT(wp.website_pageview_id) count_page_viewed 
INTO #bounced_session_only
FROM #session_landing_page slp
	LEFT JOIN website_pageviews wp 
		ON slp.website_session_id = wp.website_session_id
GROUP BY slp.landing_page, slp.website_session_id
HAVING COUNT(wp.website_pageview_id) = 1;

-- summarize to get the bounce rate

SELECT COUNT(DISTINCT slp.website_session_id) [sessions]
	, COUNT(DISTINCT bso.website_session_id) bounced_sessions
	,CAST(CAST(COUNT(DISTINCT bso.website_session_id) AS DECIMAL)/COUNT(DISTINCT slp.website_session_id) AS DECIMAL(5,4)) AS bounce_rate
FROM #session_landing_page slp
	LEFT JOIN #bounced_session_only bso 
		ON slp.website_session_id = bso.website_session_id
GROUP BY slp.landing_page

