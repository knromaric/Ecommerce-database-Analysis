USE MavenFuzzyFactory
GO
/*
	Gsearch Device level performance
	- Pull conversion rates from session to order by device type
*/

SELECT ws.device_type
	, COUNT(DISTINCT ws.website_session_id) as [sessions]
	, COUNT(DISTINCT o.order_id) as [orders]
	, CAST((CAST(COUNT(DISTINCT o.order_id) AS DECIMAL))/COUNT(DISTINCT ws.website_session_id) AS DECIMAL(5,4)) AS session_to_order_conv_rate
FROM website_sessions ws
LEFT JOIN orders o on o.website_session_id = ws.website_session_id
WHERE ws.created_at < '2012-05-11'
	AND utm_source = 'gsearch'
	AND utm_campaign = 'nonbrand'
GROUP BY ws.device_type;


/*
device_type     sessions    orders      session_to_order_conv_rate
--------------- ----------- ----------- ---------------------------------------
desktop         3883        144         0.0371
mobile          2475        24          0.0097

*/