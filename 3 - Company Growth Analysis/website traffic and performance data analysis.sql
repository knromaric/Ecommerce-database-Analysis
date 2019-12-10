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
	, COUNT(DISTINCT o.order_id)*1.0 / COUNT(DISTINCT ws.website_session_id) [sessions_to_orders_rate]
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

--## 3- Let's Dive into nonbrand and pull monthly trend sessions and orders split by device type

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

--## 4- Montly trends for Gsearch alongside monthly trends for each of our other channels
	
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






