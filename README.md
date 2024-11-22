# Supply-Chain-Analysis-Using-SQL


## Objective
The purpose of this analysis is to identify trends, inefficiencies, and areas of improvement in the supply chain. By leveraging SQL queries, we examine key aspects such as supplier reliability, stock levels, manufacturing costs, shipping efficiency, and product performance. The ultimate goal is to provide actionable insights to enhance overall supply chain efficiency, reduce costs, and support strategic decision-making.

---

## Approach
The dataset, `supply_chain_data`, was analyzed using SQL queries to address specific business questions. Each query was designed to extract insights about different segments of the supply chain, including suppliers, products, transportation, and customer behaviors. Key metrics such as lead times, defect rates, and profit margins were calculated to provide a comprehensive view of supply chain performance.

---

## Business Questions and Analysis

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
