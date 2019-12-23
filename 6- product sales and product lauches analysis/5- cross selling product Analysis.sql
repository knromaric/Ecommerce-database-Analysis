USE MavenFuzzyFactory
GO 

/*=================================================================================================================
							CROSS SELLING ANALYSIS 
		on september 25th we started giving customers the option to add a 2nd product while on the /cart page.
		Compare the month before vs teh month after the change? 
		pull CTR from the /cart page, AVG products per order, AOV, and overall revenue per /cart page view
===================================================================================================================*/

-- 1: retrieve the relevant /cart page views and their sessions
SELECT
	CASE 
		WHEN created_at < '2013-09-25' THEN 'A. Pre_Cross_Sell'
		WHEN created_at >= '2013-01-06' THEN 'B. Post_Cross_Sell'
		ELSE 'uh oh...check logic'
	END time_period
	,website_session_id AS cart_session_id
	,website_pageview_id AS car_pageview_id 
INTO #sessions_seeing_cart
FROM website_pageviews
WHERE created_at BETWEEN '2013-08-25' AND '2013-10-25'
	AND pageview_url = '/cart';
GO

-- 2: see which of those /cart sessions clicked through to the shipping page
SELECT 
	ssc.time_period,
	ssc.cart_session_id,
	MIN(wp.website_pageview_id) AS pv_id_after_cart
INTO #cart_sessions_seeing_another_page
from #sessions_seeing_cart ssc
	LEFT JOIN website_pageviews wp
		ON wp.website_session_id= ssc.cart_session_id
			AND wp.website_pageview_id > ssc.car_pageview_id
GROUP BY 
	ssc.time_period,
	ssc.cart_session_id
HAVING 
	MIN(wp.website_pageview_id) IS NOT NULL;
GO

-- 3: Find the orders associated with the /cart sessions. Analyze products purchased, AOV
SELECT 
	time_period
	, cart_session_id
	, order_id
	, items_purchased
	,price_usd
INTO #pre_post_sessions_orders
FROM #sessions_seeing_cart
	INNER JOIN orders
		ON #sessions_seeing_cart.cart_session_id = orders.website_session_id
GO		


-- 4: Aggregate and Analyze a summary of our findings
SELECT 
	time_period
	,COUNT(DISTINCT cart_session_id) AS cart_sessions
	,SUM(clicked_to_another_page) AS clickthroughs
	,SUM(clicked_to_another_page)*1.0 / COUNT(DISTINCT cart_session_id) AS cart_ctr
	,SUM(placed_order) AS orders_placed
	,SUM(items_purchased) AS products_purchased
	,SUM(items_purchased)*1.0/SUM(placed_order) AS Product_per_order
	,SUM(price_usd) AS revenue
	,SUM(price_usd)/SUM(placed_order) AS aov
	,SUM(price_usd)/ COUNT(DISTINCT cart_session_id) AS rev_per_cart_session
FROM
	(
	SELECT 
		ssc.time_period
		,ssc.cart_session_id
		,CASE WHEN ssap.cart_session_id IS NULL THEN 0 ELSE 1 END AS clicked_to_another_page
		,CASE WHEN ppso.order_id IS NULL THEN 0 ELSE 1 END AS placed_order
		,ppso.items_purchased
		,ppso.price_usd
	FROM #sessions_seeing_cart ssc
		LEFT JOIN #cart_sessions_seeing_another_page ssap
			ON ssc.cart_session_id = ssap.cart_session_id
		LEFT JOIN #pre_post_sessions_orders ppso
			ON ppso.cart_session_id = ssc.cart_session_id) AS full_data
GROUP BY time_period
GO