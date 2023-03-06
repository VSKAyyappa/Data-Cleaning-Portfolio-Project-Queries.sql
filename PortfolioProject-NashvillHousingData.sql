/*
--Cleaning Data in SQL Query---
*/

select * from NashvilleHD

----------------------------------------------------------------

/*
Standardize Date Format
*/

select SaleDateConverted, Convert(Date,SaleDate)
from NashvilleHD

Update NashvilleHD
SET SaleDate = Convert(Date,SaleDate)

Alter Table NashvilleHD
Add SaleDateConverted Date;

Update NashvilleHD
SET SaleDateConverted = Convert(Date,SaleDate)
-----------------------------------------------------------------------------------------------
---Popular property Address Data

select *
from NashvilleHD
--Where propertyaddress is NULL
Order by ParcelID

select a.ParcelID,a.propertyaddress,b.ParcelID,b.propertyaddress, ISNULL(a.propertyaddress,b.propertyaddress)
from NashvilleHD a
JOIN NashvilleHD b
on a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
where a.propertyaddress is null

Update a
set propertyaddress = ISNULL(a.propertyaddress,b.propertyaddress)
from NashvilleHD a
JOIN NashvilleHD b
on a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
where a.propertyaddress is null

----------------------------------------------------------
--Breaking out address into individual coloumns (Address,State,City)

Select propertyaddress
from NashvilleHD

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as address
from NashvilleHD

Alter Table NashvilleHD
Add PropertySplitAddress NVARCHAR(255);

Update NashvilleHD
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table NashvilleHD
Add PropertySplitCity NVARCHAR(255);

Update NashvilleHD
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

select *
from NashvilleHD



select OwnerAddress
from NashvilleHD

select
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
from NashvilleHD


Alter Table NashvilleHD
Add OwnerSplitAddress NVARCHAR(255);

Update NashvilleHD
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

Alter Table NashvilleHD
Add OwnerSplitCity NVARCHAR(255);

Update NashvilleHD
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

Alter Table NashvilleHD
Add OwnerSplitState NVARCHAR(255);

Update NashvilleHD
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)


select *
from NashvilleHD

------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in 'Sold as Vacant' field

select DISTINCT(SoldAsVacant), count(SoldAsVacant)
from NashvilleHD
Group by SoldAsVacant
Order By 2


select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
from NashvilleHD

Update NashvilleHD
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
------------------------------------------------------------------------------------------------
--Remove Duplicates

with RowNumCTE as(
select *,
	ROW_NUMBER () Over(
	Partition By ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID
				) row_num
from NashvilleHD
--Order by ParcelID
)
select * --Delete--
from RowNumCTE
where ROW_Num >1
order by PropertyAddress

-------------------------------------------------------------------------------------------------
--Delete Unused Columns--

select *
from NashvilleHD

Alter Table NashVilleHD
DROP Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table NashVilleHD
DROP Column SaleDate