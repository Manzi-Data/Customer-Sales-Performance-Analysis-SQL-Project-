-- ================================================================================
--         1. (Top Customer Analysis)
--         Q. Who are our most valuable customers?
-- ================================================================================
WITH CustomerSales AS (
    SELECT 
        c.CustomerID,
        c.FirstName,
        c.LastName,
        c.Email,
        c.Phone,
        c.Country,
        c.CustomerTier,
        SUM(o.TotalAmount) AS TotalSales,  
        COUNT(o.OrderID) AS TotalOrders   
    FROM Customers c
    INNER JOIN Orders o 
        ON c.CustomerID = o.CustomerID
    GROUP BY 
        c.CustomerID, 
        c.FirstName, 
        c.LastName, 
        c.Email, 
        c.Phone, 
        c.Country, 
        c.CustomerTier
)

SELECT 
    ROW_NUMBER() OVER (ORDER BY TotalSales DESC) AS RankID,
    CustomerID,
    FirstName,
    LastName,
    Email,
    Phone,
    Country,
    CustomerTier,
    TotalSales,
    TotalOrders,

    SUM(TotalSales) OVER() AS OverallRevenue,
    CAST(TotalSales * 100.0 / SUM(TotalSales) OVER() AS DECIMAL(5,2)) AS RevenuePercent,
    CAST(TotalSales * 1.0 / NULLIF(TotalOrders, 0) AS DECIMAL(10,2)) AS AvgOrderValue

FROM CustomerSales
ORDER BY TotalSales DESC;

-- I created a customer-level aggregation to calculate total revenue and order frequency, 
-- then used window functions to rank customers and calculate their contribution to overall revenue. 
-- This helped identify high-value customers and understand their purchasing behavior.

   
-- ================================================================================
--         2. (Comparative analysis)
--         Q. How does sales performance vary across customer segments?
-- ================================================================================
SELECT 
    c.CustomerTier, 

    COUNT(o.OrderID) AS TotalOrders,

    SUM(o.TotalAmount) AS TotalRevenue,

    AVG(o.TotalAmount) AS AvgOrderValue,

    SUM(SUM(o.TotalAmount)) OVER() AS OverallRevenue,

    CAST(SUM(o.TotalAmount) * 100.0 
         / SUM(SUM(o.TotalAmount)) OVER() AS DECIMAL(5,2)) AS RevenuePercent,

    RANK() OVER (ORDER BY SUM(o.TotalAmount) DESC) AS SegmentRank

FROM Customers c
JOIN Orders o 
    ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerTier
ORDER BY TotalRevenue DESC;

-- Silver customers generate the highest revenue and contribute the largest share of total sales, 
-- while standard customers place more frequent but lower-value orders.

-- ================================================================================
--         3. (Product Performance Analysis)
--         Q. Which products generate the highest profit?
-- ================================================================================
SELECT 
    p.ProductID,
    p.ProductName,
    p.Category,

    SUM(oi.Quantity) AS TotalUnitsSold,
    SUM(oi.LineTotal) AS TotalRevenue,
    SUM(oi.Quantity * p.Cost) AS TotalCost,
    SUM(oi.LineTotal - (oi.Quantity * p.Cost)) AS TotalProfit,

    CAST(
        SUM(oi.LineTotal - (oi.Quantity * p.Cost)) * 100.0
        / NULLIF(SUM(oi.LineTotal), 0)
        AS DECIMAL(18,2) 
    ) AS ProfitMargin,

    CAST(
        SUM(oi.LineTotal - (oi.Quantity * p.Cost)) * 100.0
        / NULLIF(SUM(SUM(oi.LineTotal - (oi.Quantity * p.Cost))) OVER(), 0)
        AS DECIMAL(18,2)
    ) AS ProfitContributionPercent,

    RANK() OVER (
        ORDER BY SUM(oi.LineTotal - (oi.Quantity * p.Cost)) DESC
    ) AS ProfitRank

FROM OrderItems oi
JOIN Products p 
    ON oi.ProductID = p.ProductID
GROUP BY 
    p.ProductID, 
    p.ProductName, 
    p.Category
ORDER BY TotalProfit DESC;

-- The company can optimize profitability by focusing on high-margin products and reviewing pricing or cost strategies for low-margin,
-- high-volume items.

-- ================================================================================
--         4. (Trend analysis)
--         Q. Are customers increasing or decreasing their spending over time?
-- ================================================================================
WITH MonthlySales AS (
    SELECT 
        DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1) AS SalesMonth,
        SUM(TotalAmount) AS CurrentMonthSpending
    FROM Orders
    GROUP BY DATEFROMPARTS(YEAR(OrderDate), MONTH(OrderDate), 1)
)

SELECT 
    SalesMonth,
    CurrentMonthSpending,

    LAG(CurrentMonthSpending) OVER (ORDER BY SalesMonth) AS PreviousMonthSpending,

    CurrentMonthSpending 
        - LAG(CurrentMonthSpending) OVER (ORDER BY SalesMonth) AS GrowthDifference,

    CAST(
        (
            CurrentMonthSpending 
            - LAG(CurrentMonthSpending) OVER (ORDER BY SalesMonth)
        ) * 100.0
        / NULLIF(LAG(CurrentMonthSpending) OVER (ORDER BY SalesMonth), 0)
        AS DECIMAL(10,2)
    ) AS MoM_Growth_Percent

FROM MonthlySales
ORDER BY SalesMonth;

-- The business can use these trends to plan marketing campaigns, inventory levels, 
-- and staffing during high or low demand periods.

-- ================================================================================
--         5. (Performance Ranking)
--         Q. Which employees perform best in terms of revenue?
-- ================================================================================
SELECT 
    e.EmployeeID,

    e.FirstName + ' ' + e.LastName AS EmployeeName,

    COUNT(o.OrderID) AS TotalOrders,

    SUM(o.TotalAmount) AS TotalRevenueGenerated,
    
    RANK() OVER (
        ORDER BY SUM(o.TotalAmount) DESC
    ) AS RevenueRank,
    
    CAST(AVG(o.TotalAmount) AS DECIMAL(18,2)) AS AvgOrderValue

FROM Employees e

JOIN Orders o 
    ON e.EmployeeID = o.EmployeeID

GROUP BY 
    e.EmployeeID, 
    e.FirstName, 
    e.LastName

ORDER BY TotalRevenueGenerated DESC;

-- High average order value may indicate stronger negotiation skills or focus on premium products.

-- ================================================================================
--         6. (Quality Control)
--         Q. What is the return rate and which products are most returned?
-- ================================================================================
SELECT 
    p.ProductName,
    p.Category,

    COUNT(o.OrderID) AS TotalOrders,

    SUM(
        CASE 
            WHEN o.Status = 'Returned' THEN 1 
            ELSE 0 
        END
    ) AS TotalReturns,

    CAST(
        SUM(CASE WHEN o.Status = 'Returned' THEN 1 ELSE 0 END) * 100.0 
        / NULLIF(COUNT(o.OrderID), 0) 
    AS DECIMAL(18,2)) AS ReturnRatePercentage

FROM Products p

JOIN OrderItems oi 
    ON p.ProductID = oi.ProductID

JOIN Orders o 
    ON oi.OrderID = o.OrderID

GROUP BY 
    p.ProductName, 
    p.Category
ORDER BY ReturnRatePercentage DESC;

-- The company should investigate high-return products to improve quality, 
-- adjust product descriptions, or refine return policies.

-- ================================================================================
--         7. (ROI Analysis)
--         Q. Are marketing campaigns profitable?
-- ================================================================================
SELECT 
    c.CampaignName,
    c.Budget AS CampaignCost,

    COALESCE(SUM(o.TotalAmount), 0) AS TotalRevenue,

    COALESCE(SUM(o.TotalAmount), 0) - c.Budget AS NetProfit,

    CAST(
        (
            (COALESCE(SUM(o.TotalAmount), 0) - c.Budget) * 100.0
        ) / NULLIF(c.Budget, 0)
    AS DECIMAL(18,2)) AS ROIPercentage

FROM Campaigns c
LEFT JOIN Orders o 
    ON c.CampaignID = o.CampaignID

GROUP BY c.CampaignName, c.Budget
ORDER BY ROIPercentage DESC;
SELECT 
    c.CampaignName,
    c.Budget AS CampaignCost,

    COALESCE(SUM(o.TotalAmount), 0) AS TotalRevenue,

    COALESCE(SUM(o.TotalAmount), 0) - c.Budget AS NetProfit,

    CAST(
        (
            (COALESCE(SUM(o.TotalAmount), 0) - c.Budget) * 100.0
        ) / NULLIF(c.Budget, 0)
    AS DECIMAL(18,2)) AS ROIPercentage

FROM Campaigns c
LEFT JOIN Orders o 
    ON c.CampaignID = o.CampaignID

GROUP BY c.CampaignName, c.Budget
ORDER BY ROIPercentage DESC;

-- The company should scale high-ROI campaigns and reevaluate or discontinue underperforming ones.