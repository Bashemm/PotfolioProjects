SELECT *
FROM Portfolio_trial..Sheet1$

-- Standardize Date Format in SALEDATE Column
ALTER TABLE Sheet1$
ADD SalesDateConverted date;

UPDATE Sheet1$
SET  SalesDateConverted = CONVERT(DATE, saleDate)


-- Populate PROPERTYADDRESS Column nulls.
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyAddress, b.PropertyAddress)
FROM Portfolio_trial..Sheet1$ a
	JOIN Portfolio_trial..Sheet1$ b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress =  ISNULL(a.propertyAddress, b.PropertyAddress)
FROM Portfolio_trial..Sheet1$ a
	JOIN Portfolio_trial..Sheet1$ b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-- Seperate Address and City in PROPERTYADDRESS Column
SELECT PropertyAddress, OwnerAddress
FROM Portfolio_trial..Sheet1$

SELECT PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS ADDRESS,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS ADDRESS
FROM Portfolio_trial..Sheet1$

ALTER TABLE Sheet1$
ADD PropertySplitAddress NVARCHAR(255);

UPDATE Sheet1$
SET  PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE Sheet1$
ADD PropertySplitCity NVARCHAR(255);

UPDATE Sheet1$
SET  PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


-- Breaking out OWNERADDRESS into Address, City and State.
Select OwnerAddress
from Portfolio_trial..Sheet1$

SELECT OwnerAddress, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1), PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2), PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
FROM Portfolio_trial..Sheet1$

ALTER TABLE Sheet1$
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE Sheet1$
SET  OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE Sheet1$
ADD OwnerSplitCity NVARCHAR(255);

UPDATE Sheet1$
SET  OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE Sheet1$
ADD OwnerSplitState NVARCHAR(255);

UPDATE Sheet1$
SET  OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- REPLACE ALL 'Y' AND 'N' TO 'YES' AND 'NO' IN SOLDASVACANT COLUMN

SELECT DISTINCT(SoldAsVacant)
FROM Portfolio_trial..Sheet1$

SELECT SoldAsVacant, 
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
END
FROM Portfolio_trial..Sheet1$

UPDATE Sheet1$
SET  SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	WHEN SoldAsVacant = 'N' THEN 'NO'
	ELSE SoldAsVacant
END

--DELETE DUPLICATES 
SELECT *
FROM Portfolio_trial..Sheet1$

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
					 SaleDate, 
					 propertyAddress,
					 LegalReference, 
					 OwnerName
		ORDER BY uniqueID
		) row_num

FROM Portfolio_trial..Sheet1$
)

DELETE
FROM RowNumCTE
WHERE row_num > 1

SELECT *
FROM Portfolio_trial..Sheet1$

--DROP UNUSED COLUMNS
ALTER TABLE Portfolio_trial..Sheet1$
DROP COLUMN propertyAddress, SaleDate, OwnerAddress, TaxDistrict

SELECT *
FROM Portfolio_trial..Sheet1$


