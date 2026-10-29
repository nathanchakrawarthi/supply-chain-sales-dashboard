-- 1. Create and select the database
CREATE DATABASE IF NOT EXISTS supply_chain_db;
USE supply_chain_db;

-- 2. Create Customer Dimension Table
CREATE TABLE customer (
    PK_Customer INT PRIMARY KEY,
    CustomerCode VARCHAR(20),
    CustomerFirstName VARCHAR(50),
    CustomerLastName VARCHAR(50),
    Country VARCHAR(50),
    CountryISOCode VARCHAR(5),
    City VARCHAR(50),
    Gender VARCHAR(10),
    Birthdate VARCHAR(20),
    CustomerFullName VARCHAR(100)
);

-- 3. Create Product Dimension Table
CREATE TABLE product (
    PK_Product INT PRIMARY KEY,
    ProductCode VARCHAR(20),
    ProductName VARCHAR(100),
    ProductCategory VARCHAR(50),
    ProductUnitPrice DECIMAL(10,2)
);

-- 4. Create Sales Fact Table
CREATE TABLE sales (
    FK_Customer INT,
    FK_Product INT,
    Quantity INT,
    UnitPrice DECIMAL(10,2),
    Discount DECIMAL(10,2),
    TotalAmount DECIMAL(10,2),
    FOREIGN KEY (FK_Customer) REFERENCES customer(PK_Customer),
    FOREIGN KEY (FK_Product) REFERENCES product(PK_Product)
);

SET FOREIGN_KEY_CHECKS = 1;

SELECT 'Customer' AS Table_Name, COUNT(*) AS Total_Rows FROM customer
UNION ALL
SELECT 'Product', COUNT(*) FROM product
UNION ALL
SELECT 'Sales', COUNT(*) FROM sales;

SELECT 
    p.ProductName,
    p.ProductCategory,
    SUM(s.Quantity) AS Total_Units_Sold,
    ROUND(SUM(s.TotalAmount), 2) AS Revenue
FROM sales s
JOIN product p ON s.FK_Product = p.PK_Product
GROUP BY p.ProductName, p.ProductCategory
ORDER BY Revenue DESC
LIMIT 5;

SELECT 
    c.Country,
    COUNT(DISTINCT c.PK_Customer) AS Total_Customers,
    SUM(s.Quantity) AS Units_Sold,
    ROUND(SUM(s.TotalAmount), 2) AS Total_Revenue,
    ROUND(AVG(s.TotalAmount), 2) AS Avg_Order_Value
FROM sales s
JOIN customer c ON s.FK_Customer = c.PK_Customer
GROUP BY c.Country
ORDER BY Total_Revenue DESC;

SELECT 
    p.ProductCategory,
    ROUND(SUM(s.Quantity * s.UnitPrice), 2) AS Gross_Sales,
    ROUND(SUM(s.Discount), 2) AS Total_Discounts,
    ROUND(SUM(s.TotalAmount), 2) AS Net_Revenue,
    ROUND((SUM(s.Discount) / SUM(s.Quantity * s.UnitPrice)) * 100, 2) AS Discount_Pct
FROM sales s
JOIN product p ON s.FK_Product = p.PK_Product
GROUP BY p.ProductCategory
ORDER BY Net_Revenue DESC;