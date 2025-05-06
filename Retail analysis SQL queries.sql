-- monthly sales
select monthname(sales_date) as `Month`, concat("Rs. ",round(sum(total_amount),0)) as 'Total Sales'
from fact_sales
group by month(sales_date), monthname(sales_date)
order by month(sales_date) asc;

-- top 3 campaings
SELECT 
    c.campaign_name,
    SUM(fs.total_amount) / c.campaign_budget AS roi
FROM fact_sales fs
JOIN campaigns c ON fs.campaign_sk = c.campaign_sk
GROUP BY c.campaign_name, c.campaign_budget
ORDER BY roi DESC
LIMIT 3;

-- rank stores worst
SELECT CEIL(COUNT(DISTINCT store_sk) * 0.10) FROM fact_sales;
SELECT 
    s.store_name,
    SUM(f.total_amount) AS revenue
FROM fact_sales f 
JOIN stores s ON f.store_sk = s.store_sk
GROUP BY s.store_name
ORDER BY revenue ASC
LIMIT 50;




--  Top 5% Customers by Revenue
WITH customer_revenue AS (
    SELECT 
        c.customer_id,
        c.first_name,
        c.last_name,
        SUM(fs.total_amount) AS total_spend,
        PERCENT_RANK() OVER (ORDER BY SUM(fs.total_amount) DESC) AS percentile
    FROM 
        fact_sales fs
    JOIN 
        customers c ON fs.customer_sk = c.customer_sk
    GROUP BY 
        c.customer_id, c.first_name, c.last_name
)
SELECT 
    customer_id,
    first_name,
	last_name,
    total_spend
FROM 
    customer_revenue
WHERE 
    percentile <= 0.05
ORDER BY 
    total_spend DESC;

-- customer segment spending
SELECT 
    c.customer_segment,
    COUNT(DISTINCT c.customer_id) AS customer_count,
    SUM(fs.total_amount) AS total_revenue,
    SUM(fs.total_amount) / COUNT(DISTINCT c.customer_id) AS avg_revenue_per_customer
FROM 
    fact_sales fs
JOIN 
    customers c ON fs.customer_sk = c.customer_sk
GROUP BY 
    c.customer_segment
ORDER BY 
    total_revenue DESC;

-- 7. Best/Worst Selling Products
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    SUM(fs.total_amount) AS total_revenue,
    RANK() OVER (ORDER BY SUM(fs.total_amount) DESC) AS revenue_rank
FROM 
    fact_sales fs
JOIN 
    products p ON fs.product_sk = p.product_sk
GROUP BY 
    p.product_id, p.product_name, p.category
ORDER BY 
    total_revenue DESC
LIMIT 5;


-- worst
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    SUM(fs.total_amount) AS total_revenue,
    RANK() OVER (ORDER BY SUM(fs.total_amount) DESC) AS revenue_rank
FROM 
    fact_sales fs
JOIN 
    products p ON fs.product_sk = p.product_sk
GROUP BY 
    p.product_id, p.product_name, p.category
ORDER BY 
    total_revenue
LIMIT 5;

-- salesperson 
SELECT 
    sp.salesperson_id,
    sp.salesperson_name,
    sp.salesperson_role,
    SUM(fs.total_amount) AS total_sales,
    RANK() OVER (ORDER BY SUM(fs.total_amount) DESC) AS `rank`
FROM 
    fact_sales fs
JOIN 
    salespersons sp ON fs.salesperson_sk = sp.salesperson_sk
GROUP BY 
    sp.salesperson_id, sp.salesperson_name, sp.salesperson_role
ORDER BY 
    total_sales DESC
LIMIT 10;

-- store performance
SELECT 
    s.store_type,
    COUNT(DISTINCT s.store_id) AS store_count,
    SUM(fs.total_amount) AS total_revenue,
    SUM(fs.total_amount) / COUNT(DISTINCT s.store_id) AS revenue_per_store
FROM 
    fact_sales fs
JOIN 
    stores s ON fs.store_sk = s.store_sk
GROUP BY 
    s.store_type
ORDER BY 
    total_revenue DESC;

-- 12. Geographic Opportunities    
SELECT 
    s.store_location,
    c.residential_location,
    SUM(fs.total_amount) AS revenue,
    RANK() OVER (PARTITION BY s.store_location ORDER BY SUM(fs.total_amount) DESC) AS location_rank
FROM 
    fact_sales fs
JOIN 
    stores s ON fs.store_sk = s.store_sk
JOIN 
    customers c ON fs.customer_sk = c.customer_sk
GROUP BY 
    s.store_location, c.residential_location
ORDER BY 
    revenue desc;    
    
    
-- budget
SELECT 
    c.campaign_id,
    c.campaign_name,
    c.campaign_budget,
    SUM(fs.total_amount) AS revenue_generated,
    CASE 
        WHEN SUM(fs.total_amount) > c.campaign_budget THEN 'Keep'
        ELSE 'Re-evaluate'
    END AS recommendation
FROM 
    fact_sales fs
JOIN 
    campaigns c ON fs.campaign_sk = c.campaign_sk
GROUP BY 
    c.campaign_id, c.campaign_name, c.campaign_budget
ORDER BY 
    recommendation, revenue_generated DESC;


