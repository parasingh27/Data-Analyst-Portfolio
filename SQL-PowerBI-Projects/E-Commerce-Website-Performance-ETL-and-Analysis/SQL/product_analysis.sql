USE ecommerce;


SELECT
	YEAR(created_at) AS year,
	MONTH(created_at) AS month,
    COUNT(DISTINCT order_id) AS orders,
    SUM(price_usd) AS revenue,
    SUM(price_usd - cogs_usd) AS margin
FROM
	orders
GROUP BY
	1,2;


SELECT
	YEAR(ws.created_at) AS year,
	MONTH(ws.created_at) AS month,
	COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) AS conversion_rate,
	SUM(o.price_usd) / COUNT(DISTINCT ws.website_session_id) AS avg_revenue_per_session,
	COUNT(DISTINCT CASE WHEN o.primary_product_id = 1 THEN o.order_id ELSE NULL END) AS product_1_orders,
	COUNT(DISTINCT CASE WHEN o.primary_product_id = 2 THEN o.order_id ELSE NULL END) AS product_2_orders
FROM
	orders o RIGHT JOIN website_sessions ws
		ON o.website_session_id = ws.website_session_id
WHERE
	ws.created_at BETWEEN '2012-04-1' AND '2013-04-05'
GROUP BY
	1,2;
    
    
# Product Level Website Pathing
SELECT DISTINCT pageview_url
FROM website_pageviews;

DROP TABLE IF EXISTS product_funnel;
CREATE TEMPORARY TABLE product_funnel
SELECT 
	date,
	website_session_id,
	MAX(products_page) AS to_product,
    MAX(mr_fuzzy_page) AS to_mr_fuzzy,
    MAX(love_bear_page) AS to_love_bear,
    MAX(cart_page) AS to_cart,
    MAX(shipping_page) AS to_shipping,
    MAX(billing_page) AS to_billing,
    MAX(thank_you_page) AS to_thank_you_page
FROM
(
	SELECT
		DATE(created_at) AS date,
		website_session_id,
		pageview_url,
		CASE WHEN pageview_url = '/products' THEN 1 ELSE NULL END AS products_page, 
		CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE NULL END AS mr_fuzzy_page,
		CASE WHEN pageview_url = '/the-forever-love-bear' THEN 1 ELSE NULL END AS love_bear_page,
        CASE WHEN pageview_url = '/cart' THEN 1 ELSE NULL END AS cart_page,
        CASE WHEN pageview_url = '/shipping' THEN 1 ELSE NULL END AS shipping_page,
        CASE WHEN pageview_url = '/billing' THEN 1 ELSE NULL END AS billing_page,
        CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE NULL END AS thank_you_page
	FROM
		website_pageviews
	WHERE 
		pageview_url IN ('/products','/the-forever-love-bear','/the-original-mr-fuzzy', '/cart', '/shipping' , '/billing', '/thank-you-for-your-order')
        AND created_at BETWEEN '2012-10-05' AND '2013-04-06'
) AS conversion_funnel
GROUP BY
	1, 2;
    
SELECT 
	CASE
		WHEN date BETWEEN '2012-10-05' AND '2013-01-05' THEN 'Pre_Product2_Launch'
        WHEN date BETWEEN '2013-01-06' AND '2013-04-06' THEN 'Post_Product2_Launch'
	END AS seasons,
    COUNT(to_product) AS to_product,
    COUNT(to_mr_fuzzy) AS to_mr_fuzzy,
    COUNT(to_mr_fuzzy) / COUNT(to_product) * 100 AS products_to_mr_fuzzy_cvr,
    COUNT(to_love_bear) AS to_love_bear,
    COUNT(to_love_bear) / COUNT(to_product) * 100 AS products_to_love_bear_cvr,
    COUNT(to_cart) AS to_cart,
    COUNT(to_shipping) AS to_shipping,
    COUNT(to_billing) AS to_billing,
    COUNT(to_thank_you_page) AS to_thank_you_page
FROM
	product_funnel
GROUP BY 
	1
ORDER BY 
	1 DESC;
    
    
# Cross Selling
SELECT 
	o.primary_product_iD,
    COUNT(DISTINCT o.order_id) as orders,
    COUNT(DISTINCT CASE WHEN oi.product_id = 1 THEN o.order_id ELSE NULL END) AS cross_sell_product_1,
    COUNT(DISTINCT CASE WHEN oi.product_id = 2 THEN o.order_id ELSE NULL END) AS cross_sell_product_2,
    COUNT(DISTINCT CASE WHEN oi.product_id = 3 THEN o.order_id ELSE NULL END) AS cross_sell_product__3,
    COUNT(DISTINCT CASE WHEN oi.product_id = 4 THEN o.order_id ELSE NULL END) AS cross_sell_product_4
FROM
	orders o LEFT JOIN order_items oi
		ON o.order_id = oi.order_id
        AND oi.is_primary_item = 0		#cross sell only
GROUP BY
	1;


# Product Refund 
SELECT
	YEAR(o.created_at) AS year,
    MONTH(o.created_at) AS month,
    COUNT(DISTINCT CASE WHEN o.product_id = 1 THEN o.order_item_id ELSE NULL END) AS product_1_refund, 
    COUNT(DISTINCT CASE WHEN o.product_id = 2 THEN o.order_item_id ELSE NULL END) AS product_2_refund,
    COUNT(DISTINCT CASE WHEN o.product_id = 3 THEN o.order_item_id ELSE NULL END) AS product_3_refund,
	COUNT(DISTINCT CASE WHEN o.product_id = 4 THEN o.order_item_id ELSE NULL END) AS product_4_refund
FROM
	order_items o LEFT JOIN order_item_refunds refund
		ON o.order_id = refund.order_id
GROUP BY
	1,2;
    