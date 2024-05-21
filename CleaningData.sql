--Cleaning Data in SQL

select *
From CovidPortfolio.dbo.NashvilleHousing

-- Standardize Date format
-- Comment: Standardizing all date data and updating table

select SaleDateConverted, convert(date,SaleDate)
From CovidPortfolio..NashvilleHousing

update NashvilleHousing
set SaleDate = convert(date,SaleDate)

alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = convert(date,SaleDate)


-- Populate Property Address Data
-- Comment: Finding all PropertyAddress wich are NULLs and using ParcelID finding properties
--			with same address and updating the table


select *
From CovidPortfolio..NashvilleHousing
where PropertyAddress is null



select a.ParcelID, a.PropertyAddress, b. ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
From CovidPortfolio..NashvilleHousing a
join CovidPortfolio..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
From CovidPortfolio..NashvilleHousing a
join CovidPortfolio..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)

-- METHOD 1 Substring and Charindex

SELECT PropertyAddress
FROM CovidPortfolio..NashvilleHousing
WHERE CHARINDEX(',', PropertyAddress) > 0;

select
	case
	when CHARINDEX(',', PropertyAddress) > 0
	then SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )
	else PropertyAddress
	end as Address1,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as Address2
From CovidPortfolio..NashvilleHousing
--where PropertyAddress is null

alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = case
	when CHARINDEX(',', PropertyAddress) > 0
	then SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )
	else PropertyAddress
end;

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

-- METHOD 2 PARSENAME

select OwnerAddress
From CovidPortfolio..NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
From CovidPortfolio..NashvilleHousing

alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)




-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
From CovidPortfolio..NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant,
case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end
From CovidPortfolio..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end


-- Remove Duplicates

with RowNumCTE as(
select *,
	ROW_NUMBER() over (
	partition by ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
	Order by UniqueID
	) Dups

From CovidPortfolio..NashvilleHousing
--order by Dups desc
)
delete
from RowNumCTE
where Dups > 1
--order by PropertyAddress


-- Delete Unused Columns

select *
From CovidPortfolio..NashvilleHousing

alter table CovidPortfolio..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
