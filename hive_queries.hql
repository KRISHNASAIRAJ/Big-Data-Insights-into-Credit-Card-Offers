create database cc_analysis;


use cc_analysis;


CREATE TABLE cc_data (
    Client_Number STRING,
    Customer_Type STRING,
    Customer_Age INT,
    Gender STRING,
    Education STRING,
    Income DOUBLE,
    Credit_Card_Type STRING,
    Product STRING,
    Working_Professional STRING,
    Offer_Availed STRING,
    Offer_Utilized STRING,
    Utilized_Product STRING,
    Order_Amount DOUBLE,
    Annual_Charges DOUBLE,
    Credit_Score INT,
    'Date' STRING, -- Column 'Date' with STRING data type
    PIN_Code STRING,
    Housing_Type STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;


LOAD DATA INPATH '/rawdata.csv' INTO TABLE cc_analysis.cc_data;


SELECT * FROM cc_analysis.cc_data LIMIT 10;


CREATE TABLE transformed_cc_data AS
SELECT
    utilized_product AS product_type,
    COUNT(DISTINCT client_number) AS total_users,
    COUNT(*) AS total_transactions,
    SUM(order_amount) AS total_cost
FROM
    cc_analysis.cc_data
WHERE
    offer_availed = 'Yes'
    AND offer_utilized = 'Yes'
GROUP BY
    utilized_product;


CREATE TABLE availed_offer AS
SELECT
    client_number,
    credit_card_type,
    product,
    order_amount,
    credit_score
FROM
    cc_analysis.cc_data
WHERE
    offer_availed = 'Yes' AND client_number IS NOT NULL;


INSERT OVERWRITE LOCAL DIRECTORY '/home/krishnasairaj/PROJECT'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
SELECT
    'client_number' AS client_number,
    'credit_card_type' AS credit_card_type,
    'product' AS product,
    'order_amount' AS order_amount,
    'credit_score' AS credit_score
UNION ALL
SELECT
    client_number,
    credit_card_type,
    product,
    order_amount,
    credit_score
FROM cc_analysis.availed_offer;

INSERT OVERWRITE DIRECTORY '/offer_utilized.csv'
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
SELECT *
FROM availed_offer;
