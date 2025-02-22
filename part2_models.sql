/* Questions

1. What are the top 5 brands by receipts scanned for most recent month?
2. How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?
3. When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
4. When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
5. Which brand has the most spend among users who were created within the past 6 months?
6. Which brand has the most transactions among users who were created within the past 6 months?

*/

WITH
-- 1. Get the most recent and previous month receipts
monthly_receipts AS (
    SELECT
        ri.brand_id,
        b.name AS brand_name,
        DATE_TRUNC('month', r.purchase_date) AS purchase_month,
        COUNT(DISTINCT r.receipt_id) AS receipt_count
    FROM receipts r
    JOIN receipt_items ri ON r.receipt_id = ri.receipt_id
    JOIN brands b ON ri.brand_id = b.brand_id
    WHERE r.purchase_date IS NOT NULL
    GROUP BY 1, 2, 3
),

recent_month AS (
    SELECT MAX(purchase_month) AS latest_month FROM monthly_receipts
),

-- 2. Top 5 brands by receipts scanned for the most recent month
top_5_recent_month AS (
    SELECT
        brand_id,
        brand_name,
        receipt_count,
        RANK() OVER (ORDER BY receipt_count DESC) AS rank_current_month
    FROM monthly_receipts, recent_month
    WHERE purchase_month = latest_month
    ORDER BY rank_current_month
    LIMIT 5
),

-- 3. Ranking comparison with the previous month
top_5_previous_month AS (
    SELECT
        mr.brand_id,
        mr.brand_name,
        mr.receipt_count,
        RANK() OVER (ORDER BY mr.receipt_count DESC) AS rank_previous_month
    FROM monthly_receipts mr
    JOIN recent_month rm ON mr.purchase_month = rm.latest_month - INTERVAL '1 month'
    WHERE mr.brand_id IN (SELECT brand_id FROM top_5_recent_month)
),

-- 4. Average spend comparison for 'Accepted' vs 'Rejected'
avg_spend_status AS (
    SELECT
        rewards_receipt_status,
        ROUND(AVG(total_spent), 2) AS avg_spend
    FROM receipts
    WHERE rewards_receipt_status IN ('Accepted', 'Rejected')
    GROUP BY 1
),

-- 5. Total items purchased for 'Accepted' vs 'Rejected'
total_items_status AS (
    SELECT
        r.rewards_receipt_status,
        SUM(ri.quantity) AS total_items
    FROM receipts r
    JOIN receipt_items ri ON r.receipt_id = ri.receipt_id
    WHERE r.rewards_receipt_status IN ('Accepted', 'Rejected')
    GROUP BY 1
),

-- 6. Users created within the last 6 months
recent_users AS (
    SELECT user_id
    FROM users
    WHERE created_date >= CURRENT_DATE - INTERVAL '6 months'
),

-- 7. Brand with most spend among recent users
brand_spend_recent_users AS (
    SELECT
        ri.brand_id,
        b.name AS brand_name,
        SUM(ri.item_spent) AS total_spend
    FROM receipts r
    JOIN receipt_items ri ON r.receipt_id = ri.receipt_id
    JOIN brands b ON ri.brand_id = b.brand_id
    WHERE r.user_id IN (SELECT user_id FROM recent_users)
    GROUP BY 1, 2
    ORDER BY total_spend DESC
    LIMIT 1
),

-- 8. Brand with most transactions among recent users
brand_transactions_recent_users AS (
    SELECT
        ri.brand_id,
        b.name AS brand_name,
        COUNT(DISTINCT r.receipt_id) AS total_transactions
    FROM receipts r
    JOIN receipt_items ri ON r.receipt_id = ri.receipt_id
    JOIN brands b ON ri.brand_id = b.brand_id
    WHERE r.user_id IN (SELECT user_id FROM recent_users)
    GROUP BY 1, 2
    ORDER BY total_transactions DESC
    LIMIT 1
)

-- Final combined results
SELECT
    -- Q1 & Q2: Top 5 brands by receipts scanned for recent month + rank comparison
    t5rm.brand_name AS top_brand_recent_month,
    t5rm.rank_current_month,
    COALESCE(t5pm.rank_previous_month, 'Not in top 5') AS rank_previous_month,

    -- Q3: Average spend comparison
    (SELECT avg_spend FROM avg_spend_status WHERE rewards_receipt_status = 'Accepted') AS avg_spend_accepted,
    (SELECT avg_spend FROM avg_spend_status WHERE rewards_receipt_status = 'Rejected') AS avg_spend_rejected,

    -- Q4: Total items comparison
    (SELECT total_items FROM total_items_status WHERE rewards_receipt_status = 'Accepted') AS total_items_accepted,
    (SELECT total_items FROM total_items_status WHERE rewards_receipt_status = 'Rejected') AS total_items_rejected,

    -- Q5: Brand with most spend among recent users
    (SELECT brand_name FROM brand_spend_recent_users) AS brand_most_spend_recent_users,
    (SELECT total_spend FROM brand_spend_recent_users) AS total_spend_recent_users,

    -- Q6: Brand with most transactions among recent users
    (SELECT brand_name FROM brand_transactions_recent_users) AS brand_most_transactions_recent_users,
    (SELECT total_transactions FROM brand_transactions_recent_users) AS total_transactions_recent_users

FROM top_5_recent_month t5rm
LEFT JOIN top_5_previous_month t5pm ON t5rm.brand_id = t5pm.brand_id;
