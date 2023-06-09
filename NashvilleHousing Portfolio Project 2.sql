Select * 
From PortfolioProject..NashvilleHousing

---------------------
--Standardize Date Format

Select SaleDate, CONVERT(Date, SaleDate)
From NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

-----------------------------------------------------------------
--Populate Property Address Data

Select *
From NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

--Populate property address if parcelID are equal

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--We joined the table to it self on property address but when the uniqueid was different. then we conditioned only null 
--addresses and required that when the address is null, replace with the existing property address. 

--We shall update the table now

UPDATE a --use alias instead of table name
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--------------------------------------------------------------------------------------------
-- Breaking Out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From PortfolioProject..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
FROM NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) as Address
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress;

Select *
From PortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------------------
--Split Owner's Address

Select OwnerAddress
From PortfolioProject..NashvilleHousing

--Use ParseName instead of delimeter
SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar (255)

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar (255)

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar (255)

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

----------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

Select DISTINCT(SoldAsVacant)
From PortfolioProject..NashvilleHousing

--Let's take the above and do a count of the "Sold as Vacant" field

Select DISTINCT(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing

--this gives error, until you add the group by function

Select DISTINCT(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
order by 2 -- we can also sort it out

--using a case statement we can change the values

Select SoldAsVacant,
	Case When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
From PortfolioProject..NashvilleHousing

--NOW UPDATE THE TABLE
Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

----------------------------------------------------------------------------------------------------
-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY	ParcelID,
					PropertySplitAddress,
					SalePrice,
					SaleDate,
					LegalReference
					Order by
						UniqueID
						) row_num
FROM NashvilleHousing
--Order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1

--SEE IF THE DUPLICATES ARE REMOVED
WITH RowNumCTE AS(
SELECT *, 
	ROW_NUMBER() OVER (
	PARTITION BY	ParcelID,
					PropertySplitAddress,
					SalePrice,
					SaleDate,
					LegalReference
					Order by
						UniqueID
						) row_num
FROM NashvilleHousing
--Order by ParcelID
)
SELECT *
From RowNumCTE
Where row_num > 1

----------------------------------------------------------------------------------------------------
-- Drop Unused Columns

ALTER TABLE NASHVILLEHOUSING
DROP COLUMN OwnerAddress, TaxDistrict

ALTER TABLE NASHVILLEHOUSING
DROP COLUMN SaleDate

SELECT * FROM NashvilleHousing