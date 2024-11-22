SELECT TOP (1000) [Product_type]
      ,[SKU]
      ,[Price]
      ,[Availability]
      ,[Number_of_products_sold]
      ,[Revenue_generated]
      ,[Customer_demographics]
      ,[Stock_levels]
      ,[Lead_times]
      ,[Order_quantities]
      ,[Shipping_times]
      ,[Shipping_carriers]
      ,[Shipping_costs]
      ,[Supplier_name]
      ,[Location]
      ,[Lead_time]
      ,[Production_volumes]
      ,[Manufacturing_lead_time]
      ,[Manufacturing_costs]
      ,[Inspection_results]
      ,[Defect_rates]
      ,[Transportation_modes]
      ,[Routes]
      ,[Costs]
      ,[Order_date]
  FROM supply_chain_data



-- Question.
-- Supplier Performance: Which suppliers consistently meet lead times?
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

-- Question. Stockout Analysis: Which products frequently run out of stock?
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


-- Question. Defect Analysis: Which suppliers contribute to the highest defect rates?
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


-- Question.
-- High-Cost Products: Which products have the highest manufacturing and shipping costs?

SELECT 
    Product_type,
    AVG(Manufacturing_costs) AS AvgManufacturingCost,
    AVG(Shipping_costs) AS AvgShippingCost,
    AVG(Manufacturing_costs + Shipping_costs) AS AvgTotalCost,
    SUM(Revenue_generated) AS TotalRevenue,
    ROUND(SUM(Revenue_generated) - SUM(Manufacturing_costs + Shipping_costs), 2) AS TotalProfit
FROM 
    supply_chain_data
GROUP BY 
    Product_type
ORDER BY 
    AvgTotalCost DESC;


-- Question. High-Volume Shipments: Which transportation modes are most cost-efficient for large shipments?
SELECT 
    Transportation_modes,
    AVG(Shipping_costs) AS AvgShippingCost,
    AVG(Shipping_times) AS AvgShippingTime,
    SUM(Order_quantities) AS TotalOrderQuantity
FROM 
    supply_chain_data
GROUP BY 
    Transportation_modes
HAVING 
    SUM(Order_quantities) > 5000 -- Focus on high-volume shipments
ORDER BY 
    AvgShippingCost ASC, AvgShippingTime ASC;

-------------------------------------------
-- Question. Profitability by Region: Which locations generate the highest profit margins?
SELECT 
    Location,
    SUM(Revenue_generated) AS TotalRevenue,
    SUM(Manufacturing_costs + Shipping_costs) AS TotalCosts,
    ROUND(SUM(Revenue_generated - (Manufacturing_costs + Shipping_costs)), 2) AS TotalProfit,
    ROUND(SUM(Revenue_generated - (Manufacturing_costs + Shipping_costs)) * 100.0 / NULLIF(SUM(Revenue_generated), 0), 2) AS ProfitMargin
FROM 
    supply_chain_data
GROUP BY 
    Location
ORDER BY 
    ProfitMargin DESC, TotalProfit DESC;

-------------------------------------------


-- Question. Seasonal Trends: How does product demand vary by month?
SELECT 
    MONTH(Order_date) AS OrderMonth,
    Product_type,
    SUM(Order_quantities) AS TotalUnitsSold,
    SUM(Revenue_generated) AS MonthlyRevenue
FROM 
    supply_chain_data
GROUP BY 
    MONTH(Order_date), Product_type
ORDER BY 
    OrderMonth ASC, MonthlyRevenue DESC;


-- Question. Which products consistently generate low revenue?
SELECT 
    Product_type,
    AVG(Revenue_generated) AS AvgRevenue,
    AVG(Order_quantities) AS AvgUnitsSold
FROM 
    supply_chain_data
GROUP BY 
    Product_type
ORDER BY 
    AvgRevenue ASC;


-- Question. Revenue Recovery: What is the revenue loss due to returned products?
SELECT 
    Product_type,
    SUM(CASE WHEN Inspection_results = 'Returned' THEN Revenue_generated ELSE 0 END) AS RevenueLost,
    SUM(Revenue_generated) AS TotalRevenue,
    ROUND(SUM(CASE WHEN Inspection_results = 'Returned' THEN Revenue_generated ELSE 0 END) * 100.0 / NULLIF(SUM(Revenue_generated), 0), 2) AS RevenueLostPercentage
FROM 
    supply_chain_data
GROUP BY 
    Product_type
ORDER BY 
    RevenueLost DESC;


-- Question. Inventory Turnover: Which products have the highest turnover rates?
SELECT 
    Product_type,
    SUM(Number_of_products_sold) AS TotalUnitsSold,
    AVG(Stock_levels) AS AvgStock,
    ROUND(SUM(Number_of_products_sold) / NULLIF(AVG(Stock_levels), 1), 2) AS TurnoverRate
FROM 
    supply_chain_data
GROUP BY 
    Product_type
ORDER BY 
    TurnoverRate DESC;


-- Question. Production Bottlenecks: Which products suffer the most from delayed manufacturing?
SELECT 
    Product_type,
    AVG(Manufacturing_lead_time) AS AvgManufacturingLeadTime,
    AVG(Lead_times) AS AvgDeliveryLeadTime,
    COUNT(*) AS TotalOrders
FROM 
    supply_chain_data
GROUP BY 
    Product_type
HAVING 
    AVG(Manufacturing_lead_time) > 10 -- Focus on delayed manufacturing
ORDER BY 
    AvgManufacturingLeadTime DESC, AvgDeliveryLeadTime DESC;


-- Question. Profitability Analysis: Which products have the highest revenue but low profit margins?
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


-- Question. High Demand Regions: Which locations consistently order high volumes of products?
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

-- Question. Shipping Delays: Which products experience frequent shipping delays and at what cost?
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


-- Question. Supplier Concentration Risk: Which products depend heavily on a single supplier?
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

-- Question. Inventory Turnover Analysis: Which products have the highest turnover rates by location?
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

-- Question. Cost-Efficiency by Supplier: Which suppliers have the lowest shipping and manufacturing costs per product?
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
    Rank = 1 -- Select only the top-ranked supplier
ORDER BY 
    ProfitMargin DESC;



-- Question. High-Risk Products: Which products have low profitability and high defect rates?
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



-- Question. Regional Shipping Efficiency: Which regions have the most delays and highest shipping costs?
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


-- Question. Product Reorder Cycles: What is the average reorder frequency for each product?
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


-- Question.
-- What are the trends in revenue generation across months for high-demand products?
SELECT 
    MONTH(Order_date) AS OrderMonth, -- Extracts the month as a numeric value (1 to 12)
    Product_type,
    SUM(Revenue_generated) AS MonthlyRevenue,
    SUM(Order_quantities) AS TotalUnitsSold
FROM 
    supply_chain_data
GROUP BY 
    MONTH(Order_date), Product_type
HAVING 
    SUM(Order_quantities) > 500
ORDER BY 
    OrderMonth ASC, MonthlyRevenue DESC;






-- Question 2. 
-- Which products have the highest return rates, and what is the revenue impact of these returns?
SELECT 
    Product_type,
    COUNT(*) AS TotalOrders,
    SUM(CASE WHEN Inspection_results = 'Returned' THEN 1 ELSE 0 END) AS TotalReturns,
    ROUND(SUM(CASE WHEN Inspection_results = 'Returned' THEN Revenue_generated ELSE 0 END) * 100.0 / NULLIF(SUM(Revenue_generated), 0), 2) AS RevenueLostPercentage
FROM 
    supply_chain_data
GROUP BY 
    Product_type
ORDER BY 
    RevenueLostPercentage DESC;


-- Question 3. 
-- What are the most cost-effective suppliers when considering both manufacturing and shipping costs?
SELECT 
    Supplier_name,
    SUM(Manufacturing_costs) AS TotalManufacturingCosts,
    SUM(Shipping_costs) AS TotalShippingCosts,
    (SUM(Manufacturing_costs) + SUM(Shipping_costs)) AS TotalCosts,
    ROUND(SUM(Revenue_generated) - (SUM(Manufacturing_costs) + SUM(Shipping_costs)), 2) AS TotalProfit
FROM 
    supply_chain_data
GROUP BY 
    Supplier_name
ORDER BY 
    TotalProfit DESC, TotalCosts ASC;



-- Question 4. 
-- Which customer demographics generate the most revenue, and what are their purchasing patterns?
SELECT 
    Customer_demographics,
    SUM(Revenue_generated) AS TotalRevenue,
    COUNT(*) AS TotalOrders,
    AVG(Order_quantities) AS AvgOrderQuantity
FROM 
    supply_chain_data
GROUP BY 
    Customer_demographics
ORDER BY 
    TotalRevenue DESC;




-- Question. How do defect rates impact production efficiency across suppliers?

SELECT 
    Supplier_name,
    AVG(Defect_rates) AS AvgDefectRate,
    SUM(Production_volumes) AS TotalProductionVolume,
    ROUND(SUM(Production_volumes) / NULLIF(AVG(Defect_rates), 0), 2) AS ProductionEfficiency
FROM 
    supply_chain_data
GROUP BY 
    Supplier_name
ORDER BY 
    AvgDefectRate ASC, ProductionEfficiency DESC;

-- Question. Which transportation modes are the most efficient for shipping high-volume products?
SELECT 
    Transportation_modes,
    Product_type,
    AVG(Shipping_costs) AS AvgShippingCost,
    AVG(Shipping_times) AS AvgShippingTime,
    SUM(Order_quantities) AS TotalOrderQuantity
FROM 
    supply_chain_data
GROUP BY 
    Transportation_modes, Product_type
ORDER BY 
     AvgShippingCost ASC, AvgShippingTime ASC,TotalOrderQuantity DESC;


-- Question. Product Lifecycle: Which products show declining/increasing demand over time?
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











