USE ecommerce;

SELECT
	MIN(DATE(created_at)) AS week_start,
    COUNT(DISTINCT website_session_id) AS total_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' THEN website_session_id ELSE NULL END) AS gsearch_sessions,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' THEN website_session_id ELSE NULL END) AS bsearch_sessions
FROM
	website_sessions
WHERE
	created_at BETWEEN '2012-08-22' AND '2012-11-29'
GROUP BY
	YEARWEEK(created_at);


SELECT
	utm_source,
    COUNT(DISTINCT website_session_id) AS total_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mob_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id) * 100 AS mob_sessions_rate
FROM
	website_sessions
WHERE
	utm_campaign = 'nonbrand'
GROUP BY
	utm_source;
    
    
SELECT
	ws.device_type,
	ws.utm_source,
	COUNT(DISTINCT ws.website_session_id) AS total_sessions,
    COUNT(DISTINCT o.order_id) AS total_orders,
    COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) * 100 AS sessions_to_orders_cvr
FROM
	website_sessions ws LEFT JOIN orders o 
		ON ws.website_session_id = o.website_session_id
WHERE
	utm_campaign = 'nonbrand'
    AND ws.created_at > '2012-08-21' 
    AND ws.created_at < '2012-09-19'
GROUP BY
	ws.utm_source,
    ws.device_type
ORDER BY
	ws.device_type;
    
    
SELECT
	MIN(DATE(created_at)) AS week_start,
    utm_source,
    #COUNT(DISTINCT website_session_id) AS total_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) AS mob_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id) * 100 AS mob_rate,
    COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_session_id ELSE NULL END) AS desktop_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_session_id ELSE NULL END) / COUNT(DISTINCT website_session_id) * 100 AS desktop_rate
FROM
	website_sessions
WHERE
	utm_campaign = 'nonbrand'
    AND created_at > '2012-09-04'
    AND created_at < '2012-12-22'
GROUP BY
	YEARWEEK(created_at),
    utm_source;
    
    

SELECT * FROM website_sessions
WHERE utm_campaign IS NULL;
    
SELECT
	MIN(DATE(created_at)) AS start_of_month,
    COUNT(DISTINCT website_session_id) AS nonbrand_sessions,
	COUNT(DISTINCT CASE WHEN http_referer IS NULL THEN website_session_id ELSE NULL END) AS 'direct_type_in',
    COUNT(DISTINCT CASE WHEN http_referer = 'https://www.gsearch.com' THEN website_session_id ELSE NULL END) AS 'gsearch_organic',
	COUNT(DISTINCT CASE WHEN http_referer = 'https://www.bsearch.com' THEN website_session_id ELSE NULL END) AS 'bsearch_organic'
FROM
	website_sessions
WHERE 
	utm_source IS NULL
    AND created_at > '2013-01-01'
GROUP BY
	YEAR(created_at),
    MONTH(created_at)
ORDER BY 
	YEAR(created_at),
    MONTH(created_at);