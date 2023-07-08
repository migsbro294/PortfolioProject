--  Nashville Housing data cleaning 

SELECT *
FROM dbo.NashvilleHousing 

-- standardize date format 


SELECT SaleDate, CONVERT(DATE,SaleDate)
FROM dbo.NashvilleHousing 

UPDATE NashvilleHousing
SET SaleDate =  CONVERT(DATE,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted =  CONVERT(DATE,SaleDate)

-- Populate property address data

SELECT *
FROM dbo.NashvilleHousing 
WHERE PropertyAddress is null 


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM dbo.NashvilleHousing a 
JOIN dbo.NashvilleHousing b
    on a.ParcelID = b.ParcelID 
    and a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null 

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM dbo.NashvilleHousing a 
JOIN dbo.NashvilleHousing b
    on a.ParcelID = b.ParcelID 
    and a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null 


-- breaking out address into individual colums (address, city, state)

SELECT PropertyAddress
FROM dbo.NashvilleHousing 


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM dbo.NashvilleHousing 

ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress =  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


UPDATE NashvilleHousing
SET PropertySplitCity =  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT 
PARSENAME( REPLACE(OwnerAddress,',','.'), 3 ),
PARSENAME( REPLACE(OwnerAddress,',','.'), 2 ),
PARSENAME( REPLACE(OwnerAddress,',','.'), 1)
FROM dbo.NashvilleHousing 



ALTER TABLE NashvilleHousing
ADD OnwerSplitAddress nvarchar(255);


ALTER TABLE NashvilleHousing
ADD OnwerSplitCity nvarchar(255);


ALTER TABLE NashvilleHousing
ADD OnwerSplitState nvarchar(255);


UPDATE NashvilleHousing
SET OnwerSplitAddress =  PARSENAME( REPLACE(OwnerAddress,',','.'), 3 )


UPDATE NashvilleHousing
SET OnwerSplitCity =  PARSENAME( REPLACE(OwnerAddress,',','.'), 2 )


UPDATE NashvilleHousing
SET OnwerSplitState =  PARSENAME( REPLACE(OwnerAddress,',','.'), 1)

-- change Y and N to Yes and No in "sold as vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM dbo.NashvilleHousing 
GROUP BY SoldAsVacant
ORDER BY 2



SELECT SoldAsVacant,
CASE 
    WHEN SoldAsVacant = 'Y' THEN 'YES'
    WHEN SoldAsVacant = 'N' THEN 'NO '
    ELSE SoldAsVacant
END
FROM dbo.NashvilleHousing 

UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE 
    WHEN SoldAsVacant = 'Y' THEN 'YES'
    WHEN SoldAsVacant = 'N' THEN 'NO '
    ELSE SoldAsVacant
END


-- remove dupicates 

WITH RowNumCTE
AS 
(
    SELECT *,
    ROW_NUMBER() OVER (PARTITION BY ParcelID,
                                    PropertyAddress, 
                                    SalePrice,SaleDate,
                                    LegalReference 
                                    ORDER BY UniqueID) row_num
    FROM dbo.NashvilleHousing 
   -- ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num >1
-- ORDER BY PropertyAddress







 -- delete unused colums 

SELECT *
FROM dbo.NashvilleHousing 


ALTER TABLE  dbo.NashvilleHousing 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE  dbo.NashvilleHousing 
DROP COLUMN SaleDate 

