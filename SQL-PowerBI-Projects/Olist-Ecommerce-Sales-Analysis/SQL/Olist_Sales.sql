CREATE DATABASE Olist_Sales
USE Olist_Sales

--Identrify NULL Values

;WITH XMLNAMESPACES('http://www.w3.org/2001/XMLSchema-instance' as ns)
SELECT *
FROM  olist_customers
WHERE  (SELECT olist_customers.*
        FOR xml path('row'), elements xsinil, type
        ).value('count(//*[local-name() != "colToIgnore"]/@ns:nil)', 'int') > 0  -- No Null Values
---
;WITH XMLNAMESPACES('http://www.w3.org/2001/XMLSchema-instance' as ns)
SELECT *
FROM  olist_sellers
WHERE  (SELECT olist_sellers.*
        FOR xml path('row'), elements xsinil, type
        ).value('count(//*[local-name() != "colToIgnore"]/@ns:nil)', 'int') > 0 -- No Null Values
---

;WITH XMLNAMESPACES('http://www.w3.org/2001/XMLSchema-instance' as ns)
SELECT *
FROM  olist_order_items
WHERE  (SELECT olist_order_items.*
        FOR xml path('row'), elements xsinil, type
        ).value('count(//*[local-name() != "colToIgnore"]/@ns:nil)', 'int') > 0 -- No Null Values

---
SELECT
    SUM(CASE WHEN geolocation_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS geo_zip_null,
    SUM(CASE WHEN geolocation_city IS NULL THEN 1 ELSE 0 END) AS geo_city_null,
    SUM(CASE WHEN geolocation_state IS NULL THEN 1 ELSE 0 END) AS geo_state_null,
    SUM(CASE WHEN geolocation_lat IS NULL THEN 1 ELSE 0 END) AS geo_lat_null,				-- 0.13%
	SUM(CASE WHEN geolocation_lng IS NULL THEN 1 ELSE 0 END) AS geo_lng_null
FROM olist_geolocation

---
;WITH XMLNAMESPACES('http://www.w3.org/2001/XMLSchema-instance' as ns)
SELECT *
FROM  olist_order_payments
WHERE  (SELECT olist_order_payments.*
        FOR xml path('row'), elements xsinil, type
        ).value('count(//*[local-name() != "colToIgnore"]/@ns:nil)', 'int') > 0 -- No Null Values

---
SELECT
    SUM(CASE WHEN review_id IS NULL THEN 1 ELSE 0 END) AS review_id_null,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS order_id_null,
    SUM(CASE WHEN review_score IS NULL THEN 1 ELSE 0 END) AS review_score_null,
    SUM(CASE WHEN review_comment_title IS NULL THEN 1 ELSE 0 END) AS review_commentT_null,				-- 88.34%
	SUM(CASE WHEN review_comment_message IS NULL THEN 1 ELSE 0 END) AS review_commentM_null,			-- 58.71%
	SUM(CASE WHEN review_creation_date IS NULL THEN 1 ELSE 0 END) AS review_creationD_null,
	SUM(CASE WHEN review_answer_timestamp IS NULL THEN 1 ELSE 0 END) AS review_answerT_null
FROM olist_order_reviews

---
SELECT
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS orderID_null,
    SUM(CASE WHEN order_status IS NULL THEN 1 ELSE 0 END) AS orderStatus_null,
    SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END) AS order_pur_null,
    SUM(CASE WHEN order_approved_at IS NULL THEN 1 ELSE 0 END) AS order_app_null,							-- 0.16%
	SUM(CASE WHEN order_delivered_carrier_date IS NULL THEN 1 ELSE 0 END) AS order_delCarries_null,			-- 1.79%
	SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS order_delCustomer_null,		-- 2.98%
	SUM(CASE WHEN order_estimated_delivery_date IS NULL THEN 1 ELSE 0 END) AS order_est_null
FROM olist_orders

---
SELECT
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS p_id,
    SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) AS p_category,							-- 1.85%
    SUM(CASE WHEN product_name_lenght IS NULL THEN 1 ELSE 0 END) AS p_name,									-- 1.85%
    SUM(CASE WHEN product_description_lenght IS NULL THEN 1 ELSE 0 END) AS p_description,					-- 1.85%
	SUM(CASE WHEN product_photos_qty IS NULL THEN 1 ELSE 0 END) AS p_photos,								-- 1.85%
	SUM(CASE WHEN product_weight_g IS NULL THEN 1 ELSE 0 END) AS p_weight,									
	SUM(CASE WHEN product_length_cm IS NULL THEN 1 ELSE 0 END) AS p_len,
	SUM(CASE WHEN product_height_cm IS NULL THEN 1 ELSE 0 END) AS p_hight,
	SUM(CASE WHEN product_width_cm IS NULL THEN 1 ELSE 0 END) AS p_width
FROM olist_products

--------------------------------------------------------------------------------
-- Data Cleaning

SELECT DISTINCT(product_category_name) 
FROM olist_products

SELECT DISTINCT product_category_name
FROM olist_products
WHERE product_category_name NOT IN (SELECT spanish_name FROM product_category_name_translation);

SELECT COUNT(*) 
FROM olist_products
WHERE product_category_name = 'pc_gamer'	--3 records

SELECT COUNT(*) 
FROM olist_products
WHERE product_category_name = 'portateis_cozinha_e_preparadores_de_alimentos'	-- 10 records

BEGIN TRANSACTION
UPDATE olist_products
SET product_category_name = null 
WHERE product_category_name = 'pc_gamer' OR
	  product_category_name = 'portateis_cozinha_e_preparadores_de_alimentos'
COMMIT

ALTER TABLE olist_products
ADD CONSTRAINT FK_olist_products_product_category_name_translation
FOREIGN KEY (product_category_name)
REFERENCES product_category_name_translation (spanish_name);

ALTER TABLE olist_products
ADD product_category_name_english NVARCHAR(50)

UPDATE op
SET op. product_category_name_english = pct.english_name
FROM olist_products op
JOIN product_category_name_translation pct ON op.product_category_name = pct.spanish_name;

SELECT COUNT(product_category_name_english), COUNT(product_category_name)
FROM olist_products

--------------------------------------------------------------------------------
--KPI's and Exploration

SELECT COUNT(customer_id) AS Total_Customers
FROM olist_customers

SELECT COUNT(DISTINCT(customer_city)) AS Total_Cities
FROM olist_customers

SELECT customer_city, COUNT(customer_state) AS Total_States
FROM olist_customers
GROUP BY customer_city
ORDER BY COUNT(customer_state) DESC

---

SELECT COUNT(order_id) AS Total_Orders
FROM olist_order_items

SELECT ROUND(SUM(price),2) AS Orders_Revenue
FROM olist_order_items

SELECT ROUND(SUM(price) + SUM(freight_value), 2) 
FROM olist_order_items

---

SELECT DISTINCT(payment_type), COUNT(payment_type) AS Number_of_Payments
FROM olist_order_payments
GROUP BY payment_type

SELECT MAX(payment_installments) AS Max, 
	   MIN(payment_installments) AS Min, 
	   AVG(payment_installments) AS Average
FROM olist_order_payments

SELECT MAX(payment_sequential) AS Max, 
	   MIN(payment_sequential) AS Min, 
	   AVG(payment_sequential) AS Average
FROM olist_order_payments

SELECT COUNT(order_id) AS Total_Orders, YEAR(order_purchase_timestamp) AS Year
FROM olist_orders
GROUP BY YEAR(order_purchase_timestamp)

---

SELECT MAX(review_score) AS Max, 
	   MIN(review_score) AS Min, 
	   AVG(review_score) AS Average
FROM olist_order_reviews

SELECT AVG(DATEDIFF(DAY, review_creation_date, review_answer_timestamp )) AS Days_Between
FROM olist_order_reviews

SELECT COUNT(review_id) AS Total_Reviews, YEAR(review_creation_date) AS Year
FROM olist_order_reviews
GROUP BY YEAR(review_creation_date)

---

SELECT COUNT(product_id) AS Total_Products
FROM olist_products

SELECT COUNT(DISTINCT(product_category_name_english)) AS Total_Categories
FROM olist_products

SELECT product_category_name_english ,COUNT(product_id) AS Total_Products
FROM olist_products
GROUP BY product_category_name_english
ORDER BY COUNT(product_id) DESC

---

SELECT AVG(DATEDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date))
FROM olist_orders

SELECT AVG(DATEDIFF(DAY, order_purchase_timestamp, order_delivered_carrier_date))
FROM olist_orders

SELECT AVG(DATEDIFF(DAY, order_delivered_carrier_date, order_delivered_customer_date))
FROM olist_orders

SELECT AVG(DATEDIFF(DAY, order_delivered_customer_date, order_estimated_delivery_date))
FROM olist_orders

---

SELECT MAX(product_weight_g) AS Max, 
	   MIN(product_weight_g) AS Min, 
	   AVG(product_weight_g) AS Average
FROM olist_products
WHERE product_weight_g IS NOT NULL

SELECT MAX(product_length_cm) AS Max, 
	   MIN(product_length_cm) AS Min, 
	   AVG(product_length_cm) AS Average
FROM olist_products
WHERE product_length_cm IS NOT NULL

SELECT MAX(product_height_cm) AS Max, 
	   MIN(product_height_cm) AS Min, 
	   AVG(product_height_cm) AS Average
FROM olist_products
WHERE product_height_cm IS NOT NULL

SELECT MAX(product_width_cm) AS Max, 
	   MIN(product_width_cm) AS Min, 
	   AVG(product_width_cm) AS Average
FROM olist_products
WHERE product_width_cm IS NOT NULL

SELECT MAX(product_photos_qty) AS Max, 
	   MIN(product_photos_qty) AS Min, 
	   AVG(product_photos_qty) AS Average
FROM olist_products
WHERE product_photos_qty IS NOT NULL

---

SELECT COUNT(seller_id)
FROM olist_sellers

SELECT seller_city, COUNT(seller_id) AS Number_of_Sellers
FROM olist_sellers
GROUP BY seller_city
ORDER BY COUNT(seller_id) DESC

--------------------------------------------------------------------------------
-- Analysis

SELECT product_category_name_english , ROUND(AVG(price),2) AS Average_Price
FROM olist_order_items O INNER JOIN olist_products P
ON O.product_id = P.product_id
GROUP BY product_category_name_english
HAVING product_category_name_english IS NOT NULL
ORDER BY ROUND(AVG(price),2) DESC

SELECT product_category_name_english , COUNT(order_id) AS Total_Orders
FROM olist_order_items O INNER JOIN olist_products P
ON O.product_id = P.product_id
GROUP BY product_category_name_english
HAVING product_category_name_english IS NOT NULL
ORDER BY COUNT(order_id) DESC

SELECT AVG(freight_value) Average_Freight_Value, product_category_name_english 
FROM olist_order_items O INNER JOIN olist_products P
ON O.product_id = P.product_id
GROUP BY product_category_name_english
HAVING product_category_name_english IS NOT NULL
ORDER BY AVG(freight_value) DESC

-- Reviews
SELECT DISTINCT(review_score), COUNT(review_score) AS Total_Reviews
FROM olist_order_reviews
GROUP BY review_score
ORDER BY COUNT(review_score)

SELECT product_category_name_english,
	   COUNT(review_id) AS Total_Reviews,  
	   ROUND(AVG(price),2) AS Average_Price 
FROM olist_order_items O 
	 INNER JOIN olist_products P ON P.product_id = O.product_id 
	 INNER JOIN olist_order_reviews R ON R.order_id = O.order_id 
WHERE review_score IN (1, 2, 3)
      AND product_category_name_english IS NOT NULL
GROUP BY product_category_name_english
ORDER BY COUNT(review_id) DESC


SELECT review_score, 
	   DATEDIFF(DAY, order_estimated_delivery_date, order_delivered_customer_date) AS Late_Delivery, 
	   COUNT(O.order_id) AS Total_Orders
FROM olist_order_reviews R INNER JOIN olist_orders O
ON R.order_id = O.order_id
WHERE review_score IN (1,2)
      AND order_estimated_delivery_date IS NOT NULL
      AND order_delivered_customer_date IS NOT NULL
	  AND DATEDIFF(DAY, order_estimated_delivery_date, order_delivered_customer_date) > 0
GROUP BY review_score,
		 DATEDIFF(DAY, order_estimated_delivery_date, order_delivered_customer_date)
ORDER BY review_score, COUNT(O.order_id) DESC


--- Payments
SELECT ROUND(AVG(payment_value),2) AS Average_Payment_Value, payment_installments 
FROM olist_order_payments
GROUP BY payment_installments
ORDER BY payment_installments

SELECT ROUND(AVG(CONVERT(FLOAT,order_item_id)),2) AS Order_Quantity, payment_installments 
FROM olist_order_items O INNER JOIN olist_order_payments P
ON O.order_id = P.order_id
GROUP BY payment_installments

SELECT customer_city,
	   COUNT(review_score) AS Total_Reviews, 
	   AVG(DATEDIFF(DAY, order_estimated_delivery_date, order_delivered_customer_date)) AS Late_Delivery_in_Days
FROM olist_customers C INNER JOIN olist_orders O
ON C.customer_id = O.customer_id INNER JOIN olist_order_reviews R
ON O.order_id = R.order_id
WHERE review_score IN (1,2) 
	  AND DATEDIFF(DAY, order_estimated_delivery_date, order_delivered_customer_date) > 0
GROUP BY customer_city
ORDER BY COUNT(review_score) DESC
---

--Sellers
SELECT COUNT(DISTINCT S.seller_id) AS N_of_Sellers,
	   seller_city, 
	   COUNT(O.order_id) AS N_of_Orders
FROM olist_orders O INNER JOIN olist_order_items I
ON O.order_id = I.order_id INNER JOIN olist_sellers S
ON i.seller_id = S.seller_id
GROUP BY seller_city
ORDER BY COUNT(O.order_id) DESC

SELECT 
    COUNT(I.order_id) AS Total_Orders, 
    I.seller_id, 
    AVG(R.review_score) AS Average_Review_Score
FROM olist_order_items I INNER JOIN olist_order_reviews R 
	 ON I.order_id = R.order_id
WHERE R.review_score IN (1, 2)
GROUP BY I.seller_id
ORDER BY Total_Orders DESC;
