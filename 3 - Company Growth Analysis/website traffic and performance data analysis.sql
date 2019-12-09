USE MavenFuzzyFactory;
GO 

/*====================================================================================================
			Quantify Company growth (revenue impact) by extracting and analyzing website traffic and 
			performance data from the Maven Fuzzy Factory database, and tell the story
			on how you have been able to generate that growth

			Analyze current performance and use the data available to assess upcoming opportunities

======================================================================================================*/


--## 1- Montly trends for gsearch sessions and orders so that we can show case the growth there

SELECT YEAR(ws.created_at) [year]
	, MONTH(ws.created_at) [month]
	, COUNT(DISTINCT ws.website_session_id) [sessions]
	, COUNT(DISTINCT o.order_id) [orders]
FROM website_sessions ws
	LEFT JOIN orders o 
		ON o.website_session_id = ws.website_session_id
WHERE  ws.created_at < '2012-11-27'
	AND utm_source = 'gsearch'
GROUP BY YEAR(ws.created_at), MONTH(ws.created_at)
ORDER BY [year], [month];
GO

--## 2- Montly trends for gsearch sessions/orders split out for nonbrand and brand campaign separately

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






