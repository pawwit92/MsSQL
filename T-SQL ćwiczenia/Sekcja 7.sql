/*
1. Z tabeli HumanResources.Employee wyœwietl LoginId oraz SickLeaveHours
2. W nowym zapytaniu wyœwietl œredni¹ iloœæ SickleaveHours
3. Napisz zapytanie w którym:
	-wyœwietlone zostan¹ dane z pierwszego zapytania
	-w dodatkowej kolumnie wyœwietl œredni¹ iloœæ SickleaveHours w postaci podzapytania
	-zaaliasuj t¹ kolumnê jako AvgSickLeaveHours
4. Skopiuj poprzednie zapytanie. W nowej kolumnie wylicz ró¿nicê miêdzy SickLeaveHours pracownika a wartoœci¹ œredni¹ ca³ej tabeli. 
   Kolumnê zaaliasuj jako SickLeaveDiff
5. Skopiuj poprzednie zapytanie. Dodaj klauzulê where, która spowoduje wyœwietlenie tylko tych pracowników, 
   którzy maj¹ liczbê godzin SickLeaveHours wiêksz¹ ni¿ wartoœæ œredni¹. Uporz¹dkuj dane wg kolumny SickLeaveDiff malej¹co
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
1. Napisz zapytanie zwracaj¹ce BusinessEntityId dla jednego dowolnego pracownika (TOP(1)) z tabeli Sales.SalesPerson.
   Rekord powinien prezentowaæ pracownika z TerritoryId=1
2. Napisz zapytanie wyœwietlaj¹ce zamówienia z tabeli SalesOrderHeader dla tego pracownika
3. Skopuj zapytanie z punktu (1) i usuñ z niego TOP(1).  Ile rekordów jest wyœwietlanych?
4. Skopiuj zapytanie z punktu (2). Usuñ z niego TOP(1). Czy zapytanie dzia³a?
5. Popraw zapytanie aby zwraca³o poprawny wynik
6. Wyœwietl BusinessEntityId z tabeli HumanResources.DepartmentHistory dla DepartmentId=1.
7. Wyœwietl rekordy z HumanResources.Employee rekordy pracowników, którzy kiedykolwiek pracowali w DepartamentId=1. 
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
1. W aplikacji czêsto masz siê pos³ugiwaæ  informacjami o nazwie produktu, podkategorii i kategorii. 
Napisz zapytanie, które przy pomocy polecenia JOIN po³aczy ze sob¹ tabele:
	Production.Product, 
	Production.Subcategory i 
	Production.Category. 
Wyœwietliæ nale¿y:
	ProductId
	ProductName
	SubcategoryName
	CategoryName
Kolumny z nazwami powinny zostaæ zaaliasowane.
2.  Napisz zapytanie, które z tabeli Sales.SalesOrderDetail wyœwietli LineTotal
3. Do zapytania z pkt (2) do³¹cz zapytanie z pkt (1) tak aby do³aczane zapytanie by³o podzapytaniem. Wyœwietl:
	ProductId,
	ProductName,
	ProductSubcategory
	ProductCategory
	LineTotal
4. Napisz zapytanie, które z tabel:
	Sales.SpecialOfferProduct
	Sales.SpecialOffer
wyœwietli:
	ProductId
	Description
5. Do zapytania z pkt (4) do³¹cz zapytanie z pkt (1) tak aby do³aczane zapytanie by³o podzapytaniem. Wyœwietl:
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
1. Napisz zapytanie, które ³aczy ze sob¹ tabele: HumanResources.Employee i Person.Person (kolumna ³¹cz¹ca BusinessEntityId) i wyœwietla LastName i FirstName
2. Bazuj¹c na poprzednim zapytaniu dodaj w liœcie select podzapytanie, które wyliczy ile razy dany pracownik zmienia³ departament pracuj¹c w firmie. 
W tym celu policz iloœæ rekordów w tabeli HumanResources. EmployeeDepartamentHistory, które maj¹ BusinessEntityId zgodne z numerem tego pracownika)
3. Zmodyfikuj poprzednie polecenie tak, aby wyœwietliæ tylko pracowników, którzy pracowali co najmniej w dwóch departamentach
4. W oparciu o dane z tabel HumanResources.Employee i Person.Person wyœwietl imiê i nazwisko pracownika (FirstName i LastName) oraz rok z daty zatrudnienia pracownika
5. Do poprzedniego zapytania dodaj w SELECT podzapytanie wyœwietlaj¹ce informacjê o tym, ile osób zatrudni³o siê w tym samym roku co dany pracownik
6. Napisz zapytanie, które wyœwietli w oparciu o tabele Sales.SalesPerson oraz Person.Person: LastName, FirstName, Bonus oraz SalesQuota
7. Do poprzedniego zapytania dodaj dwa podzapytania w SELECT, które:
	-wyznacz¹ œredni¹ wartoœæ Bonus dla wszystkich pracowników z tego samego terytorium (równoœæ wartoœci w kolumnie TerritoryID)
	-wyznacz¹ œredni¹ wartoœæ SalesQuota dla wszystkich pracowników z tego samego terytorium (równoœæ wartoœci w kolumnie TerritoryID)
8. Napisz polecenie wyœwietlaj¹ce WSZYSTKIE informacje z tabeli Sales.SalesPerson, dla tych sprzedawców, którzy SalesQuota maj¹ mniejsze od œrednieigo SalesQuota
9. Zmodyfikuj poprzednie polecenie tak, aby liczenie œredniego SalesQuota dotyczy³o tylko sprzedawców z tego samego terytorium (zgodna kolumna TerritoryID)
10. Z tabeli Sales.SalesOrderHeader wyœwietl rok i miesi¹c z OrderDate oraz iloœæ rekordów (pamiêtaj o grupowaniu)
11. Do poprzedniego polecenia dodaj do SELECT informacjê o iloœci zamówieñ w poprzednim roku w tym samym miesi¹cu. Skorzystaj z podzapytania.
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
1. Trzeba sprawdziæ czy w tabeli Production.UnitMeasure znajduj¹ siê jednostki miary, które nie s¹ u¿ywane przez ¿aden rekord w Production.Product.
Korzystaj¹c z jednego z przedstawionych w tej lekcji s³ów napisz zapytanie, które wyœwietli rekordy z Production.UnitMeasure nieu¿ywane 
w tabeli Production.Product ani w kolumnie SizeUnitMeasureCode ani w WeightUnitMeasureCode.
2. Zmodyfikuj polecenie z punktu (1), tak aby wyœwietliæ te jednostki miary które s¹ wykorzystywane w Production.Product
3.Wyœwietl z tabeli Production.Product te rekordy, gdzie ListPrice jest wiêksze ni¿ ListPrice ka¿dego produktu z kategorii 1
4. Wyœwietl z tabeli Production.Product te rekordy, gdzie ListPrice jest wiêksze ni¿ ListPrice dla chocia¿ jednego produktu z kategorii 1
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
1. Poni¿sze zapytania odpowiada na pytanie "Jakie produkty maj¹ taki sam kolor, co produkt 322". Zapisz to zapytanie nie korzytaj¹c z podzapytañ

SELECT p.* FROM Production.Product p
WHERE
p.Color = (SELECT Color FROM Production.Product WHERE ProductID=322)


2. Poni¿sze zapytanie odpowiada na pytanie "Jak nazywa siê pracownik". Zamieñ je na postaæ bez podzapytañ

SELECT
 e.LoginID
 ,(SELECT p.LastName+' '+p.FirstName 
   FROM Person.Person p WHERE p.BusinessEntityID = e.BusinessEntityID) AS Name
FROM HumanResources.Employee e

3. Poni¿sze zapytanie odpowiada na pytanie "Jakie jednostki miary nie s¹ wykorzystywane przez produkty". Zapisz je nie wykorzystuj¹c podzapytañ

SELECT 
*
FROM Production.UnitMeasure um
WHERE
 NOT EXISTS(
 SELECT * FROM Production.Product p 
 WHERE um.UnitMeasureCode = p.SizeUnitMeasureCode 
       OR um.UnitMeasureCode =p.WeightUnitMeasureCode
 )

4. Poni¿sze zapytanie odpowiada na pytanie "Jakie jednostki miary s¹ wykorzystywane przez produkty". Zapisz je nie wykorzystuj¹c podzapytañ

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
