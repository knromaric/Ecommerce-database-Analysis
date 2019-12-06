USE mavenfuzzyfactory;
GO

SELECT 
	ws.utm_content
    , COUNT(DISTINCT ws.website_session_id) AS sessions
    , COUNT(DISTINCT o.order_id) AS orders
    , COUNT(DISTINCT o.order_id)/COUNT(DISTINCT ws.website_session_id) AS session_to_order_conv_rt
FROM website_sessions ws
LEFT JOIN orders o 
	ON o.website_session_id = ws.website_session_id
WHERE ws.website_session_id between 1000 AND 2000
GROUP BY 
	utm_content
ORDER BY sessions DESC;
GO

-- Finding top traffic sources to the date april 12, 2012
-- session volume by utm_source, utm_campaign, http_referer
SELECT utm_source
	   , utm_campaign
       , http_referer
       , COUNT(*)  numberOfsessions
FROM website_sessions
WHERE created_at < '2012-04-12'
GROUP BY utm_source, utm_campaign, http_referer
ORDER BY numberOfsessions DESC;
