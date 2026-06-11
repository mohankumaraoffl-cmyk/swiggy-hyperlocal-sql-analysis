# Swiggy Hyperlocal Analysis: Food Delivery Insights of Poonamallee, Chennai

## 📌 Project Overview
This project performs an in-depth data analytics study on a dataset consisting of **2,148 clean records** from Swiggy's food delivery operations in **Poonamallee, Chennai**. The objective is to assist new restaurant owners, investors, and cloud kitchen managers in making data-driven business decisions regarding competitive pricing, high-demand cuisines, and vegetarian-specific market niches.

## 🛠️ Tech Stack & Tools
* **Database Management System:** MySQL Workbench
* **Language:** SQL (Structured Query Language)
* **Key Techniques:** Data Imputation, Conditional Aggregations, Analytical Filtering.

---

## 🧼 Phase 1: Data Architecture & Cleaning Pipeline
Before conducting business logic analysis, a data preparation script was executed on the `swiggy` table:
1. **Handling Missing Values:** Isolated rows with missing `price` markers and applied an imputation tactic using restaurant average costs (`price = cost / 2`).
2. **Datatype Conversion:** Cast core columns into proper database mathematical formats (`DECIMAL`, `UNSIGNED INT`).
3. **Redundancy Isolation:** Audited and handled duplicate rows to secure data integrity.

```sql
-- Safe Updates Override for Cleaning Operations
SET SQL_SAFE_UPDATES = 0;
SELECT COUNT(*) FROM swiggy WHERE price IS NULL;

-- Q1: Budget Profiling (Average Cost Across Competitors)
SELECT restaurant, 
       ROUND(AVG(CAST(cost AS UNSIGNED)), 2) AS average_dining_cost
FROM swiggy
GROUP BY restaurant
ORDER BY average_dining_cost ASC;

-- Q2: Competitive Landscape (Top 10 Highest-Rated Unique Spots)
SELECT DISTINCT restaurant, rating, subcity 
FROM swiggy
ORDER BY rating DESC

-- Q3: Operational Metrics (Veg vs Non-Veg Item Spread per Vendor)
SELECT restaurant, veg_or_non_veg, COUNT(*) AS total_items
FROM swiggy
GROUP BY restaurant, veg_or_non_veg
LIMIT 20;

-- Q4: Core Demand (Most Popular Listed Cuisines)
SELECT restaurant, cuisine, COUNT(*) AS Total 
FROM swiggy
GROUP BY restaurant, cuisine
ORDER BY Total DESC
LIMIT 15;

-- Q5: Advanced Market Segmentation (Isolating "Pure Vegetarian" Chains)
SELECT restaurant, subcity
FROM swiggy
GROUP BY restaurant, subcity
HAVING SUM(CASE WHEN veg_or_non_veg = 'Non-veg' THEN 1 ELSE 0 END) = 0;

-- Q6: Variety Architecture (Menu Density Leaders)
SELECT restaurant, COUNT(item) AS Total 
FROM swiggy
GROUP BY restaurant
ORDER BY Total DESC
LIMIT 10;

-- Q7: Upper Ceiling Pricing Metrics (Top 5 Most Premium Items)
SELECT restaurant, item, price 
FROM swiggy
GROUP BY restaurant, item, price
ORDER BY price DESC
LIMIT 5;
LIMIT 10;


---

## 🏗️ Phase 4: Production-Grade Database Normalization (3NF Architecture)

To eliminate data redundancy, optimize storage architecture, and ensure strict data integrity, the flat `swiggy` dataset was decomposed into a **Third Normal Form (3NF)** relational database model.

### 🗺️ Data Architecture Schema (Entity Relationship Blueprint)

The monolithic architecture was broken down into two **Dimension Tables** and one central **Fact Table**:

1. **`dim_restaurants` (Dimension Table)**: Stores unique restaurant profiles.
2. **`dim_cuisines` (Dimension Table)**: Enforces unique, standardized culinary categories.
3. **`fact_menu_items` (Fact Table)**: The core transactional engine bridging restaurants, cuisines, and specific menu configurations via strict Foreign Keys.

---

-- NORMALIZATION
-- Database selection
use dummy;

----------------------------------------------------------------------------------

-- 1 Create table dim_restaurants

create table dim_restaurants (
	restaurant_id int auto_increment primary key,
    restaurant_name varchar (250) not null,
    subcity varchar (100),
    rating decimal(3,1),
    cost int);


----------------------------------------------------------------------------------

-- 2 Create table dim_cuisines

create table dim_cuisines(
	cuisine_id int auto_increment primary key,
    cuisine_name varchar (100) not null unique);

----------------------------------------------------------------------------------
    
 -- 3 Create table fact_menu_items
 
create table fact_menu_items(
	item_id int auto_increment primary key,
    restaurant_id int,
    cuisine_id int,
    item_name varchar (100) not null,
    Price decimal (10,2),
    veg_or_non_veg varchar(20),
    foreign key (restaurant_id) references dim_restaurants(restaurant_id),
    foreign key (cuisine_id) references dim_cuisines(cuisine_id));

----------------------------------------------------------------------------------

-- Insert the values to dim_restaurants
INSERT INTO dim_restaurants (restaurant_name, subcity, rating, cost)
SELECT restaurant, subcity, MAX(rating), MAX(cost)
FROM swiggy
GROUP BY restaurant, subcity;

----------------------------------------------------------------------------------

-- Insert the values to dim_cuisines
insert into dim_cuisines (cuisine_name)
select distinct cuisine
from swiggy
where cuisine is not null and cuisine !=' ';

----------------------------------------------------------------------------------

-- Insert the values to fact_menu_items
insert into fact_menu_items (restaurant_id,cuisine_id,item_name,price,veg_or_non_veg)
select r.restaurant_id, c.cuisine_id, s.item, s.price, s.veg_or_non_veg
from swiggy s
inner join dim_restaurants r
	on s.restaurant = r.restaurant_name and s.subcity = r.subcity
inner join dim_cuisines c
	on s.cuisine like concat('%', c.cuisine_name, '%');

----------------------------------------------------------------------------------

-- Q1: Avg cost by each restaurant
select restaurant_name,avg(cost) from dim_restaurants
group by restaurant_name;

----------------------------------------------------------------------------------

-- Q2: Top 10 Highesst rating hotels
select restaurant_name, rating from dim_restaurants
group by restaurant_name, rating
order by rating desc
limit 10;

----------------------------------------------------------------------------------

-- Q3: Veg and Non Veg count in each hotels
select r.restaurant_name,f.veg_or_non_veg, count(*) as total
from fact_menu_items f
inner join dim_restaurants r
on r.restaurant_id = f.restaurant_id
group by r.restaurant_name, f.veg_or_non_veg
limit 10;

----------------------------------------------------------------------------------

-- Q4: Which is so popularity cuisine in Poonamallee
select c.cuisine_name,count(*) as total
from dim_cuisines c
inner join fact_menu_items f
on c.cuisine_id = f.cuisine_id
group by cuisine_name
order by total desc
limit 15;

----------------------------------------------------------------------------------

-- Q5: Top 10 Hotels that offer most cuisine
select r.restaurant_name, count(f.item_name) as Total
from Dim_restaurants r
inner join fact_menu_items f
on r.restaurant_id = f.restaurant_id
group by r.restaurant_name
order by count(*) desc
limit 10;

----------------------------------------------------------------------------------

-- Q6: Top 5 high rated premium item
select r.restaurant_name, f.item_name, f.price
from fact_menu_items f
inner join dim_restaurants r
on f.restaurant_id = r.restaurant_id
group by r.restaurant_name, f.item_name, f.price
order by f.price desc
limit 5;

----------------------------------------------------------------------------------

select * from dim_cuisines;
Select * from Dim_restaurants;
select * from fact_menu_items;

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
