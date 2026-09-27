-- Overall Totals (Sales, Orders, Customers, Quantity)
SELECT
  COUNT(DISTINCT order_id) AS total_orders,
  COUNT(DISTINCT customer_id) AS total_customers,
  SUM(quantity) AS total_quantity_sold,
  SUM(total_amount) AS total_sales
FROM "ecommerce_curated_db"."fact_order_detail";

-- Monthly Sales & Orders
SELECT
  d.year,
  d.month,
  SUM(od.total_amount) AS monthly_sales,
  COUNT(DISTINCT o.order_id) AS monthly_orders,
  SUM(od.quantity) AS monthly_quantity
FROM "ecommerce_curated_db"."fact_order_detail" od
JOIN "ecommerce_curated_db"."fact_order" o ON od.order_id = o.order_id
JOIN "ecommerce_curated_db"."dim_date" d ON o.date_id = d.date_id
GROUP BY d.year, d.month
ORDER BY d.year, d.month;

-- Sales by Category
SELECT 
  c.category_name, 
  SUM(od.total_amount) AS total_sales
FROM "ecommerce_curated_db"."fact_order_detail" od
JOIN "ecommerce_curated_db"."dim_product" p ON od.product_id = p.product_id
JOIN "ecommerce_curated_db"."dim_category" c ON p.category_id = c.category_id
GROUP BY c.category_name 
ORDER BY total_sales DESC;

-- Top 10 Products by Sales
SELECT 
  p.product_name, 
  SUM(od.total_amount) AS total_sales
FROM "ecommerce_curated_db"."fact_order_detail" od
JOIN "ecommerce_curated_db"."dim_product" p ON od.product_id = p.product_id
GROUP BY p.product_name 
ORDER BY total_sales DESC 
LIMIT 10;

-- Top 10 Customers by Total Spending
SELECT 
  c.first_name || ' ' || c.last_name AS customer_name, 
  fcs.total_sales AS total_spending
FROM "ecommerce_curated_db"."fact_customer_sales" fcs
JOIN "ecommerce_curated_db"."dim_customer" c ON fcs.customer_id = c.customer_id
ORDER BY total_spending DESC 
LIMIT 10;

-- Average Order Value (AOV)
SELECT 
  SUM(total_amount) / COUNT(DISTINCT order_id) AS average_order_value
FROM "ecommerce_curated_db"."fact_order_detail";

-- Order Status Analysis
SELECT 
  s.order_status, 
  COUNT(o.order_id) AS order_count
FROM "ecommerce_curated_db"."fact_order" o
JOIN "ecommerce_curated_db"."dim_order_status" s ON o.order_status_id = s.order_status_id
GROUP BY s.order_status;

-- Payment Methods Analysis
SELECT 
  pm.payment_method, 
  COUNT(p.payment_id) AS num_transactions, 
  SUM(p.amount) AS total_amount, 
  AVG(p.amount) AS avg_payment_amount
FROM "ecommerce_curated_db"."fact_payment" p
JOIN "ecommerce_curated_db"."dim_payment_method" pm ON p.payment_method_id = pm.payment_method_id
GROUP BY pm.payment_method;

-- Shipment Performance
SELECT 
  COUNT(shipment_id) AS total_shipments, 
  AVG(shipping_days) AS avg_delivery_days, 
  MIN(shipping_days) AS min_delivery_days, 
  MAX(shipping_days) AS max_delivery_days
FROM "ecommerce_curated_db"."fact_shipment";

-- Cumulative Running Sales
WITH DailySales AS (
  SELECT 
    o.order_date, 
    SUM(od.total_amount) AS daily_sales
  FROM "ecommerce_curated_db"."fact_order_detail" od
  JOIN "ecommerce_curated_db"."fact_order" o ON od.order_id = o.order_id
  GROUP BY o.order_date
)
SELECT 
  order_date, 
  daily_sales, 
  SUM(daily_sales) OVER (ORDER BY order_date ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total_sales
FROM DailySales 
ORDER BY order_date;

-- Month-over-Month (MoM) Growth
WITH MonthlySales AS (
  SELECT 
    d.year, 
    d.month, 
    SUM(od.total_amount) AS current_sales
  FROM "ecommerce_curated_db"."fact_order_detail" od
  JOIN "ecommerce_curated_db"."fact_order" o ON od.order_id = o.order_id
  JOIN "ecommerce_curated_db"."dim_date" d ON o.date_id = d.date_id
  GROUP BY d.year, d.month
)
SELECT 
  year, 
  month, 
  current_sales,
  LAG(current_sales) OVER (ORDER BY year, month) AS prev_sales,
  current_sales - LAG(current_sales) OVER (ORDER BY year, month) AS sales_diff,
  ((current_sales - LAG(current_sales) OVER (ORDER BY year, month)) / NULLIF(LAG(current_sales) OVER (ORDER BY year, month), 0)) * 100 AS growth_pct
FROM MonthlySales 
ORDER BY year, month;

-- Product Ranking within Category
WITH RankedProducts AS (
  SELECT 
    c.category_name, 
    p.product_name, 
    SUM(od.total_amount) AS sales,
    RANK() OVER (PARTITION BY c.category_name ORDER BY SUM(od.total_amount) DESC) AS rank
  FROM "ecommerce_curated_db"."fact_order_detail" od
  JOIN "ecommerce_curated_db"."dim_product" p ON od.product_id = p.product_id
  JOIN "ecommerce_curated_db"."dim_category" c ON p.category_id = c.category_id
  GROUP BY c.category_name, p.product_name
)
SELECT * FROM RankedProducts 
WHERE rank <= 3 
ORDER BY category_name, rank;

-- Customer Ranking by Total Spending
SELECT 
  c.first_name || ' ' || c.last_name AS customer, 
  fcs.total_sales AS total_spending, 
  fcs.total_orders AS order_count,
  RANK() OVER (ORDER BY fcs.total_sales DESC) AS rank
FROM "ecommerce_curated_db"."fact_customer_sales" fcs
JOIN "ecommerce_curated_db"."dim_customer" c ON fcs.customer_id = c.customer_id
ORDER BY rank;