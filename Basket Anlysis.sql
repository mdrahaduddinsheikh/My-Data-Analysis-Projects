-- ** Pizza Basket Analysis.
-- 1. Identify Most Frequently Ordered Pizzas.

SELECT pt.name AS pizza_name, COUNT(od.order_id) AS total_orders
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
join order_details od on od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY total_orders DESC
LIMIT 10;


-- 2. Find Pizza Combinations Ordered Together

SELECT pt1.name AS pizza_A, pt2.name AS pizza_B, COUNT(*) AS frequency
FROM order_details od1
JOIN order_details od2
  ON od1.order_id = od2.order_id AND od1.pizza_id <> od2.pizza_id
JOIN pizzas p1 ON od1.pizza_id = p1.pizza_id
JOIN pizzas p2 ON od2.pizza_id = p2.pizza_id
JOIN pizza_types pt1 ON p1.pizza_type_id = pt1.pizza_type_id
JOIN pizza_types pt2 ON p2.pizza_type_id = pt2.pizza_type_id
WHERE pt1.name < pt2.name
GROUP BY pizza_A, pizza_B
ORDER BY frequency DESC
LIMIT 10;


-- ***Calculate Support, Confidence, and Lift.
-- 3. Support (How frequently an item appears in transactions).

SELECT pt.name AS pizza_name, 
       COUNT(od.pizza_id) / (SELECT COUNT(DISTINCT order_id) FROM order_details) AS support
FROM order_details od 
JOIN pizzas p ON od.pizza_id = p.pizza_id 
join pizza_types pt on p.pizza_type_id = pt.pizza_type_id
GROUP BY pt.name 
ORDER BY support DESC;


-- 4. Confidence (How often B is bought when A is bought).

WITH pizza_order_count AS (
    SELECT pizza_id, COUNT(*) AS total_orders
    FROM order_details
    GROUP BY pizza_id
)
SELECT pt1.name AS pizza_A, pt2.name AS pizza_B, 
       COUNT(*) / poc.total_orders AS confidence
FROM order_details od1
JOIN order_details od2 
  ON od1.order_id = od2.order_id AND od1.pizza_id <> od2.pizza_id
JOIN pizzas p1 ON od1.pizza_id = p1.pizza_id
JOIN pizzas p2 ON od2.pizza_id = p2.pizza_id
JOIN pizza_types pt1 ON p1.pizza_type_id = pt1.pizza_type_id
JOIN pizza_types pt2 ON p2.pizza_type_id = pt2.pizza_type_id
JOIN pizza_order_count poc ON p1.pizza_id = poc.pizza_id
WHERE pt1.name > pt2.name
GROUP BY pt1.name, pt2.name, poc.total_orders
ORDER BY confidence DESC
LIMIT 10;


-- 5. Lift (Strength of the relationship).

WITH total_orders_cte AS (
    SELECT COUNT(DISTINCT order_id) AS total_orders
    FROM order_details
),
pizza_counts AS (
    SELECT pizza_id, COUNT(DISTINCT order_id) AS orders_count
    FROM order_details
    GROUP BY pizza_id
),
pair_counts AS (
    SELECT 
        od1.pizza_id AS pizza_A_id, 
        od2.pizza_id AS pizza_B_id, 
        COUNT(DISTINCT od1.order_id) AS pair_count
    FROM order_details od1
    JOIN order_details od2 
      ON od1.order_id = od2.order_id 
     AND od1.pizza_id < od2.pizza_id   
    GROUP BY od1.pizza_id, od2.pizza_id
)
SELECT 
    pt1.name AS pizza_A, 
    pt2.name AS pizza_B,
    (pc_pair.pair_count * tot.total_orders) / (pc1.orders_count * pc2.orders_count) AS lift
FROM pair_counts pc_pair
JOIN pizza_counts pc1 ON pc_pair.pizza_A_id = pc1.pizza_id
JOIN pizza_counts pc2 ON pc_pair.pizza_B_id = pc2.pizza_id
CROSS JOIN total_orders_cte tot
JOIN pizzas p1 ON pc_pair.pizza_A_id = p1.pizza_id
JOIN pizzas p2 ON pc_pair.pizza_B_id = p2.pizza_id
JOIN pizza_types pt1 ON p1.pizza_type_id = pt1.pizza_type_id
JOIN pizza_types pt2 ON p2.pizza_type_id = pt2.pizza_type_id
ORDER BY lift DESC
LIMIT 10;













