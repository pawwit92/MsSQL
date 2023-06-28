/*
1. Z tabeli HumanResources.Employee wy�wietl LoginId oraz SickLeaveHours
2. W nowym zapytaniu wy�wietl �redni� ilo�� SickleaveHours
3. Napisz zapytanie w kt�rym:
	-wy�wietlone zostan� dane z pierwszego zapytania
	-w dodatkowej kolumnie wy�wietl �redni� ilo�� SickleaveHours w postaci podzapytania
	-zaaliasuj t� kolumn� jako AvgSickLeaveHours
4. Skopiuj poprzednie zapytanie. W nowej kolumnie wylicz r�nic� mi�dzy SickLeaveHours pracownika a warto�ci� �redni� ca�ej tabeli. 
   Kolumn� zaaliasuj jako SickLeaveDiff
5. Skopiuj poprzednie zapytanie. Dodaj klauzul� where, kt�ra spowoduje wy�wietlenie tylko tych pracownik�w, 
   kt�rzy maj� liczb� godzin SickLeaveHours wi�ksz� ni� warto�� �redni�. Uporz�dkuj dane wg kolumny SickLeaveDiff malej�co
*/

use AdventureWorks
go

--1-3
select
	hre.LoginID
	, hre.SickLeaveHours
	, (select avg(SickLeaveHours) from HumanResources.Employee) AvgSickLeaveHours
from HumanResources.Employee hre
go

--4
select
	hre.LoginID
	, hre.SickLeaveHours
	, (select avg(SickLeaveHours) from HumanResources.Employee) AvgSickLeaveHours
	, hre.SickLeaveHours - (select avg(SickLeaveHours) from HumanResources.Employee) SickLeaveDiff
from HumanResources.Employee hre
where hre.SickLeaveHours > (select avg(SickLeaveHours) from HumanResources.Employee)
order by 4 desc
go

/*
1. Napisz zapytanie zwracaj�ce BusinessEntityId dla jednego dowolnego pracownika (TOP(1)) z tabeli Sales.SalesPerson.
   Rekord powinien prezentowa� pracownika z TerritoryId=1
2. Napisz zapytanie wy�wietlaj�ce zam�wienia z tabeli SalesOrderHeader dla tego pracownika
3. Skopuj zapytanie z punktu (1) i usu� z niego TOP(1).  Ile rekord�w jest wy�wietlanych?
4. Skopiuj zapytanie z punktu (2). Usu� z niego TOP(1). Czy zapytanie dzia�a?
5. Popraw zapytanie aby zwraca�o poprawny wynik
6. Wy�wietl BusinessEntityId z tabeli HumanResources.DepartmentHistory dla DepartmentId=1.
7. Wy�wietl rekordy z HumanResources.Employee rekordy pracownik�w, kt�rzy kiedykolwiek pracowali w DepartamentId=1. 
   Skorzystaj w tym celu z zapytania z pkt (6)
*/
go

--1
select --top(1)
	ssp.BusinessEntityID
from Sales.SalesPerson ssp
where ssp.TerritoryID = 1

--2-5
select
*	
from Sales.SalesOrderHeader ssoh
where ssoh.SalesPersonID in (select 
								ssp.BusinessEntityID
							from Sales.SalesPerson ssp
							where ssp.TerritoryID = 1)
go

--6-7
select
	*
from HumanResources.Employee hre
where hre.BusinessEntityID in	(select
									hredh.BusinessEntityID
								from HumanResources.EmployeeDepartmentHistory hredh
								where hredh.DepartmentID = 1)
go


/*
1. W aplikacji cz�sto masz si� pos�ugiwa�  informacjami o nazwie produktu, podkategorii i kategorii. 
Napisz zapytanie, kt�re przy pomocy polecenia JOIN po�aczy ze sob� tabele:
	Production.Product, 
	Production.Subcategory i 
	Production.Category. 
Wy�wietli� nale�y:
	ProductId
	ProductName
	SubcategoryName
	CategoryName
Kolumny z nazwami powinny zosta� zaaliasowane.
2.  Napisz zapytanie, kt�re z tabeli Sales.SalesOrderDetail wy�wietli LineTotal
3. Do zapytania z pkt (2) do��cz zapytanie z pkt (1) tak aby do�aczane zapytanie by�o podzapytaniem. Wy�wietl:
	ProductId,
	ProductName,
	ProductSubcategory
	ProductCategory
	LineTotal
4. Napisz zapytanie, kt�re z tabel:
	Sales.SpecialOfferProduct
	Sales.SpecialOffer
wy�wietli:
	ProductId
	Description
5. Do zapytania z pkt (4) do��cz zapytanie z pkt (1) tak aby do�aczane zapytanie by�o podzapytaniem. Wy�wietl:
	ProductId,
	Description
	ProductName,
	ProductSubcategory
	ProductCategory
*/
go

--1
select
	pp.ProductID prod_ID
	, pp.Name prod_name
	, ppc.ProductCategoryID prod_cat
	, pps.ProductSubcategoryID prod_subcat
from Production.Product pp
join Production.ProductSubcategory pps on pp.ProductSubcategoryID = pps.ProductSubcategoryID
join Production.ProductCategory ppc on pps.ProductCategoryID = ppc.ProductCategoryID
go

--1-3
select
	sq1.prod_ID
	,sq1.prod_name
	,sq1.prod_cat
	,sq1.prod_subcat
	,ssod.LineTotal
from Sales.SalesOrderDetail ssod
join							(select
									pp.ProductID prod_ID
									, pp.Name prod_name
									, ppc.ProductCategoryID prod_cat
									, pps.ProductSubcategoryID prod_subcat
								from Production.Product pp
								join Production.ProductSubcategory pps on pp.ProductSubcategoryID = pps.ProductSubcategoryID
								join Production.ProductCategory ppc on pps.ProductCategoryID = ppc.ProductCategoryID) sq1 
								on ssod.ProductID = sq1.prod_ID 
go

--4-5
select
	ssop.ProductID
	,sso.Description
	,sq1.prod_name
	,sq1.prod_cat
	,sq1.prod_subcat
from Sales.SpecialOfferProduct ssop
join Sales.SpecialOffer sso on ssop.SpecialOfferID = sso.SpecialOfferID
join	(select
			pp.ProductID prod_ID
			, pp.Name prod_name
			, ppc.ProductCategoryID prod_cat
			, pps.ProductSubcategoryID prod_subcat
		from Production.Product pp
		join Production.ProductSubcategory pps on pp.ProductSubcategoryID = pps.ProductSubcategoryID
		join Production.ProductCategory ppc on pps.ProductCategoryID = ppc.ProductCategoryID) sq1
		on ssop.ProductID = sq1.prod_ID
go

/*
1. Napisz zapytanie, kt�re �aczy ze sob� tabele: HumanResources.Employee i Person.Person (kolumna ��cz�ca BusinessEntityId) i wy�wietla LastName i FirstName
2. Bazuj�c na poprzednim zapytaniu dodaj w li�cie select podzapytanie, kt�re wyliczy ile razy dany pracownik zmienia� departament pracuj�c w firmie. 
W tym celu policz ilo�� rekord�w w tabeli HumanResources. EmployeeDepartamentHistory, kt�re maj� BusinessEntityId zgodne z numerem tego pracownika)
3. Zmodyfikuj poprzednie polecenie tak, aby wy�wietli� tylko pracownik�w, kt�rzy pracowali co najmniej w dw�ch departamentach
4. W oparciu o dane z tabel HumanResources.Employee i Person.Person wy�wietl imi� i nazwisko pracownika (FirstName i LastName) oraz rok z daty zatrudnienia pracownika
5. Do poprzedniego zapytania dodaj w SELECT podzapytanie wy�wietlaj�ce informacj� o tym, ile os�b zatrudni�o si� w tym samym roku co dany pracownik
6. Napisz zapytanie, kt�re wy�wietli w oparciu o tabele Sales.SalesPerson oraz Person.Person: LastName, FirstName, Bonus oraz SalesQuota
7. Do poprzedniego zapytania dodaj dwa podzapytania w SELECT, kt�re:
	-wyznacz� �redni� warto�� Bonus dla wszystkich pracownik�w z tego samego terytorium (r�wno�� warto�ci w kolumnie TerritoryID)
	-wyznacz� �redni� warto�� SalesQuota dla wszystkich pracownik�w z tego samego terytorium (r�wno�� warto�ci w kolumnie TerritoryID)
8. Napisz polecenie wy�wietlaj�ce WSZYSTKIE informacje z tabeli Sales.SalesPerson, dla tych sprzedawc�w, kt�rzy SalesQuota maj� mniejsze od �rednieigo SalesQuota
9. Zmodyfikuj poprzednie polecenie tak, aby liczenie �redniego SalesQuota dotyczy�o tylko sprzedawc�w z tego samego terytorium (zgodna kolumna TerritoryID)
10. Z tabeli Sales.SalesOrderHeader wy�wietl rok i miesi�c z OrderDate oraz ilo�� rekord�w (pami�taj o grupowaniu)
11. Do poprzedniego polecenia dodaj do SELECT informacj� o ilo�ci zam�wie� w poprzednim roku w tym samym miesi�cu. Skorzystaj z podzapytania.
*/
go

--1 - 3
select	
	pp.FirstName f_name
	,pp.LastName l_name
	,(select count(*) from HumanResources.EmployeeDepartmentHistory hredh where hre.BusinessEntityID = hredh.BusinessEntityID) q_dept
from HumanResources.Employee hre
join Person.Person pp on hre.BusinessEntityID = pp.BusinessEntityID
where (select count(*) from HumanResources.EmployeeDepartmentHistory hredh where hre.BusinessEntityID = hredh.BusinessEntityID) > 1
go

--lub

select
	sq1.f_name
	,sq1.l_name
	,sq1.q_dept
from		(select	
				pp.FirstName f_name
				,pp.LastName l_name
				,(select count(*) from HumanResources.EmployeeDepartmentHistory hredh where hre.BusinessEntityID = hredh.BusinessEntityID) q_dept
			from HumanResources.Employee hre
			join Person.Person pp on hre.BusinessEntityID = pp.BusinessEntityID) sq1
where sq1.q_dept >1
go

--4-5
select
	pp.LastName
	,pp.FirstName
	,year(hre.HireDate)
	,(select count(hre1.HireDate) from HumanResources.Employee hre1 where year(hre1.HireDate)=year(hre.HireDate))
from HumanResources.Employee hre
join Person.Person pp on hre.BusinessEntityID = pp.BusinessEntityID
go

--6-8
select
	pp.LastName
	,pp.FirstName
	,ssp.Bonus
		,(select avg(ssp1.Bonus) from sales.SalesPerson ssp1 where ssp.TerritoryID = ssp1.TerritoryID) avg_bonus
	,ssp.SalesQuota
	,(select avg(ssp1.SalesQuota) from sales.SalesPerson ssp1 where ssp.TerritoryID = ssp1.TerritoryID) avg_quota
from Sales.SalesPerson ssp
join Person.Person pp on ssp.BusinessEntityID = pp.BusinessEntityID
where ssp.SalesQuota < (select avg(ssp1.SalesQuota) from sales.SalesPerson ssp1 where ssp.TerritoryID = ssp1.TerritoryID)
go

/*
1. Trzeba sprawdzi� czy w tabeli Production.UnitMeasure znajduj� si� jednostki miary, kt�re nie s� u�ywane przez �aden rekord w Production.Product.
Korzystaj�c z jednego z przedstawionych w tej lekcji s��w napisz zapytanie, kt�re wy�wietli rekordy z Production.UnitMeasure nieu�ywane 
w tabeli Production.Product ani w kolumnie SizeUnitMeasureCode ani w WeightUnitMeasureCode.
2. Zmodyfikuj polecenie z punktu (1), tak aby wy�wietli� te jednostki miary kt�re s� wykorzystywane w Production.Product
3.Wy�wietl z tabeli Production.Product te rekordy, gdzie ListPrice jest wi�ksze ni� ListPrice ka�dego produktu z kategorii 1
4. Wy�wietl z tabeli Production.Product te rekordy, gdzie ListPrice jest wi�ksze ni� ListPrice dla chocia� jednego produktu z kategorii 1
*/
go

--1
select distinct
	pum.Name
from Production.UnitMeasure pum
where   NOT EXISTS	(select 
						*
					from Production.Product pp 
					where pum.UnitMeasureCode = pp.WeightUnitMeasureCode or pum.UnitMeasureCode = pp.SizeUnitMeasureCode)
go

--2
select distinct
	pum.Name
from Production.UnitMeasure pum
where EXISTS	(select 
					*
				from Production.Product pp 
				where pum.UnitMeasureCode = pp.WeightUnitMeasureCode or pum.UnitMeasureCode = pp.SizeUnitMeasureCode)
go

--3 
select
	*
from Production.Product pp
where pp.ListPrice  >	ALL (select
							pp1.ListPrice
						from Production.Product pp1
						where pp1.ProductSubcategoryID =1)
go

--4
select
	*
from Production.Product pp
where pp.ListPrice  >	SOME (select
							pp1.ListPrice
						from Production.Product pp1
						where pp1.ProductSubcategoryID =1)
go

/*
1. Poni�sze zapytania odpowiada na pytanie "Jakie produkty maj� taki sam kolor, co produkt 322". Zapisz to zapytanie nie korzytaj�c z podzapyta�

SELECT p.* FROM Production.Product p
WHERE
p.Color = (SELECT Color FROM Production.Product WHERE ProductID=322)


2. Poni�sze zapytanie odpowiada na pytanie "Jak nazywa si� pracownik". Zamie� je na posta� bez podzapyta�

SELECT
 e.LoginID
 ,(SELECT p.LastName+' '+p.FirstName 
   FROM Person.Person p WHERE p.BusinessEntityID = e.BusinessEntityID) AS Name
FROM HumanResources.Employee e

3. Poni�sze zapytanie odpowiada na pytanie "Jakie jednostki miary nie s� wykorzystywane przez produkty". Zapisz je nie wykorzystuj�c podzapyta�

SELECT 
*
FROM Production.UnitMeasure um
WHERE
 NOT EXISTS(
 SELECT * FROM Production.Product p 
 WHERE um.UnitMeasureCode = p.SizeUnitMeasureCode 
       OR um.UnitMeasureCode =p.WeightUnitMeasureCode
 )

4. Poni�sze zapytanie odpowiada na pytanie "Jakie jednostki miary s� wykorzystywane przez produkty". Zapisz je nie wykorzystuj�c podzapyta�

SELECT 
um.*
FROM Production.UnitMeasure um
WHERE
 EXISTS( 
 SELECT * FROM Production.Product p 
 WHERE um.UnitMeasureCode = p.SizeUnitMeasureCode 
   OR um.UnitMeasureCode =p.WeightUnitMeasureCode
 )
*/

--1

select
	pp.*
from Production.Product pp
join Production.Product pp2 on pp.Color = pp2.Color
where pp2.ProductID = 322
go

--2


select distinct
	pum.UnitMeasureCode
from Production.UnitMeasure pum
except
(select distinct
	pp.SizeUnitMeasureCode
from Production.Product pp
union
select distinct
	pp.WeightUnitMeasureCode
from Production.Product pp)
