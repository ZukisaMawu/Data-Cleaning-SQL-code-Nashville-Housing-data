-- Cleaning data with SQL

select *
from PortfolioProject..NashvilleHousing

---------------------------------------------------------------------------------------------------------------
--Standardize the date format
select SaleDate, convert(date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
add SaleDateConverted Date
update NashvilleHousing
set SaleDateConverted = convert(date, SaleDate)

select SaleDateConverted, convert(date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

----------------------------------------------------------------------------------------------------------------
--Populate property addres data
--First view all data enries with null Property address.
select *
from PortfolioProject..NashvilleHousing
where PropertyAddress is null
order by ParcelID
--Observe all data entries with null Property address' to a join table for editing
select *
from PortfolioProject..NashvilleHousing as nash01
join PortfolioProject..NashvilleHousing as nash02
	on nash01.ParcelID = nash01.ParcelID and nash01.[UniqueID ] <> nash02.[UniqueID ]
where nash01.PropertyAddress is null
--Update and edit all null property address' in join table
Update nash01
set PropertyAddress = isnull(nash01.PropertyAddress, nash02.PropertyAddress)
from PortfolioProject..NashvilleHousing as nash01
join PortfolioProject..NashvilleHousing as nash02
	on nash01.ParcelID = nash01.ParcelID and nash01.[UniqueID ] <> nash02.[UniqueID ]
where nash01.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------
--Breaking out address into individual columns, (Adress, City, State).
select PropertyAddress
from PortfolioProject..NashvilleHousing

select
substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1) as Address, substring(PropertyAddress, charindex(',', PropertyAddress) +1,
len(PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
add PropertySplitAddress nvarchar(250);

update PortfolioProject..NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) - 1)

alter table PortfolioProject..NashvilleHousing
add PropertySplitCity nvarchar(250);

update PortfolioProject..NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress))

select *
from PortfolioProject..NashvilleHousing


Select OwnerAddress
from PortfolioProject..NashvilleHousing

select
parsename(replace(OwnerAddress, ',','.'), 3), parsename(replace(OwnerAddress, ',','.'), 2),
parsename(replace(OwnerAddress, ',','.'), 1)
from PortfolioProject..NashvilleHousing

alter table PortfolioProject..NashvilleHousing
add OwnerSplitAddress nvarchar(250);

update PortfolioProject..NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',','.'), 3)

alter table PortfolioProject..NashvilleHousing
add OwnerSplitCity nvarchar(250);

update PortfolioProject..NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',','.'), 2)

alter table PortfolioProject..NashvilleHousing
add OwnerSplitState nvarchar(250);

update PortfolioProject..NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',','.'), 1)

select *
from PortfolioProject..NashvilleHousing

-------------------------------------------------------------------------------------------------------------------
--Change 'Y' and 'N' to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from PortfolioProject..NashvilleHousing

update PortfolioProject..NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						else SoldAsVacant
						end

-------------------------------------------------------------------------------------------------------------------------
--Removing Duplicates

--First check for duplicates
with RowNumCTE as (
select *, row_number() over (
		  partition by ParcelID,
					   PropertyAddress,
					   SalePrice,
					   LegalReference
		  order by UniqueID
		  ) row_num
from PortfolioProject..NashvilleHousing
)
select *
from RowNumCTE
where row_num > 1
order by PropertyAddress 

--Delete duplicates
with RowNumCTE as (
select *, row_number() over (
		  partition by ParcelID,
					   PropertyAddress,
					   SalePrice,
					   LegalReference
		  order by UniqueID
		  ) row_num
from PortfolioProject..NashvilleHousing
)
delete
from RowNumCTE
where row_num > 1

--------------------------------------------------------------------------------------------------------------------
--Romoving Unused columns 

alter table PortfolioProject..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

select *
from PortfolioProject..NashvilleHousing