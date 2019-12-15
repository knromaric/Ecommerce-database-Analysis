USE MavenFuzzyFactory
GO 

/*=================================================================================================================
							ANALYZE THE BUSINESS SEASONALITY
			take A look at 2012 monthly and weekly pattern volume pattern, pull session and order volume
===================================================================================================================*/

SELECT YEAR(ws.created_at) yr
	, MONTH(ws.created_at) mo
	, COUNT(DISTINCT ws.website_session_id) [sessions]
	,COUNT(DISTINCT o.website_session_id) [orders]
FROM website_sessions ws
	LEFT JOIN orders o 
		ON ws.website_session_id = o.website_session_id
WHERE ws.created_at < '20130101'
GROUP BY YEAR(ws.created_at), MONTH(ws.created_at)
GO


SELECT MIN(CAST(ws.created_at AS DATE)) week_start_date
	, COUNT(DISTINCT ws.website_session_id) [sessions]
	,COUNT(DISTINCT o.website_session_id) [orders]
FROM website_sessions ws
	LEFT JOIN orders o 
		ON ws.website_session_id = o.website_session_id
WHERE ws.created_at < '20130101'
GROUP BY YEAR(ws.created_at), DATEPART(WEEK, ws.created_at)
GO