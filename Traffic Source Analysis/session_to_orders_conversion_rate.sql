USE MavenFuzzyFactory
GO


/*
	Calculate the conversion rate (CVR) from sesssion to order. 
*/

SELECT COUNT(DISTINCT ws.website_session_id) numberOfSessions
	,COUNT(DISTINCT o.order_id) numberOfOrders
	, CAST(CAST(COUNT(DISTINCT o.order_id) AS DECIMAL)/COUNT(DISTINCT ws.website_session_id) AS DECIMAL(5,4)) sessionToOrderConvRate
FROM website_sessions ws
LEFT JOIN orders o ON O.website_session_id = ws.website_session_id
WHERE ws.created_at < '2012-04-14' 
	AND ws.utm_source = 'gsearch'
	AND ws.utm_campaign = 'nonbrand';
