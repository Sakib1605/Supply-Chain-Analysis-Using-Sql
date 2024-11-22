# Supply-Chain-Analysis-Using-SQL


## Objective
The purpose of this analysis is to identify trends, inefficiencies, and areas of improvement in the supply chain. By leveraging SQL queries, we examine key aspects such as supplier reliability, stock levels, manufacturing costs, shipping efficiency, and product performance. The ultimate goal is to provide actionable insights to enhance overall supply chain efficiency, reduce costs, and support strategic decision-making.

---

## Approach
The dataset, `supply_chain_data`, was analyzed using SQL queries to address specific business questions. Each query was designed to extract insights about different segments of the supply chain, including suppliers, products, transportation, and customer behaviors. Key metrics such as lead times, defect rates, and profit margins were calculated to provide a comprehensive view of supply chain performance.

---

## Business Questions and Analysis

### **Stockout Analysis: Which products frequently run out of stock?**

**Objective:** 
Identify products with frequent stockouts to improve inventory management.

**SQL Query:**
```sql
SELECT 
    Product_type,
    COUNT(*) AS StockoutOccurrences,
    AVG(Lead_times) AS AvgRestockTime
FROM 
    supply_chain_data
WHERE 
    Stock_levels = 0 -- Stockout condition
GROUP BY 
    Product_type
ORDER BY 
    StockoutOccurrences DESC;

```
Analysis: Counts the number of times each product type experiences a stockout and calculates the average restocking time.

Insights: Focus on maintaining adequate inventory for frequently out-of-stock products to prevent disruptions and lost sales.

### **Product Lifecycle: Which products show declining/increasing demand over time?**

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
**Analysis:** This query tracks monthly demand changes and categorizes trends as increasing, declining, or stable, highlighting shifts in market demand.

**Insights:** Focus on products with increasing demand to scale efforts, address declining demand to mitigate losses, and ensure consistent availability of stable products.


### **Profitability Analysis: Which products have the highest revenue but low profit margins?**

**Objective:** 
Identify high-revenue products with low profit margins to improve pricing strategies and cost management.

**SQL Query:**
```sql
SELECT 
    Product_type,
    SUM(Revenue_generated) AS TotalRevenue,
    SUM(Manufacturing_costs + Shipping_costs) AS TotalCosts,
    SUM(Revenue_generated - (Manufacturing_costs + Shipping_costs)) AS TotalProfit,
    ROUND(SUM(Revenue_generated - (Manufacturing_costs + Shipping_costs)) * 100.0 / NULLIF(SUM(Revenue_generated), 0), 2) AS ProfitMargin
FROM 
    supply_chain_data
GROUP BY 
    Product_type
ORDER BY 
    ProfitMargin ASC, TotalRevenue DESC;
```

Analysis: This query calculates total revenue, total costs, and profit margins for each product type, sorting by low profit margins to identify products with high revenue but suboptimal profitability.

**Insights:** High-revenue, low-margin products indicate potential areas for cost optimization, pricing adjustments, or process improvement to enhance profitability.


### **High Demand Regions: Which locations consistently order high volumes of products?**

**Objective:** 
Identify regions with high demand for specific products to prioritize inventory distribution and marketing efforts.

**SQL Query:**
```sql
SELECT 
    Location,
    Product_type,
    SUM(Order_quantities) AS TotalUnitsOrdered,
    ROUND(SUM(Order_quantities) * 100.0 / SUM(SUM(Order_quantities)) OVER (PARTITION BY Product_type), 2) AS DemandPercentage
FROM 
    supply_chain_data
GROUP BY 
    Location, Product_type
ORDER BY 
    DemandPercentage DESC, TotalUnitsOrdered DESC;
```

Analysis: This query calculates the total units ordered and the percentage share of demand for each product type by location, highlighting regions with the highest contribution to product demand.

**Insights:** Focus on high-demand regions to optimize inventory placement and tailor marketing strategies, ensuring better service and reduced logistics costs.

### **Shipping Delays: Which products experience frequent shipping delays and at what cost?**

**Objective:** 
Identify products with frequent shipping delays and quantify their associated costs.

**SQL Query:**
```sql
SELECT 
    Product_type,
    COUNT(*) AS TotalShipments,
    SUM(CASE WHEN Shipping_times > 7 THEN 1 ELSE 0 END) AS DelayedShipments,
    ROUND(SUM(CASE WHEN Shipping_times > 7 THEN Shipping_costs ELSE 0 END), 2) AS DelayCost,
    ROUND(SUM(CASE WHEN Shipping_times > 7 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DelayRate
FROM 
    supply_chain_data
GROUP BY 
    Product_type
ORDER BY 
    DelayedShipments DESC, DelayRate DESC, DelayCost DESC;

```
Analysis: This query calculates the frequency and cost of shipping delays for each product, highlighting products with the most delays.

Insights: Focus on products with high delay rates and costs to optimize shipping strategies and reduce delays.



### **Supplier Concentration Risk: Which products depend heavily on a single supplier??**
**Objective:** Evaluate products with high dependency on a single supplier to mitigate supply chain risks.
**SQL Query:**
```sql
SELECT TOP 5
    Product_type,
    Supplier_name,
    COUNT(*) AS TotalOrders,
    ROUND(COUNT(*) * 100.0 / NULLIF(SUM(COUNT(*)) OVER (PARTITION BY Product_type), 0), 2) AS SupplierDependency
FROM 
    supply_chain_data
GROUP BY 
    Product_type, Supplier_name
ORDER BY 
    SupplierDependency DESC;


```
Analysis: Calculates the dependency of each product type on its primary supplier by analyzing order shares.

Insights: Reduce risks by diversifying suppliers for products heavily reliant on a single vendor.



### **Inventory Turnover Analysis: Which products have the highest turnover rates by location?**
**Objective:** Identify products with high turnover rates to optimize stock management by location.
**SQL Query:**
```sql
WITH TurnoverAnalysis AS (
    SELECT 
        Product_type,
        Location,
        SUM(Number_of_products_sold) AS TotalUnitsSold,
        AVG(Stock_levels) AS AvgStock,
        CASE 
            WHEN AVG(Stock_levels) > 0 THEN 
                ROUND(SUM(Number_of_products_sold) / NULLIF(AVG(Stock_levels), 0), 2)
            ELSE 0 
        END AS TurnoverRate
    FROM 
        supply_chain_data
    GROUP BY 
        Product_type, Location
)
SELECT 
    Product_type,
    Location,
    TotalUnitsSold,
    AvgStock,
    TurnoverRate
FROM 
    TurnoverAnalysis
ORDER BY 
    TurnoverRate DESC, TotalUnitsSold DESC;
```

Analysis: Determines the turnover rates of products at different locations based on sales and stock levels.

Insights: High-turnover products indicate strong demand, necessitating adequate restocking to prevent shortages.




### **Cost-Efficiency by Supplier: Which suppliers have the lowest shipping and manufacturing costs per product?**
**Objective:** Identify cost-efficient suppliers to optimize procurement strategies.
**SQL Query:**
```sql
WITH SupplierCostEfficiency AS (
    SELECT 
        Supplier_name,
        Product_type,
        AVG(Shipping_costs) AS AvgShippingCost,
        AVG(Manufacturing_costs) AS AvgManufacturingCost,
        AVG(Shipping_costs + Manufacturing_costs) AS TotalAvgCost,
        SUM(Revenue_generated) AS TotalRevenue,
        ROUND(SUM(Revenue_generated - (Shipping_costs + Manufacturing_costs)), 2) AS TotalProfit,
        ROUND((SUM(Revenue_generated - (Shipping_costs + Manufacturing_costs)) * 100.0) / NULLIF(SUM(Revenue_generated), 0), 2) AS ProfitMargin
    FROM 
        supply_chain_data
    GROUP BY 
        Supplier_name, Product_type
),
RankedSuppliers AS (
    SELECT 
        Supplier_name,
        Product_type,
        AvgShippingCost,
        AvgManufacturingCost,
        TotalAvgCost,
        TotalRevenue,
        TotalProfit,
        ProfitMargin,
        ROW_NUMBER() OVER (PARTITION BY Product_type ORDER BY ProfitMargin DESC) AS Rank
    FROM 
        SupplierCostEfficiency
)
SELECT 
    Supplier_name,
    Product_type,
    AvgShippingCost,
    AvgManufacturingCost,
    TotalAvgCost,
    TotalRevenue,
    TotalProfit,
    ProfitMargin
FROM 
    RankedSuppliers
WHERE 
    Rank = 1
ORDER BY 
    ProfitMargin DESC;

```
Analysis: Calculates average shipping and manufacturing costs for suppliers and ranks them by cost efficiency.

Insights: Work with top-ranked suppliers to reduce costs and maximize profit margins.





### **High-Risk Products: Which products have low profitability and high defect rates?**
**Objective:** Identify products with high defect rates and low profitability for improvement.
**SQL Query:**
```sql
WITH DefectProfitAnalysis AS (
    SELECT 
        Product_type,
        SUM(CASE WHEN Inspection_results = 'Failed' THEN 1 ELSE 0 END) AS TotalDefects,
        ROUND(SUM(CASE WHEN Inspection_results = 'Failed' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0), 2) AS DefectRate,
        SUM(Revenue_generated) AS TotalRevenue,
        SUM(Manufacturing_costs + Shipping_costs) AS TotalCosts,
        ROUND(SUM(Revenue_generated - (Manufacturing_costs + Shipping_costs)), 2) AS TotalProfit,
        ROUND(SUM(Revenue_generated - (Manufacturing_costs + Shipping_costs)) * 100.0 / NULLIF(SUM(Revenue_generated), 0), 2) AS ProfitMargin
    FROM 
        supply_chain_data
    GROUP BY 
        Product_type
)
SELECT 
    Product_type,
    TotalDefects,
    DefectRate,
    TotalRevenue,
    TotalCosts,
    TotalProfit,
    ProfitMargin
FROM 
    DefectProfitAnalysis
ORDER BY 
    DefectRate DESC, ProfitMargin ASC;
```
Analysis: Ranks products based on defect rates and profitability to identify high-risk products.

Insights: Address high-defect, low-profit products to improve quality and profitability.


### **Regional Shipping Efficiency: Which regions have the most delays and highest shipping costs?**
**Objective:** Evaluate regional shipping performance to optimize costs and reduce delays.
**SQL Query:**
```sql
SELECT 
    Location,
    AVG(Shipping_times) AS AvgShippingTime,
    SUM(CASE WHEN Shipping_times > 7 THEN 1 ELSE 0 END) AS DelayedShipments,
    ROUND(SUM(CASE WHEN Shipping_times > 7 THEN Shipping_costs ELSE 0 END), 2) AS TotalDelayCost,
    COUNT(*) AS TotalShipments
FROM 
    supply_chain_data
GROUP BY 
    Location
ORDER BY 
    TotalDelayCost DESC, AvgShippingTime DESC;

```
Analysis: Calculates average shipping times, delays, and costs for each location.

Insights: Focus on improving shipping efficiency in high-cost regions to reduce delays and costs.

### **Product Reorder Cycles: What is the average reorder frequency for each product?**
**Objective:** Determine reorder cycles for products to streamline inventory planning.
**SQL Query:**
```sql
SELECT 
    Product_type,
    ROUND(AVG(Lead_times), 2) AS AvgReorderCycle,
    SUM(Order_quantities) AS TotalUnitsOrdered,
    AVG(Stock_levels) AS AvgStockOnHand
FROM 
    supply_chain_data
GROUP BY 
    Product_type
ORDER BY 
    AvgReorderCycle DESC, TotalUnitsOrdered DESC;
```

Analysis: Calculates average lead times for product reordering and evaluates stock levels.

Insights: Align reorder schedules with demand to ensure optimal inventory levels.


### **Defect Analysis: Which suppliers contribute to the highest defect rates?**

**Objective:** 
Determine which suppliers and products are associated with high defect rates to improve quality control.

**SQL Query:**
```sql
SELECT 
    Supplier_name,
    Product_type,
    COUNT(*) AS TotalInspections,
    SUM(CASE WHEN Inspection_results = 'Failed' THEN 1 ELSE 0 END) AS TotalDefects,
    ROUND(SUM(CASE WHEN Inspection_results = 'Failed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS DefectRate
FROM 
    supply_chain_data
GROUP BY 
    Supplier_name, Product_type
ORDER BY 
    DefectRate DESC;

```

Analysis: Calculates the defect rate for each supplier and product type by analyzing inspection outcomes.

Insights: High-defect suppliers and products should be targeted for quality improvement initiatives or alternative sourcing.


### **Supplier Performance: Which suppliers consistently meet lead times?**

**Objective:** 
Evaluate supplier reliability based on their adherence to promised lead times.

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
```

Analysis: This query calculates the on-time delivery percentage for each supplier by comparing actual lead times with manufacturing lead times.

Insights: Suppliers with high on-time percentages should be prioritized for procurement, while underperforming suppliers may need process improvements or alternative evaluations.

