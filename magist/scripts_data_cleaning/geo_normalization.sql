/* geolocation
there are duplicates in zip codes with different coordinates
but the same city / state

we will take avg lat and lng
and make zip codes a Primary Key

zip_geolocation is the new table to use
geolocation will be dropped
*/
drop temporary table zip_geo_temp;
CREATE TEMPORARY TABLE zip_geo_temp AS (SELECT geolocation_zip_code_prefix,
    ROUND(AVG(geolocation_lat), 4) AS lat,
    ROUND(AVG(geolocation_lng), 4) AS lng FROM
    geolocation
GROUP BY geolocation_zip_code_prefix);

CREATE TEMPORARY TABLE zip_city_state AS(
SELECT * FROM (
  SELECT 
  g.geolocation_zip_code_prefix as zip_code_prefix, 
  g.geolocation_city as city,
  g.geolocation_state as state, 
  ROW_NUMBER() OVER (PARTITION BY geolocation_zip_code_prefix ORDER BY geolocation_city) AS rg
  FROM geolocation AS g
) ranked_geolocation WHERE rg = 1);

drop table zip_geolocation;
CREATE TABLE zip_geolocation AS (
SELECT zcs.zip_code_prefix, zcs.city, zcs.state, zg.lat, zg.lng FROM
      zg
        LEFT JOIN
    zip_city_state zcs ON zg.geolocation_zip_code_prefix = zcs.zip_code_prefix
ORDER BY zcs.zip_code_prefix);

ALTER TABLE zip_geolocation
MODIFY zip_code_prefix INT NOT NULL;

ALTER TABLE zip_geolocation
ADD PRIMARY KEY (zip_code_prefix);

drop table geolocation;

-- zip codes in sellers, not in zip_geolocation
SELECT DISTINCT(seller_zip_code_prefix) FROM
sellers WHERE seller_zip_code_prefix NOT IN (
SELECT zip_code_prefix FROM
zip_geolocation);

-- adding unknown codes to zip_geolocation
insert into zip_geolocation values 
("7412", null, null, null, null),
("72580", null, null, null, null),
("91901", null, null, null, null),
("2285", null, null, null, null),
("71551", null, null, null, null),
("82040", null, null, null, null),
("37708", null, null, null, null);

/* Some zip codes present in the customers table are not in the zip_geolocation table 
We create a new table that contains all the zip codes
*/

CREATE TABLE zip_geolocation_full AS (
SELECT * FROM zip_geolocation
UNION
SELECT 
c.customer_zip_code_prefix AS zip_code_prefix,
c.customer_city AS city,
c.customer_state AS state,
g.lat,
g.lng
FROM customers c
LEFT JOIN zip_geolocation g
ON c.customer_zip_code_prefix = g.zip_code_prefix
);

/* The new table has duplicates we have to get rid of
*/
DROP TABLE geo;
CREATE TABLE geo AS(
SELECT zip_code_prefix, city, state, lat, lng FROM (
  SELECT 
  g.*,
  ROW_NUMBER() OVER (PARTITION BY zip_code_prefix ORDER BY zip_code_prefix) AS rg
  FROM zip_geolocation_full AS g
) ranked_geolocation WHERE rg = 1);

ALTER TABLE geo
MODIFY zip_code_prefix INT NOT NULL;

ALTER TABLE geo
ADD PRIMARY KEY (zip_code_prefix);