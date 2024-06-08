-- Dimension Tables
DROP TABLE IF EXISTS DimRole CASCADE;
CREATE TABLE DimRole (
  RoleID SERIAL PRIMARY KEY,
  RoleName VARCHAR(50) NOT NULL
);

DROP TABLE IF EXISTS DimDate CASCADE;
CREATE TABLE DimDate (
  DateID SERIAL PRIMARY KEY,
  Date DATE NOT NULL,
  Year INT NOT NULL,
  Month INT NOT NULL,
  Day INT NOT NULL,
  Week INT NOT NULL
);

DROP TABLE IF EXISTS DimSize CASCADE;
CREATE TABLE DimSize (
  SizeID SERIAL PRIMARY KEY,
  USSize DECIMAL(4, 1),
  UKSize DECIMAL(4, 1),
  EURSize DECIMAL(4, 1),
  CMSize DECIMAL(4, 1),
  BRSize DECIMAL(4, 1),
  CNSize DECIMAL(4, 1)
);

DROP TABLE IF EXISTS DimCustomer CASCADE;
CREATE TABLE DimCustomer (
  CustomerID SERIAL PRIMARY KEY,
  Username VARCHAR(50) NOT NULL,
  Email VARCHAR(100) NOT NULL,
  Address VARCHAR(255),
  Phone VARCHAR(20),
  RoleID INT,
  FOREIGN KEY (RoleID) REFERENCES DimRole(RoleID)
);

DROP TABLE IF EXISTS DimCategory CASCADE;
CREATE TABLE DimCategory (
  CategoryID SERIAL PRIMARY KEY,
  CategoryName VARCHAR(100) NOT NULL
);

DROP TABLE IF EXISTS DimBrand CASCADE;
CREATE TABLE DimBrand (
  BrandID SERIAL PRIMARY KEY,
  BrandName VARCHAR(100) NOT NULL
);

DROP TABLE IF EXISTS DimOrderStatus CASCADE;
CREATE TABLE DimOrderStatus (
  StatusID SERIAL PRIMARY KEY,
  StatusName VARCHAR(50) NOT NULL
);

DROP TABLE IF EXISTS DimProduct_SCD CASCADE;
CREATE TABLE DimProduct_SCD (
  ProductSCDID SERIAL PRIMARY KEY,
  ProductID INT,
  ProductName VARCHAR(100) NOT NULL,
  Description TEXT,
  Price DECIMAL(10, 2) NOT NULL,
  CategoryID INT,
  BrandID INT,
  EffectiveDate DATE NOT NULL,
  ExpirationDate DATE,
  IsCurrent BOOLEAN NOT NULL,
  FOREIGN KEY (CategoryID) REFERENCES DimCategory(CategoryID),
  FOREIGN KEY (BrandID) REFERENCES DimBrand(BrandID)
);

DROP TABLE IF EXISTS DimProduct CASCADE;
CREATE TABLE DimProduct (
  ProductID SERIAL PRIMARY KEY,
  ProductName VARCHAR(100) NOT NULL,
  Description TEXT,
  Price DECIMAL(10, 2) NOT NULL,
  CategoryID INT,
  BrandID INT,
  FOREIGN KEY (CategoryID) REFERENCES DimCategory(CategoryID),
  FOREIGN KEY (BrandID) REFERENCES DimBrand(BrandID)
);

-- Fact Tables
DROP TABLE IF EXISTS FactSales CASCADE;
CREATE TABLE FactSales (
  SalesID SERIAL PRIMARY KEY,
  DateID INT,
  ProductID INT,
  SizeID INT,
  CustomerID INT,
  Quantity INT NOT NULL CHECK (Quantity > 0),
  TotalAmount DECIMAL(10, 2) NOT NULL,
  FOREIGN KEY (DateID) REFERENCES DimDate(DateID),
  FOREIGN KEY (ProductID) REFERENCES DimProduct(ProductID),
  FOREIGN KEY (SizeID) REFERENCES DimSize(SizeID),
  FOREIGN KEY (CustomerID) REFERENCES DimCustomer(CustomerID)
);

DROP TABLE IF EXISTS FactInventory CASCADE;
CREATE TABLE FactInventory (
  InventoryID SERIAL PRIMARY KEY,
  DateID INT,
  ProductID INT,
  SizeID INT,
  StockQuantity INT NOT NULL CHECK (StockQuantity >= 0),
  FOREIGN KEY (DateID) REFERENCES DimDate(DateID),
  FOREIGN KEY (ProductID) REFERENCES DimProduct(ProductID),
  FOREIGN KEY (SizeID) REFERENCES DimSize(SizeID)
);

-- ETL for Slowly Changing Dimension Type 2
DROP FUNCTION IF EXISTS update_dimproduct_scd CASCADE;
CREATE OR REPLACE FUNCTION update_dimproduct_scd() RETURNS TRIGGER AS $$
BEGIN
  IF NEW.ProductName IS DISTINCT FROM OLD.ProductName OR
     NEW.Description IS DISTINCT FROM OLD.Description OR
     NEW.Price IS DISTINCT FROM OLD.Price OR
     NEW.CategoryID IS DISTINCT FROM OLD.CategoryID OR
     NEW.BrandID IS DISTINCT FROM OLD.BrandID THEN
     
    -- Expire the old record
    UPDATE DimProduct_SCD
    SET ExpirationDate = CURRENT_DATE - 1, IsCurrent = FALSE
    WHERE ProductID = OLD.ProductID AND IsCurrent = TRUE;
    
    -- Insert the new record
    INSERT INTO DimProduct_SCD (ProductID, ProductName, Description, Price, CategoryID, BrandID, EffectiveDate, IsCurrent)
    VALUES (NEW.ProductID, NEW.ProductName, NEW.Description, NEW.Price, NEW.CategoryID, NEW.BrandID, CURRENT_DATE, TRUE);
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_dimproduct_scd
AFTER UPDATE ON DimProduct
FOR EACH ROW
EXECUTE FUNCTION update_dimproduct_scd();


-- Indexes 
DROP INDEX IF EXISTS idx_dimcustomer_email;
CREATE INDEX idx_dimcustomer_email ON DimCustomer(Email);

DROP INDEX IF EXISTS idx_dimproduct_categoryid;
CREATE INDEX idx_dimproduct_categoryid ON DimProduct(CategoryID);
DROP INDEX IF EXISTS idx_dimproduct_brandid;
CREATE INDEX idx_dimproduct_brandid ON DimProduct(BrandID);

DROP INDEX IF EXISTS idx_dimproduct_scd_categoryid;
CREATE INDEX idx_dimproduct_scd_categoryid ON DimProduct_SCD(CategoryID);
DROP INDEX IF EXISTS idx_dimproduct_scd_brandid;
CREATE INDEX idx_dimproduct_scd_brandid ON DimProduct_SCD(BrandID);

DROP INDEX IF EXISTS idx_factsales_dateid;
CREATE INDEX idx_factsales_dateid ON FactSales(DateID);
DROP INDEX IF EXISTS idx_factsales_productid;
CREATE INDEX idx_factsales_productid ON FactSales(ProductID);
DROP INDEX IF EXISTS idx_factsales_sizeid;
CREATE INDEX idx_factsales_sizeid ON FactSales(SizeID);
DROP INDEX IF EXISTS idx_factsales_customerid;
CREATE INDEX idx_factsales_customerid ON FactSales(CustomerID);

DROP INDEX IF EXISTS idx_factinventory_dateid;
CREATE INDEX idx_factinventory_dateid ON FactInventory(DateID);
DROP INDEX IF EXISTS idx_factinventory_productid;
CREATE INDEX idx_factinventory_productid ON FactInventory(ProductID);
DROP INDEX IF EXISTS idx_factinventory_sizeid;
CREATE INDEX idx_factinventory_sizeid ON FactInventory(SizeID);

