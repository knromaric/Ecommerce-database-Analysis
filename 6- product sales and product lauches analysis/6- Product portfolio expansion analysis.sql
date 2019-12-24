USE MavenFuzzyFactory
GO 

/*=================================================================================================================
										Portfolio Expansion ANALYSIS 
		on December 12th 2013, we launched a third product targeting the birthday gift market.
		Run a pre-post analysis comparing the month before vs the month after, in terms of session-to-order
		conversion rate, AOV, products per order and revenue per session.
===================================================================================================================*/

SELECT CASE	
		WHEN ws.created_at <'20131212' THEN 'A. Pre_Birthday_Bear'
		WHEN ws.created_at >='20131212' THEN 'B. Post_Birthday_Bear'
	   END time_period
	   , COUNT(DISTINCT ws.website_session_id) [sessions]
	   , COUNT(DISTINCT o.order_id) [orders]
	   , COUNT(DISTINCT o.order_id)*1.0 / COUNT(DISTINCT ws.website_session_id) conv_rate
	   , SUM(o.price_usd) total_revenue
	   , SUM(o.items_purchased) total_product_sold
	   , SUM(o.price_usd)*1.0 / COUNT(DISTINCT o.order_id) average_order_value
	   , SUM(o.items_purchased)*1.0/ COUNT(DISTINCT o.order_id) product_per_order
	   , SUM(o.price_usd)*1.0 / COUNT(DISTINCT ws.website_session_id) revenue_per_session
FROM website_sessions ws
	LEFT JOIN orders o ON ws.website_session_id = o.website_session_id
WHERE ws.created_at BETWEEN '20131112' AND '20140112'
GROUP BY CASE	
		WHEN ws.created_at <'20131212' THEN 'A. Pre_Birthday_Bear'
		WHEN ws.created_at >='20131212' THEN 'B. Post_Birthday_Bear'
	   END ;
