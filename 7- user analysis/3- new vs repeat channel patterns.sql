USE MavenFuzzyFactory
GO 

/*=================================================================================================================
							NEW VS REPEAT CHANNEL PATTERNS
		identify which channel customer uses when the come back? Comparing new vs repeat sessions by channel
===================================================================================================================*/

SELECT utm_campaign
	,utm_source
	,http_referer
	,COUNT(CASE WHEN is_repeat_session = 0 THEN website_session_id else NULL END) new_sessions
	,COUNT(CASE WHEN is_repeat_session = 1 THEN website_session_id ELSE NULL END) repeat_sessions
FROM website_sessions
WHERE created_at < '20141105'
	AND created_at >= '20140101'
GROUP BY utm_campaign
	,utm_source
	,http_referer;
GO

SELECT channel_group
	,COUNT(new_sessions) new_sessions
	,COUNT(repeat_sessions) repeat_sessions
FROM
(
	SELECT 
		CASE	
			WHEN utm_source IS NULL AND http_referer IN ('https://www.gsearch.com', 'https://www.bsearch.com') THEN 'organic_search'
			WHEN utm_campaign = 'nonbrand' THEN 'paid_nonbrand'
			WHEN utm_campaign = 'brand' THEN 'paid_brand'
			WHEN utm_source IS NULL AND http_referer IS NULL THEN 'direct_type_in'
			WHEN utm_source = 'socialbook' THEN 'paid_social'
		END AS channel_group
		,CASE WHEN is_repeat_session = 0 THEN website_session_id else NULL END new_sessions
		,CASE WHEN is_repeat_session = 1 THEN website_session_id ELSE NULL END repeat_sessions
	FROM website_sessions
	WHERE created_at < '20141105'
		AND created_at >= '20140101') tmp
GROUP BY channel_group
ORDER BY repeat_sessions DESC;
GO
