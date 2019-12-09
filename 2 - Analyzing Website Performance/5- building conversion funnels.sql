USE MavenFuzzyFactory
GO

/*======================================================================================
	BUILD a conversion funnel from /lander-1 page all the way to our /thank_you_page
				(Analyzing how many customers make it to each step ?)
							Use data since August 5th
=======================================================================================*/


SELECT website_session_id
	, MAX(product_page) as products_made_it
	, MAX(mrfuzzy_page) as mrfuzzy_made_it
	, MAX(cart_page) as cart_made_it
	, MAX(shipping_page) shipping_made_it
	, MAX(billing_page) as billing_made_it
	, MAX(thank_you_page) as thank_you_made_it
INTO #session_level_made_it_flag3
FROM
	(
	SELECT ws.website_session_id
		, wp.pageview_url
		, wp.created_at AS pageviews_created_at
		, (CASE WHEN wp.pageview_url = '/products' THEN 1 ELSE 0 END) AS product_page
		, (CASE WHEN wp.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END) AS mrfuzzy_page
		, (CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END) AS cart_page
		, (CASE WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0 END) AS shipping_page
		, (CASE WHEN wp.pageview_url = '/billing' THEN 1 ELSE 0 END) AS billing_page
		, (CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END) AS thank_you_page
	FROM website_sessions ws
		LEFT JOIN website_pageviews wp
			ON ws.website_session_id = wp.website_session_id
	WHERE wp.created_at > '2012-08-05' AND wp.created_at <'2012-09-05'
		AND utm_source = 'gsearch'
		AND utm_campaign = 'nonbrand') pageview_level
GROUP BY website_session_id
GO

SELECT COUNT(DISTINCT website_session_id) AS sessions
	, COUNT(DISTINCT CASE WHEN products_made_it = 1 THEN website_session_id ELSE NULL END) AS to_products
	, COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END ) AS to_mrfuzzy
	, COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart
	, COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS to_shipping
	, COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END ) AS to_thank_you
FROM #session_level_made_it_flag3

SELECT
	 COUNT(DISTINCT CASE WHEN products_made_it = 1 THEN website_session_id ELSE NULL END)*1.0  / COUNT(DISTINCT website_session_id) AS lander_click_rate
	, COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END )*1.0 / COUNT(DISTINCT CASE WHEN products_made_it = 1 THEN website_session_id ELSE NULL END) AS products_click_rate
	, COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END)*1.0 / COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END ) AS mrfuzzy_click_rate
	, COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END)*1.0 / COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS cart_click_rate
	, COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END )*1.0 / COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS shipping_click_rate
	, COUNT(DISTINCT CASE WHEN thank_you_made_it = 1 THEN website_session_id ELSE NULL END )*1.0 / COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END ) AS billing_click_rate
FROM #session_level_made_it_flag3
 