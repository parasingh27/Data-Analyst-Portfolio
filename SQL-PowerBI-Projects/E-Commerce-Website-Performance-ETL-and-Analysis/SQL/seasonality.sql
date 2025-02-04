USE ecommerce;

# Monthly Trends
SELECT 
	YEAR(ws.created_at) AS year,
	MONTH(ws.created_at) AS month,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) * 100 AS sessions_to_orders_cvr
FROM
	website_sessions ws LEFT JOIN orders o
		ON ws.website_session_id = o.website_session_id
WHERE 
	YEAR(ws.created_at) = 2012
GROUP BY
	1,2;
    

# Weekly Trends    
SELECT 
	MIN(DATE(ws.created_at)) AS week,
    COUNT(DISTINCT ws.website_session_id) AS sessions,
    COUNT(DISTINCT o.order_id) AS orders,
    COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) * 100 AS sessions_to_orders_cvr
FROM
	website_sessions ws LEFT JOIN orders o
		ON ws.website_session_id = o.website_session_id
WHERE 
	YEAR(ws.created_at) = 2012
GROUP BY
	YEARWEEK(ws.created_at);
    

# Day - Hour Trends
SELECT 
	hr AS hour,
	ROUND(AVG(CASE WHEN weekday = 0 THEN sessions ELSE NULL END), 2) AS Monday,
	ROUND(AVG(CASE WHEN weekday = 1 THEN sessions ELSE NULL END), 2) AS Tuesday,
    ROUND(AVG(CASE WHEN weekday = 2 THEN sessions ELSE NULL END), 2) AS Wednesday,
    ROUND(AVG(CASE WHEN weekday = 3 THEN sessions ELSE NULL END), 2) AS Thursday,
    ROUND(AVG(CASE WHEN weekday = 4 THEN sessions ELSE NULL END), 2) AS Friday,
    ROUND(AVG(CASE WHEN weekday = 5 THEN sessions ELSE NULL END), 2) AS Saturday,
    ROUND(AVG(CASE WHEN weekday = 6 THEN sessions ELSE NULL END), 2) AS Sunday
FROM
(    
	SELECT
		DATE(created_at) AS creaed_date,
		WEEKDAY(created_at) AS weekday,
		HOUR(created_At) AS hr,
		COUNT(DISTINCT website_session_id) AS sessions
	FROM
		website_sessions
	GROUP BY
		1,2,3
) AS date_query
GROUP BY
	hour;
        