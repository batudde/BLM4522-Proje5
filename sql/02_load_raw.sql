TRUNCATE TABLE raw.geoplaces2;
TRUNCATE TABLE raw.userprofile;
TRUNCATE TABLE raw.rating_final;

-- geoplaces2.csv dosyasi UTF8 degil; Windows-1252/Latin1 benzeri kodlama ile geliyor.
\copy raw.geoplaces2 FROM './geoplaces2.csv' WITH (FORMAT csv, HEADER true, ENCODING 'WIN1252');
\copy raw.userprofile FROM './userprofile.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');
\copy raw.rating_final FROM './rating_final.csv' WITH (FORMAT csv, HEADER true, ENCODING 'UTF8');
