-- Step 1: Import the Dataset of .csv file to database

----------------------------------------------------------------------------------

-- Step 2: Database Selection
use dummy;

----------------------------------------------------------------------------------

-- Step 3: check and overview of the table (swiggy)
SELECT COUNT(*) FROM swiggy;

select Subcity, Restaurant, avg(price), Min(Price), Max(price), count(*) 
from swiggy
group by Restaurant,subcity
order by count(*)  desc
limit 50;

----------------------------------------------------------------------------------

-- DATA CLEANING
-- Step 4: Handling Missing Prices
SELECT *
FROM swiggy 
WHERE price IS NULL;

----------------------------------------------------------------------------------

-- Step 5: Remove duplicates
/* In this uploaded dataset didn't had Duploicates. Go to the next process. */

----------------------------------------------------------------------------------

-- EDA (EXPLORATORY DATA ANALYSIS)
-- Q1: Analyzing the average cost for different restaurants
select avg(cost),restaurant from swiggy
group by restaurant
order by avg(cost) asc ;

----------------------------------------------------------------------------------

-- Q2: Top 10 highest-rated restaurants in Poonamallee
select distinct restaurant, rating, subcity from swiggy
order by rating desc
limit 10;

----------------------------------------------------------------------------------

-- Q3: Count of Veg vs Non-Veg items in each restaurant
select restaurant, veg_or_non_veg, COUNT(*) as Total
from swiggy
group by restaurant, veg_or_non_veg
limit 20;

----------------------------------------------------------------------------------

-- Q4: Most popular cuisines in each restuarant
select restaurant, cuisine, count(*) as Total from swiggy
group by restaurant,cuisine
order by Total desc
limit 15;

----------------------------------------------------------------------------------

-- Q5: Identifying Pure Vegetarian restaurants in the dataset
SELECT restaurant, subcity
FROM swiggy
GROUP BY restaurant, subcity
HAVING SUM(CASE WHEN veg_or_non_veg = 'Non-veg' THEN 1 ELSE 0 END) = 0;

----------------------------------------------------------------------------------

-- Q6: Top 10 restaurants with the highest number of menu items
select restaurant, count(item) as Total from swiggy
group by restaurant
order by Total desc
limit 10;

----------------------------------------------------------------------------------

-- Q7: Top 5 most expensive food items in the dataset
select restaurant,item,Price from swiggy
Group by restaurant,item, price
order by price desc
limit 5;

----------------------------------------------------------------------------------

select* from swiggy;

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------