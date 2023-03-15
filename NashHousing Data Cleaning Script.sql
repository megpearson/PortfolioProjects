SELECT * FROM HousingProject..NashHousing

-- Standardize date format

SELECT SaleDate, CONVERT(Date, SaleDate) from HousingProject..NashHousing

UPDATE HousingProject..NashHousing SET SaleDate = CONVERT(Date, SaleDate)

SELECT * FROM HousingProject..NashHousing

-- Populate property address data

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM HousingProject..NashHousing a
JOIN HousingProject..NashHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID]<>b.[UniqueID]
WHERE a.PropertyAddress is NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM HousingProject..NashHousing a
JOIN HousingProject..NashHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID]<>b.[UniqueID]
WHERE a.PropertyAddress is NULL

SELECT PropertyAddress FROM HousingProject..NashHousing WHERE PropertyAddress is NULL

-- Breaking address information into individual columns
-- Finding information in PropertyAddress column before ,

SELECT PropertyAddress FROM HousingProject..NashHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM HousingProject..NashHousing

ALTER TABLE HousingProject..NashHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE HousingProject..NashHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE HousingProject..NashHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE HousingProject..NashHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT * FROM HousingProject..NashHousing

SELECT OwnerAddress From HousingProject..NashHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From HousingProject..NashHousing

ALTER TABLE HousingProject..NashHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE HousingProject..NashHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE HousingProject..NashHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE HousingProject..NashHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE HousingProject..NashHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE HousingProject..NashHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT * FROM HousingProject..NashHousing

-- Change Y and N to Yes and No in "Sold as Vacant"

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM HousingProject..NashHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM HousingProject..NashHousing

Update HousingProject..NashHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

SELECT SoldAsVacant FROM HousingProject..NashHousing

-- Removing duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM HousingProject..NashHousing
)
DELETE FROM RowNumCTE
WHERE row_num > 1

-- Delete unused columns

ALTER TABLE HousingProject..NashHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

SELECT * FROM HousingProject..NashHousing