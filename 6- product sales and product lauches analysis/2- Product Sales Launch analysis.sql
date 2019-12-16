USE MavenFuzzyFactory
GO 

/*=================================================================================================================
							PRODUCT LAUNCH SALES ANALYSIS
			study the impact of the product launched: 
			Monthly order volume, overall conversion rates, revenue per 
			session, breakdown of sales by product
			since april 1, 2012

===================================================================================================================*/

SELECT YEAR(ws.created_at) yr
	, MONTH(ws.created_at) mo
	, COUNT(DISTINCT o.order_id) [orders]
	, COUNT(DISTINCT o.order_id)*0.1 / COUNT(DISTINCT ws.website_session_id) conv_rate
	, SUM(o.price_usd) / COUNT(DISTINCT ws.website_session_id) revenue_per_session
	, COUNT(DISTINCT CASE WHEN o.primary_product_id = 1 THEN o.order_id ELSE NULL END ) product_one_orders
	, COUNT(DISTINCT CASE WHEN o.primary_product_id = 2 THEN o.order_id ELSE NULL END ) product_two_orders
FROM website_sessions ws
	LEFT JOIN orders o ON ws.website_session_id = o.website_session_id
WHERE ws.created_at < '20130401' 
	AND ws.created_at > '20120401'
GROUP BY YEAR(ws.created_at), MONTH(ws.created_at)
ORDER BY yr, mo;