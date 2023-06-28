/*
1. Napisz zapytanie, które z tabeli Sales.SalesPerson oraz Person.Person wyœwietli: LastName, FirstName i sta³y napis Seller
	Napisz zapytanie, które z tabeli HumanResources.Employee oraz Person.Person wyœwietli LastName, FIrstName oraz JobTitle
	Po³¹cz wyniki tych dwóch zapytañ. Postaraj siê aby:
	-alias ostatniej kolumny by³ "job"
	wyniki by³y posortowane wg ostatniej kolumny
2. Z tabeli HumanResources.Department  pobierz nazwê departamentu (Name) oraz sta³y napis "Department"
	Z tabeli Sales.Store pobierz nazwê sklepu (Name) oraz sta³y napis 'Store'
Po³acz wyniki tych dwóch poleceñ. Zadbaj aby:
	Kolumna prezentuj¹ca sta³e wartoœci by³a zaaliasowana jako "Location"
	Sortowanie odbywa³o siê w oparciu o Name
*/
go

use AdventureWorks
go

--1
select
	pp.FirstName Name
	,pp.LastName Surname
	,'Seller' position
from Sales.SalesPerson ssp
join Person.Person pp on ssp.BusinessEntityID = pp.BusinessEntityID
union
select
	pp.FirstName
	,pp.LastName
	,hre.JobTitle
from HumanResources.Employee hre
join Person.Person pp on hre.BusinessEntityID = hre.BusinessEntityID
order by position
go

--2
select
	hrd.Name
	,'Department' Location
from HumanResources.Department hrd
union
select
	ss.Name
	,'Store'
from Sales.Store ss
order by hrd.Name
go

/*
1. Napisz zapytanie, które z tabeli Person.Person wybierze LastName i FirstName. 
	Napisz zapytanie, które z tabeli HumanResources.Employee i Person.Person wybierze LastName i FirstName pracowników
	Po³¹cz oba w/w zapytania tak, aby jeœli dana osoba jest pracownikiem, pojawi³a sie w wyniku 2 razy
2. A teraz poka¿ te osoby z pierwszego zapytania, które NIE s¹ pracownikami
3. A teraz wyœwietl te osoby, które s¹ pracownikami
*/

--1
select
	pp.FirstName
	,pp.LastName
from Person.Person pp
union all
select
	pp.FirstName
	,pp.LastName
from HumanResources.Employee hre
join Person.Person pp on hre.BusinessEntityID = pp.BusinessEntityID
go

--2
select
	pp.FirstName
	,pp.LastName
from Person.Person pp
except
select
	pp.FirstName
	,pp.LastName
from HumanResources.Employee hre
join Person.Person pp on hre.BusinessEntityID = pp.BusinessEntityID
go

--3
select
	pp.FirstName
	,pp.LastName
from Person.Person pp
intersect
select
	pp.FirstName
	,pp.LastName
from HumanResources.Employee hre
join Person.Person pp on hre.BusinessEntityID = pp.BusinessEntityID
go
