USE MavenFuzzyFactory
GO	

/*=============================================
	Most viewed pages, ranked by session volume
============================================== */
 
SELECT pageview_url
	,COUNT(DISTINCT website_pageview_id) as [sessions]
FROM website_pageviews
WHERE created_at < '2012-06-09'
GROUP BY pageview_url
ORDER BY [sessions] DESC;

/*=============================================
	Top Entry Pages, ranked by entry volume
============================================== */

-- step 1: find the first pageview for each session
SELECT website_session_id
	,MIN(website_pageview_id) min_pv_id
INTO #landing_page_temp 
FROM website_pageviews
WHERE created_at < '2012-06-12'
GROUP BY website_session_id

-- step 2: find the url the customer saw on that pageview
SELECT wp.pageview_url AS landing_page_url
	,COUNT(DISTINCT lpt.website_session_id) AS sessions_hitting_this_landing_page
FROM #landing_page_temp lpt
	LEFT JOIN website_pageviews wp 
		ON wp.website_pageview_id = lpt.min_pv_id
GROUP BY wp.pageview_url
ORDER BY sessions_hitting_this_landing_page DESC


