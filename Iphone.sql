CREATE DATABASE iPhoneData;
USE iPhoneData;

SELECT * FROM iphone;

--- Products Table ----
CREATE TABLE Products (
Product_ID INT Primary Key ,
productAsin NVARCHAR(150) ,
country VARCHAR(150) 
);
INSERT INTO Products (Product_ID,productAsin,country)
SELECT Product_ID, productAsin, country 
FROM iphone;

--- Variant Table ---
CREATE TABLE Variant (
Product_ID INT ,
variant_ID INT Primary key ,
variant NVARCHAR(150) ,
variantAsin NVARCHAR(150) ,
Foreign Key (Product_ID) REFERENCES Products (Product_ID)
);
INSERT INTO Variant (Product_ID,variant_ID,variant,variantAsin)
SELECT Product_ID,variant_ID,variant,variantAsin
FROM iphone ;

--- Review Table ---
CREATE TABLE Review (
 Review_ID INT PRIMARY KEY  ,
 Product_ID INT ,
 isVerified INT ,
 ratingScore INT ,
 reviewTitle NVARCHAR (3650) ,
 reviewDescription NVARCHAR (MAX) ,
 reviewURL NVARCHAR (3650) ,
 reviewedIN NVARCHAR (3650) ,
 date date , 
 FOREIGN KEY (Product_ID) REFERENCES Products (Product_ID)
);
INSERT INTO Review (Review_ID,Product_ID,isVerified,ratingScore,reviewTitle,reviewDescription,
reviewURL,reviewedIN,date)
SELECT Review_ID,Product_ID,isVerified,ratingScore,reviewTitle,reviewDescription,
reviewURL,reviewedIN,date
FROM iphone ;

------ Creating Schema called Iphone_Data ------
CREATE SCHEMA Iph;
ALTER SCHEMA Iph TRANSFER Iphone_Data.Products;
ALTER SCHEMA Iph TRANSFER Iphone_Data.Review;
ALTER SCHEMA Iph TRANSFER Iphone_Data.Variant;


---- Which iPhone model has the highest number of customer reviews? ----
SELECT P.productAsin AS iPhoneModel, COUNT(R.Review_ID) AS review_count, AVG(R.ratingScore) AS Average_Rating
FROM Products P
JOIN Review R 
ON P.Product_ID = R.Product_ID
GROUP BY  P.productAsin
ORDER BY review_count DESC ;

---- What is the distribution of ratings for each iPhone model? ----
SELECT P.productAsin AS iPhoneModel,R.ratingScore,COUNT(R.Review_ID) AS review_count
FROM Products P
JOIN Review R ON P.Product_ID = R.Product_ID
GROUP BY P.productAsin, R.ratingScore
ORDER BY P.productAsin, R.ratingScore;

---- Which features are most frequently mentioned in reviews for a particular iPhone model? ----
SELECT 
    Feature,
    COUNT(*) AS MentionCount 
FROM (
    SELECT 
        CASE 
            WHEN reviewDescription LIKE '%battery%' AND ratingScore<5 THEN 'Battery'
			WHEN reviewDescription LIKE'%Battery%' AND ratingScore<5 THEN 'Battery'
            WHEN reviewDescription LIKE '%camera%' AND ratingScore<5 THEN 'Camera'
            WHEN reviewDescription LIKE '%screen%' AND ratingScore<5 THEN 'Screen'
            WHEN reviewDescription LIKE '%performance%' AND ratingScore<5 THEN 'Performance'
            WHEN reviewDescription LIKE '%design%' AND ratingScore<5 THEN 'Design'
			WHEN reviewDescription LIKE '%material%' AND ratingScore<5 THEN 'Material'
			WHEN reviewDescription LIKE '%price%' AND ratingScore<5 THEN 'Price'
            ELSE 'Other'
        END AS Feature
    FROM Review 
) AS FeatureMentions
GROUP BY Feature
ORDER BY MentionCount DESC;

---- What are the reviews on products with ratings less than 5? ----
SELECT  p.Product_ID, P.country , R.ratingScore , R.reviewTitle , R.reviewDescription 
FROM Review R
JOIN Products P 
ON P.Product_ID = R.Product_ID
WHERE ratingScore < 5
ORDER BY ratingScore DESC ;

---- What are the reviews on products with ratings that are equal 5? ----
SELECT p.Product_ID, P.country , R.ratingScore , R.reviewTitle , R.reviewDescription 
FROM Review R
JOIN Products P 
ON P.Product_ID = R.Product_ID
WHERE ratingScore = 5 ;

---- How many review for each rating? ----
SELECT ratingScore , COUNT(reviewTitle) AS No_of_Reviews
FROM Review
GROUP  BY ratingScore
ORDER BY ratingScore ASC ;

---- How many reviews were made in each country? ----
CREATE VIEW CountryReviewCount AS
SELECT P.country, COUNT(R.reviewTitle) AS No_of_Reviews
FROM Products P
JOIN Review R
ON P.Product_ID = R.Product_ID
GROUP BY P.country;

---- How many reviews were made in each date? ----
SELECT reviewedIN , COUNT(reviewTitle) AS No_of_Reviews
FROM Review 
GROUP BY reviewedIN
ORDER BY No_of_Reviews DESC ;

---- How many reviews and rationg for each product? ----
SELECT P.productAsin , COUNT(R.ratingScore) AS No_of_Ratings  , COUNT(R.reviewTitle) AS No_of_Reviews
FROM Review R
JOIN Products P
ON P.Product_ID = R.Product_ID
GROUP BY P.productAsin
ORDER BY No_of_Ratings ASC ;

---- What is the average rating by its colour and size? ----
SELECT V.variant , AVG(R.ratingScore) AS Average_Rating
FROM Variant V
JOIN Review R
ON V.Product_ID = R.Product_ID
GROUP BY V.variant
ORDER BY Average_Rating DESC ;

---- The number of the verified and non-verified regarding to the country ----
SELECT  SUM(CASE WHEN R.isVerified = 1 THEN 1 ELSE 0 END) AS Verified_count,
SUM(CASE WHEN R.isVerified = 0 THEN 1 ELSE 0 END) AS Non_verified_count,
P.country 
FROM Review R
JOIN Products P
ON P.Product_ID = R.Product_ID
GROUP BY  P.country

