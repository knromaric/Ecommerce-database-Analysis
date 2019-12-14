USE MavenFuzzyFactory
GO 

/*=================================================================================================================
			CROSS CHANNEL BID OPTIMIZATION
	Pull nonbrand conversion rates from session to order for gsearch and bsearch and slice the data
	by device type.(from August 22 to September 18)
===================================================================================================================*/

SELECT ws.device_type
	,ws.utm_source
	,COUNT(DISTINCT ws.website_session_id) AS [sessions]
	,COUNT(DISTINCT o.order_id) AS [orders]
	, COUNT(DISTINCT o.order_id)*1.0 / COUNT(DISTINCT ws.website_session_id) AS conv_rate
FROM website_sessions ws
	LEFT JOIN orders o
		ON ws.website_session_id = o.website_session_id
WHERE ws.created_at > '2012-08-22' 
	AND ws.created_at <= '2012-09-18'
	AND ws.utm_campaign = 'nonbrand'
GROUP BY ws.device_type
		,ws.utm_source
ORDER BY ws.device_type;

/*
device_type     utm_source   sessions    orders      conv_rate
--------------- ------------ ----------- ----------- ---------------------------------------
desktop         bsearch      1119        43          0.038427167113
desktop         gsearch      2834        132         0.046577275935
mobile          bsearch      124         1           0.008064516129
mobile          gsearch      958         11          0.011482254697
*/