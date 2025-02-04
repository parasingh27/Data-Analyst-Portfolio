Create DATABASE Pizza_Store
USE Pizza_Store

SELECT * FROM Pizza_Store..pizza_sales

-- KPI'S


SELECT CAST(SUM(total_price) AS DECIMAL(10,2)) AS Total_Revenue
FROM Pizza_Store..pizza_sales

SELECT SUM(total_price) / COUNT(DISTINCT order_id)  AS Average_Order_Value
FROM Pizza_Store..pizza_sales

SELECT SUM(quantity) AS Total_Pizza_Sold
From Pizza_Store..pizza_sales

SELECT COUNT(DISTINCT order_id) AS Total_Orders
FROM Pizza_Store..pizza_sales

SELECT CAST(SUM(quantity) / COUNT(DISTINCT order_id) AS DECIMAL(10,2)) AS Average_Pizza_Per_Order
FROM Pizza_Store..pizza_sales

-- Charts Requirments

SELECT DATENAME(DW, order_date) AS Order_Day, COUNT(DISTINCT order_id) AS Total_Orders
FROM Pizza_Store..pizza_sales
GROUP BY  DATENAME(DW, order_date)

SELECT DATENAME(MONTH , order_date) AS Month, COUNT(DISTINCT order_id) AS Total_Orders
FROM Pizza_Store..pizza_sales
GROUP BY DATENAME(MONTH, order_date)

SELECT pizza_category, CAST(sum(total_price) *100 / (SELECT SUM(total_price) FROM Pizza_Store..pizza_sales) AS DECIMAL(10,2)) AS Sale_Percentage
FROM Pizza_Store..pizza_sales 
GROUP BY pizza_category

SELECT pizza_size, CAST(sum(total_price) *100 / (SELECT SUM(total_price) FROM Pizza_Store..pizza_sales) AS DECIMAL(10,2)) AS Sale_Percentage
FROM Pizza_Store..pizza_sales 
GROUP BY pizza_size
ORDER BY Sale_Percentage 

SELECT TOP 5 pizza_name, cast(SUM(total_price) AS DECIMAL(10,2)) AS Total_Revenue
FROM Pizza_Store..pizza_sales
GROUP BY pizza_name
ORDER BY Total_Revenue DESC

SELECT TOP 5 pizza_name, cast(SUM(total_price) AS DECIMAL(10,2)) AS Total_Revenue
FROM Pizza_Store..pizza_sales
GROUP BY pizza_name
ORDER BY Total_Revenue 

SELECT TOP 5 pizza_name, SUM(quantity) AS Total_Quantity
FROM Pizza_Store..pizza_sales
GROUP BY pizza_name
ORDER BY Total_Quantity DESC 

SELECT TOP 5 pizza_name, SUM(quantity) AS Total_Quantity
FROM Pizza_Store..pizza_sales
GROUP BY pizza_name
ORDER BY Total_Quantity

SELECT TOP 5 pizza_name, cast(COUNT(DISTiNCT order_id) AS DECIMAL(10,2)) AS Total_Ordered
FROM Pizza_Store..pizza_sales
GROUP BY pizza_name
ORDER BY Total_Ordered DESC

SELECT TOP 5 pizza_name, cast(COUNT(DISTiNCT order_id) AS DECIMAL(10,2)) AS Total_Ordered
FROM Pizza_Store..pizza_sales
GROUP BY pizza_name
ORDER BY Total_Ordered



