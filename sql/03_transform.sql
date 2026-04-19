TRUNCATE TABLE stg.restaurants;

INSERT INTO stg.restaurants (
    place_id,
    latitude,
    longitude,
    geom_meter,
    restaurant_name,
    address,
    city,
    state,
    country,
    fax,
    zip_code,
    alcohol,
    smoking_area,
    dress_code,
    accessibility,
    price_level,
    url,
    ambience,
    franchise,
    area_status,
    other_services
)
SELECT
    NULLIF(TRIM(placeid), '?')::integer,
    NULLIF(TRIM(latitude), '?')::numeric(10,7),
    NULLIF(TRIM(longitude), '?')::numeric(10,7),
    NULLIF(TRIM(the_geom_meter), '?'),
    NULLIF(TRIM(name), '?'),
    NULLIF(TRIM(address), '?'),
    CASE
        WHEN NULLIF(TRIM(city), '?') IS NULL THEN NULL
        WHEN LOWER(TRIM(city)) IN ('san luis potosi', 'san luis potos', 's.l.p.', 's.l.p', 'slp', 's.l.p. ') THEN 'San Luis Potosi'
        WHEN LOWER(TRIM(city)) IN ('victoria', 'cd. victoria', 'cd victoria', 'ciudad victoria', 'victoria ') THEN 'Ciudad Victoria'
        ELSE INITCAP(TRIM(city))
    END,
    CASE
        WHEN NULLIF(TRIM(state), '?') IS NULL THEN NULL
        WHEN LOWER(TRIM(state)) IN ('s.l.p.', 's.l.p', 'san luis potosi') THEN 'San Luis Potosi'
        WHEN LOWER(TRIM(state)) IN ('tamaulipas', 'tamaulipas ') THEN 'Tamaulipas'
        WHEN LOWER(TRIM(state)) IN ('morelos', 'morelos ') THEN 'Morelos'
        ELSE INITCAP(TRIM(state))
    END,
    CASE
        WHEN NULLIF(TRIM(country), '?') IS NULL THEN NULL
        WHEN LOWER(TRIM(country)) IN ('mexico', 'méxico', 'mexico ') THEN 'Mexico'
        ELSE INITCAP(TRIM(country))
    END,
    NULLIF(TRIM(fax), '?'),
    NULLIF(TRIM(zip), '?'),
    REPLACE(NULLIF(TRIM(alcohol), '?'), '_', ' '),
    REPLACE(NULLIF(TRIM(smoking_area), '?'), '_', ' '),
    REPLACE(NULLIF(TRIM(dress_code), '?'), '_', ' '),
    REPLACE(NULLIF(TRIM(accessibility), '?'), '_', ' '),
    NULLIF(TRIM(price), '?'),
    CASE
        WHEN NULLIF(TRIM(url), '?') IS NULL THEN NULL
        WHEN POSITION('http' IN LOWER(TRIM(url))) = 1 THEN TRIM(url)
        ELSE 'http://' || TRIM(url)
    END,
    REPLACE(NULLIF(TRIM(rambience), '?'), '_', ' '),
    CASE
        WHEN LOWER(TRIM(franchise)) = 't' THEN true
        WHEN LOWER(TRIM(franchise)) = 'f' THEN false
        ELSE NULL
    END,
    NULLIF(TRIM(area), '?'),
    REPLACE(NULLIF(TRIM(other_services), '?'), '_', ' ')
FROM raw.geoplaces2;

TRUNCATE TABLE stg.users;

INSERT INTO stg.users (
    user_id,
    latitude,
    longitude,
    smoker,
    drink_level,
    dress_preference,
    ambience,
    transport,
    marital_status,
    children_status,
    birth_year,
    interest,
    personality,
    religion,
    activity,
    favorite_color,
    weight_kg,
    budget,
    height_m
)
SELECT
    NULLIF(TRIM(userid), '?'),
    NULLIF(TRIM(latitude), '?')::numeric(10,6),
    NULLIF(TRIM(longitude), '?')::numeric(10,6),
    CASE
        WHEN LOWER(TRIM(smoker)) = 'true' THEN true
        WHEN LOWER(TRIM(smoker)) = 'false' THEN false
        ELSE NULL
    END,
    REPLACE(NULLIF(TRIM(drink_level), '?'), '_', ' '),
    REPLACE(NULLIF(TRIM(dress_preference), '?'), '_', ' '),
    REPLACE(NULLIF(TRIM(ambience), '?'), '_', ' '),
    REPLACE(NULLIF(TRIM(transport), '?'), '_', ' '),
    REPLACE(NULLIF(TRIM(marital_status), '?'), '_', ' '),
    REPLACE(NULLIF(TRIM(hijos), '?'), '_', ' '),
    NULLIF(TRIM(birth_year), '?')::integer,
    REPLACE(NULLIF(TRIM(interest), '?'), '_', ' '),
    REPLACE(NULLIF(TRIM(personality), '?'), '_', ' '),
    REPLACE(NULLIF(TRIM(religion), '?'), '_', ' '),
    REPLACE(NULLIF(TRIM(activity), '?'), '_', ' '),
    REPLACE(NULLIF(TRIM(color), '?'), '_', ' '),
    NULLIF(TRIM(weight), '?')::numeric(5,2),
    REPLACE(NULLIF(TRIM(budget), '?'), '_', ' '),
    NULLIF(TRIM(height), '?')::numeric(4,2)
FROM raw.userprofile;

TRUNCATE TABLE stg.ratings;

INSERT INTO stg.ratings (
    user_id,
    place_id,
    rating,
    food_rating,
    service_rating
)
SELECT DISTINCT
    NULLIF(TRIM(r.userid), '?') AS user_id,
    NULLIF(TRIM(r.placeid), '?')::integer AS place_id,
    NULLIF(TRIM(r.rating), '?')::integer AS rating,
    NULLIF(TRIM(r.food_rating), '?')::integer AS food_rating,
    NULLIF(TRIM(r.service_rating), '?')::integer AS service_rating
FROM raw.rating_final r
WHERE NULLIF(TRIM(r.userid), '?') IS NOT NULL
  AND NULLIF(TRIM(r.placeid), '?') IS NOT NULL;

DELETE FROM stg.ratings sr
WHERE NOT EXISTS (
    SELECT 1
    FROM stg.users su
    WHERE su.user_id = sr.user_id
)
OR NOT EXISTS (
    SELECT 1
    FROM stg.restaurants sres
    WHERE sres.place_id = sr.place_id
);

TRUNCATE TABLE dw.restaurant_ratings;

INSERT INTO dw.restaurant_ratings (
    user_id,
    place_id,
    restaurant_name,
    city,
    price_level,
    user_budget,
    overall_rating,
    food_rating,
    service_rating
)
SELECT
    r.user_id,
    r.place_id,
    res.restaurant_name,
    res.city,
    res.price_level,
    u.budget,
    r.rating,
    r.food_rating,
    r.service_rating
FROM stg.ratings r
JOIN stg.restaurants res
    ON res.place_id = r.place_id
JOIN stg.users u
    ON u.user_id = r.user_id;
