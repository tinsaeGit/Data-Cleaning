---Cleaning Data in sql Queries

select * from PortfolioProject.dbo.NashvilleHousingPortfolio

-----------------------------------------------------------------------------------------------------------------------
--satandardize date format

select SaleDateConverted, Convert(Date, SaleDate)
from PortfolioProject.dbo.NashvilleHousingPortfolio


update NashvilleHousingPortfolio
set SaleDate = Convert(Date, SaleDate)

Alter Table NashvilleHousingPortfolio
Add SaleDateConverted Date;

update NashvilleHousingPortfolio
set SaleDateConverted = Convert(Date, SaleDate)

-----------------------------------------------------------------------------------------------------------------
--Populate property Address data

select *
from PortfolioProject.dbo.NashvilleHousingPortfolio
--where PropertyAddress is null
order by ParcelID
---self join

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousingPortfolio a
join
NashvilleHousingPortfolio b
on  a.ParcelID = b.ParcelID
And
    a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) --or ISNULL(a.PropertyAddress, 'No Address')
from NashvilleHousingPortfolio a
join
NashvilleHousingPortfolio b
on  a.ParcelID = b.ParcelID
And
    a.[UniqueID ]<>b.[UniqueID ]
	where a.PropertyAddress is null

	select PropertyAddress from NashvilleHousingPortfolio
	where PropertyAddress is null

-------------------------------------------------------------------------------------------------------------
-- Breaking out addresses into individual columns(Address, city state)

select propertyAddress from NashvilleHousingPortfolio

--This will select the address from the first index till the comma

select SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)) as Address
from NashvilleHousingPortfolio

--But the comma is still there at the end of the address, and we don't want it

select SUBSTRING(PropertyAddress,1,  CHARINDEX(',', PropertyAddress)-1) as Address

, SUBSTRING(PropertyAddress , CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address2

from NashvilleHousingPortfolio


Alter Table NashvilleHousingPortfolio
Add PropertySplitAddress nvarchar(100);

update NashvilleHousingPortfolio
set PropertySplitAddress = SUBSTRING(PropertyAddress,1,  CHARINDEX(',', PropertyAddress)-1)



Alter Table NashvilleHousingPortfolio
Add PropertySplitcity  nvarchar(100);

update NashvilleHousingPortfolio
set PropertySplitcity = SUBSTRING(PropertyAddress , CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

select OwnerAddress from NashvilleHousingPortfolio ---This returns the address city and state
--use another methhod called ParseName which used to Return the specified part of an object name.

--ParseName works with period(.) so replace ',' by '.'
--parsename starts from the end(work backwards)
select PARSENAME(Replace(OwnerAddress, ',','.'),3)as Address
,PARSENAME(Replace(OwnerAddress, ',','.'),2) as city
,PARSENAME(Replace(OwnerAddress, ',','.'),1)as state 
from NashvilleHousingPortfolio



Alter Table NashvilleHousingPortfolio
Add OwnerSplitAddress nvarchar(100);

update NashvilleHousingPortfolio
set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',','.'),3)


Alter Table NashvilleHousingPortfolio
Add OwnerSplitcity  nvarchar(100);

update NashvilleHousingPortfolio
set OwnerSplitcity = PARSENAME(Replace(OwnerAddress, ',','.'),2)

Alter Table NashvilleHousingPortfolio
Add OwenerSplitState nvarchar(100);

update NashvilleHousingPortfolio
set OwenerSplitState = PARSENAME(Replace(OwnerAddress, ',','.'),1)

select * from NashvilleHousingPortfolio

------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as vaccant" field

select Distinct(SoldAsVacant),count(SoldAsVacant)  ---This count only different values
from NashvilleHousingPortfolio
group by SoldAsVacant
order by 2



select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
 from NashvilleHousingPortfolio
  
  ---update the table
 update NashvilleHousingPortfolio
 set
 SoldAsVacant = case 
       when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end

---------------------------------------------------------------------------------------------------------------------
--Remove Duplicates 
with RowNumCTE As (
select * ,
ROW_NUMBER() over (
partition by parcelID, PropertyAddress, Saleprice, SaleDate, Legalreference order by UniqueID)row_num
from NashvilleHousingPortfolio
)
Select * 
from RowNumCTE
where row_num >1

-------------------------------------------------------------------------------------
--Delete unused columns

select * from NashvilleHousingPortfolio

Alter Table NashvilleHousingPortfolio
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table NashvilleHousingPortfolio
Drop Column SaleDate
