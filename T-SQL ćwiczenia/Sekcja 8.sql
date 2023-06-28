/*
1. Napisz zapytanie, kt�re z tabeli Sales.SalesPerson oraz Person.Person wy�wietli: LastName, FirstName i sta�y napis Seller
	Napisz zapytanie, kt�re z tabeli HumanResources.Employee oraz Person.Person wy�wietli LastName, FIrstName oraz JobTitle
	Po��cz wyniki tych dw�ch zapyta�. Postaraj si� aby:
	-alias ostatniej kolumny by� "job"
	wyniki by�y posortowane wg ostatniej kolumny
2. Z tabeli HumanResources.Department  pobierz nazw� departamentu (Name) oraz sta�y napis "Department"
	Z tabeli Sales.Store pobierz nazw� sklepu (Name) oraz sta�y napis 'Store'
Po�acz wyniki tych dw�ch polece�. Zadbaj aby:
	Kolumna prezentuj�ca sta�e warto�ci by�a zaaliasowana jako "Location"
	Sortowanie odbywa�o si� w oparciu o Name
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
1. Napisz zapytanie, kt�re z tabeli Person.Person wybierze LastName i FirstName. 
	Napisz zapytanie, kt�re z tabeli HumanResources.Employee i Person.Person wybierze LastName i FirstName pracownik�w
	Po��cz oba w/w zapytania tak, aby je�li dana osoba jest pracownikiem, pojawi�a sie w wyniku 2 razy
2. A teraz poka� te osoby z pierwszego zapytania, kt�re NIE s� pracownikami
3. A teraz wy�wietl te osoby, kt�re s� pracownikami
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
