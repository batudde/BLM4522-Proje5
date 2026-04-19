CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS stg;
CREATE SCHEMA IF NOT EXISTS dw;

DROP TABLE IF EXISTS raw.geoplaces2;
CREATE TABLE raw.geoplaces2 (
    placeid text,
    latitude text,
    longitude text,
    the_geom_meter text,
    name text,
    address text,
    city text,
    state text,
    country text,
    fax text,
    zip text,
    alcohol text,
    smoking_area text,
    dress_code text,
    accessibility text,
    price text,
    url text,
    rambience text,
    franchise text,
    area text,
    other_services text
);

DROP TABLE IF EXISTS raw.userprofile;
CREATE TABLE raw.userprofile (
    userid text,
    latitude text,
    longitude text,
    smoker text,
    drink_level text,
    dress_preference text,
    ambience text,
    transport text,
    marital_status text,
    hijos text,
    birth_year text,
    interest text,
    personality text,
    religion text,
    activity text,
    color text,
    weight text,
    budget text,
    height text
);

DROP TABLE IF EXISTS raw.rating_final;
CREATE TABLE raw.rating_final (
    userid text,
    placeid text,
    rating text,
    food_rating text,
    service_rating text
);

DROP TABLE IF EXISTS stg.restaurants;
CREATE TABLE stg.restaurants (
    place_id integer PRIMARY KEY,
    latitude numeric(10,7),
    longitude numeric(10,7),
    geom_meter text,
    restaurant_name text,
    address text,
    city text,
    state text,
    country text,
    fax text,
    zip_code text,
    alcohol text,
    smoking_area text,
    dress_code text,
    accessibility text,
    price_level text,
    url text,
    ambience text,
    franchise boolean,
    area_status text,
    other_services text
);

DROP TABLE IF EXISTS stg.users;
CREATE TABLE stg.users (
    user_id text PRIMARY KEY,
    latitude numeric(10,6),
    longitude numeric(10,6),
    smoker boolean,
    drink_level text,
    dress_preference text,
    ambience text,
    transport text,
    marital_status text,
    children_status text,
    birth_year integer,
    interest text,
    personality text,
    religion text,
    activity text,
    favorite_color text,
    weight_kg numeric(5,2),
    budget text,
    height_m numeric(4,2)
);

DROP TABLE IF EXISTS stg.ratings;
CREATE TABLE stg.ratings (
    user_id text,
    place_id integer,
    rating integer,
    food_rating integer,
    service_rating integer,
    CONSTRAINT ratings_pk PRIMARY KEY (user_id, place_id)
);

DROP TABLE IF EXISTS dw.restaurant_ratings;
CREATE TABLE dw.restaurant_ratings (
    user_id text,
    place_id integer,
    restaurant_name text,
    city text,
    price_level text,
    user_budget text,
    overall_rating integer,
    food_rating integer,
    service_rating integer
);
