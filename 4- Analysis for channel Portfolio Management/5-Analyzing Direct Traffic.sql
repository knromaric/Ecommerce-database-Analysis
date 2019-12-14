USE MavenFuzzyFactory
GO 

/*=================================================================================================================
			ANALYZING DIRECT TRAFFIC
	Pull organic search, direct type in and paid brand search sessions by month
	and show those sessions as % of paid search nonbrand
===================================================================================================================*/

SELECT YEAR(created_at) yr
	,MONTh(created_at) mo
	,COUNT(DISTINCT CASE WHEN utm_campaign='nonbrand' THEN website_session_id ELSE NULL END) nonbrand
	,COUNT(DISTINCT CASE WHEN utm_campaign='brand' THEN website_session_id ELSE NULL END) brand
	,COUNT(DISTINCT CASE WHEN utm_campaign='brand' THEN website_session_id ELSE NULL END)*0.1 / COUNT(DISTINCT CASE WHEN utm_campaign='nonbrand' THEN website_session_id ELSE NULL END) brand_pct_of_nonbrand
	,COUNT(DISTINCT CASE WHEN  http_referer is null THEN website_session_id ELSE NULL END) direct 
	,COUNT(DISTINCT CASE WHEN  http_referer is null THEN website_session_id ELSE NULL END)*0.1 /COUNT(DISTINCT CASE WHEN utm_campaign='nonbrand' THEN website_session_id ELSE NULL END) direct_pct_of_nonbrand
	, COUNT(DISTINCT CASE WHEN  http_referer IS NOT NULL AND utm_source IS NULL THEN website_session_id ELSE NULL END) organic
	, COUNT(DISTINCT CASE WHEN  http_referer IS NOT NULL AND utm_source IS NULL THEN website_session_id ELSE NULL END)*.1 / COUNT(DISTINCT CASE WHEN utm_campaign='nonbrand' THEN website_session_id ELSE NULL END)
FROM website_sessions
WHERE created_at < '2012-12-23'
GROUP BY YEAR(created_at), MONTH(created_at);

