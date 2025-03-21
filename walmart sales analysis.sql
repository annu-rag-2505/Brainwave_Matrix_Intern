-- Create database
CREATE DATABASE IF NOT EXISTS walmartSales;

-- Create table
CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

----------------------------- add coloum time of day--------------------------------------


select time,
(case
    when `time` between "00:00:00" and "12:00:00" then "morning"
    when `time` between "12:00:01" and "16:00:00" then "afternoon"
    else "evening"
 end
) as time_of_date
from sales;


alter table sales add column time_of_day varchar(10);

update sales set time_of_day =(
case
    when `time` between "00:00:00" and "12:00:00" then "morning"
    when `time` between "12:00:01" and "16:00:00" then "afternoon"
    else "evening"
 end
 );
 
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------- day name-------------------------------------------------------------------------------------------------------------
select date,
dayname(date)
from sales;

alter table sales add column day_name varchar(10);

update sales set day_name= (dayname(date) );

------------------------------------------------------ month name---------------------------------------------------------------------------------------------------------------

select date,
monthname(date)
from sales;

alter table sales add column month_name varchar(10);

update sales set month_name=(monthname(date) );

---------------------------------------------------------------- questions---------------------------------------------------------------------------------------------------

------  1.which branch is in which city ---------------------------------------------------------------------------

select distinct city,
branch from sales;

------- 2. How many unique product lines does the data have?--------------------

select  distinct product_line from sales;

select count( distinct product_line )from sales;

------------ 3. What is the most selling product line?---------------
select product_line,
   count(product_line) AS num
FROM SALES
group by product_line 
order by num desc ;

---------- 4. What is the total revenue by month ?-----------------------------------------------
SELECT month_name as month,
 sum(total) as total_revenue
from sales
group by month_name
order by total_revenue desc ;

------------ 5. What month had the largest COGS?------------------------------------------------
SELECT month_name as month,
 sum(cogs) as cog
from sales
group by month_name
order by cog desc ;

------------------------------ 6. What product line had the largest revenue?------------------------------------------
SELECT product_line as product,
 sum(total) as total
from sales
group by product_line
order by total desc ;

-------------------------------- 7.What is the city with the largest revenue? --------------
SELECT city ,
 sum(total) as total
from sales
group by city
order by total desc ;

------------- 8.What product line had the largest VAT?-----------------
SELECT product_line as product,
 avg(tax_pct) as vat
from sales
group by product_line
order by vat desc ;

------------------- 9. Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales ----------------
    SELECT 
    product_line,
    SUM(total) AS total_sales,
    CASE 
        WHEN SUM(total) > (
            SELECT AVG(total_sales)
            FROM (
                SELECT product_line, SUM(total) AS total_sales
                FROM sales
                GROUP BY product_line
            ) AS subquery
        ) THEN 'Good'
        ELSE 'Bad'
    END AS performance
FROM 
    sales
GROUP BY 
    product_line;

-------- 10. Which branch sold more products than average product sold?------------------------------------------

select branch ,
sum(quantity) as qty
from sales
group by branch
having sum(quantity) > (        select avg(quantity) from sales                   )
order by qty desc;


select round(avg(quantity) ,2) from sales;

-------------------------- 11. What is the most common product line by gender?-----------------------------------------

SELECT product_line as product,
 gender,
 count(gender) as total_cnt
from sales
group by product_line , gender
order by total_cnt desc;

------------------------------- 11.What is the average rating of each product line? -----------------------------------------------------------------------------------------

SELECT product_line as product,
 round(avg(rating), 2) as rating
from sales
group by product_line
order by rating desc ;

------------------------------------------- 12. Number of sales made in each time of the day per weekday---------------------------------------
select time_of_day,
count(*) as total_sales
from sales
where day_name = 'monday'
group by time_of_day
ORDER BY total_sales;

-------------------------------------------- 13.Which of the customer types brings the most revenue? -----------------------------
select distinct customer_type ,
sum(total) as ttl
from sales
group by customer_type 
order by ttl desc ;

--------------------------------------------- 14.Which city has the largest tax percent/ VAT (Value Added Tax)?-------------------------------------------------

select  city ,
sum(tax_pct) as vat
from sales
group by city 
order by vat desc ;

------------------------------ 14.Which customer type pays the most in VAT?---------------------------------------------------
select  customer_type ,
sum(tax_pct) as vat
from sales
group by customer_type 
order by vat desc ;

---------- 15. How many unique customer types does the data have?-----------------------------------------------------------------
SELECT
	DISTINCT customer_type
FROM sales;

---------- 16. How many unique payment methods does the data have?-------------------------------------------------------------------------------
SELECT
	DISTINCT payment
FROM sales;


-- 17. What is the most common customer type?--------------------------------------------------------------------------------------------------
SELECT
	customer_type,
	count(*) as count
FROM sales
GROUP BY customer_type
ORDER BY count DESC;

------------------------------- 18.  Which customer type buys the most?---------------------------------------------------------------
SELECT
	customer_type,
	count(*) as quantity
FROM sales
GROUP BY customer_type
ORDER BY quantity DESC;

------------------------- 20.What is the gender of most of the customers?---------------------------------------------------------
SELECT
	gender,
	count(*) as quantity
FROM sales
GROUP BY gender
ORDER BY quantity DESC;

--------------------------- 21. What is the gender distribution per branch?-----------------------------------------------------------------


SELECT 
    branch,
    gender,
    COUNT(*) AS count
FROM 
    sales
GROUP BY 
    branch, gender
ORDER BY 
    count desc;
    
------------------------------ 22.Which time of the day do customers give most ratings?----------------------------------------------------

SELECT 
    time_of_day,
    COUNT(*) AS rating_count
FROM 
    sales
GROUP BY 
    time_of_day
ORDER BY 
  rating_count desc;
  
  ---------------------------- 23. Which time of the day do customers give most ratings per branch?--------------------------------------
  SELECT branch,
    time_of_day, 
    COUNT(*) AS rating_count
FROM 
    sales
GROUP BY 
    time_of_day,branch
ORDER BY 
  branch ,rating_count desc;
  
  ------------------------------ 24. Which day of the week has the best avg ratings -------------------------------------------------------------
  
    SELECT day_name,
	
    round(avg(rating),2) AS avg_rating 
FROM 
    sales
GROUP BY 
    day_name
ORDER BY 
  avg_rating desc;
  
--------------------- 25.Which day of the week has the best average ratings per branch?------------------------------------
    SELECT branch,day_name,
	
    round(avg(rating),2) AS avg_rating 
FROM 
    sales
GROUP BY 
    branch,day_name
ORDER BY 
 branch, avg_rating desc;
 
 
 
 WITH avg_ratings AS (
    SELECT 
        branch,
        day_name,
        ROUND(AVG(rating), 2) AS avg_rating,
        ROW_NUMBER() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS rn
    FROM 
        sales
    GROUP BY 
        branch, day_name
)
SELECT 
    branch,
    day_name AS best_day,
    avg_rating
FROM 
    avg_ratings
WHERE 
    rn = 1;

  
  
  
  
  
  
    
    


