-- adjusting date

select SaleDate, convert(Date,SaleDate)
from master.dbo.HousingData

Update HousingData
Set SaleDate= convert(Date,SaleDate)

ALTER TABLE HousingData
add SaleDateConverted Date;

Update HousingData
SET SaleDateConverted = Convert(Date,SaleDate)

-- populate property address data

select *
from master.dbo.HousingData
 where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress, b.PropertyAddress)
from master.dbo.HousingData as a 
join master.dbo.HousingData as b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from master.dbo.HousingData as a 
join master.dbo.HousingData as b
	on a.ParcelID=b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]

--breaking out address into seperate columns (address,city,state)

select PropertyAddress
from master.dbo.HousingData

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress)+1, LEN(PropertyAddress)) as City
from master.dbo.HousingData

-- update Address column
ALTER TABLE HousingData
add Address Nvarchar(250);

Update HousingData
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress)-1)

-- update City column

ALTER TABLE HousingData
add City Nvarchar(250);

Update HousingData
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',' , PropertyAddress)+1, LEN(PropertyAddress))

--another option for spliting the data
select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from master.dbo.HousingData

ALTER TABLE HousingData
add State Nvarchar(250);

update HousingData
SET State = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select *
from HousingData

--changing Y and N to YES and NO for uniformed data

select Distinct(SoldAsVacant)
from HousingData
order by 1 -- order by the number of the column shown

select SoldAsVacant
,CASE 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	when SoldAsVacant = 'n' then 'No'
	Else SoldAsVacant
	End

from HousingData

Update HousingData
SET SoldAsVacant =CASE 
						when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
						when SoldAsVacant = 'n' then 'No'
						Else SoldAsVacant
						End
-- Remove Duplicates
WITH RownumCTE AS (
select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 Legalreference
				 Order By
				 UniqueID
				 ) rou_num
from HousingData )

--Delete
--from RownumCTE
--where rou_num > 1

select *
from RownumCTE
where rou_num > 1
order by PropertyAddress

--useless columns

ALTER TABLE HousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress