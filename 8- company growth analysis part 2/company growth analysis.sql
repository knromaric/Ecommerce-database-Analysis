USE MavenFuzzyFactory
GO

/* ===========================================================================================================
		1-	Show the volume growth. pull overal session and order volume,
			trended by quarter of the life of the business
=============================================================================================================*/

SELECT YEAR(ws.created_at) yr 
	,DATEPART(QUARTER, ws.created_at) qtr
	,COUNT(ws.website_session_id) [sessions]
	,COUNT(o.order_id) [orders] 
FROM website_sessions ws
	LEFT JOIN orders o ON ws.website_session_id = o.website_session_id
GROUP BY YEAR(ws.created_at) 
	,DATEPART(QUARTER, ws.created_at)
ORDER BY yr, qtr;
GO

/* ===========================================================================================================
		2-	Show quarterly figures since we launched, for session to order conversion rate,
			revenue per order, revenue per session
=============================================================================================================*/

SELECT YEAR(ws.created_at) yr 
	,DATEPART(QUARTER, ws.created_at) qtr
	,COUNT(ws.website_session_id) [sessions]
	,COUNT(o.order_id)*1.0 / COUNT(ws.website_session_id) sess_to_ord_cvr
	,SUM(o.price_usd) / COUNT(o.order_id) rev_per_orders
	,SUM(o.price_usd) / COUNT(ws.website_session_id) rev_per_sessions
FROM website_sessions ws
	LEFT JOIN orders o ON ws.website_session_id = o.website_session_id
GROUP BY YEAR(ws.created_at) 
	,DATEPART(QUARTER, ws.created_at)
ORDER BY yr, qtr;
GO



/* ===========================================================================================================
		3-	Show quarterly view of orders from Gsearch nonbrand, Bsearch nonbrand, brand search overall, 
			organic search, direct type-in
=============================================================================================================*/

SELECT YEAR(ws.created_at) yr 
	,DATEPART(QUARTER, ws.created_at) qtr 
	,COUNT( CASE WHEN ws.utm_source='gsearch' AND ws.utm_campaign ='nonbrand'  THEN o.order_id ELSE NULL END ) gsearch_nonbrand_orders
	,COUNT( CASE WHEN ws.utm_source='bsearch' AND ws.utm_campaign ='nonbrand'  THEN o.order_id ELSE NULL END ) bsearch_nonbrand_orders
	,COUNT( CASE WHEN ws.utm_campaign ='brand'  THEN o.order_id ELSE NULL END ) brand_search_overall_orders
	,COUNT( CASE WHEN ws.utm_source IS NULL AND http_referer IS NOT NULL  THEN o.order_id ELSE NULL END ) organic_search_orders
	,COUNT( CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN o.order_id ELSE NULL END ) direct_type_in_orders
FROM website_sessions ws
	LEFT JOIN orders o ON ws.website_session_id = o.website_session_id
GROUP BY YEAR(ws.created_at) 
	,DATEPART(QUARTER, ws.created_at)
ORDER BY yr, qtr;
GO

/* ===========================================================================================================
		4-	Show quarterly overall session-to-order conversion rate trends for those same channels
			(from Gsearch nonbrand, Bsearch nonbrand, brand search overall,organic search, direct type-in)
=============================================================================================================*/

SELECT YEAR(ws.created_at) yr 
	,DATEPART(QUARTER, ws.created_at) qtr 
	,COUNT( CASE WHEN ws.utm_source='gsearch' AND ws.utm_campaign ='nonbrand'  THEN o.order_id ELSE NULL END )*1.0
		/NULLIF(COUNT( CASE WHEN ws.utm_source='gsearch' AND ws.utm_campaign ='nonbrand'  THEN ws.website_session_id ELSE NULL END ),0) gsearch_nonbrand_cv_rt
	,COUNT( CASE WHEN ws.utm_source='bsearch' AND ws.utm_campaign ='nonbrand'  THEN o.order_id ELSE NULL END )*1.0
		/NULLIF(COUNT( CASE WHEN ws.utm_source='bsearch' AND ws.utm_campaign ='nonbrand'  THEN ws.website_session_id ELSE NULL END ),0) bsearch_nonbrand_cv_rt
	,COUNT( CASE WHEN ws.utm_campaign ='brand'  THEN o.order_id ELSE NULL END )*1.0
		/NULLIF(COUNT( CASE WHEN ws.utm_campaign ='brand'  THEN ws.website_session_id ELSE NULL END ),0) brand_search_overall_cv_rt
	,COUNT( CASE WHEN ws.utm_source IS NULL AND http_referer IS NOT NULL  THEN o.order_id ELSE NULL END )*1.0
		/NULLIF(COUNT( CASE WHEN ws.utm_source IS NULL AND http_referer IS NOT NULL  THEN ws.website_session_id ELSE NULL END ),0) organic_search_cv_rt
	,COUNT( CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN o.order_id ELSE NULL END )*1.0
		/NULLIF(COUNT( CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN ws.website_session_id ELSE NULL END ),0) direct_type_in_orders_cv_rt
FROM website_sessions ws
	LEFT JOIN orders o ON ws.website_session_id = o.website_session_id
GROUP BY YEAR(ws.created_at) 
	,DATEPART(QUARTER, ws.created_at)
ORDER BY yr, qtr;
GO

/* ===========================================================================================================
		5-	pull monthly trending for revenue and margin by product, along with total sales and revenue
			(pay attention to seasonality)
=============================================================================================================*/


SELECT YEAR(created_at) yr 
	,MONTH(created_at) mo 
	,SUM(CASE WHEN product_id=1 THEN price_usd ELSE NULL END) AS mrfuzzy_rev
	,SUM(CASE WHEN product_id=1 THEN price_usd - cogs_usd ELSE NULL END) AS mrfuzzy_marg
	,SUM(CASE WHEN product_id=2 THEN price_usd ELSE NULL END) AS lovebear_rev
	,SUM(CASE WHEN product_id=2 THEN price_usd - cogs_usd ELSE NULL END) AS lovebear_marg
	,SUM(CASE WHEN product_id=3 THEN price_usd ELSE NULL END) AS birthdaybear_rev
	,SUM(CASE WHEN product_id=3 THEN price_usd - cogs_usd ELSE NULL END) AS birthdaybear_marg
	,SUM(CASE WHEN product_id=4 THEN price_usd ELSE NULL END) AS minibear_rev
	,SUM(CASE WHEN product_id=4 THEN price_usd - cogs_usd ELSE NULL END) AS minibear_marg
	,SUM(price_usd) total_revenue
	,SUM(price_usd - cogs_usd) total_margin
FROM order_items
GROUP BY YEAR(created_at) 
	,MONTH(created_at)
ORDER BY yr, mo;
GO 

/* ===========================================================================================================
		6-	Analyze the impact of introducing new products. Pull monthly sessions to the /products page
		and show how the % of those sessions clicking through another page has changed over time, along with
		a view of how conversion from /products to placing has improved
=============================================================================================================*/

-- all the view of the /products page

SELECT website_session_id,
	website_pageview_id,
	created_at AS saw_product_page_at
INTO #products_pageviews
FROM website_pageviews
WHERE pageview_url = '/products';
GO

SELECT YEAR(saw_product_page_at) yr 
	,MONTH(saw_product_page_at) mo 
	,COUNT(DISTINCT pp.website_session_id) sessions_to_product_page
	,COUNT(DISTINCT wp.website_session_id) clicked_to_next_page
	,COUNT(DISTINCT wp.website_session_id)*1.0/COUNT(DISTINCT pp.website_session_id) clickthrough_rt
	,COUNT(DISTINCT o.order_id) [orders]
	,COUNT(DISTINCT o.order_id)*1.0 / COUNT(DISTINCT pp.website_session_id) products_to_order_rt
FROM #products_pageviews pp
	LEFT JOIN website_pageviews wp
		ON PP.website_session_id = wp.website_session_id
		AND wp.website_pageview_id > pp.website_pageview_id
	LEFT JOIN orders o
		ON o.website_session_id = pp.website_session_id
GROUP BY YEAR(saw_product_page_at)  
	,MONTH(saw_product_page_at)  
ORDER BY yr, mo;
GO

/* ===========================================================================================================
		7-	we made our 4th product available on December 05, 2014 (it was previously only a cross-sell) item
		Pull sales data since then, and show how well each product cross-sells from one another
=============================================================================================================*/

SELECT 
	order_id
	,primary_product_id
	,created_at AS ordered_at
INTO #primary_products
FROM orders
WHERE created_at > '20141205'; -- when the 4th product was added
GO 


SELECT 
	primary_product_id
	,COUNT(DISTINCT order_id) AS total_orders
	,COUNT(DISTINCT CASE WHEN cross_sell_product_id=1 THEN order_id ELSE NULL END) xsold_p1
	,COUNT(DISTINCT CASE WHEN cross_sell_product_id=2 THEN order_id ELSE NULL END) xsold_p2
	,COUNT(DISTINCT CASE WHEN cross_sell_product_id=3 THEN order_id ELSE NULL END) xsold_p3
	,COUNT(DISTINCT CASE WHEN cross_sell_product_id=4 THEN order_id ELSE NULL END) xsold_p4
	,COUNT(DISTINCT CASE WHEN cross_sell_product_id=1 THEN order_id ELSE NULL END)*1.0 / COUNT(DISTINCT order_id) p1_xsell_rt
	,COUNT(DISTINCT CASE WHEN cross_sell_product_id=2 THEN order_id ELSE NULL END)*1.0 / COUNT(DISTINCT order_id) p2_xsell_rt
	,COUNT(DISTINCT CASE WHEN cross_sell_product_id=3 THEN order_id ELSE NULL END)*1.0 / COUNT(DISTINCT order_id) p3_xsell_rt
	,COUNT(DISTINCT CASE WHEN cross_sell_product_id=4 THEN order_id ELSE NULL END)*1.0 / COUNT(DISTINCT order_id) p4_xsell_rt
FROM (
	SELECT pp.*
		,oi.product_id as cross_sell_product_id
	FROM #primary_products pp
		LEFT JOIN order_items oi
			ON oi.order_id = pp.order_id
			AND oi.is_primary_item = 0 --only bringing in cross-sells
	) AS primary_w_cross_sell

GROUP BY primary_product_id;
GO