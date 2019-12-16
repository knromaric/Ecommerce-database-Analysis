USE MavenFuzzyFactory
GO 

/*=================================================================================================================
							PRODUCT LEVEL SALES ANALYSIS
			Pull monthly trends to date for number of sales, total revenue, and total margin generated
===================================================================================================================*/

SELECT YEAR(created_at) yr
	, MONTH(created_at) mo
	, COUNT(order_id) number_sales
	, SUM(price_usd) revenue
	, SUM(price_usd - cogs_usd) margin
FROM orders
WHERE created_at < '20130104' -- date of request
GROUP BY YEAR(created_at), MONTH(created_at)
ORDER BY yr, mo;