USE ecommerce;

# Website Performance:
SELECT pageview_url,
	COUNT(DISTINCT website_pageview_id) AS page_view
FROM website_pageviews
WHERE created_at < '2012-06-09'
GROUP BY pageview_url
ORDER BY page_view DESC;


CREATE TEMPORARY TABLE first_page_view
SELECT 
	website_session_id,
	MIN(website_pageview_id) AS min_page_view_id
FROM 
	website_pageviews
GROUP BY 
	website_session_id;


SELECT 
	w.pageview_url,
	COUNT(DISTINCT f.website_session_id) AS sessions
FROM 
	first_page_view f 
	LEFT JOIN website_pageviews w
		ON f.min_page_view_id = w.website_pageview_id
GROUP BY 
	w.pageview_url;


DROP TABLE IF EXISTS first_url_view;
CREATE TEMPORARY TABLE first_url_view
SELECT   
	fp.start_of_the_week,
	fp.website_session_id,
	wp.pageview_url AS entry_page
FROM 	
	website_pageviews wp 
    INNER JOIN first_page_view fp
		ON wp.website_session_id = fp.website_session_id;


DROP TABLE IF EXISTS bounced_sessions_only;
CREATE TEMPORARY TABLE bounced_sessions_only
SELECT 
	start_of_the_week,
	first_url_view.website_session_id,
	first_url_view.entry_page,
	COUNT(wp.website_pageview_id) AS sessions
FROM	 
	first_url_view 
    LEFT JOIN website_pageviews wp
		ON first_url_view.website_session_id = wp.website_session_id
GROUP BY 
	start_of_the_week,
	first_url_view.website_session_id,
	first_url_view.entry_page
HAVING 	 
	COUNT(wp.website_pageview_id) = 1; 

SELECT * 
FROM bounced_sessions_only 
LIMIT 5;


SELECT  
	first_url_view.entry_page,
	first_url_view.website_session_id,
	bs.website_session_id
FROM 	
	first_url_view 
    LEFT JOIN bounced_sessions_only bs
		ON first_url_view.website_session_id = bs.website_session_id
ORDER BY 
	first_url_view.website_session_id;


# No. of Session and Bounced sessions
SELECT  
	first_url_view.entry_page,
	COUNT(DISTINCT first_url_view.website_session_id) AS sessions,
	COUNT(DISTINCT bs.website_session_id) AS bounce_sessions
FROM 	
	first_url_view 
    LEFT JOIN bounced_sessions_only bs
		ON first_url_view.website_session_id = bs.website_session_id
GROUP BY 
	first_url_view.entry_page
ORDER BY 
	sessions DESC;
    

SELECT  first_url_view.entry_page,
		COUNT(DISTINCT first_url_view.website_session_id) AS sessions,
		COUNT(DISTINCT bs.website_session_id) AS bounce_sessions,
        COUNT(DISTINCT bs.website_session_id) / COUNT(DISTINCT first_url_view.website_session_id) * 100 AS bounce_session_rate
FROM 	
	first_url_view LEFT JOIN 
    bounced_sessions_only bs ON first_url_view.website_session_id = bs.website_session_id 
WHERE
	first_url_view.entry_page = '/home' 
GROUP BY 
	first_url_view.entry_page;


SELECT  
	first_url_view.entry_page,
	COUNT(DISTINCT first_url_view.website_session_id) AS sessions,
	COUNT(DISTINCT bs.website_session_id) AS bounce_sessions,
    COUNT(DISTINCT bs.website_session_id) / COUNT(DISTINCT first_url_view.website_session_id) * 100 AS bounce_rate
FROM 	
	first_url_view 
    LEFT JOIN bounced_sessions_only bs
		ON first_url_view.website_session_id = bs.website_session_id
GROUP BY 
	first_url_view.entry_page
HAVING 
	COUNT(DISTINCT bs.website_session_id) > 0
ORDER BY 
	sessions DESC;


# A/B testing
SELECT 	MIN(created_at),
		MIN(website_pageview_id),
		pageview_url
FROM 	website_pageviews
WHERE	pageview_url = '/lander-1'
		AND created_at IS NOT NULL;			# '2012-06-19'


DROP TABLE IF EXISTS first_page_view;
CREATE TEMPORARY TABLE first_page_view
SELECT 
	wp.website_session_id,
	MIN(website_pageview_id) AS min_page_view_id
FROM 
	website_pageviews wp 
    INNER JOIN website_sessions ws
		ON wp.website_session_id = ws.website_session_id
WHERE 
	ws.created_at < '2012-07-19'
    AND website_pageview_id > 23504
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY 
	wp.website_session_id;
# After you run this table recreate the other 2 temporary tables "first_url_view" and "bounced_sessions_only"


SELECT 
	first_url_view.entry_page,
	COUNT(DISTINCT first_url_view.website_session_id) AS total_sessions,
	COUNT(DISTINCT bs.website_session_id) AS bounce_sessions,
    COUNT(DISTINCT bs.website_session_id) / COUNT(DISTINCT first_url_view.website_session_id) * 100 AS bounce_rate
FROM 
	first_url_view LEFT JOIN bounced_sessions_only bs
		ON first_url_view.website_session_id = bs.website_session_id
WHERE 
	first_url_view.entry_page = '/home' 
    OR first_url_view.entry_page = '/lander-1'
GROUP BY 
	first_url_view.entry_page;


# Weekly trending
DROP TABLE IF EXISTS first_page_view;
CREATE TEMPORARY TABLE first_page_view
SELECT 
	MIN(DATE(ws.created_at)) AS start_of_the_week,
	wp.website_session_id,
	MIN(website_pageview_id) AS min_page_view_id
FROM 
	website_pageviews wp 
    INNER JOIN website_sessions ws
		ON wp.website_session_id = ws.website_session_id
WHERE 
	ws.created_at < '2012-08-31'
    AND website_pageview_id > 23504
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY 
	YEAR(ws.created_at),
    WEEK(ws.created_at),
	wp.website_session_id;
# After you run this table recreate the other 2 temporary tables "first_url_view" and "bounced_sessions_only"

SELECT 
	MIN(DATE(fu.start_of_the_week)) AS week,
    fu.entry_page,
	COUNT(DISTINCT fu.website_session_id) AS sessions,
    COUNT(DISTINCT bs.website_session_id) AS bounced_sessions,
    COUNT(DISTINCT bs.website_session_id) / COUNT(DISTINCT fu.website_session_id) * 100 AS bounce_session_rate
FROM 
	first_url_view fu LEFT JOIN bounced_sessions_only bs
		ON fu.website_session_id = bs.website_session_id
WHERE
	fu.entry_page IN ('/home', '/lander-1')
GROUP BY 
	YEAR(fu.start_of_the_week),
    WEEK(fu.start_of_the_week),
    fu.entry_page;
    
    
# Lander1 vs Lander2 Conversion Funnels
SELECT DISTINCT(pageview_url)
FROM website_pageviews;

# Lander 1
SELECT 
	pageview_url,
    MIN(created_at),
    MAX(created_at)
FROM
	website_pageviews
WHERE
	pageview_url = '/lander-1'; # 9 Months
    

DROP TABLE IF EXISTS lander1_conversion_funnels;
CREATE TEMPORARY TABLE lander1_conversion_funnels
SELECT 
	website_session_id,
	MAX(products_page) AS products_page,
    MAX(mr_fuzzy_page) AS mr_fuzzy_page,
    MAX(cart_page) AS cart_page,
    MAX(shipping_page) AS shipping_page,
    MAX(billing_page) AS billing_page,
    MAX(thank_you_page) AS thank_you_page
FROM
(
	SELECT 
		ws.website_session_id,
		wp.pageview_url,
		CASE WHEN wp.pageview_url = '/products' THEN 1 ELSE 0 END AS products_page,
		CASE WHEN wp.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mr_fuzzy_page,
		CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
		CASE WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
		CASE WHEN wp.pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
		CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thank_you_page
	FROM
		website_sessions ws LEFT JOIN website_pageviews wp
			ON ws.website_session_id = wp.website_session_id
	WHERE 
		pageview_url IN ('/lander-1', '/products', '/the-original-mr-fuzzy', '/cart', '/shipping', '/billing', '/thank-you-for-your-order')
        AND ws.utm_source = 'gsearch'
        AND ws.utm_campaign = 'nonbrand'
		AND wp.created_at BETWEEN '2012-06-19' AND '2013-03-10'
	GROUP BY
		ws.website_session_id,
        wp.pageview_url
) AS pageview_level
GROUP BY 	
	website_session_id;
    
    
SELECT
	COUNT(DISTINCT website_session_id) AS total_sessions,
    COUNT(DISTINCT CASE WHEN products_page = 1 THEN website_session_id ELSE NULL END) AS to_products_page,
    COUNT(DISTINCT CASE WHEN mr_fuzzy_page = 1 THEN website_session_id ELSE NULL END) AS to_mr_fuzzy_page,
	COUNT(DISTINCT CASE WHEN cart_page = 1 THEN website_session_id ELSE NULL END) AS to_cart_page,
	COUNT(DISTINCT CASE WHEN shipping_page  = 1 THEN website_session_id ELSE NULL END) AS to_shipping_page,
	COUNT(DISTINCT CASE WHEN billing_page = 1 THEN website_session_id ELSE NULL END) AS to_billing_page,
	COUNT(DISTINCT CASE WHEN thank_you_page  = 1 THEN website_session_id ELSE NULL END) AS to_thank_you_page
FROM
	lander1_conversion_funnels;


# Lander-2
SELECT
	pageview_url,
    MIN(created_at),
    MAX(created_at)
FROM
	website_pageviews
WHERE
	pageview_url = '/lander-2'; # 23 Months

DROP TABLE IF EXISTS lander2_conversion_funnels;
CREATE TEMPORARY TABLE lander2_conversion_funnels
SELECT 
	website_session_id,
    MAX(product_page) AS product_page,
    MAX(mr_fuzzy_page) AS mr_fuzzy_page,
    MAX(cart_page) AS cart_page,
    MAX(shipping_page) AS shipping_page,
    MAX(billing_page) AS billing_page,
    MAX(thank_you_page) AS thank_you_page
FROM
	(
		SELECT 
			ws.website_session_id,
			wp.pageview_url,
			ws.created_at AS pageview_created_at,    
			CASE WHEN wp.pageview_url = '/products' THEN 1 ELSE 0 END AS product_page,
			CASE WHEN wp.pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mr_fuzzy_page,
			CASE WHEN wp.pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
            CASE WHEN wp.pageview_url = '/shipping' THEN 1 ELSE 0 END AS shipping_page,
            CASE WHEN wp.pageview_url = '/billing' THEN 1 ELSE 0 END AS billing_page,
            CASE WHEN wp.pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS thank_you_page
		FROM 
			website_sessions ws LEFT JOIN website_pageviews wp
				ON ws.website_session_id = wp.website_session_id
		WHERE 
			utm_source = 'gsearch'
            AND utm_campaign = 'nonbrand'
            AND wp.pageview_url IN ('/lander-2', '/products', '/the-original-mr-fuzzy', '/cart', '/shipping', '/billing', '/thank-you-for-your-order')
            AND ws.created_at BETWEEN '213-01-14' AND '2014-12-27'
		GROUP BY
			ws.website_session_id,
			wp.pageview_url,
			ws.created_at
	) AS pageview_level
GROUP BY 
	website_session_id;
    

# Lander-1 vs Lander-2
	SELECT 
		COUNT(DISTINCT website_session_id) AS total_sessions,
		COUNT(DISTINCT CASE WHEN products_page = 1 THEN website_session_id ELSE 0 END) AS to_products,
		COUNT(DISTINCT CASE WHEN mr_fuzzy_page = 1 THEN website_session_id ELSE 0 END) AS to_mr_fuzzy,
		COUNT(DISTINCT CASE WHEN cart_page = 1 THEN website_session_id ELSE 0 END) AS to_cart_page,
		COUNT(DISTINCT CASE WHEN shipping_page = 1 THEN website_session_id ELSE 0 END) AS to_shipping_page,
		COUNT(DISTINCT CASE WHEN billing_page = 1 THEN website_session_id ELSE 0 END) to_billing_page,
		COUNT(DISTINCT CASE WHEN thank_you_page = 1 THEN website_session_id ELSE 0 END) AS to_thank_you_page
	FROM 
		lander1_conversion_funnels
UNION
	SELECT 
		COUNT(DISTINCT website_session_id) AS total_sessions,
		COUNT(DISTINCT CASE WHEN product_page = 1 THEN website_session_id ELSE 0 END) AS to_products,
		COUNT(DISTINCT CASE WHEN mr_fuzzy_page = 1 THEN website_session_id ELSE 0 END) AS to_mr_fuzzy,
		COUNT(DISTINCT CASE WHEN cart_page = 1 THEN website_session_id ELSE 0 END) AS to_cart_page,
		COUNT(DISTINCT CASE WHEN shipping_page = 1 THEN website_session_id ELSE 0 END) AS to_shipping_page,
		COUNT(DISTINCT CASE WHEN billing_page = 1 THEN website_session_id ELSE 0 END) to_billing_page,
		COUNT(DISTINCT CASE WHEN thank_you_page = 1 THEN website_session_id ELSE 0 END) AS to_thank_you_page
	FROM 
		lander2_conversion_funnels;

# Billing-1 vs Billing-2
SELECT 
	pageview_url,
    MIN(created_at),
    MAX(created_at)
FROM 
	website_pageviews
WHERE
	pageview_url = '/billing'; #2012-09-10 - 2013-01-05


SELECT
	billing_version_seen,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id) / COUNT(DISTINCT website_session_id) * 100 AS billing_to_orders_ratio
FROM
(
	SELECT
		wp.website_session_id,
		o.order_id,
		wp.pageview_url AS billing_version_seen
	FROM
		website_pageviews wp LEFT JOIN orders o
			ON wp.website_session_id = o.website_session_id
	WHERE 
		wp.pageview_url IN ('/billing', '/billing-2')
		AND wp.created_at BETWEEN '2012-09-10' AND '2013-01-05'
	GROUP BY
		wp.website_session_id,
		wp.pageview_url,
		o.order_id
) AS billing_sessions
GROUP BY
	billing_version_seen;

