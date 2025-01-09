WITH order_summary AS (
    SELECT 
        CUSTOMERNAME,
        ORDERNUMBER,
        ORDERDATE,
        SUM(SALES) AS TOTAL_SALES
    FROM sales_sample_data
    GROUP BY CUSTOMERNAME, ORDERNUMBER, ORDERDATE
),
RFM_Segmentation AS (
    SELECT 
        t1.CUSTOMERNAME, 
        COUNT(t1.ORDERNUMBER) AS Frequency,
        ROUND(SUM(t1.TOTAL_SALES), 0) AS Monetary,
        DATEDIFF(
            (SELECT MAX(STR_TO_DATE(ORDERDATE, '%d/%m/%y')) FROM order_summary),
            (SELECT MAX(STR_TO_DATE(ORDERDATE, '%d/%m/%y')) 
             FROM order_summary 
             WHERE CUSTOMERNAME = t1.CUSTOMERNAME)
        ) AS Recency,
         NTILE(4) OVER (
            ORDER BY DATEDIFF(
                (SELECT MAX(STR_TO_DATE(ORDERDATE, '%d/%m/%y')) FROM order_summary),
                (SELECT MAX(STR_TO_DATE(ORDERDATE, '%d/%m/%y')) 
                 FROM order_summary 
                 WHERE CUSTOMERNAME = t1.CUSTOMERNAME)
            ) DESC
        ) AS R,
        NTILE(4) OVER (ORDER BY COUNT(t1.ORDERNUMBER) ASC) AS F,
        NTILE(4) OVER (ORDER BY ROUND(SUM(t1.TOTAL_SALES), 0) ASC) AS M
    FROM order_summary t1
    GROUP BY t1.CUSTOMERNAME
),
Customer_Segmentation AS (
    SELECT 
        CUSTOMERNAME, 
        Recency, 
        Frequency, 
        Monetary, 
        R, 
        F, 
        M, 
        CONCAT('', R, F, M) AS RFM
    FROM RFM_Segmentation
    ORDER BY CUSTOMERNAME
),
Final AS (
    SELECT 
        CUSTOMERNAME,
        Recency,
        Frequency,
        Monetary,
        R,
        F,
        M,
        RFM,
        CASE
            WHEN RFM IN ('111', '112', '121', '123', '132', '211', '212', '114', '141') THEN 'CHURNED CUSTOMER'
            WHEN RFM IN ('133', '134', '143', '244', '334', '343', '344', '144') THEN 'SLIPPING AWAY, CANNOT LOSE'
            WHEN RFM IN ('311', '411', '331') THEN 'NEW CUSTOMERS'
            WHEN RFM IN ('222', '231', '221', '223', '233', '322') THEN 'POTENTIAL CHURNERS'
            WHEN RFM IN ('323', '333', '321', '341', '422', '332', '432') THEN 'ACTIVE'
            WHEN RFM IN ('433', '434', '443', '444') THEN 'LOYAL'
            ELSE 'CANNOT BE DEFINED'
        END AS CUSTOMER_SEGMENT
    FROM Customer_Segmentation
)
SELECT 
    CUSTOMERNAME, 
    Recency, 
    Frequency, 
    Monetary, 
    R, 
    F, 
    M, 
    RFM, 
    Customer_Segment
FROM Final
ORDER BY CUSTOMERNAME;
