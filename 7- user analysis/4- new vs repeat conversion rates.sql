USE MavenFuzzyFactory
GO 

/*=================================================================================================================
							NEW VS REPEAT PERFORMANCE
		comparison of conversion rates and revenue per sessions for repeat sessions vs new sessions
===================================================================================================================*/
SELECT is_repeat_session
	,COUNT(DISTINCT ws.website_session_id) sessions
	,COUNT(DISTINCT o.order_id) orders
	,COUNT(DISTINCT o.order_id)*1.0 / COUNT(DISTINCT ws.website_session_id) conv_rate
	,SUM(price_usd) total_revenue
	,SUM(price_usd) / COUNT(DISTINCT ws.website_session_id) rev_per_session
FROM website_sessions ws
	LEFT JOIN orders o 
		 ON o.website_session_id = ws.website_session_id
WHERE ws.created_at < '20141105'
	AND ws.created_at >= '20140101'
GROUP BY is_repeat_session