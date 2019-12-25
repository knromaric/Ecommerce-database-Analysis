USE MavenFuzzyFactory
GO 

/*=================================================================================================================
							PRODUCT REFUND RATES ANALYSIS 
		Pull the monthly product refund rates by product and confirm our quality issues are now fixed.
===================================================================================================================*/

SELECT 
	YEAR(oi.created_at) yr
	,MONTH(oi.created_at) mo
	,COUNT(DISTINCT CASE WHEN product_id=1 THEN oi.order_item_id ELSE NULL END) AS p1_orders
	,COUNT(DISTINCT CASE WHEN product_id=1 THEN oir.order_item_id ELSE NULL END) * 1.0
			/ COUNT(DISTINCT CASE WHEN product_id=1 THEN oi.order_item_id ELSE NULL END) AS p1_refund_rt
	,COUNT(DISTINCT CASE WHEN product_id=2 THEN oi.order_item_id ELSE NULL END) AS p2_orders
	,COUNT(DISTINCT CASE WHEN product_id=2 THEN oir.order_item_id ELSE NULL END) * 1.0
			/ NULLIF(COUNT(DISTINCT CASE WHEN product_id=2 THEN oi.order_item_id ELSE NULL END), 0) AS p2_refund_rt
	,COUNT(DISTINCT CASE WHEN product_id=3 THEN oi.order_item_id ELSE NULL END) AS p2_orders
	,COUNT(DISTINCT CASE WHEN product_id=3 THEN oir.order_item_id ELSE NULL END) * 1.0
			/ NULLIF(COUNT(DISTINCT CASE WHEN product_id=3 THEN oi.order_item_id ELSE NULL END), 0) AS p3_refund_rt
	,COUNT(DISTINCT CASE WHEN product_id=4 THEN oi.order_item_id ELSE NULL END) AS p2_orders
	,COUNT(DISTINCT CASE WHEN product_id=4 THEN oir.order_item_id ELSE NULL END) * 1.0
			/ NULLIF(COUNT(DISTINCT CASE WHEN product_id=4 THEN oi.order_item_id ELSE NULL END), 0) AS p4_refund_rt
FROM order_items oi
	LEFT JOIN order_item_refunds oir ON oi.order_item_id = oir.order_item_id
WHERE oi.created_at < '20141015'
GROUP BY YEAR(oi.created_at), MONTH(oi.created_at);
GO

