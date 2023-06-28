use AdventureWorks

select
	hre.LoginID
	,CHARINDEX('\', hre.LoginID)
	,SUBSTRING(hre.LoginID, 0, CHARINDEX('\', hre.LoginID))
	,SUBSTRING(hre.LoginID, CHARINDEX('\', hre.LoginID) +1, len(hre.LoginID))
	,left(hre.LoginID, CHARINDEX('\', hre.LoginID)-1)
	,right(hre.LoginID, len(hre.LoginID) - CHARINDEX('\', hre.LoginID))
	,(hre.LoginID)
from HumanResources.Employee hre
go

declare @d datetime = GetDate()
print @d

select format(@d, 'd', 'pl-PL')
select format(@d, 'D', 'pl-PL') 
select format(@d, 'D', 'en-EN')
select format(@d, 'dd-mm-yyyy hh:mm:ss')
select format(12345.6789, '0.00')