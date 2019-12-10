USE MavenFuzzyFactory;
GO 

/*====================================================================================================
			Quantify Company growth (revenue impact) by extracting and analyzing website traffic and 
			performance data from the Maven Fuzzy Factory database, and tell the story
			on how you have been able to generate that growth

			Analyze current performance and use the data available to assess upcoming opportunities

======================================================================================================*/

--###########################################################################################################
--## 1- Montly trends for gsearch sessions and orders so that we can show case the growth there
--###########################################################################################################

SELECT YEAR(ws.created_at) [year]
	, MONTH(ws.created_at) [month]
	, COUNT(DISTINCT ws.website_session_id) [sessions]
	, COUNT(DISTINCT o.order_id) [orders]
	, COUNT(DISTINCT o.order_id)*1.0 / COUNT(DISTINCT ws.website_session_id) [sessions_to_orders_rate]
FROM website_sessions ws
	LEFT JOIN orders o 
		ON o.website_session_id = ws.website_session_id
WHERE  ws.created_at < '2012-11-27'
	AND utm_source = 'gsearch'
GROUP BY YEAR(ws.created_at), MONTH(ws.created_at)
ORDER BY [year], [month];
GO

--###########################################################################################################
--## 2- Montly trends for gsearch sessions/orders split out for nonbrand and brand campaign separately
--###########################################################################################################

SELECT YEAR(ws.created_at) [year]
	, MONTH(ws.created_at) [month]
	, COUNT(DISTINCT CASE WHEN ws.utm_campaign='nonbrand' THEN ws.website_session_id ELSE NULL END) [nonbrand_sessions]
	, COUNT(DISTINCT CASE WHEN ws.utm_campaign='nonbrand' THEN o.order_id ELSE NULL END) [nonbrand_orders]
	, COUNT(DISTINCT CASE WHEN ws.utm_campaign='brand' THEN ws.website_session_id ELSE NULL END) [brand_sessions]
	, COUNT(DISTINCT CASE WHEN ws.utm_campaign='brand' THEN o.order_id ELSE NULL END) [brand_orders]
FROM website_sessions ws
	LEFT JOIN orders o 
		ON o.website_session_id = ws.website_session_id
WHERE  ws.created_at < '2012-11-27'
	AND utm_source = 'gsearch'
GROUP BY YEAR(ws.created_at), MONTH(ws.created_at)
ORDER BY [year], [month];
GO

--###########################################################################################################
--## 3- Let's Dive into nonbrand and pull monthly trend sessions and orders split by device type
--###########################################################################################################

SELECT YEAR(ws.created_at) [year]
	, MONTH(ws.created_at) [month]
	,  COUNT(DISTINCT CASE WHEN ws.device_type = 'desktop' THEN ws.website_session_id ELSE NULL END) [desktop_sessions]
	,  COUNT(DISTINCT CASE WHEN ws.device_type = 'desktop' THEN o.order_id ELSE NULL END) [desktop_orders]
	,  COUNT(DISTINCT CASE WHEN ws.device_type = 'mobile' THEN ws.website_session_id ELSE NULL END) [mobile_sessions]
	,  COUNT(DISTINCT CASE WHEN ws.device_type = 'mobile' THEN o.order_id ELSE NULL END) [mobile_orders]
FROM website_sessions ws 
	LEFT JOIN orders o 
		ON o.website_session_id = ws.website_session_id
WHERE ws.created_at < '2012-11-27'
	AND utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand'
GROUP BY YEAR(ws.created_at), MONTH(ws.created_at)
ORDER BY [year], [month];
GO

--###########################################################################################################
--## 4- Montly trends for Gsearch alongside monthly trends for each of our other channels
--###########################################################################################################	

--find the different utm sources and referers to see the traffic we're getting 

SELECT DISTINCT	
	utm_source
	,utm_campaign
	,http_referer
FROM website_sessions
WHERE created_at <  '2012-11-27';
GO

SELECT
	YEAR(created_at) [year]
	, MONTH(created_at) [month] 
	, COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN website_session_id ELSE NULL END) gsearch_sessions
	, COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN website_session_id ELSE NULL END) bsearch_sessions
	, COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_session_id ELSE NULL END) organic_search_sessions
	, COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS  NULL THEN website_session_id ELSE NULL END) direct_type_in_sessions
FROM website_sessions
WHERE created_at < '2012-11-27'
GROUP BY YEAR(created_at), MONTH(created_at)
ORDER BY [year], [month];
GO

--###########################################################################################################
--## 5- Story of our website performance improvements over the course of the first 8 month(session to order conversion rates by months)
--###########################################################################################################

SELECT YEAR(ws.created_at) [year]
	, MONTH(ws.created_at) [month]
	, COUNT(DISTINCT ws.website_session_id) [sessions]
	, COUNT(DISTINCT o.order_id) [orders]
	, COUNT(DISTINCT o.order_id)*1.0 / COUNT(DISTINCT ws.website_session_id) [sessions_to_orders_rate]
FROM website_sessions ws
	LEFT JOIN orders o 
		ON o.website_session_id = ws.website_session_id
WHERE  ws.created_at < '2012-11-27'
	AND utm_source = 'gsearch'
GROUP BY YEAR(ws.created_at), MONTH(ws.created_at)
ORDER BY [year], [month];
GO
--###########################################################################################################
--## 6- For Gsearch lander test, estimate the revenue that the test earned us
--###########################################################################################################

-- find the pageviews_id of all the landing page per sessions
SELECT ws.website_session_id
	,MIN(wp.website_pageview_id) landing_page_id
INTO #landing_page_table
FROM website_sessions ws
	LEFT JOIN website_pageviews wp 
		ON ws.website_session_id = wp.website_session_id
WHERE wp.created_at >= '2012-06-19' AND wp.created_at <= '2012-07-28'
	AND ws.utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand'
GROUP BY ws.website_session_id

-- find the url of all the landing pages
SELECT lpt.website_session_id 
	,wp.pageview_url
INTO #session_id_w_landing_page_url
FROM #landing_page_table lpt
	LEFT JOIN website_pageviews wp
		ON wp.website_pageview_id = lpt.landing_page_id
WHERE wp.pageview_url IN ('/lander-1', '/home');

-- compare the sessions to orders conversion rate for lander and home pages
SELECT slpu.pageview_url landing_page
	, COUNT(DISTINCT slpu.website_session_id) [sessions]
	, COUNT(DISTINCT o.order_id) [orders]
	, COUNT(DISTINCT o.order_id)*1.0 / COUNT(DISTINCT slpu.website_session_id) sessions_orders_rate
FROM #session_id_w_landing_page_url slpu
	LEFT JOIN orders o 
		ON o.website_session_id = slpu.website_session_id
GROUP BY slpu.pageview_url;
GO  -- .032 for /home, vs .0409 for /lander-1 -->> 0.0089 additional orders per session

-- find the most recent page viewed by gsearch nonbrand where the traffic was sent to /home

SELECT MAX(ws.website_session_id) most_recent_gsearch_nonbrand_home_pageview
FROM website_sessions ws
	LEFT JOIN website_pageviews wp 
		ON ws.website_session_id = wp.website_session_id
WHERE  ws.created_at < '2012-11-27'
	AND ws.utm_source = 'gsearch'
	AND ws.utm_campaign = 'nonbrand'
	AND wp.pageview_url = '/home' 
GO   
-- result -->>  sessions = 17145

-- Count of sessions since the last test

SELECT COUNT(DISTINCT website_session_id) AS count_sessions_since_test
FROM website_sessions
WHERE created_at < '2012-11-27'
	AND website_session_id > 17145 -- last /home session
	AND utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand';
GO
-- 22450 website sessions since the last test

-- 22450 * 0.0089 incremental conversion = 200 incremental orders since 7/29
	-- roughly 4 months, so roughly 50 extra orders per month. NOT BAD!!!


--###############################################################################################################
--## 7- For the landing page test we analyzed previously, it would be great to show a full conversion funnel
--##    from each of the 2 pages to orders, we will use the same time period (june 19 - july 28).
--###############################################################################################################

SELECT website_session_id
	, MAX(home_page) as home_made_it
	, MAX(lander_page) as lander_made_it
	, MAX(product_page) as products_made_it
	, MAX(mrfuzzy_page) as mrfuzzy_made_it
	, MAX(cart_page) as cart_made_it
	, MAX(shipping_page) shipping_made_it
	, MAX(billing_page) as billing_made_it
	, MAX(thank_you_page) as thank_you_made_it
INTO #session_level_made_if_flagged
FROM (
	SELECT ws.website_session_id
		, wp.pageview_url
		, wp.created_at AS pageviews_created_at
		, (CASE WHEN wp.pageview_url = '/home' THEN 1 ELSE 0 END) AS home_page
		, (CASE WHEN wp.pageview_url = '/lander-1' THEN 1 ELSE 0 END) AS lander_page
		, (CASE WHEN wp.pageview_url = '/products' THEN 1 ELSE 0 END) AS product_page
		, (CASE WHEN wp.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END) AS mrfuzzy_page
		, (CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END) AS cart_page
		, (CASE WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0 END) AS shipping_page
		, (CASE WHEN wp.pageview_url = '/billing' THEN 1 ELSE 0 END) AS billing_page
		, (CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END) AS thank_you_page
	FROM website_sessions ws
		LEFT JOIN website_pageviews wp
			ON ws.website_session_id = wp.website_session_id
	WHERE wp.created_at >= '2012-06-19' AND wp.created_at <='2012-07-28'
		AND utm_source = 'gsearch'
		AND utm_campaign = 'nonbrand') pageview_level
GROUP BY website_session_id
GO

SELECT 
	CASE 
		WHEN home_made_it = 1 THEN 'saw_homepage'
		WHEN lander_made_it = 1 THEN 'saw_custom_lander'
		ELSE 'check the logic '
	END AS segment
	, COUNT(DISTINCT website_session_id) AS sessions
	, COUNT(DISTINCT CASE WHEN products_made_it = 1 THEN website_session_id ELSE NULL END) AS to_products
	, COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END ) AS to_mrfuzzy
	, COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) AS to_cart
	, COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS to_shipping
	, COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS to_billing
	, COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END ) AS to_thank_you
FROM #session_level_made_if_flagged
GROUP BY CASE 
		WHEN home_made_it = 1 THEN 'saw_homepage'
		WHEN lander_made_it = 1 THEN 'saw_custom_lander'
		ELSE 'check the logic '
	 END
GO

SELECT 
	CASE 
		WHEN home_made_it = 1 THEN 'saw_homepage'
		WHEN lander_made_it = 1 THEN 'saw_custom_lander'
		ELSE 'check the logic '
	END AS segment
	, COUNT(DISTINCT website_session_id) AS sessions
	, COUNT(DISTINCT CASE WHEN products_made_it = 1 THEN website_session_id ELSE NULL END)*1.0/COUNT(DISTINCT website_session_id) AS home_click_rt
	, COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END )*1.0/COUNT(DISTINCT CASE WHEN products_made_it = 1 THEN website_session_id ELSE NULL END) AS product_click_rt
	, COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END)*1.0/COUNT(DISTINCT CASE WHEN mrfuzzy_made_it = 1 THEN website_session_id ELSE NULL END ) AS mrfuzzy_click_rt
	, COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END)*1.0 / COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END)AS card_click_rt
	, COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END)*1.0 / COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) AS shipping_click_rt
	, COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END )*1.0 / COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) AS billing_click_rt
FROM #session_level_made_if_flagged
GROUP BY CASE 
		WHEN home_made_it = 1 THEN 'saw_homepage'
		WHEN lander_made_it = 1 THEN 'saw_custom_lander'
		ELSE 'check the logic '
	 END
GO


--###############################################################################################################
--## 8- quantify the impact of our billing test, as well. analyze the lift generated from the test(sept 10 - nov 10)
--##    in terms of revenue per billing page session, and then pulll the number of billing sessions forthe past month
--##    to understand monthly impact 
--###############################################################################################################

SELECT billing_version_viewed
	,COUNT(DISTINCT website_session_id) [sessions]
	,SUM(price_usd) / COUNT(DISTINCT website_session_id) AS revenue_per_billing_page_seen
FROM (
SELECT wp.website_session_id
	,wp.pageview_url AS billing_version_viewed
	,o.order_id
	,o.price_usd
FROM website_pageviews wp
	LEFT JOIN orders o
		ON o.website_session_id = wp.website_session_id
WHERE wp.created_at > '2012-09-10'
	AND wp.created_at < '2012-11-10'
	AND wp.pageview_url IN ('/billing', '/billing-2')) billing_pageviews_and_order_data
GROUP BY billing_version_viewed

-- $22.94 revenue per billing page seen for the old version
-- $31.38 for the new version
-- LIFT : $8.44 per billing page view

-- how many session hits the billing in the past month
SELECT COUNT(DISTINCT wp.website_session_id) billing_sessions_past_month
FROM website_pageviews wp
WHERE wp.created_at BETWEEN '2012-10-27' AND  '2012-11-27'
	AND wp.pageview_url IN ('/billing', '/billing-2')

-- 1137 billing sessions past month
-- lift: $8.44 per billing session
-- value of billing test: $9,596 over the past month