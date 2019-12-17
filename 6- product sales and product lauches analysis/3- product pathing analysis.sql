USE MavenFuzzyFactory
GO 

/*=================================================================================================================
							PRODUCT PATHING  ANALYSIS
			Let's look at sessions which hit the /products page and see where they went next
			pull clickthrough rates from /products since january 6, 2013 by product and compare
			to the 3 months leading up to launch as a baseline.
===================================================================================================================*/

--## version 1
WITH session_level_made_id_flag AS
(
	SELECT created_at
			,website_session_id
			,MAX(products_page) AS product_made_it
			,MAX(mrfuzzy_page) AS mrfuzzy_made_it
			,MAX(love_bear_page) AS love_bear_made_it
	FROM
		(SELECT ws.created_at
			, ws.website_session_id 
			,CASE WHEN wp.pageview_url = '/products' THEN 1 ELSE 0 END AS products_page
			,CASE WHEN wp.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page
			,CASE WHEN wp.pageview_url = '/the-forever-love-bear' THEN 1 ELSE 0 END AS love_bear_page
		FROM website_sessions ws
			LEFT JOIN website_pageviews wp ON ws.website_session_id = wp.website_session_id
		WHERE ws.created_at < '20130406' 
			AND ws.created_at >= '20121006') pageview_level --3 months prior to the launch(october 6, 2012)
	GROUP BY created_at, website_session_id
)
SELECT CASE 
		 WHEN  created_at <'20130106' THEN 'A.Pre_Product_2'
		 ELSE 'B.Post_Product_2'
		 END AS time_period
	, COUNT(DISTINCT CASE WHEN product_made_it = 1 THEN website_session_id ELSE NULL END) [sessions]
	, COUNT(CASE WHEN product_made_it = 1 AND (mrfuzzy_made_it = 1 OR love_bear_made_it=1) THEN website_session_id ELSE NULL END) w_next_pg
	, COUNT(CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) to_mrfuzzy
	, COUNT(CASE WHEN love_bear_made_it = 1 THEN website_session_id ELSE NULL END) to_love_bear

FROM session_level_made_id_flag
GROUP BY CASE 
		 WHEN  created_at <'20130106' THEN 'A.Pre_Product_2'
		 ELSE 'B.Post_Product_2'
		 END
ORDER BY time_period
GO

--## version 2

-- step 1: find the relevant /products pageviews with website_sessions_id
SELECT 
	website_session_id
	,website_pageview_id
	,created_at
	, CASE
		WHEN created_at < '20130106' THEN 'A. Pre_Product_2'
		WHEN created_at >= '20130106' THEN 'B. Post_Product_2'
		ELSE 'uh oh .. check logic'
	END AS time_period
INTO #product_pageviews
FROM website_pageviews
WHERE created_at < '20130406' 
	AND created_at > '20121006'
	AND pageview_url = '/products';
GO

-- step 2: find the next pageviews id that occurs AFTER the product pageview
SELECT 
	pp.time_period
	,pp.website_session_id
	,MIN(wp.website_pageview_id) next_pageview_id
INTO #session_w_next_pageview_id
FROM #product_pageviews pp
	LEFT JOIN website_pageviews wp
		ON pp.website_session_id = wp.website_session_id
	    AND WP.website_pageview_id > PP.website_pageview_id
GROUP BY pp.time_period
		,pp.website_session_id
GO

-- step 3: find the pageview_url associated with any applicable next pageview id
SELECT snpi.time_period
	,snpi.website_session_id
	,wp.pageview_url AS next_pageview_url
INTO #session_w_next_pageview_url
FROM #session_w_next_pageview_id snpi
	LEFT JOIN website_pageviews wp 
		ON snpi.next_pageview_id = wp.website_pageview_id
GO

-- step 4: summarize the data and analyze the pre vs post periods
SELECT 
	time_period
	,COUNT(DISTINCT website_session_id) AS [sessions]
	,COUNT(DISTINCT CASE WHEN next_pageview_url IS NOT NULL THEN website_session_id ELSE NULL END) w_next_pg
	,COUNT(DISTINCT CASE WHEN next_pageview_url IS NOT NULL THEN website_session_id ELSE NULL END)*1.0/COUNT(DISTINCT website_session_id) pct_w_next_pg
	,COUNT(DISTINCT CASE WHEN  next_pageview_url='/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END) to_mrfuzzy
	,COUNT(DISTINCT CASE WHEN  next_pageview_url='/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END)*1.0/COUNT(DISTINCT website_session_id) pct_to_fuzzy
	,COUNT(DISTINCT CASE WHEN  next_pageview_url='/the-forever-love-bear' THEN website_session_id ELSE NULL END) to_lovebear
	,COUNT(DISTINCT CASE WHEN  next_pageview_url='/the-forever-love-bear' THEN website_session_id ELSE NULL END)*1.0/COUNT(DISTINCT website_session_id) pct_to_lovebear
FROM #session_w_next_pageview_url
GROUP BY time_period
ORDER BY time_period;
GO

