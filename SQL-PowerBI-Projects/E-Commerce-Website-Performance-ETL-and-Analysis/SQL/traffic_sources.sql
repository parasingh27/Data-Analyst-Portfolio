USE ecommerce;

# Traffic Sources:
SELECT * 
FROM website_sessions
LIMIT 5;


SELECT 
	w.utm_content,
    COUNT(DISTINCT w.website_session_id) as sessions,
    COUNT(DISTINCT o.order_id) as orders,
    COUNT(DISTINCT o.order_id) / COUNT(DISTINCT w.website_session_id) * 100 AS orders_to_sessions_CVR
FROM website_sessions w 
	LEFT JOIN orders o
		ON w.website_session_id = o.website_session_id
GROUP BY w.utm_content
ORDER BY sessions DESC;


SELECT utm_source,
	utm_campaign,
    http_referer,
    COUNT(DISTINCT website_session_id) as sessions
FROM website_sessions
GROUP BY 1, 2, 3
ORDER BY sessions DESC;


SELECT 
	COUNT(DISTINCT w.website_session_id) as sessions,
    COUNT(DISTINCT o.order_id) as orders,
    COUNT(DISTINCT o.order_id) / COUNT(DISTINCT w.website_session_id) * 100 AS sessions_to_orders_CVR
FROM website_sessions w
	LEFT JOIN orders o
    ON w.website_session_id = o.website_session_id
WHERE w.created_at < '2012-04-14'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
ORDER BY sessions DESC;


SELECT
    MIN(DATE(created_at)) AS week_start,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE created_at < '2012-05-10' 
	AND utm_source = 'gsearch' 
    AND utm_campaign = 'nonbrand'
GROUP BY 
	YEAR(created_at),
	WEEK(created_at);


SELECT 
	primary_product_id,
    COUNT(DISTINCT CASE WHEN items_purchased = 1 THEN order_id ELSE NULL END) AS one_item_purchase,
    COUNT(DISTINCT CASE WHEN items_purchased = 2 THEN order_id ELSE NULL END) AS two_item_purchase,
    COUNT(DISTINCT order_id) as total_orders
FROM orders
GROUP BY 1;


SELECT device_type,
	COUNT(DISTINCT w.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.order_id) / COUNT(DISTINCT w.website_session_id) * 100 AS orders_to_session_CVR
FROM website_sessions w
	LEFT JOIN orders o
    ON w.website_session_id = o.website_session_id
WHERE w.created_at < '2012-05-11'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY 1;


SELECT 
	MIN(DATE(created_at)) AS week_start_date,
	COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(CASE WHEN device_type = 'desktop' THEN website_session_id ELSE NULL END) AS desktop_sessions,
	COUNT(CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mob_sessions
FROM website_sessions
WHERE created_at < '2012-06-09'
	AND created_at > '2012-04-15'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY 
	YEAR(created_at),
	WEEK(created_at);