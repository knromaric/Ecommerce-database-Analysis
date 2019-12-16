USE MavenFuzzyFactory
GO 

/*=================================================================================================================
							PRODUCT PATHING  ANALYSIS
			Let's look at sessions which hit the /products page and see where they went next
			pull clickthrough rates from /products since january 6, 2013 by product and compare
			to the 3 months leading up to launch as a baseline.
===================================================================================================================*/

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
			AND ws.created_at >= '20121006'  ) pageview_level --3 months prior to the launch(october 6, 2012)
	GROUP BY created_at, website_session_id
)
SELECT CASE 
		 WHEN  created_at <'20130106' THEN 'A.Pre_Product_2'
		 ELSE 'B.Post_Product_2'
		 END AS time_period
	, COUNT(DISTINCT website_session_id) [sessions]
	, COUNT(CASE WHEN product_made_it = 1 AND (mrfuzzy_made_it = 1 OR love_bear_made_it=1) THEN website_session_id ELSE NULL END) w_next_pg
	, COUNT(CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END) to_mrfuzzy
	, COUNT(CASE WHEN love_bear_made_it = 1 THEN website_session_id ELSE NULL END) to_love_bear

FROM session_level_made_id_flag
GROUP BY CASE 
		 WHEN  created_at <'20130106' THEN 'A.Pre_Product_2'
		 ELSE 'B.Post_Product_2'
		 END
