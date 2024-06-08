RESET ROLE;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Create Roles Table
DROP TABLE IF EXISTS Roles CASCADE;
CREATE TABLE Roles (
  RoleID SERIAL PRIMARY KEY,
  RoleName VARCHAR(50) UNIQUE NOT NULL
);

-- Create Users Table
DROP TABLE IF EXISTS Users CASCADE;
CREATE TABLE Users (
  UserID SERIAL PRIMARY KEY,
  Username VARCHAR(50) NOT NULL,
  Password VARCHAR(60) NOT NULL,
  Email VARCHAR(100) NOT NULL,
  Address VARCHAR(255),
  Phone VARCHAR(20),
  RoleId INT,
  FOREIGN KEY (RoleId) REFERENCES Roles(RoleId)	
);

-- Create Categories Table
DROP TABLE IF EXISTS Categories CASCADE;
CREATE TABLE Categories (
  CategoryID SERIAL PRIMARY KEY,
  CategoryName VARCHAR(100) NOT NULL
);

-- Create Brands Table
DROP TABLE IF EXISTS Brands CASCADE;
CREATE TABLE Brands (
  BrandID SERIAL PRIMARY KEY,
  BrandName VARCHAR(100) NOT NULL
);

-- Create Products Table
DROP TABLE IF EXISTS Products CASCADE;
CREATE TABLE Products (
  ProductID SERIAL PRIMARY KEY,
  ProductName VARCHAR(100) NOT NULL,
  Description TEXT,
  Price DECIMAL(10, 2) NOT NULL,
  CategoryID INT,
  BrandID INT,
  FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
  FOREIGN KEY (BrandID) REFERENCES Brands(BrandID)
);

-- Create Sizes Table
DROP TABLE IF EXISTS Sizes CASCADE;
CREATE TABLE Sizes (
  SizeID SERIAL PRIMARY KEY,
  USSize DECIMAL(4, 1),
  UKSize DECIMAL(4, 1),
  EURSize DECIMAL(4, 1),
  CMSize DECIMAL(4, 1),
  BRSize DECIMAL(4, 1),
  CNSize DECIMAL(4, 1)
);

-- Create ProductSizes Table
DROP TABLE IF EXISTS ProductSizes CASCADE;
CREATE TABLE ProductSizes (
  ProductSizeID SERIAL PRIMARY KEY,
  ProductID INT REFERENCES Products(ProductID),
  SizeID INT REFERENCES Sizes(SizeID),
  StockQuantity INT NOT NULL CHECK (StockQuantity >= 0)
);

-- Create OrderStatuses Table
DROP TABLE IF EXISTS OrderStatuses CASCADE;
CREATE TABLE OrderStatuses (
  StatusID SERIAL PRIMARY KEY,
  StatusName VARCHAR(50) NOT NULL
);

-- Create Orders Table
DROP TABLE IF EXISTS Orders CASCADE;
CREATE TABLE Orders (
  OrderID SERIAL PRIMARY KEY,
  UserID INT,
  OrderDate TIMESTAMP NOT NULL,
  TotalAmount DECIMAL(10, 2) NOT NULL,
  StatusID INT,
  FOREIGN KEY (UserID) REFERENCES Users(UserID),
  FOREIGN KEY (StatusID) REFERENCES OrderStatuses(StatusID)
);

-- Create OrderDetails Table
DROP TABLE IF EXISTS OrderDetails CASCADE;
CREATE TABLE OrderDetails (
  OrderDetailID SERIAL PRIMARY KEY,
  OrderID INT,
  ProductSizeID INT,
  Quantity INT NOT NULL CHECK (Quantity > 0),
  Price DECIMAL(10, 2) NOT NULL,
  FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
  FOREIGN KEY (ProductSizeID) REFERENCES ProductSizes(ProductSizeID)
);

-- Create Reviews Table
DROP TABLE IF EXISTS Reviews CASCADE;
CREATE TABLE Reviews (
  ReviewID SERIAL PRIMARY KEY,
  UserID INT,
  ProductID INT,
  Rating INT NOT NULL,
  Comment TEXT,
  ReviewDate TIMESTAMP,
  FOREIGN KEY (UserID) REFERENCES Users(UserID),
  FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Create ShoppingCart Table
DROP TABLE IF EXISTS ShoppingCart CASCADE;
CREATE TABLE ShoppingCart (
  CartID SERIAL PRIMARY KEY,
  UserID INT,
  FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- Create ShoppingCartItems Table
DROP TABLE IF EXISTS ShoppingCartItems CASCADE;
CREATE TABLE ShoppingCartItems (
  CartItemID SERIAL PRIMARY KEY,
  CartID INT,
  ProductSizeID INT,
  Quantity INT NOT NULL CHECK (Quantity > 0),
  FOREIGN KEY (CartID) REFERENCES ShoppingCart(CartID),
  FOREIGN KEY (ProductSizeID) REFERENCES ProductSizes(ProductSizeID)
);

-- Create PaymentMethods Table
DROP TABLE IF EXISTS PaymentMethods CASCADE;
CREATE TABLE PaymentMethods (
  PaymentMethodID SERIAL PRIMARY KEY,
  MethodName VARCHAR(50) NOT NULL
);

-- Create Payments Table
DROP TABLE IF EXISTS Payments CASCADE;
CREATE TABLE Payments (
  PaymentID SERIAL PRIMARY KEY,
  OrderID INT,
  PaymentDate TIMESTAMP NOT NULL,
  Amount DECIMAL(10, 2) NOT NULL,
  PaymentMethodID INT,
  FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
  FOREIGN KEY (PaymentMethodID) REFERENCES PaymentMethods(PaymentMethodID)
);





------------------------------------------------------------------------------------------------
-- Indexes
DROP INDEX IF EXISTS idx_users_email;
DROP INDEX IF EXISTS idx_products_categoryid;
DROP INDEX IF EXISTS idx_products_brandid;
DROP INDEX IF EXISTS idx_orders_userid;
DROP INDEX IF EXISTS idx_orders_statusid;
DROP INDEX IF EXISTS idx_orderdetails_orderid;
DROP INDEX IF EXISTS idx_shoppingcart_userid;
CREATE INDEX idx_users_email ON Users(Email);
CREATE INDEX idx_products_categoryid ON Products(CategoryID);
CREATE INDEX idx_products_brandid ON Products(BrandID);
CREATE INDEX idx_orders_userid ON Orders(UserID);
CREATE INDEX idx_orders_statusid ON Orders(StatusID);
CREATE INDEX idx_orderdetails_orderid ON OrderDetails(OrderID);
CREATE INDEX idx_shoppingcart_userid ON ShoppingCart(UserID);




------------------------------------------------------------------------------------------------
-- Triggers and functions for password encryption

-- Function to encrypt password before insert or update
DROP FUNCTION IF EXISTS encrypt_password;
CREATE OR REPLACE FUNCTION encrypt_password() RETURNS TRIGGER AS $$
BEGIN
  NEW.password := crypt(NEW.password, gen_salt('bf'));
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for encrypting password on insert
CREATE TRIGGER encrypt_password_insert
BEFORE INSERT ON Users
FOR EACH ROW
EXECUTE FUNCTION encrypt_password();

-- Trigger for encrypting password on update
CREATE TRIGGER encrypt_password_update
BEFORE UPDATE ON Users
FOR EACH ROW
WHEN (OLD.password IS DISTINCT FROM NEW.password)
EXECUTE FUNCTION encrypt_password();

-- Function to verify the password
DROP FUNCTION IF EXISTS verify_user_password;
CREATE OR REPLACE FUNCTION verify_user_password(in_username VARCHAR, in_password VARCHAR) RETURNS BOOLEAN AS $$
DECLARE
  stored_password VARCHAR;
BEGIN
  SELECT password INTO stored_password FROM Users WHERE username = in_username;
  RETURN stored_password = crypt(in_password, stored_password);
END;
$$ LANGUAGE plpgsql;


------------------------------------------------------------------------------------------------
-- Stored Functions for Admin Actions

-- Add Product
DROP FUNCTION IF EXISTS AddProduct;
CREATE OR REPLACE FUNCTION AddProduct(
  in_productName VARCHAR,
  in_description TEXT,
  in_price DECIMAL,
  in_categoryID INT,
  in_brandID INT
) RETURNS VOID AS $$
BEGIN
  IF current_user != 'admin' THEN
    RAISE EXCEPTION 'Permission Denied';
  END IF;

  INSERT INTO Products (ProductName, Description, Price, CategoryID, BrandID)
  VALUES (in_productName, in_description, in_price, in_categoryID, in_brandID);
END;
$$ LANGUAGE plpgsql;

-- Update Product
DROP FUNCTION IF EXISTS UpdateProduct;
CREATE OR REPLACE FUNCTION UpdateProduct(
  in_pID INT,
  in_productName VARCHAR,
  in_description TEXT,
  in_price DECIMAL,
  in_categoryID INT,
  in_brandID INT
) RETURNS VOID AS $$
BEGIN
  IF current_user != 'admin' THEN
    RAISE EXCEPTION 'Permission Denied';
  END IF;

  UPDATE Products
  SET ProductName = in_productName, Description = in_description, Price = in_price, CategoryID = in_categoryID, BrandID = in_brandID
  WHERE ProductID = in_pID;
END;
$$ LANGUAGE plpgsql;

-- Delete Product
DROP FUNCTION IF EXISTS DeleteProduct;
CREATE OR REPLACE FUNCTION DeleteProduct(in_pID INT) RETURNS VOID AS $$
BEGIN
  IF current_user != 'admin' THEN
    RAISE EXCEPTION 'Permission Denied';
  END IF;

  DELETE FROM Products WHERE ProductID = in_pID;
END;
$$ LANGUAGE plpgsql;

-- Add Brand
DROP FUNCTION IF EXISTS AddBrand;
CREATE OR REPLACE FUNCTION AddBrand(in_brandName VARCHAR) RETURNS VOID AS $$
BEGIN
  IF current_user != 'admin' THEN
    RAISE EXCEPTION 'Permission Denied';
  END IF;

  INSERT INTO Brands (BrandName) VALUES (in_brandName);
END;
$$ LANGUAGE plpgsql;

-- Update Brand
DROP FUNCTION IF EXISTS UpdateBrand;
CREATE OR REPLACE FUNCTION UpdateBrand(in_brandID INT, in_brandName VARCHAR) RETURNS VOID AS $$
BEGIN
  IF current_user != 'admin' THEN
    RAISE EXCEPTION 'Permission Denied';
  END IF;

  UPDATE Brands SET BrandName = in_brandName WHERE BrandID = in_brandID;
END;
$$ LANGUAGE plpgsql;

-- Delete Brand
DROP FUNCTION IF EXISTS DeleteBrand;
CREATE OR REPLACE FUNCTION DeleteBrand(in_brandID INT) RETURNS VOID AS $$
BEGIN
  IF current_user != 'admin' THEN
    RAISE EXCEPTION 'Permission Denied';
  END IF;

  DELETE FROM Brands WHERE BrandID = in_brandID;
END;
$$ LANGUAGE plpgsql;

-- Add Size
DROP FUNCTION IF EXISTS AddSize;
CREATE OR REPLACE FUNCTION AddSize(
  in_usSize DECIMAL,
  in_ukSize DECIMAL,
  in_eurSize DECIMAL,
  in_cmSize DECIMAL,
  in_brSize DECIMAL,
  in_cnSize DECIMAL
) RETURNS VOID AS $$
BEGIN
  IF current_user != 'admin' THEN
    RAISE EXCEPTION 'Permission Denied';
  END IF;

  INSERT INTO Sizes (USSize, UKSize, EURSize, CMSize, BRSize, CNSize)
  VALUES (in_usSize, in_ukSize, in_eurSize, in_cmSize, in_brSize, in_cnSize);
END;
$$ LANGUAGE plpgsql;
-- Update Size
DROP FUNCTION IF EXISTS UpdateSize;
CREATE OR REPLACE FUNCTION UpdateSize(
  in_sizeID INT,
  in_usSize DECIMAL,
  in_ukSize DECIMAL,
  in_eurSize DECIMAL,
  in_cmSize DECIMAL,
  in_brSize DECIMAL,
  in_cnSize DECIMAL
) RETURNS VOID AS $$
BEGIN
  IF current_user != 'admin' THEN
    RAISE EXCEPTION 'Permission Denied';
  END IF;

  UPDATE Sizes
  SET USSize = in_usSize, UKSize = in_ukSize, EURSize = in_eurSize, CMSize = in_cmSize, BRSize = in_brSize, CNSize = in_cnSize
  WHERE SizeID = in_sizeID;
END;
$$ LANGUAGE plpgsql;

-- Delete Size
DROP FUNCTION IF EXISTS DeleteSize;
CREATE OR REPLACE FUNCTION DeleteSize(in_sizeID INT) RETURNS VOID AS $$
BEGIN
  IF current_user != 'admin' THEN
    RAISE EXCEPTION 'Permission Denied';
  END IF;

  DELETE FROM Sizes WHERE SizeID = in_sizeID;
END;
$$ LANGUAGE plpgsql;

-- Add ProductSize
DROP FUNCTION IF EXISTS AddProductSize;
CREATE OR REPLACE FUNCTION AddProductSize(in_productID INT, in_sizeID INT, in_quantity INT) RETURNS VOID AS $$
BEGIN
  IF current_user != 'admin' THEN
    RAISE EXCEPTION 'Permission Denied';
  END IF;

  INSERT INTO ProductSizes (ProductID, SizeID, StockQuantity) VALUES (in_productID, in_sizeID, in_quantity);
END;
$$ LANGUAGE plpgsql;

-- Remove ProductSize
DROP FUNCTION IF EXISTS RemoveProductSize;
CREATE OR REPLACE FUNCTION RemoveProductSize(in_productID INT, in_sizeID INT) RETURNS VOID AS $$
BEGIN
  IF current_user != 'admin' THEN
    RAISE EXCEPTION 'Permission Denied';
  END IF;

  DELETE FROM ProductSizes WHERE ProductID = in_productID AND SizeID = in_sizeID;
END;
$$ LANGUAGE plpgsql;

-- Add Payment Method
DROP FUNCTION IF EXISTS AddPaymentMethod;
CREATE OR REPLACE FUNCTION AddPaymentMethod(in_methodName VARCHAR) RETURNS VOID AS $$
BEGIN
  IF current_user != 'admin' THEN
    RAISE EXCEPTION 'Permission Denied';
  END IF;

  INSERT INTO PaymentMethods (MethodName) VALUES (in_methodName);
END;
$$ LANGUAGE plpgsql;

-- Update Payment Method
DROP FUNCTION IF EXISTS UpdatePaymentMethod;
CREATE OR REPLACE FUNCTION UpdatePaymentMethod(in_paymentMethodID INT, in_methodName VARCHAR) RETURNS VOID AS $$
BEGIN
  IF current_user != 'admin' THEN
    RAISE EXCEPTION 'Permission Denied';
  END IF;

  UPDATE PaymentMethods SET MethodName = in_methodName WHERE PaymentMethodID = in_paymentMethodID;
END;
$$ LANGUAGE plpgsql;

-- Delete Payment Method
DROP FUNCTION IF EXISTS DeletePaymentMethod;
CREATE OR REPLACE FUNCTION DeletePaymentMethod(in_paymentMethodID INT) RETURNS VOID AS $$
BEGIN
  IF current_user != 'admin' THEN
    RAISE EXCEPTION 'Permission Denied';
  END IF;

  DELETE FROM PaymentMethods WHERE PaymentMethodID = in_paymentMethodID;
END;
$$ LANGUAGE plpgsql;

-- Add Category
DROP FUNCTION IF EXISTS AddCategory;
CREATE OR REPLACE FUNCTION AddCategory(in_categoryName VARCHAR) RETURNS VOID AS $$
BEGIN
  IF current_user != 'admin' THEN
    RAISE EXCEPTION 'Permission Denied';
  END IF;
  INSERT INTO Categories (CategoryName) VALUES (in_categoryName);
END;
$$ LANGUAGE plpgsql;

-- Update Category
DROP FUNCTION IF EXISTS UpdateCategory;
CREATE OR REPLACE FUNCTION UpdateCategory(in_categoryID INT, in_categoryName VARCHAR) RETURNS VOID AS $$
BEGIN
  IF current_user != 'admin' THEN
    RAISE EXCEPTION 'Permission Denied';
  END IF;
  
  UPDATE Categories SET CategoryName = in_categoryName WHERE CategoryID = in_categoryID;
END;
$$ LANGUAGE plpgsql;

-- Delete Category
DROP FUNCTION IF EXISTS DeleteCategory;
CREATE OR REPLACE FUNCTION DeleteCategory(in_categoryID INT) RETURNS VOID AS $$
BEGIN
  IF current_user != 'admin' THEN
    RAISE EXCEPTION 'Permission Denied';
  END IF;
  
  DELETE FROM Categories WHERE CategoryID = in_categoryID;
END;
$$ LANGUAGE plpgsql;

-- Add OrderStatus
DROP FUNCTION IF EXISTS AddOrderStatus;
CREATE OR REPLACE FUNCTION AddOrderStatus(statusName VARCHAR) RETURNS VOID AS $$
BEGIN
  IF current_user != 'admin' THEN
    RAISE EXCEPTION 'Permission Denied';
  END IF;
  
  INSERT INTO OrderStatuses (StatusName) VALUES (statusName);
END;
$$ LANGUAGE plpgsql;

-- Update OrderStatus
DROP FUNCTION IF EXISTS UpdateOrderStatus;
CREATE OR REPLACE FUNCTION UpdateOrderStatus(sID INT, sName VARCHAR) RETURNS VOID AS $$
BEGIN
  IF current_user != 'admin' THEN
    RAISE EXCEPTION 'Permission Denied';
  END IF;
  
  UPDATE OrderStatuses SET StatusName = sName WHERE StatusID = sID;
END;
$$ LANGUAGE plpgsql;

-- Delete OrderStatus
DROP FUNCTION IF EXISTS DeleteOrderStatus;
CREATE OR REPLACE FUNCTION DeleteOrderStatus(sID INT) RETURNS VOID AS $$
BEGIN
  IF current_user != 'admin' THEN
    RAISE EXCEPTION 'Permission Denied';
  END IF;
  
  DELETE FROM OrderStatuses WHERE StatusID = sID;
END;
$$ LANGUAGE plpgsql;


------------------------------------------------------------------------------------------------
-- Roles and Rights

-- Create Roles
REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM admin;
REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public FROM admin;
REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public FROM admin;

REVOKE ALL PRIVILEGES ON ALL TABLES IN SCHEMA public FROM client;
REVOKE ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public FROM client;
REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public FROM client;
DROP ROLE IF EXISTS guest;
DROP ROLE IF EXISTS client;
DROP ROLE IF EXISTS admin;
CREATE ROLE guest;
CREATE ROLE client;
CREATE ROLE admin;

-- Guest privileges (can only search products)
GRANT SELECT ON Categories, Brands, Products TO guest;

-- Client privileges (can add to cart, place orders, and leave reviews)
GRANT SELECT, INSERT, UPDATE ON Users TO client;
GRANT SELECT ON Categories, ProductSizes, Brands, Products, OrderStatuses TO client;
GRANT SELECT, INSERT, UPDATE, DELETE ON Orders, OrderDetails, Reviews, ShoppingCart, ShoppingCartItems, Payments TO client;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO client;

-- Admin privileges (full access)
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO admin;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO admin;

------------------------------------------------------------------------------------------------
-- Stored Procedures for User Actions

-- Add Item to Cart
DROP FUNCTION IF EXISTS AddToCart;
CREATE OR REPLACE FUNCTION AddToCart(in_uid INT, in_productSizeID INT, in_quantity INT) RETURNS VOID AS $$
DECLARE
  userCartID INT;
BEGIN
  IF current_user != 'admin' and current_user != 'client' THEN
    RAISE EXCEPTION 'Permission Denied';
  END IF;
  -- Check if a cart exists for the user
  SELECT CartID INTO userCartID FROM ShoppingCart s WHERE s.UserID = in_uid;
  -- If no cart exists, create one
  IF userCartID IS NULL THEN
    INSERT INTO ShoppingCart (UserID) VALUES (in_uid) RETURNING CartID INTO userCartID;
  END IF;
  -- Add item to the cart
  INSERT INTO ShoppingCartItems (CartID, ProductSizeID, Quantity)
  VALUES (userCartID, in_productSizeID, in_quantity);
END;
$$ LANGUAGE plpgsql;


-- Update Cart Item Quantity
DROP FUNCTION IF EXISTS UpdateCartItemQuantity;
CREATE OR REPLACE FUNCTION UpdateCartItemQuantity(in_ciID INT, in_quantity INT) RETURNS VOID AS $$
BEGIN
  IF current_user != 'admin' and current_user != 'client' THEN
    RAISE EXCEPTION 'Permission Denied';
  END IF;
  UPDATE ShoppingCartItems SET Quantity = in_quantity WHERE CartItemID = in_ciID;
END;
$$ LANGUAGE plpgsql;

-- Remove Item from Cart
DROP FUNCTION IF EXISTS RemoveFromCart;
CREATE OR REPLACE FUNCTION RemoveFromCart(in_ciID INT) RETURNS VOID AS $$
BEGIN
  IF current_user != 'admin' and current_user != 'client' THEN
    RAISE EXCEPTION 'Permission Denied';
  END IF;
  DELETE FROM ShoppingCartItems WHERE CartItemID = in_ciID;
END;
$$ LANGUAGE plpgsql;


-- Place Order
DROP FUNCTION IF EXISTS PlaceOrder;
CREATE OR REPLACE FUNCTION PlaceOrder(in_uID INT, in_pmID INT) RETURNS VOID AS $$
DECLARE
  newOrderID INT;
  insufficientStock BOOLEAN := FALSE;
  productSize RECORD;
BEGIN
  IF current_user != 'admin' and current_user != 'client' THEN
    RAISE EXCEPTION 'Permission Denied';
  END IF;
  -- Create a new order with 'Pending' status
  INSERT INTO Orders (UserID, OrderDate, TotalAmount, StatusID)
  VALUES (in_uID, CURRENT_TIMESTAMP, 0, (SELECT StatusID FROM OrderStatuses WHERE StatusName = 'Pending')) RETURNING OrderID INTO newOrderID;

  -- Move items from cart to order details
  FOR productSize IN
    SELECT ps.ProductSizeID, sci.Quantity, ps.ProductSizeID, p.Price
    FROM ShoppingCartItems sci
    JOIN ShoppingCart sc ON sci.CartID = sc.CartID
    JOIN ProductSizes ps ON sci.ProductSizeID = ps.ProductSizeID
    JOIN Products p ON ps.ProductID = p.ProductID
    WHERE sc.UserID = in_uID
  LOOP
    -- Check if the requested quantity is available
    IF productSize.Quantity > (SELECT StockQuantity FROM ProductSizes WHERE ProductSizeID = productSize.ProductSizeID) THEN
      RAISE EXCEPTION 'Insufficient stock for ProductID: %, SizeID: %', productSize.ProductID, productSize.SizeID;
    ELSE
      -- Update the stock quantity
	  RESET ROLE;
      UPDATE ProductSizes
      SET StockQuantity = StockQuantity - productSize.Quantity
      WHERE ProductSizeID = productSize.ProductSizeID;
	  SET ROLE client;
      
      -- Insert into OrderDetails
      INSERT INTO OrderDetails (OrderID, ProductSizeID, Quantity, Price)
      VALUES (newOrderID, productSize.ProductSizeID, productSize.Quantity, productSize.Price);
    END IF;
  END LOOP;

  -- Update the total amount of the order
  UPDATE Orders
  SET TotalAmount = (SELECT SUM(od.Price * od.Quantity) FROM OrderDetails od WHERE od.OrderID = newOrderID)
  WHERE OrderID = newOrderID;

  -- Clear the shopping cart
  DELETE FROM ShoppingCartItems WHERE CartID = (SELECT CartID FROM ShoppingCart WHERE UserID = in_uID);
END;
$$ LANGUAGE plpgsql;

-- Search Products
DROP FUNCTION IF EXISTS SearchProducts;
CREATE OR REPLACE FUNCTION SearchProducts(in_searchTerm VARCHAR) RETURNS TABLE (
  ProductID INT,
  ProductName VARCHAR,
  Description TEXT,
  Price DECIMAL,
  CategoryName VARCHAR,
  BrandName VARCHAR
) AS $$
BEGIN
  RETURN QUERY
  SELECT p.ProductID, p.ProductName, p.Description, p.Price, c.CategoryName, b.BrandName
  FROM Products p
  JOIN Categories c ON p.CategoryID = c.CategoryID
  JOIN Brands b ON p.BrandID = b.BrandID
  WHERE p.ProductName ILIKE '%' || in_searchTerm || '%'
     OR p.Description ILIKE '%' || in_searchTerm || '%'
     OR c.CategoryName ILIKE '%' || in_searchTerm || '%'
     OR b.BrandName ILIKE '%' || in_searchTerm || '%';
END;
$$ LANGUAGE plpgsql;

-- Register User Function
DROP FUNCTION IF EXISTS RegisterUser;
CREATE OR REPLACE FUNCTION RegisterUser(
  in_username VARCHAR,
  in_password VARCHAR,
  in_email VARCHAR,
  in_address VARCHAR,
  in_phone VARCHAR
) RETURNS VOID AS $$
DECLARE
  role_id INT;
BEGIN
  reset role;
  -- Get the RoleID for the given role name
  SELECT RoleID INTO role_id FROM Roles WHERE RoleName = 'client';
  
  -- Insert the new user with the RoleID
  INSERT INTO Users (Username, Password, Email, Address, Phone, RoleID)
  VALUES (in_username, in_password, in_email, in_address, in_phone, 2);
  
  PERFORM set_config('role', 'guest', false);
END;
$$ LANGUAGE plpgsql;


-- Create login function
DROP FUNCTION IF EXISTS Login;
CREATE OR REPLACE FUNCTION Login(in_username VARCHAR, in_password VARCHAR) RETURNS VARCHAR AS $$
DECLARE
  userRole VARCHAR;
BEGIN
  reset role;
  IF verify_user_password(in_username, in_password) THEN
    -- Get the user's role
    SELECT r.RoleName INTO userRole
    FROM Users u
    JOIN Roles r ON u.RoleID = r.RoleID
    WHERE u.Username = in_username;

    PERFORM set_config('role', userRole, false);
    RETURN userRole;
  ELSE
    RETURN 'guest';
  END IF;
END;
$$ LANGUAGE plpgsql;

-- Create logout function
DROP FUNCTION IF EXISTS Logout;
CREATE OR REPLACE FUNCTION Logout() RETURNS VOID AS $$
BEGIN
  PERFORM set_config('role', 'guest', false);
END;
$$ LANGUAGE plpgsql;




------------------------------------------------------------------------------------------------

-- -- -- Tests 
-- -- Insert initial roles
-- INSERT INTO Roles (RoleName) VALUES ('guest'), ('client'), ('admin');


-- INSERT INTO Users (Username, Password, Email, Address, Phone, RoleID)
-- VALUES ('admin', 'adminpassword', 'admin@example.com', 'Admin Address', '1234567890', (SELECT RoleID FROM Roles WHERE RoleName = 'admin'));

-- -- Login for admin actions
-- SELECT * FROM Login('admin', 'adminpassword');

-- -- Test AddCategory function
-- SELECT AddCategory('Running Shoes');
-- SELECT * FROM Categories;

-- -- Test AddOrderStatus function 
-- SELECT * FROM AddOrderStatus('Pending');

-- -- Test UpdateCategory function
-- SELECT UpdateCategory(1, 'Updated Category Name');
-- SELECT * FROM Categories WHERE CategoryID = 1;

-- -- Test AddBrand function
-- SELECT AddBrand('Nike');
-- SELECT * FROM Brands;

-- -- Test UpdateBrand function
-- SELECT UpdateBrand(1, 'Updated Nike');
-- SELECT * FROM Brands WHERE BrandID = 1;

-- -- Test AddPaymentMethod function
-- SELECT AddPaymentMethod('Credit Card');
-- SELECT * FROM PaymentMethods;

-- -- Test UpdatePaymentMethod function
-- SELECT UpdatePaymentMethod(1, 'Updated Credit Card');
-- SELECT * FROM PaymentMethods WHERE PaymentMethodID = 1;

-- -- Test AddProduct function
-- SELECT AddProduct('Mercurial', 'Nike Mercurial soccer shoes', 199.99, 1, 1);
-- SELECT * FROM Products;

-- -- Test UpdateProduct function
-- SELECT UpdateProduct(1, 'Updated Mercurial', 'Updated description', 179.99, 1, 1);
-- SELECT * FROM Products WHERE ProductID = 1;

-- -- Test AddSize function
-- SELECT AddSize(9.5, 9, 43, 27, 42, 270);
-- SELECT * FROM Sizes;

-- -- Test UpdateSize function
-- SELECT UpdateSize(1, 10, 9.5, 44, 28, 43, 280);
-- SELECT * FROM Sizes WHERE SizeID = 1;

-- -- Test AddProductSize function
-- SELECT AddProductSize(1, 1, 50);
-- SELECT * FROM ProductSizes;

-- -- Test Search
-- SELECT * FROM SearchProducts('Mercurial');

-- -- Test Logout 
-- SELECT * FROM Logout();
-- SELECT current_user;
-- Test Registration
--SELECT * FROM RegisterUser('aaa', '123456', 'aaa@gmail.com', 'str. trs', '+12312321');
-- SELECT * FROM Login('aaa', '123456');
-- SELECT current_user;

-- -- Test AddToCart function
-- SELECT AddToCart(2, 1, 2);
-- SELECT * FROM ShoppingCartItems WHERE CartID = (SELECT CartID FROM ShoppingCart WHERE UserID = 1);

-- -- Test UpdateCartItemQuantity function
-- SELECT UpdateCartItemQuantity(1, 3);
-- SELECT * FROM ShoppingCartItems WHERE CartItemID = 1;

-- -- Test PlaceOrder function
-- SELECT PlaceOrder(2, 1);
-- SELECT * FROM Orders WHERE UserID = 2;
-- SELECT * FROM OrderDetails WHERE OrderID = (SELECT OrderID FROM Orders WHERE UserID = 2 ORDER BY OrderDate DESC LIMIT 1);
-- SELECT * FROM ShoppingCartItems WHERE CartID = (SELECT CartID FROM ShoppingCart WHERE UserID = 2); -- should be empty