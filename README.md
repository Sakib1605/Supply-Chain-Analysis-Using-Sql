# Supply-Chain-Analysis-Using-SQL


## Objective
The purpose of this analysis is to identify trends, inefficiencies, and areas of improvement in the supply chain. By leveraging SQL queries, we examine key aspects such as supplier reliability, stock levels, manufacturing costs, shipping efficiency, and product performance. The ultimate goal is to provide actionable insights to enhance overall supply chain efficiency, reduce costs, and support strategic decision-making.

---

## Approach
The dataset, `supply_chain_data`, was analyzed using SQL queries to address specific business questions. Each query was designed to extract insights about different segments of the supply chain, including suppliers, products, transportation, and customer behaviors. Key metrics such as lead times, defect rates, and profit margins were calculated to provide a comprehensive view of supply chain performance.

---

## Business Questions and Analysis


### **8. Product Lifecycle: Which products show declining/increasing demand over time?**

**Objective:** 
Determine trends in product demand over time to support strategic inventory and production decisions.

**SQL Query:**
```sql
WITH MonthlyDemand AS (
    SELECT 
        Product_type,
        DATEPART(YEAR, Order_date) AS OrderYear,
        DATEPART(MONTH, Order_date) AS OrderMonth,
        SUM(Order_quantities) AS MonthlyOrders
    FROM 
        supply_chain_data
    GROUP BY 
        Product_type, DATEPART(YEAR, Order_date), DATEPART(MONTH, Order_date)
),
MonthlyDemandWithLag AS (
    SELECT 
        Product_type,
        OrderYear,
        OrderMonth,
        MonthlyOrders,
        LAG(MonthlyOrders) OVER (
            PARTITION BY Product_type 
            ORDER BY OrderYear, OrderMonth
        ) AS PreviousMonthOrders
    FROM 
        MonthlyDemand
)
SELECT 
    Product_type,
    CONCAT(OrderYear, '-', OrderMonth) AS CurrentMonth,
    MonthlyOrders AS CurrentMonthOrders,
    PreviousMonthOrders,
    ROUND((MonthlyOrders - PreviousMonthOrders) * 100.0 / NULLIF(PreviousMonthOrders, 0), 2) AS MoMChangePercentage,
    CASE 
        WHEN (MonthlyOrders - PreviousMonthOrders) > 0 THEN 'Increasing Demand'
        WHEN (MonthlyOrders - PreviousMonthOrders) < 0 THEN 'Declining Demand'
        ELSE 'No Change'
    END AS DemandTrend
FROM 
    MonthlyDemandWithLag
WHERE 
    PreviousMonthOrders IS NOT NULL -- Exclude the first month since it has no previous month
ORDER BY 
    Product_type, OrderYear, OrderMonth;

```
Analysis: This query tracks monthly demand changes and categorizes trends as increasing, declining, or stable, highlighting shifts in market demand.

Insights: Focus on products with increasing demand to scale efforts, address declining demand to mitigate losses, and ensure consistent availability of stable products.

### **1. Supplier Performance: Which suppliers consistently meet lead times?**
**Objective:** Identify reliable suppliers to strengthen partnerships and improve overall supply chain reliability.
**SQL Query:**
```sql
SELECT 
    Supplier_name,
    COUNT(*) AS TotalOrders,
    SUM(CASE WHEN Lead_times <= Manufacturing_lead_time THEN 1 ELSE 0 END) AS OnTimeOrders,
    ROUND(SUM(CASE WHEN Lead_times <= Manufacturing_lead_time THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS OnTimePercentage
FROM 
    supply_chain_data
GROUP BY 
    Supplier_name
HAVING 
    ROUND(SUM(CASE WHEN Lead_times <= Manufacturing_lead_time THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) >= 40
ORDER BY 
    OnTimePercentage DESC;
