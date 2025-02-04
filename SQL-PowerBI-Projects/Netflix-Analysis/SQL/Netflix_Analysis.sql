
CREATE DATABASE Netflix_Analysis
USE Netflix_Analysis

SELECT * FROM netflix_titles

SELECT COUNT(*) 
FROM netflix_titles

SELECT COUNT(*)
FROM netflix_titles
WHERE director IS NULL
/*
24 'titles' in the dataset have null values.		(0.27%) Low Bais
2634 'director' in the dataset have null values.    (29,9%) High Bais
831 'country' in the dataset have null values.		(9.43%) High Bais
0 'release year' in the dataset have null values.
3 'duration' in the dataset have null values.		(0.03%) No Bais
0 'listed in' in the dataset have null values.			
825 'cast' in the dataset have null values.			(9.36%) High Bais
0 'type' in the dataset have null values.
*/
--
SELECT type, COUNT(*) AS count, COUNT(*) * 100.0 / (SELECT COUNT(*) FROM netflix_titles) AS percentage
FROM netflix_titles
GROUP BY type;

CREATE VIEW TOP10_Countries_inProduction AS
SELECT TOP 10 country, COUNT(title) AS title_count
FROM netflix_titles
WHERE country IS NOT NULL
GROUP BY country
ORDER BY title_count DESC

--
ALTER TABLE netflix_titles 
ADD movie_duration INT

UPDATE netflix_titles
SET movie_duration = CAST(SUBSTRING(duration, 1, CHARINDEX(' ', duration) - 1) AS INT)
WHERE type = 'Movie'

SELECT COUNT(movie_duration) - COUNT(duration)
FROM netflix_titles
WHERE type = 'Movie'

-- Functions
SELECT title, movie_duration
FROM netflix_titles
WHERE movie_duration = (
    SELECT MAX(movie_duration)
    FROM netflix_titles
    WHERE type = 'Movie'  
)

CREATE VIEW Average_Movie_Duration AS
SELECT AVG(movie_duration) AS average_movie_duration
FROM netflix_titles

SELECT title, movie_duration
FROM netflix_titles
WHERE movie_duration = (
    SELECT MIN(movie_duration)
    FROM netflix_titles
    WHERE type = 'Movie'  
)


-- To make sure all tv shows are in seasons
SELECT duration 
FROM netflix_titles
WHERE type = 'TV Show' AND duration NOT LIKE '%Seasons' AND duration NOT LIKE '%Season'

ALTER TABLE netflix_titles 
ADD tv_show_duration INT

UPDATE netflix_titles
SET tv_show_duration = CAST(SUBSTRING(duration, 1, CHARINDEX(' ', duration) - 1) AS INT)
WHERE type = 'TV Show'

SELECT COUNT(tv_show_duration) - COUNT(duration)
FROM netflix_titles
WHERE type = 'TV Show'

-- Functions
SELECT title, tv_show_duration
FROM netflix_titles
WHERE tv_show_duration = (
    SELECT MAX(tv_show_duration)
    FROM netflix_titles
    WHERE type = 'TV Show'
)

CREATE VIEW Average_TvShows_Duration_inSeasons AS
SELECT AVG(tv_show_duration) AS average_TvShow_duration
FROM netflix_titles

SELECT title, tv_show_duration
FROM netflix_titles
WHERE tv_show_duration = (
    SELECT MIN(tv_show_duration)
    FROM netflix_titles
    WHERE type = 'TV Show'
)

-- Years
CREATE VIEW Trending_Years AS 
SELECT TOP 10 COUNT(show_id) as 'Count', release_year
FROM netflix_titles
WHERE show_id IS NOT NULL
GROUP BY release_year
ORDER BY Count DESC;

-- Months
ALTER TABLE netflix_titles
ADD month_added INT

UPDATE netflix_titles
SET month_added = MONTH(date_added)

SELECT * FROM netflix_titles

CREATE VIEW Trending_Months AS
SELECT TOP 12 COUNT(show_id) as 'Count', month_added
FROM netflix_titles
WHERE show_id IS NOT NULL
GROUP BY month_added
ORDER BY Count DESC;

-- Seasons
ALTER TABLE netflix_titles
ADD season_added VARCHAR(10)

UPDATE netflix_titles
SET season_added = 
CASE 
	WHEN MONTH(date_added) IN (12, 1, 2) THEN 'Winter'
	WHEN MONTH(date_added) IN (3, 4, 5) THEN 'Spring'
	WHEN MONTH(date_added) IN (6, 7, 8) THEN 'Summer'
	WHEN MONTH(date_added) IN (9, 10, 11) THEN 'Autumn'
	ELSE 'Unknown'
END;

CREATE VIEW Trending_Seasons AS 
SELECT TOP 4 COUNT(show_id) as 'Count', season_added
FROM netflix_titles
WHERE show_id IS NOT NULL
GROUP BY season_added
ORDER BY Count DESC

-- Rating
SELECT rating AS Movie_Rating, COUNT(rating) AS Count
FROM netflix_titles
WHERE rating IS NOT NULL AND type = 'Movie'
GROUP BY rating

SELECT rating AS TV_Show_Rating, COUNT(rating) AS Count
FROM netflix_titles
WHERE rating IS NOT NULL AND type = 'TV Show'
GROUP BY rating

CREATE VIEW All_Ratings AS
SELECT rating AS Rating, COUNT(rating) AS Count
FROM netflix_titles
WHERE rating IS NOT NULL 
GROUP BY rating

-- Duration By Country
SELECT country, AVG(movie_duration) AS Average_Movie_Duration
FROM netflix_titles
WHERE country IS NOT NULL
GROUP BY country
ORDER BY Average_Duration DESC

SELECT country, AVG(tv_show_duration) AS Average_TV_Duration_inSeason
FROM netflix_titles
WHERE country IS NOT NULL
GROUP BY country
ORDER BY Average_TV_Duration_inSeason DESC

-- Rating count is a specific country
SELECT country AS Country, rating AS Rating, COUNT(rating) AS Count
FROM netflix_titles
WHERE country LIKE 'Egypt'
GROUP BY country, Rating
ORDER BY Count DESC

--  The correlation between the duration of titles and their ratings
SELECT rating, COUNT(*) AS Title_Count, AVG(tv_show_duration) AS Average_Duration, 
	MIN(tv_show_duration) AS Min_Duration, MAX(tv_show_duration) AS Max_Duration
FROM netflix_titles
WHERE rating IS NOT NULL AND type = 'TV Show'
GROUP BY rating;

SELECT rating, COUNT(*) AS title_count, AVG(movie_duration) AS average_duration, 
	MIN(movie_duration) AS min_duration, MAX(movie_duration) AS max_duration
FROM netflix_titles
WHERE rating IS NOT NULL AND type = 'Movie'
GROUP BY rating;

