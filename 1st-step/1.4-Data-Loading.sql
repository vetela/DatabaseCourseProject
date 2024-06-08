-- Drop temporary tables if they exist
DROP TABLE IF EXISTS temp_roles, temp_users, temp_categories, temp_brands, temp_products,
                    temp_sizes, temp_product_sizes, temp_order_statuses, temp_orders,
                    temp_order_details, temp_reviews, temp_shopping_cart, temp_shopping_cart_items,
                    temp_payment_methods, temp_payments;

-- Create temporary tables
CREATE TEMP TABLE temp_roles (LIKE Roles INCLUDING ALL);
CREATE TEMP TABLE temp_users (LIKE Users INCLUDING ALL);
CREATE TEMP TABLE temp_categories (LIKE Categories INCLUDING ALL);
CREATE TEMP TABLE temp_brands (LIKE Brands INCLUDING ALL);
CREATE TEMP TABLE temp_products (LIKE Products INCLUDING ALL);
CREATE TEMP TABLE temp_sizes (LIKE Sizes INCLUDING ALL);
CREATE TEMP TABLE temp_product_sizes (LIKE ProductSizes INCLUDING ALL);
CREATE TEMP TABLE temp_order_statuses (LIKE OrderStatuses INCLUDING ALL);
CREATE TEMP TABLE temp_orders (LIKE Orders INCLUDING ALL);
CREATE TEMP TABLE temp_order_details (LIKE OrderDetails INCLUDING ALL);
CREATE TEMP TABLE temp_reviews (LIKE Reviews INCLUDING ALL);
CREATE TEMP TABLE temp_shopping_cart (LIKE ShoppingCart INCLUDING ALL);
CREATE TEMP TABLE temp_shopping_cart_items (LIKE ShoppingCartItems INCLUDING ALL);
CREATE TEMP TABLE temp_payment_methods (LIKE PaymentMethods INCLUDING ALL);
CREATE TEMP TABLE temp_payments (LIKE Payments INCLUDING ALL);

COPY temp_roles FROM 'D:/ESDE/4th semester/nosql-databases/courseProject/Dataset-1/dataset1_roles.csv' DELIMITER ',' CSV HEADER;
COPY temp_users FROM 'D:/ESDE/4th semester/nosql-databases/courseProject/Dataset-1/dataset1_users.csv' DELIMITER ',' CSV HEADER;
COPY temp_categories FROM 'D:/ESDE/4th semester/nosql-databases/courseProject/Dataset-1/dataset1_categories.csv' DELIMITER ',' CSV HEADER;
COPY temp_brands FROM 'D:/ESDE/4th semester/nosql-databases/courseProject/Dataset-1/dataset1_brands.csv' DELIMITER ',' CSV HEADER;
COPY temp_products FROM 'D:/ESDE/4th semester/nosql-databases/courseProject/Dataset-1/dataset1_products.csv' DELIMITER ',' CSV HEADER;
COPY temp_sizes FROM 'D:/ESDE/4th semester/nosql-databases/courseProject/Dataset-1/dataset1_sizes.csv' DELIMITER ',' CSV HEADER;
COPY temp_product_sizes FROM 'D:/ESDE/4th semester/nosql-databases/courseProject/Dataset-1/dataset1_product_sizes.csv' DELIMITER ',' CSV HEADER;
COPY temp_order_statuses FROM 'D:/ESDE/4th semester/nosql-databases/courseProject/Dataset-1/dataset1_order_statuses.csv' DELIMITER ',' CSV HEADER;
COPY temp_orders FROM 'D:/ESDE/4th semester/nosql-databases/courseProject/Dataset-1/dataset1_orders.csv' DELIMITER ',' CSV HEADER;
COPY temp_order_details FROM 'D:/ESDE/4th semester/nosql-databases/courseProject/Dataset-1/dataset1_order_details.csv' DELIMITER ',' CSV HEADER;
COPY temp_reviews FROM 'D:/ESDE/4th semester/nosql-databases/courseProject/Dataset-1/dataset1_reviews.csv' DELIMITER ',' CSV HEADER;
COPY temp_shopping_cart FROM 'D:/ESDE/4th semester/nosql-databases/courseProject/Dataset-1/dataset1_shopping_cart.csv' DELIMITER ',' CSV HEADER;
COPY temp_shopping_cart_items FROM 'D:/ESDE/4th semester/nosql-databases/courseProject/Dataset-1/dataset1_shopping_cart_items.csv' DELIMITER ',' CSV HEADER;
COPY temp_payment_methods FROM 'D:/ESDE/4th semester/nosql-databases/courseProject/Dataset-1/dataset1_payment_methods.csv' DELIMITER ',' CSV HEADER;
COPY temp_payments FROM 'D:/ESDE/4th semester/nosql-databases/courseProject/Dataset-1/dataset1_payments.csv' DELIMITER ',' CSV HEADER;




INSERT INTO Roles (RoleName)
SELECT RoleName FROM temp_roles
WHERE RoleID NOT IN (SELECT RoleID FROM Roles);

INSERT INTO Users (Username, Password, Email, Address, Phone, RoleID)
SELECT Username, Password, Email, Address, Phone, RoleID FROM temp_users
WHERE UserID NOT IN (SELECT UserID FROM Users);

INSERT INTO Categories (CategoryName)
SELECT CategoryName FROM temp_categories
WHERE CategoryID NOT IN (SELECT CategoryID FROM Categories);

INSERT INTO Brands (BrandName)
SELECT BrandName FROM temp_brands
WHERE BrandID NOT IN (SELECT BrandID FROM Brands);

INSERT INTO Products (ProductName, Description, Price, CategoryID, BrandID)
SELECT ProductName, Description, Price, CategoryID, BrandID FROM temp_products
WHERE ProductID NOT IN (SELECT ProductID FROM Products);

INSERT INTO Sizes (USSize, UKSize, EURSize, CMSize, BRSize, CNSize)
SELECT USSize, UKSize, EURSize, CMSize, BRSize, CNSize FROM temp_sizes
WHERE SizeID NOT IN (SELECT SizeID FROM Sizes);

INSERT INTO ProductSizes (ProductID, SizeID, StockQuantity)
SELECT ProductID, SizeID, StockQuantity FROM temp_product_sizes
WHERE ProductSizeID NOT IN (SELECT ProductSizeID FROM ProductSizes);

INSERT INTO OrderStatuses (StatusName)
SELECT StatusName FROM temp_order_statuses
WHERE StatusID NOT IN (SELECT StatusID FROM OrderStatuses);

INSERT INTO Orders (UserID, OrderDate, TotalAmount, StatusID)
SELECT UserID, OrderDate, TotalAmount, StatusID FROM temp_orders
WHERE OrderID NOT IN (SELECT OrderID FROM Orders);

INSERT INTO OrderDetails (OrderID, ProductSizeID, Quantity, Price)
SELECT OrderID, ProductSizeID, Quantity, Price FROM temp_order_details
WHERE OrderDetailID NOT IN (SELECT OrderDetailID FROM OrderDetails);

INSERT INTO Reviews (UserID, ProductID, Rating, Comment, ReviewDate)
SELECT UserID, ProductID, Rating, Comment, ReviewDate FROM temp_reviews
WHERE ReviewID NOT IN (SELECT ReviewID FROM Reviews);

INSERT INTO ShoppingCart (UserID)
SELECT UserID FROM temp_shopping_cart
WHERE CartID NOT IN (SELECT CartID FROM ShoppingCart);

INSERT INTO ShoppingCartItems (CartID, ProductSizeID, Quantity)
SELECT CartID, ProductSizeID, Quantity FROM temp_shopping_cart_items
WHERE CartItemID NOT IN (SELECT CartItemID FROM ShoppingCartItems);

INSERT INTO PaymentMethods (MethodName)
SELECT MethodName FROM temp_payment_methods
WHERE PaymentMethodID NOT IN (SELECT PaymentMethodID FROM PaymentMethods);

INSERT INTO Payments (OrderID, PaymentDate, Amount, PaymentMethodID)
SELECT OrderID, PaymentDate, Amount, PaymentMethodID FROM temp_payments
WHERE PaymentID NOT IN (SELECT PaymentID FROM Payments);

DROP TABLE temp_roles, temp_users, temp_categories, temp_brands, temp_products,
           temp_sizes, temp_product_sizes, temp_order_statuses, temp_orders,
           temp_order_details, temp_reviews, temp_shopping_cart, temp_shopping_cart_items,
           temp_payment_methods, temp_payments;



-- Drop temporary tables if they exist
DROP TABLE IF EXISTS temp_roles, temp_users, temp_categories, temp_brands, temp_products,
                    temp_sizes, temp_product_sizes, temp_order_statuses, temp_orders,
                    temp_order_details, temp_reviews, temp_shopping_cart, temp_shopping_cart_items,
                    temp_payment_methods, temp_payments;

-- Create temporary tables
CREATE TEMP TABLE temp_roles (LIKE Roles INCLUDING ALL);
CREATE TEMP TABLE temp_users (LIKE Users INCLUDING ALL);
CREATE TEMP TABLE temp_categories (LIKE Categories INCLUDING ALL);
CREATE TEMP TABLE temp_brands (LIKE Brands INCLUDING ALL);
CREATE TEMP TABLE temp_products (LIKE Products INCLUDING ALL);
CREATE TEMP TABLE temp_sizes (LIKE Sizes INCLUDING ALL);
CREATE TEMP TABLE temp_product_sizes (LIKE ProductSizes INCLUDING ALL);
CREATE TEMP TABLE temp_order_statuses (LIKE OrderStatuses INCLUDING ALL);
CREATE TEMP TABLE temp_orders (LIKE Orders INCLUDING ALL);
CREATE TEMP TABLE temp_order_details (LIKE OrderDetails INCLUDING ALL);
CREATE TEMP TABLE temp_reviews (LIKE Reviews INCLUDING ALL);
CREATE TEMP TABLE temp_shopping_cart (LIKE ShoppingCart INCLUDING ALL);
CREATE TEMP TABLE temp_shopping_cart_items (LIKE ShoppingCartItems INCLUDING ALL);
CREATE TEMP TABLE temp_payment_methods (LIKE PaymentMethods INCLUDING ALL);
CREATE TEMP TABLE temp_payments (LIKE Payments INCLUDING ALL);

COPY temp_roles FROM 'D:/ESDE/4th semester/nosql-databases/courseProject/Dataset-2/dataset2_roles.csv' DELIMITER ',' CSV HEADER;
COPY temp_users FROM 'D:/ESDE/4th semester/nosql-databases/courseProject/Dataset-2/dataset2_users.csv' DELIMITER ',' CSV HEADER;
COPY temp_categories FROM 'D:/ESDE/4th semester/nosql-databases/courseProject/Dataset-2/dataset2_categories.csv' DELIMITER ',' CSV HEADER;
COPY temp_brands FROM 'D:/ESDE/4th semester/nosql-databases/courseProject/Dataset-2/dataset2_brands.csv' DELIMITER ',' CSV HEADER;
COPY temp_products FROM 'D:/ESDE/4th semester/nosql-databases/courseProject/Dataset-2/dataset2_products.csv' DELIMITER ',' CSV HEADER;
COPY temp_sizes FROM 'D:/ESDE/4th semester/nosql-databases/courseProject/Dataset-2/dataset2_sizes.csv' DELIMITER ',' CSV HEADER;
COPY temp_product_sizes FROM 'D:/ESDE/4th semester/nosql-databases/courseProject/Dataset-2/dataset2_product_sizes.csv' DELIMITER ',' CSV HEADER;
COPY temp_order_statuses FROM 'D:/ESDE/4th semester/nosql-databases/courseProject/Dataset-2/dataset2_order_statuses.csv' DELIMITER ',' CSV HEADER;
COPY temp_orders FROM 'D:/ESDE/4th semester/nosql-databases/courseProject/Dataset-2/dataset2_orders.csv' DELIMITER ',' CSV HEADER;
COPY temp_order_details FROM 'D:/ESDE/4th semester/nosql-databases/courseProject/Dataset-2/dataset2_order_details.csv' DELIMITER ',' CSV HEADER;
COPY temp_reviews FROM 'D:/ESDE/4th semester/nosql-databases/courseProject/Dataset-2/dataset2_reviews.csv' DELIMITER ',' CSV HEADER;
COPY temp_shopping_cart FROM 'D:/ESDE/4th semester/nosql-databases/courseProject/Dataset-2/dataset2_shopping_cart.csv' DELIMITER ',' CSV HEADER;
COPY temp_shopping_cart_items FROM 'D:/ESDE/4th semester/nosql-databases/courseProject/Dataset-2/dataset2_shopping_cart_items.csv' DELIMITER ',' CSV HEADER;
COPY temp_payment_methods FROM 'D:/ESDE/4th semester/nosql-databases/courseProject/Dataset-2/dataset2_payment_methods.csv' DELIMITER ',' CSV HEADER;
COPY temp_payments FROM 'D:/ESDE/4th semester/nosql-databases/courseProject/Dataset-2/dataset2_payments.csv' DELIMITER ',' CSV HEADER;



INSERT INTO Roles (RoleName)
SELECT RoleName FROM temp_roles
WHERE RoleID NOT IN (SELECT RoleID FROM Roles);

INSERT INTO Users (Username, Password, Email, Address, Phone, RoleID)
SELECT Username, Password, Email, Address, Phone, RoleID FROM temp_users
WHERE UserID NOT IN (SELECT UserID FROM Users);

INSERT INTO Categories (CategoryName)
SELECT CategoryName FROM temp_categories
WHERE CategoryID NOT IN (SELECT CategoryID FROM Categories);

INSERT INTO Brands (BrandName)
SELECT BrandName FROM temp_brands
WHERE BrandID NOT IN (SELECT BrandID FROM Brands);

INSERT INTO Products (ProductName, Description, Price, CategoryID, BrandID)
SELECT ProductName, Description, Price, CategoryID, BrandID FROM temp_products
WHERE ProductID NOT IN (SELECT ProductID FROM Products);

INSERT INTO Sizes (USSize, UKSize, EURSize, CMSize, BRSize, CNSize)
SELECT USSize, UKSize, EURSize, CMSize, BRSize, CNSize FROM temp_sizes
WHERE SizeID NOT IN (SELECT SizeID FROM Sizes);

INSERT INTO ProductSizes (ProductID, SizeID, StockQuantity)
SELECT ProductID, SizeID, StockQuantity FROM temp_product_sizes
WHERE ProductSizeID NOT IN (SELECT ProductSizeID FROM ProductSizes);

INSERT INTO OrderStatuses (StatusName)
SELECT StatusName FROM temp_order_statuses
WHERE StatusID NOT IN (SELECT StatusID FROM OrderStatuses);

INSERT INTO Orders (UserID, OrderDate, TotalAmount, StatusID)
SELECT UserID, OrderDate, TotalAmount, StatusID FROM temp_orders
WHERE OrderID NOT IN (SELECT OrderID FROM Orders);

INSERT INTO OrderDetails (OrderID, ProductSizeID, Quantity, Price)
SELECT OrderID, ProductSizeID, Quantity, Price FROM temp_order_details
WHERE OrderDetailID NOT IN (SELECT OrderDetailID FROM OrderDetails);

INSERT INTO Reviews (UserID, ProductID, Rating, Comment, ReviewDate)
SELECT UserID, ProductID, Rating, Comment, ReviewDate FROM temp_reviews
WHERE ReviewID NOT IN (SELECT ReviewID FROM Reviews);

INSERT INTO ShoppingCart (UserID)
SELECT UserID FROM temp_shopping_cart
WHERE CartID NOT IN (SELECT CartID FROM ShoppingCart);

INSERT INTO ShoppingCartItems (CartID, ProductSizeID, Quantity)
SELECT CartID, ProductSizeID, Quantity FROM temp_shopping_cart_items
WHERE CartItemID NOT IN (SELECT CartItemID FROM ShoppingCartItems);

INSERT INTO PaymentMethods (MethodName)
SELECT MethodName FROM temp_payment_methods
WHERE PaymentMethodID NOT IN (SELECT PaymentMethodID FROM PaymentMethods);

INSERT INTO Payments (OrderID, PaymentDate, Amount, PaymentMethodID)
SELECT OrderID, PaymentDate, Amount, PaymentMethodID FROM temp_payments
WHERE PaymentID NOT IN (SELECT PaymentID FROM Payments);

DROP TABLE temp_roles, temp_users, temp_categories, temp_brands, temp_products,
           temp_sizes, temp_product_sizes, temp_order_statuses, temp_orders,
           temp_order_details, temp_reviews, temp_shopping_cart, temp_shopping_cart_items,
           temp_payment_methods, temp_payments;
