USE MavenFuzzyFactory
GO 

/*=================================================================================================================
			COMPARING CHANNEL CHARACTERISTICS 
	Pull of the percentage of traffic coming on Mobile, and compare bsearch to gsearch
===================================================================================================================*/

SELECT
	utm_source
	,COUNT( DISTINCT  website_session_id ) AS  sessions
	,COUNT( DISTINCT CASE WHEN device_type='mobile' THEN website_session_id ELSE NULL END) AS  mobile_sessions
	,COUNT( DISTINCT CASE WHEN device_type='mobile' THEN website_session_id ELSE NULL END)*1.0 / COUNT( DISTINCT  website_session_id ) AS pct_mobile
FROM website_sessions ws
WHERE created_at > '2012-08-22' 
	AND created_at < '2012-11-30'
	AND utm_campaign = 'nonbrand'
GROUP BY utm_source


/*
	utm_source   sessions    mobile_sessions  pct_mobile
------------ ----------- --------------- ---------------------------------------
	gsearch      20089       4925             0.245159042261
	bsearch      6523        562              0.086156676375
*/