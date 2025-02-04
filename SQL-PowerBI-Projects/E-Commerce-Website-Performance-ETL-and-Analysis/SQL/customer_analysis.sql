USE ecommerce;

# Identify repeat visitors
DROP TABLE IF EXISTS sessions_with_repeats;
CREATE TEMPORARY TABLE sessions_with_repeats
SELECT 
	new_sessions.user_id AS user_id,
    new_sessions.created_at AS new_session_created_at,
	new_sessions.website_session_id AS new_session,
	website_sessions.created_at AS repeat_session_created_at,
    website_sessions.website_session_id AS repeat_session,
    website_sessions.utm_campaign
FROM
(
	SELECT 
		user_id,
		website_session_id,
        created_at,
        utm_campaign
	FROM
		website_sessions
	WHERE
		created_at BETWEEN '2012-01-01' AND '2012-12-01'
		AND is_repeat_session = 0
) AS new_sessions
	LEFT JOIN website_sessions
		ON new_sessions.user_id = website_sessions.user_id
        AND website_sessions.is_repeat_session = 1
        AND website_sessions.website_session_id > new_sessions.website_session_id
        AND website_sessions.created_at BETWEEN '2012-01-01' AND '2012-11-01';
        

SELECT
	repeat_sessions,
    COUNT(DISTINCT user_id) AS no_of_users
FROM
	(
	SELECT 
		user_id,
		COUNT(DISTINCT new_session) AS new_sessions,
		COUNT(DISTINCT repeat_session) AS repeat_sessions 
	FROM 
		sessions_with_repeats
	GROUP BY
		1
	) AS sessions
GROUP BY
	repeat_sessions;
    

# Days Between first and second visit
CREATE TEMPORARY TABLE user_first_to_second
SELECT
	user_id,
    DATEDIFF(second_session_created_at, new_session_created_at) AS days_between_first_to_second
FROM
(
	SELECT
		user_id,
		new_session,
		new_session_created_at,
		MIN(repeat_session) AS second_session_id,
		MIN(repeat_session_created_at) AS second_session_created_at
	FROM 
		sessions_with_repeats
	WHERE
		repeat_session IS NOT NULL
	GROUP BY
		1,2,3
) AS first_to_second;


SELECT
	MIN(days_between_first_to_second),
    MAX(days_between_first_to_second),
    AVG(days_between_first_to_second)
FROM 	
	user_first_to_second;
    
    
# New vs Repeat channel patterns 
SELECT 
	CASE
		WHEN http_referer IN ('https://www.gsearch.com', 'https://www.bsearch.com') THEN 'organic_search'
        WHEN utm_campaign = 'nonbrand' THEN 'paid_nonbrand' 
        WHEN utm_campaign = 'brand' THEN 'paid_brand' 
        WHEN utm_source IS NULL AND http_referer IS NULL THEN 'direct_type_in' 
        WHEN utm_source = 'social_book' THEN 'paid_social' 
        ELSE 'unknown'
	END AS channel_group,
    COUNT(DISTINCT CASE WHEN is_repeat_session = 0 THEN website_session_id ELSE NULL END) AS new_sessions,
    COUNT(DISTINCT CASE WHEN is_repeat_session = 1 THEN website_session_id ELSE NULL END) AS repeat_sessions
FROM
	website_sessions
GROUP BY
	1;
    

# New vs Repeat (Revenue)
SELECT
	CASE 
		WHEN ws.is_repeat_session = 0 THEN 'new_session'
        WHEN ws.is_repeat_session = 1 THEN 'repeat_session'
	END AS session_type,
    COUNT(DISTINCT ws.website_session_id) AS total_sessions,
    COUNT(DISTINCT o.order_id) / COUNT(DISTINCT ws.website_session_id) * 100 AS orders_to_sessions_cvr,
    SUM(o.price_usd) AS total_revenue
FROM
	website_sessions ws LEFT JOIN orders o
		ON ws.website_session_id = o.website_session_id
WHERE
	ws.created_at BETWEEN '2014-01-01' AND '2014-11-08'
GROUP BY
	1;