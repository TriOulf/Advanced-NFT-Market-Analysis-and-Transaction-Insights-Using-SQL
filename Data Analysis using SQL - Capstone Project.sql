CREATE DATABASE IF NOT EXISTS cryptopunk;

USE cryptopunk;

# Q1- How many sales occurred during the time period (Jan 1, 2018 - Dec 31, 2021)?
SELECT COUNT(*) AS total_sales
FROM cryptopunkdata;

# Q2- Top 5 Most Expensive Transactions by USD Price:
SELECT name, eth_price, usd_price, utc_timestamp AS date
FROM cryptopunkdata
ORDER BY usd_price DESC
LIMIT 5;

# Q3- Table with a Moving Average of USD Price (50 Transactions):
SELECT name AS event, usd_price,
       AVG(usd_price) OVER (ORDER BY utc_timestamp ROWS BETWEEN 49 PRECEDING AND CURRENT ROW) AS moving_avg_usd_price
FROM cryptopunkdata;

# Q4- NFT Names and Their Average Sale Price in USD (Descending Order):
SELECT name, AVG(usd_price) AS average_price
FROM cryptopunkdata
GROUP BY name
ORDER BY average_price DESC;

# Q5- Sales by Day of the Week and Average ETH Price:
SELECT DAYOFWEEK(utc_timestamp) AS day_of_week,
       COUNT(*) AS total_sales,
       AVG(eth_price) AS average_eth_price
FROM cryptopunkdata
GROUP BY day_of_week
ORDER BY total_sales ASC;

# Q6- Construct a Summary for Each Sale:
SELECT CONCAT(name, ' was sold for $', ROUND(usd_price, 3), ' to ', ï»¿buyer_address, ' from ', seller_address, ' on ', utc_timestamp) AS summary
FROM cryptopunkdata;

# Q7- Create View for Purchases by a Specific Wallet:
CREATE VIEW 1919_purchases AS
SELECT *
FROM cryptopunkdata
WHERE ï»¿buyer_address= '0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685';

# Q8- Create a Histogram of ETH Price Ranges (Rounded to Nearest Hundred):
SELECT FLOOR(eth_price / 100) * 100 AS price_range, COUNT(*) AS transaction_count
FROM cryptopunkdata
GROUP BY price_range
ORDER BY price_range;

# Q9- Union Query for Highest and Lowest Prices of Each NFT:
(SELECT name, MAX(usd_price) AS price, 'highest' AS status
 FROM cryptopunkdata
 GROUP BY name)
UNION ALL
(SELECT name, MIN(usd_price) AS price, 'lowest' AS status
 FROM cryptopunkdata
 GROUP BY name)
ORDER BY name, status;

# Q10- NFT Sold the Most in Each Month/Year:
WITH monthly_sales AS (
  SELECT name, COUNT(*) AS sales_count, EXTRACT(YEAR FROM utc_timestamp) AS year, EXTRACT(MONTH FROM utc_timestamp) AS month, MAX(usd_price) AS usd_price
  FROM cryptopunkdata
  GROUP BY name, year, month
)
SELECT name, year, month, usd_price
FROM monthly_sales
ORDER BY year, month;

# Q11- Total Sales Volume on a Monthly Basis (Rounded to Nearest Hundred):
SELECT EXTRACT(YEAR FROM utc_timestamp) AS year, EXTRACT(MONTH FROM utc_timestamp) AS month, 
       ROUND(SUM(usd_price), -2) AS total_volume
FROM cryptopunkdata
GROUP BY year, month
ORDER BY year, month;

# Q12- Count of Transactions by Wallet "0x1919...":
SELECT COUNT(*) AS transaction_count
FROM cryptopunkdata
WHERE ï»¿buyer_address= '0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685' OR seller_address = '0x1919db36ca2fa2e15f9000fd9cdc2edcf863e685';

# Q13- Estimated Average Value Calculator:
-- Part A: Subquery to Select Event Date and Average USD Price:
-- Part B: Filter Out Outliers and Return Estimated Average:

WITH daily_avg AS (
  SELECT DATE(utc_timestamp) AS event_date, 
         usd_price, 
         AVG(usd_price) OVER (PARTITION BY DATE(utc_timestamp)) AS daily_avg_price
  FROM cryptopunkdata
)
SELECT event_date, 
       AVG(usd_price) AS estimated_avg_value
FROM daily_avg
WHERE usd_price >= daily_avg_price * 0.10
GROUP BY event_date;
