🗄️ 1. DATABASE SCHEMA

Customers
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(100),
    Phone VARCHAR(20),
    Country VARCHAR(50),
    City VARCHAR(50),
    Segment VARCHAR(30),
    AcquisitionChannel VARCHAR(50),
    CustomerTier VARCHAR(20),
    SignupDate DATE,
    IsActive BIT NOT NULL DEFAULT 1,
    LifetimeValue DECIMAL(10,2)
);
Products
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    SKU VARCHAR(50),
    Price DECIMAL(10,2),
    Cost DECIMAL(10,2),
    Supplier VARCHAR(100),
    LaunchDate DATE,
    Discontinued BIT NOT NULL DEFAULT,
    Weight DECIMAL(10,2),
    Color VARCHAR(30),
    Brand VARCHAR(50)
);
Employees
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Department VARCHAR(50),
    TerritoryID INT,
    HireDate DATE,
    Salary DECIMAL(10,2),
    ManagerID INT,
    PerformanceScore INT,
    Email VARCHAR(100),
    Phone VARCHAR(20),
    Active BIT NOT NULL DEFAULT 1
);
Regions
CREATE TABLE Regions (
    RegionID INT PRIMARY KEY,
    RegionName VARCHAR(50),
    Country VARCHAR(50),
    Market VARCHAR(50),
    Manager VARCHAR(100),
    Active BIT NOT NULL DEFAULT 1,
    Currency VARCHAR(10),
    TaxRate DECIMAL(5,2),
    CreatedDate DATE,
    UpdatedDate DATE,
    Notes VARCHAR(255),
    Zone VARCHAR(50)
);
Orders
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    EmployeeID INT,
    OrderDate DATE,
    ShipDate DATE,
    Status VARCHAR(20),
    PaymentStatus VARCHAR(20),
    TotalAmount DECIMAL(10,2),
    ShippingAddress VARCHAR(255),
    BillingAddress VARCHAR(255),
    RegionID INT,
    CreatedAt DATETIME,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
    FOREIGN KEY (RegionID) REFERENCES Regions(RegionID)
);
OrderItems
CREATE TABLE OrderItems (
    OrderItemID INT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    UnitPrice DECIMAL(10,2),
    Discount DECIMAL(5,2),
    LineTotal DECIMAL(10,2),
    Status VARCHAR(20),
    CreatedAt DATETIME,
    UpdatedAt DATETIME,
    Notes VARCHAR(255),
    Returned BIT NOT NULL DEFAULT 1,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
Payments
CREATE TABLE Payments (
    PaymentID INT PRIMARY KEY,
    OrderID INT,
    PaymentDate DATE,
    Amount DECIMAL(10,2),
    Method VARCHAR(30),
    Status VARCHAR(20),
    Currency VARCHAR(10),
    TransactionID VARCHAR(100),
    Refunded BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME,
    UpdatedAt DATETIME,
    Notes VARCHAR(255),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);
CustomerInteractions
CREATE TABLE CustomerInteractions (
    InteractionID INT PRIMARY KEY,
    CustomerID INT,
    InteractionType VARCHAR(50),
    Channel VARCHAR(50),
    Status VARCHAR(20),
    CreatedAt TIMESTAMP,
    ResolvedAt TIMESTAMP,
    AgentID INT,
    Priority VARCHAR(20),
    Notes VARCHAR(255),
    Rating INT,
    FollowUpRequired DATETIME,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);
Inventory
CREATE TABLE Inventory (
    InventoryID INT PRIMARY KEY,
    ProductID INT,
    WarehouseID INT,
    StockLevel INT,
    ReorderPoint INT,
    LastUpdated DATE,
    Status VARCHAR(20),
    IncomingStock INT,
    OutgoingStock INT,
    DamagedStock INT,
    ReservedStock INT,
    AvailableStock INT,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
Campaigns
CREATE TABLE Campaigns (
    CampaignID INT PRIMARY KEY,
    CampaignName VARCHAR(100),
    Channel VARCHAR(50),
    StartDate DATE,
    EndDate DATE,
    Budget DECIMAL(10,2),
    TargetSegment VARCHAR(50),
    Impressions INT,
    Clicks INT,
    Conversions INT,
    RevenueGenerated DECIMAL(10,2),
    Active BIT NOT NULL DEFAULT 1
);
Returns
CREATE TABLE Returns (
    ReturnID INT PRIMARY KEY,
    OrderItemID INT,
    ReturnDate DATE,
    Reason VARCHAR(100),
    Status VARCHAR(20),
    RefundAmount DECIMAL(10,2),
    Approved BOOLEAN,
    CreatedAt DATETIME,
    UpdatedAt DATETIME,
    Notes VARCHAR(255),
    ProcessedBy INT,
    WarehouseID INT,
    FOREIGN KEY (OrderItemID) REFERENCES OrderItems(OrderItemID)
);
________________________________________
🔗 2. RELATIONSHIPS
•	Customers → Orders (1:M)
•	Employees → Orders (1:M)
•	Orders → OrderItems (1:M)
•	Products → OrderItems (1:M)
•	Orders → Payments (1:M)
•	Customers → Interactions (1:M)
•	Regions → Orders (1:M)
•	OrderItems → Returns (1:1 or 1:M)
________________________________________
📊 3. ERD
Customers ──< Orders ──< OrderItems >── Products │ ├── Payments ├── Returns └── Employees
Customers ──< CustomerInteractions Orders ── Regions Products ── Inventory
________________________________________
