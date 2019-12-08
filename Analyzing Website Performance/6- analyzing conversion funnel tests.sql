USE MavenFuzzyFactory
GO	

/*=====================================================================================
			ANALYZING CONVERSION FUNNELS TESTS RESULTS BETWEEN (/billing-2 and /billing)
			what % of sesssions on those pages end up placing and order.
=====================================================================================*/

SELECT MIN(created_at) first_created_at 
	,MIN(website_pageview_id) first_pv_id
FROM website_pageviews
WHERE pageview_url = '/billing-2'  -- first_created_at = '2012-09-10 08:13:05.000' fist_pv_id = 53550
GO

SELECT billing_version_seen
	, COUNT(DISTINCT website_session_id) AS sessions
	, COUNT(DISTINCT order_id) AS orders
	, COUNT(DISTINCT order_id)*1.0 / COUNT(DISTINCT website_session_id) AS Billing_to_orders_rt
FROM
	(
	SELECT wp.website_session_id
		,wp.pageview_url AS billing_version_seen
		,o.order_id
	FROM website_pageviews wp
		LEFT JOIN orders o
			ON wp.website_session_id = o.website_session_id
	WHERE wp.created_at >= '2012-09-10'
		AND wp.created_at < '2012-11-10'
		AND wp.pageview_url IN ('/billing', '/billing-2')) AS billing_sessions_w_orders
GROUP BY billing_version_seen

/*
billing_version_seen                               sessions    orders      Billing_to_orders_rt
-------------------------------------------------- ----------- ----------- ---------------------------------------
/billing                                           658         302         0.458966565349
/billing-2                                         653         410         0.627871362940

*/