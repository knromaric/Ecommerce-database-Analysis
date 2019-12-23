USE MavenFuzzyFactory
GO 

/*=================================================================================================================
							CROSS SELLING ANALYSIS 
		on september 25th we started giving customers the option to add a 2nd product while on the /cart page.
		Compare the month before vs teh month after the change? 
		pull CTR from the /cart page, AVG products per order, AOV, and overall revenue per /cart page view
===================================================================================================================*/

-- 1- retrieve all session that reach the cart page 
SELECT website_session_id
	, website_pageview_id
	, pageview_url cart_page_seen
INTO #session_seing_cart_pages
FROM website_pageviews
WHERE created_at < '20131025'
	AND created_at > '20130825'
	AND pageview_url = '/cart'
GO
-- 2- add flag with shipping page to evaluate the clickthrough
SELECT
	CASE 
		WHEN created_at <'20130925' THEN 'A. Precross_sell'
		WHEN created_at >='20130925' THEN 'B. PostCross_sell'
		ELSE 'uh oh... check logic'
	END time_period
	,website_session_id
	,MAX(shipping_page) shipping_made_it
	,MAX(billing_page) billing_made_it
	,MAX(thankyou_page) thankyou_made_it
into #session_product_level_made_it_flag
FROM 
	(SELECT wp.created_at
		, wp.website_session_id
		, CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END shipping_page
		, CASE WHEN pageview_url = '/billing-2' THEN 1 ELSE 0 END billing_page
		, CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
	FROM #session_seing_cart_pages scpg
		LEFT JOIN website_pageviews wp
			ON wp.website_session_id = scpg.website_session_id
				AND wp.website_pageview_id > scpg.website_pageview_id) session_w_flag
GROUP BY CASE 
		WHEN created_at <'20130925' THEN 'A. Precross_sell'
		WHEN created_at >='20130925' THEN 'B. PostCross_sell'
		ELSE 'uh oh... check logic'
	END 
	,website_session_id;


-- 3- join with order and order item to bring pro

SELECT time_period
	,COUNT(Distinct splf.website_session_id) cart_sessions
	,AVG(o.price_usd) aov
	,SUM(o.price_usd - o.cogs_usd) / COUNT(Distinct splf.website_session_id) rev_per_cart_sessions
FROM #session_product_level_made_it_flag splf
	LEFT JOIN orders o
		ON o.website_session_id = splf.website_session_id
GROUP BY time_period;