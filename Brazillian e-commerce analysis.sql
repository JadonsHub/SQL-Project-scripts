CREATE OR REPLACE VIEW cleaned_orders AS
SELECT 
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    -- Strategy: We only use delivered orders with valid timestamps for logistics KPIs
    order_delivered_customer_date,
    order_estimated_delivery_date,
    -- Creating derived columns for early analysis
    DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) AS days_to_delivery,
    DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) AS delivery_vs_estimated
FROM olist_orders_dataset
WHERE order_status = 'delivered' 
  AND order_delivered_customer_date IS NOT NULL;
  
CREATE OR REPLACE VIEW cleaned_products AS
SELECT 
    p.product_id,
    -- Strategy: Map Portuguese to English; Assign 'unknown' to NULLs
    COALESCE(t.product_category_name_english, 'unknown') AS product_category,
    p.product_name_lenght,
    p.product_description_lenght,
    p.product_photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
FROM olist_products_dataset p
LEFT JOIN product_category_name_translation t 
    ON p.product_category_name = t.product_category_name;
    
CREATE OR REPLACE VIEW cleaned_reviews AS
SELECT 
    review_id,
    order_id,
    review_score,
    review_comment_title,
    -- Strategy: Replace NULL messages with a standard placeholder
    COALESCE(review_comment_message, 'No comment provided') AS review_comment_message,
    review_creation_date,
    review_answer_timestamp
FROM olist_order_reviews_dataset;

CREATE OR REPLACE VIEW payment_validation AS
SELECT 
    p.order_id,
    SUM(p.payment_value) AS total_payment_value,
    COUNT(p.payment_sequential) AS number_of_installments,
    -- Strategy: Flag orders with multiple payment types for closer inspection
    COUNT(DISTINCT p.payment_type) AS distinct_payment_types
FROM olist_order_payments_dataset p
GROUP BY p.order_id;


CREATE OR REPLACE VIEW master_olist_pipeline AS
SELECT 
    o.order_id,
    o.order_purchase_timestamp,
    o.days_to_delivery,
    p.product_category,
    i.price,
    i.freight_value,
    pay.total_payment_value,
    r.review_score
FROM cleaned_orders o
JOIN olist_order_items_dataset i ON o.order_id = i.order_id
JOIN cleaned_products p ON i.product_id = p.product_id
JOIN cleaned_reviews r ON o.order_id = r.order_id
JOIN payment_validation pay ON o.order_id = pay.order_id;

-- Q1: Total Revenue Trend Month-Over-Month
SELECT 
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS order_month,
    ROUND(SUM(payment_value), 2) AS monthly_revenue
FROM olist_orders_dataset o
JOIN olist_order_payments_dataset p
ON o.order_id = p.order_id
WHERE order_status = 'delivered'
GROUP BY 1
ORDER BY 1;

-- -- Q2: Logistics Performance (Avg Days vs Estimated)
CREATE OR REPLACE VIEW report_logistics_health AS
SELECT 
    ROUND(AVG(actual_delivery_days), 2) AS avg_delivery_time,
    ROUND(AVG(days_diff_estimated), 2) AS avg_delay_vs_estimate,
    ROUND((COUNT(CASE WHEN days_diff_estimated > 0 THEN 1 END) * 100.0 / COUNT(*)), 2) AS pct_late_deliveries
FROM v_cleaned_orders;

-- Q3: Top 5 Categories by Revenue
SELECT 
    v.category_name,
    ROUND(SUM(i.price), 2) AS total_revenue
FROM olist_order_items_dataset i
JOIN v_products_english v
ON i.product_id = v.product_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- Q4: Preferred Payment Methods
SELECT 
    payment_type,
    COUNT(order_id) AS total_transactions,
    ROUND(SUM(payment_value), 2) AS total_value
FROM olist_order_payments_dataset
GROUP BY 1
ORDER BY 2 DESC;

-- Q5: Customer Geography (States with highest customers)
SELECT 
    customer_state,
    COUNT(customer_id) AS customer_count
FROM olist_customers_dataset
GROUP BY 1
ORDER BY 2 DESC;

-- Q6: Top 10 Sellers by Sales Value
SELECT 
    seller_id,
    ROUND(SUM(price), 2) AS total_sales
FROM olist_order_items_dataset
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- Q7: Average Order Value (AOV)
SELECT 
    ROUND(SUM(payment_value) / COUNT(DISTINCT order_id), 2) AS average_order_value
FROM olist_order_payments_dataset;

-- Q8: Delay vs Review Score Correlation
SELECT 
    CASE 
        WHEN DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) > 0 THEN 'Delayed'
        ELSE 'On Time'
    END AS delivery_status,
    ROUND(AVG(review_score), 2) AS avg_review_score
FROM olist_orders_dataset o
JOIN olist_order_reviews_dataset r ON o.order_id = r.order_id
WHERE order_status = 'delivered' AND order_delivered_customer_date IS NOT NULL
GROUP BY 1;

-- Q9: Product Pricing Distribution
SELECT 
    category_name,
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    ROUND(AVG(price), 2) AS avg_price
FROM olist_order_items_dataset i
JOIN v_products_english v
ON i.product_id = v.product_id
GROUP BY 1
ORDER BY 4 DESC;

-- Q10: Late Delivery Percentage
SELECT 
    (SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS pct_late_deliveries
FROM olist_orders_dataset
WHERE order_status = 'delivered' AND order_delivered_customer_date IS NOT NULL;