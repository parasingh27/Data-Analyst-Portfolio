SELECT *
FROM HousingDataAnalysis..Sheet1


ALTER TABLE Sheet1
ADD Sale_Date Date

Update Sheet1
SET Sale_Date = CONVERT(Date,SaleDate)

ALTER TABLE Sheet1
Drop Column SaleDate


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) AS New
FROM HousingDataAnalysis..Sheet1 a
Join HousingDataAnalysis..Sheet1 b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM HousingDataAnalysis..Sheet1 a
Join HousingDataAnalysis..Sheet1 b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]


SELECT PropertyAddress
FROM HousingDataAnalysis..Sheet1

SELECT 
SUBSTRING(PropertyAddress,1 ,CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM HousingDataAnalysis..Sheet1

ALTER TABLE Sheet1
ADD Address varchar(255)
Update Sheet1
SET Address = SUBSTRING(PropertyAddress,1 ,CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE Sheet1
ADD City varchar(255)
Update Sheet1
SET City = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT Address, City
FROM HousingDataAnalysis..Sheet1


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address, 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City, 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS Town
FROM Sheet1

ALTER TABLE Sheet1
ADD Owner_Address varchar(255)
Update Sheet1
SET Owner_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Sheet1
ADD Owner_City varchar(255)
Update Sheet1
SET Owner_City =PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Sheet1
ADD Owner_State varchar(255)
Update Sheet1
SET Owner_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


SELECT SoldAsVacant,
	Case When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
	END
FROM HousingDataAnalysis..Sheet1

UPDATE Sheet1
SET SoldAsVacant =
Case When SoldAsVacant = 'Y' THEN 'Yes'
		 When SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
	END


WITH RowNum_CTE AS
(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress,
				 SalePrice, Sale_Date, LegalReference
				 ORDER BY UniqueID
				)
				AS Row_Number
FROM HousingDataAnalysis..Sheet1
)
DELETE 
FROM RowNum_CTE
WHERE Row_Number > 1



