CREATE DATABASE Video_Game_Analysis
USE Video_Game_Analysis

-- Identify Null Values
SELECT 
    SUM(CASE WHEN Game IS NULL THEN 1 ELSE 0 END) AS null_count_game,
    SUM(CASE WHEN Year IS NULL THEN 1 ELSE 0 END) AS null_count_year,					--209 / 20.2%
	SUM(CASE WHEN Genre IS NULL THEN 1 ELSE 0 END) AS null_count_genre,
	SUM(CASE WHEN Publisher IS NULL THEN 1 ELSE 0 END) AS null_count_publisher,			--209 / 20.2%
	SUM(CASE WHEN North_America IS NULL THEN 1 ELSE 0 END) AS null_count_North_America,
	SUM(CASE WHEN Europe IS NULL THEN 1 ELSE 0 END) AS null_count_North_Europe,
	SUM(CASE WHEN Japan IS NULL THEN 1 ELSE 0 END) AS null_count_North_Japan,
	SUM(CASE WHEN Rest_of_World IS NULL THEN 1 ELSE 0 END) AS null_count_world,			--457 / 44.2%
	SUM(CASE WHEN Global IS NULL THEN 1 ELSE 0 END) AS null_count_global				--322 / 31.1%
FROM PS4_GamesSales
---
SELECT 
    SUM(CASE WHEN Game IS NULL THEN 1 ELSE 0 END) AS null_count_game,
    SUM(CASE WHEN Year IS NULL THEN 1 ELSE 0 END) AS null_count_year, 
	SUM(CASE WHEN Genre IS NULL THEN 1 ELSE 0 END) AS null_count_genre,
	SUM(CASE WHEN Publisher IS NULL THEN 1 ELSE 0 END) AS null_count_publisher,			--108  // 17.6%
	SUM(CASE WHEN North_America IS NULL THEN 1 ELSE 0 END) AS null_count_North_America,
	SUM(CASE WHEN Europe IS NULL THEN 1 ELSE 0 END) AS null_count_North_Europe,
	SUM(CASE WHEN Japan IS NULL THEN 1 ELSE 0 END) AS null_count_North_Japan,
	SUM(CASE WHEN Rest_of_World IS NULL THEN 1 ELSE 0 END) AS null_count_world, 
	SUM(CASE WHEN Global IS NULL THEN 1 ELSE 0 END) AS null_count_global 
FROM XboxOne_GameSales
---
SELECT 
    SUM(CASE WHEN Name IS NULL THEN 1 ELSE 0 END) AS null_count_name,
    SUM(CASE WHEN Platform IS NULL THEN 1 ELSE 0 END) AS null_count_platform, 
	SUM(CASE WHEN Genre IS NULL THEN 1 ELSE 0 END) AS null_count_genre,
	SUM(CASE WHEN Year_of_Release IS NULL THEN 1 ELSE 0 END) AS null_count_release_year,
	SUM(CASE WHEN Genre IS NULL THEN 1 ELSE 0 END) AS null_count_Genre,
	SUM(CASE WHEN Na_Sales IS NULL THEN 1 ELSE 0 END) AS null_count_NA,
	SUM(CASE WHEN EU_Sales IS NULL THEN 1 ELSE 0 END) AS null_count_EU,
	SUM(CASE WHEN JP_Sales IS NULL THEN 1 ELSE 0 END) AS null_count_Japan, 
	SUM(CASE WHEN Other_Sales IS NULL THEN 1 ELSE 0 END) AS null_count_Other_Sales, 
	SUM(CASE WHEN Global_Sales IS NULL THEN 1 ELSE 0 END) AS null_count_global,
	SUM(CASE WHEN Critic_Score IS NULL THEN 1 ELSE 0 END) AS null_count_critic_score, -- 8582 / 51.3%
	SUM(CASE WHEN Critic_Count IS NULL THEN 1 ELSE 0 END) AS null_count_critic_count, -- 8582 / 51.3%
	SUM(CASE WHEN User_Score IS NULL THEN 1 ELSE 0 END) AS null_count_user_score,     -- 9129 / 54.6%
	SUM(CASE WHEN User_Count IS NULL THEN 1 ELSE 0 END) AS null_count_user_count,     -- 9129 / 54.6%
	SUM(CASE WHEN Developer IS NULL THEN 1 ELSE 0 END) AS null_count_global,          -- 6623 / 39.6%
	SUM(CASE WHEN Rating IS NULL THEN 1 ELSE 0 END) AS null_count_global              -- 6769 / 40.5%
FROM Video_GamesSales   
------------------------------------------

-- Data Cleaning
ALTER TABLE XboxOne_GameSales
ALTER COLUMN Europe FLOAT;

ALTER TABLE XboxOne_GameSales
ALTER COLUMN Japan FLOAT;

ALTER TABLE XboxOne_GameSales
ALTER COLUMN Rest_of_World FLOAT;

ALTER TABLE XboxOne_GameSales
ALTER COLUMN Global FLOAT;
------------------------------------------------

--PS4
SELECT TOP 1 Game, 
	ROUND(Global,2) AS Total_Revenue
FROM PS4_GamesSales
ORDER BY Global DESC

SELECT TOP 1 Genre, 
	ROUND(SUM(Global),2) AS Total_Revenue
FROM PS4_GamesSales
GROUP BY Genre
ORDER BY SUM(Global) DESC

SELECT ROUND(SUM(North_America),2) AS Revenue_in_NA,
	ROUND(SUM(Europe),2) AS Revenue_in_EU,
	ROUND(SUM(Japan),2) AS Revenue_in_JP,
	ROUND(SUM(Rest_of_World),2) AS Revenue_in_Other,
	ROUND(SUM(Global),2) AS Global_Revenue
FROM PS4_GamesSales

SELECT Publisher, 
	COUNT(Publisher) AS Total_Publishes
FROM PS4_GamesSales
GROUP BY Publisher
ORDER BY COUNT(Publisher) DESC 

SELECT Genre,
	COUNT(Genre) AS N_of_Games
FROM PS4_GamesSales
GROUP BY Genre
ORDER BY COUNT(Genre) DESC

SELECT Year, 
	COUNT(Game) AS N_Games
FROM PS4_GamesSales
GROUP BY Year 
ORDER BY Year

SELECT Genre, 
	ROUND(SUM(Global),2) AS Total_Revenue,
	COUNT(Game) AS N_Games
FROM PS4_GamesSales
GROUP BY Genre
ORDER BY SUM(Global) DESC
-----------------------------------------------------

-- Xbox
SELECT TOP 1 Game, 
	Global AS Total_Revenue
FROM XboxOne_GameSales
ORDER BY Global DESC

SELECT TOP 1 Genre, 
	ROUND(SUM(Global),2) AS Total_Revenue
FROM XboxOne_GameSales
GROUP BY Genre
ORDER BY SUM(Global) DESC

SELECT ROUND(SUM(North_America),2) AS Revenue_in_NA,
	ROUND(SUM(Europe),2) AS Revenue_in_EU,
	ROUND(SUM(Japan),2) AS Revenue_in_JP,
	ROUND(SUM(Rest_of_World),2) AS Revenue_in_Other,
	ROUND(SUM(Global),2) AS Global_Revenue
FROM XboxOne_GameSales

SELECT Publisher, COUNT(Publisher) AS Total_Publishes
FROM XboxOne_GameSales
GROUP BY Publisher
ORDER BY COUNT(Publisher) DESC 

SELECT Genre, COUNT(Genre) AS N_of_Genres
FROM XboxOne_GameSales
GROUP BY Genre
ORDER BY COUNT(Genre) DESC

SELECT Year, 
	COUNT(Game) AS N_Games
FROM XboxOne_GameSales
GROUP BY Year 
ORDER BY Year

SELECT Genre, 
	ROUND(SUM(Global),2) AS Total_Revenue,
	COUNT(Game) AS N_Games
FROM XboxOne_GameSales
GROUP BY Genre
ORDER BY SUM(Global) DESC
----------------------------------------------------------------

--Video Games
SELECT * FROM Video_GamesSales

SELECT TOP 1 Name, Global_Sales 
FROM Video_GamesSales
ORDER BY Global_Sales DESC

SELECT TOP 1 Genre, 
	ROUND(SUM(Global_Sales),2) AS Total_Revenue
FROM Video_GamesSales
GROUP BY Genre
ORDER BY SUM(Global_Sales) DESC

SELECT ROUND(SUM(NA_Sales),2) AS Revenue_in_NA,
	ROUND(SUM(EU_Sales),2) AS Revenue_in_EU,
	ROUND(SUM(JP_Sales),2) AS Revenue_in_JP,
	ROUND(SUM(Other_Sales),2) AS Revenue_in_Other,
	ROUND(SUM(Global_Sales),2) AS Global_Revenue
FROM Video_GamesSales

SELECT Genre, 
	COUNT(Genre) AS N_Games,
	COUNT(User_Count) AS Total_Users,
	ROUND(SUM(Global_Sales),2) AS Total_Revenue,
	ROUND(AVG(User_Score),2) AS Average_User_Score
FROM Video_GamesSales
GROUP BY Genre
ORDER BY COUNT(Genre) DESC

SELECT Year_of_Release,
	COUNT(Name) AS N_Games,
	COUNT(User_Count) AS Total_Users,
	ROUND(SUM(Global_Sales),2) AS Total_Revenue
FROM Video_GamesSales
GROUP BY Year_of_Release
ORDER BY Year_of_Release

SELECT Platform,
	COUNT(Name) AS N_Games,
	COUNT(User_Count) AS Total_Users,
	ROUND(AVG(User_Score),2) AS Average_Score
FROM Video_GamesSales
GROUP BY Platform
ORDER BY COUNT(Name) DESC