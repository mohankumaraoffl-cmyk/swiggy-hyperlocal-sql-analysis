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
