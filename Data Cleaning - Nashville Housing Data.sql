-- Data Cleaning Portfolio Project with Nashville Housing Data
-- Data Source - https://github.com/badhu-sha/PortfolioProjects/blob/main/Nashville%20Housing%20Data%20for%20Data%20Cleaning.xlsx
-- Github Profile - https://github.com/badhu-sha

SELECT *
FROM PortfolioProject..NashvilleHousing

-- Activity 1
-- Generalize Date Format

SELECT SaleDate
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD SaleDateConverted DATE

UPDATE PortfolioProject..NashvilleHousing
SET SaleDateConverted=CONVERT(DATE,SaleDate)

SELECT SaleDateConverted
FROM PortfolioProject..NashvilleHousing

----------------------------------------------------------------------------------------------------------------------

-- Activity 2
-- Populate Property Address Data

SELECT *
FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT A.UniqueID, A.ParcelID, A.PropertyAddress, B.UniqueID, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject..NashvilleHousing AS A
JOIN PortfolioProject..NashvilleHousing AS B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ]<>B.[UniqueID ]
WHERE A.PropertyAddress IS NULL
ORDER BY A.ParcelID

UPDATE A
SET PropertyAddress=ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject..NashvilleHousing AS A
JOIN PortfolioProject..NashvilleHousing AS B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ]<>B.[UniqueID ]
WHERE A.PropertyAddress IS NULL

---------------------------------------------------------------------------------------------------------------------------------

-- Activity 3
-- Breaking Out Address into individual columns (Address, City, State)

-- Splitting Property Address
-- Using Substring

SELECT propertyAddress,
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1),
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD propertySplitAddress NVARCHAR(255)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD propertySplitCity NVARCHAR(255)

UPDATE PortfolioProject..NashvilleHousing
SET propertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1)

UPDATE PortfolioProject..NashvilleHousing
SET propertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))

-- Splitting Owner Address
-- Using Parsename

SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

---------------------------------------------------------------------------------------------------------------------------------

-- Activity 4
-- Change Y and N to Yes and No in 'Sold as Vacant' field

SELECT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant='Y' Then 'Yes'
	 WHEN SoldAsVacant='N' Then 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant=CASE WHEN SoldAsVacant='Y' Then 'Yes'
	 WHEN SoldAsVacant='N' Then 'No'
	 ELSE SoldAsVacant
	 END


---------------------------------------------------------------------------------------------------------------------------------

-- Activity 5
-- Remove Duplicates

WITH RowNumCTE AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
			 PropertyAddress,
			 SaleDate,
			 SalePrice,
			 LegalReference,
			 OwnerName
			 ORDER BY
				UniqueID
) AS row_num
FROM PortfolioProject..NashvilleHousing
)
SELECT * FROM RowNumCTE
WHERE row_num>1

WITH RowNumCTE AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
			 PropertyAddress,
			 SaleDate,
			 SalePrice,
			 LegalReference,
			 OwnerName
			 ORDER BY
				UniqueID
) AS row_num
FROM PortfolioProject..NashvilleHousing
)
DELETE FROM RowNumCTE
WHERE row_num>1


---------------------------------------------------------------------------------------------------------------------------------

-- Activity 6
-- Delete Unused Columns

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict

---------------------------The End-----------------------------
