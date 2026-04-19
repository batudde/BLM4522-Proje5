SELECT 'raw_geoplaces_row_count' AS metric, COUNT(*)::text AS value
FROM raw.geoplaces2
UNION ALL
SELECT 'raw_userprofile_row_count', COUNT(*)::text
FROM raw.userprofile
UNION ALL
SELECT 'raw_rating_final_row_count', COUNT(*)::text
FROM raw.rating_final
UNION ALL
SELECT 'stg_restaurants_row_count', COUNT(*)::text
FROM stg.restaurants
UNION ALL
SELECT 'stg_users_row_count', COUNT(*)::text
FROM stg.users
UNION ALL
SELECT 'stg_ratings_row_count', COUNT(*)::text
FROM stg.ratings
UNION ALL
SELECT 'dw_restaurant_ratings_row_count', COUNT(*)::text
FROM dw.restaurant_ratings;

SELECT
    'restaurants_missing_address' AS metric,
    COUNT(*) AS missing_count
FROM stg.restaurants
WHERE address IS NULL
UNION ALL
SELECT
    'restaurants_missing_city',
    COUNT(*)
FROM stg.restaurants
WHERE city IS NULL
UNION ALL
SELECT
    'restaurants_missing_country',
    COUNT(*)
FROM stg.restaurants
WHERE country IS NULL
UNION ALL
SELECT
    'restaurants_missing_zip_code',
    COUNT(*)
FROM stg.restaurants
WHERE zip_code IS NULL
UNION ALL
SELECT
    'users_missing_budget',
    COUNT(*)
FROM stg.users
WHERE budget IS NULL
UNION ALL
SELECT
    'users_missing_transport',
    COUNT(*)
FROM stg.users
WHERE transport IS NULL;

SELECT
    city,
    COUNT(*) AS restaurant_count,
    ROUND(AVG(overall_rating::numeric), 2) AS avg_rating
FROM dw.restaurant_ratings
GROUP BY city
ORDER BY avg_rating DESC, restaurant_count DESC;

SELECT
    restaurant_name,
    city,
    COUNT(*) AS vote_count,
    ROUND(AVG(overall_rating::numeric), 2) AS avg_rating,
    ROUND(AVG(food_rating::numeric), 2) AS avg_food_rating,
    ROUND(AVG(service_rating::numeric), 2) AS avg_service_rating
FROM dw.restaurant_ratings
GROUP BY restaurant_name, city
HAVING COUNT(*) >= 3
ORDER BY avg_rating DESC, vote_count DESC
LIMIT 10;
