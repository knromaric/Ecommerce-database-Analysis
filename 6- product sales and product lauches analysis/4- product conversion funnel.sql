USE MavenFuzzyFactory
GO 

/*=================================================================================================================
							PRODUCT CONVERSION FUNNELS 
		conversion funnels from each product page to conversion
		produce a comparison between the two conversion funnels, for all website traffic.
===================================================================================================================*/

--## step 1: select all pageviews for relevant sessions 
	SELECT website_session_id
		, website_pageview_id
		, pageview_url AS product_page_seen
	INTO #sessions_seeing_product_pages
	FROM website_pageviews
	WHERE created_at < '20130410' AND created_at >= '20130106'
		AND pageview_url IN ('/the-original-mr-fuzzy', '/the-forever-love-bear')
	GO
--## step 2: figure out which pageview urls to look for 
	SELECT DISTINCT
		wp.pageview_url
	FROM  #sessions_seeing_product_pages sspg
		LEFT JOIN website_pageviews wp
			ON wp.website_session_id = sspg.website_session_id
			AND wp.website_pageview_id > sspg.website_pageview_id;
	GO

--## step 3: pull all pageviews and identify the funnel steps 
SELECT 
	website_session_id
	,CASE 
		WHEN product_page_seen = '/the-original-mr-fuzzy' THEN 'mrfuzzy'
		WHEN product_page_seen = '/the-forever-love-bear' THEN 'lovebear'
		ELSE 'uh oh... check logic'
	END product_seen
	,MAX(cart_page) cart_made_it
	,MAX(shipping_page) shipping_made_it
	,MAX(billing_page) billing_made_it
	,MAX(thankyou_page) thankyou_made_it
INTO #session_product_level_made_it_flag
FROM 
	(
		SELECT 
		sspg.website_session_id
		,sspg.product_page_seen
		, CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END cart_page
		, CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END shipping_page
		, CASE WHEN pageview_url = '/billing-2' THEN 1 ELSE 0 END billing_page
		, CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thankyou_page
	FROM #sessions_seeing_product_pages sspg
		LEFT JOIN website_pageviews wp
			ON wp.website_session_id = sspg.website_session_id
			AND wp.website_pageview_id > sspg.website_pageview_id 
	) page_w_flag
GROUP BY website_session_id
	,CASE 
		WHEN product_page_seen = '/the-original-mr-fuzzy' THEN 'mrfuzzy'
		WHEN product_page_seen = '/the-forever-love-bear' THEN 'lovebear'
		ELSE 'uh oh... check logic'
	END;
GO
--## step 4: create the session_level conversion funnel view
SELECT product_seen
	,COUNT(DISTINCT website_session_id) session
	,COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) to_cart
	,COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) to_shipping
	,COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) to_billing
	,COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END) to_thankyou
FROM #session_product_level_made_it_flag
GROUP BY product_seen ;
GO
--## step 5: aggregate the data to assess funnel performance

 SELECT product_seen
	,COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END)*1.0/COUNT(DISTINCT website_session_id) product_page_click_rt
	,COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END)*1.0/COUNT(DISTINCT CASE WHEN cart_made_it = 1 THEN website_session_id ELSE NULL END) cart_click_rt
	,COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END)*1.0/COUNT(DISTINCT CASE WHEN shipping_made_it = 1 THEN website_session_id ELSE NULL END) shipping_click_rt
	,COUNT(DISTINCT CASE WHEN thankyou_made_it = 1 THEN website_session_id ELSE NULL END)*1.0/COUNT(DISTINCT CASE WHEN billing_made_it = 1 THEN website_session_id ELSE NULL END) billing_click_rt
FROM #session_product_level_made_it_flag
GROUP BY product_seen ;

