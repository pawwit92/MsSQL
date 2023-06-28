/*
1. Wyœwietl:
	z tabeli Person.Person: FirstName i LastName
	z tabeli Sales.SalesPerson: Bonus
	kolumn¹ ³¹cz¹c¹ jest BusinessEntityId
2. Wyœwietl:
	z tabeli Sales.SalesOrderHeader: SalesOrderId, OrderDate i SalesOrderNumber
	z tabeli SalesOrderDetail: ProductId, OrderQty, UnitPrice
	kolumn¹ ³¹cz¹c¹ jest SalesOrderId
3. Wyœwietl:
	z tabeli Production.Product: Name
	z tabeli Sales.SalesOrderDetails: wartoœæ zamówienia z rabatem (UnitPrice - UnitPriceDiscount)*OrderQty
	kolumna ³¹cz¹ca to ProductId
4. Bazuj¹c na poprzednim zapytaniu wyznacz jaka jest ca³kowita wartoœæ sprzeda¿y okreœlonych produktów, tzn. w wyniku masz zobaczyæ:
	nazwê produktu
	ca³kowit¹ wartoœæ sprzeda¿y tego produktu
	wynik posortuj wg wysokoœci sprzeda¿y malej¹co
5. Wyœwietl
	z tabeli Production.Category: Name
	z tabeli Production.SubCategory: Name
	zaaliasuj kolumny, aby by³o wiadomo, co w nich siê znajduje
6. Na podstawie poprzedniego zapytania przygotuj nastêpne, które poka¿e ile podkategorii ma ka¿da kategoria. Wyœwietl:
	nazwê kategorii
	iloœæ podkategorii
	posortuj wg nazwy kategorii
7. Wyœwietl:
	z tabeli Production.Product: name
	oraz iloœæ recencji produku (tabela Production.ProductReview)
8. Ustal, którzy pracownicy pracowali na wiêkszej iloœci zmian. W tym celu po³¹cz tabele:
	HumanResources.EmployeeDepartmentHistory z
	Person.Person
	wyœwietl:
	imiê i nazwisko (FirstName i LastName)
	oraz iloœæ dopasowanych rekordów
	Wybierz tylko te wiersze, w których wyznaczona iloœæ COUNT(*) jest wiêksza ni¿ 1
*/
use AdventureWorks
go

--1
select
	pp.FirstName
	,pp.LastName
	,ssp.Bonus
from Person.Person pp
join Sales.SalesPerson ssp on pp.BusinessEntityID = ssp.BusinessEntityID
go

--2
select
	ssoh.SalesOrderID
	, ssoh.OrderDate
	, ssoh.SalesOrderNumber
	, ssod.ProductID
	, ssod.OrderQty
	, ssod.UnitPrice
from Sales.SalesOrderHeader ssoh
join Sales.SalesOrderDetail ssod on ssoh.SalesOrderID = ssod.SalesOrderID

--3 
select
	pp.Name
	,(ssod.UnitPrice-(ssod.UnitPrice*ssod.UnitPriceDiscount))*ssod.OrderQty amount
from Production.Product pp
join Sales.SalesOrderDetail ssod on pp.ProductID = ssod.ProductID
go

--4

select
	pp.Name
	,sum((ssod.UnitPrice-(ssod.UnitPrice*ssod.UnitPriceDiscount))*ssod.OrderQty) amount
from Production.Product pp
join Sales.SalesOrderDetail ssod on pp.ProductID = ssod.ProductID
group by pp.Name
order by 2 desc
go

--5,6
select		
	ppc.Name
	,count(pps.Name)
from Production.ProductCategory ppc
join Production.ProductSubcategory pps on ppc.ProductCategoryID = pps.ProductCategoryID 
group by ppc.Name
go

--7
select
	pp.Name
	,count(*)
from Production.Product pp
join Production.ProductReview ppr on pp.ProductID = ppr.ProductID
group by pp.Name
go

--8
select
	pp.FirstName
	, pp.LastName
	, count(*)
from HumanResources.EmployeeDepartmentHistory hredh
join Person.Person pp on hredh.BusinessEntityID = pp.BusinessEntityID
group by pp.FirstName, pp.LastName
having count(*) >1
go

/*
1. Wyœwietl:
	z tabeli Person.Person: LastName i FirstName
	z tabeli Person.PersonPhone: PhoneNumber
	wyœwietlaj równie¿ te osoby, które nie poda³y numeru telefonu (jeœli takie s¹)
2. Zmodyfikuj poprzednie polecenie tak, aby wyœwietlone zosta³y tylko te osoby, które nie poda³y numeru telefonu (jeœli takie s¹)
3. Wyœwietl:
	z tabeli Production.Product: Name
	z tabeli Production.ProductDocument: DocumentNode
	uwzglêdnij w tym równie¿ te produkty, które nie maj¹ "pasuj¹cego rekordu"
4. Zmodyfikuj poprzednie polecenie tak, aby wyœwietlone zosta³y tylko te produkty, które nie maj¹ 'pasuj¹cego' rekordu w tabeli dokumentów
5. (*Wymagane dwukrotne do³¹czenie tej samej tabeli z ró¿nymi aliasami!)
W tym zadaniu szukamy, czy s¹ takie jednostki miary, które nie s¹ wykorzystywane w tabeli produktów, bo np. chcemy usun¹æ niepotrzebne jednostki miary z tabeli
wyœwietl:
z tabeli Production.UnitMeasure: Name, UnitMeasureCode
napis "Is used as a size" je¿eli uda³o siê znaleŸæ "pasuj¹cy" rekord w tabeli Production.Product ³¹cz¹c tabele UnitMeasure z tabel¹ Product korzystaj¹c z kolumny SizeUnitMeasureCode
napis "Is used as a weight" je¿eli uda³o siê znaleŸæ "pasuj¹cy" rekord w tabeli Production.Product ³¹cz¹c tabele UnitMeasure z tabel¹ Product korzystaj¹c z kolumny WeightUnitMeasureCode

6. Zmodyfikuj poprzednie polecenie tak, aby wyœwietlone zosta³y tylko te jednostki miary, które nie s¹ u¿ywane ani do okreœlenia rozmiaru produktu, ani do okreœlnenia wagi
*/
go

--1
select
	pp.FirstName
	,pp.LastName
	,ppp.PhoneNumber
from Person.Person pp
left join Person.PersonPhone ppp on pp.BusinessEntityID = ppp.BusinessEntityID
go

--2
select
	pp.FirstName
	,pp.LastName
	,ppp.PhoneNumber
from Person.Person pp
left join Person.PersonPhone ppp on pp.BusinessEntityID = ppp.BusinessEntityID
where ppp.PhoneNumber is null
go

--3 
select
	pp.Name
	, DocumentNode
from Production.Product pp
left join Production.ProductDocument ppd on pp.ProductID = ppd.ProductID
go

--4
select
	pp.Name
	, ppd.DocumentNode
from Production.Product pp
left join Production.ProductDocument ppd on pp.ProductID = ppd.ProductID
where ppd.DocumentNode is null
go

--5
select	
	pum.Name
	, pum.UnitMeasureCode
	, case pum.UnitMeasureCode
		when pp2.SizeUnitMeasureCode then 'Is used as a size'
		when pp1.WeightUnitMeasureCode then 'Is used as a weight'
	end used_as
from Production.UnitMeasure pum 
left join Production.Product pp1 on pum.UnitMeasureCode = pp1.WeightUnitMeasureCode
left join Production.Product pp2 on pum.UnitMeasureCode = pp2.SizeUnitMeasureCode
go

/*
1. Po³¹cz tabele Production.Product z Sales.SalesOrderDetail (kolumna ProductId)  i z Sales.SalesOrderHeader (kolumna SalesOrderId). 
	Wyœwietl:
	nazwê produktu (Name)
	datê zamówienia (OrderDate)
2. W oparciu o poprzednie zapytanie wyœwietl informacjêo ostatniej dacie sprzeda¿y produktu. Wynik uporz¹dkuj wg ostatniej daty zamówienia malej¹co
3. Zmodyfikuj poprzednie zapytanie tak, aby uwzglêdnione zosta³y równie¿ produkty, które nigdy nie by³y sprzedane
4. SpradŸ na jakich zmianach pracuj¹ pracownicy firmy
	Wyœwietl
	z tabeli Person.Person: LastName i FirstName
	z tabeli HumanResources.Shift: Name
	do z³¹czenia przyda siê jeszcze tabela HumanResources.EmployeeDepartmentHistory. Odgadnij nazwy kolumn ³¹cz¹ce te tabele ze sob¹
5. SprawdŸ w ramach jakich promocji s¹ sprzedawane produkty
	Wyœwietl
	z tabeli Production.Product: Name
	z tabeli Sales.SpecialOffer: Description
	do z³aczenia przyda siê tabela Sales.SpecialOfferProduct. Odgadnij nazwy kolumn ³¹cz¹ce te tabele
*/
go

--1-3
select
	pp.Name
	,max(ssoh.OrderDate)
from Production.Product pp 
left join Sales.SalesOrderDetail ssod on pp.ProductID = ssod.ProductID
left join Sales.SalesOrderHeader ssoh on ssod.SalesOrderID = ssoh.SalesOrderID
group by pp.Name
order by 2 desc
go

--4
select
	pp.LastName
	,pp.FirstName
	,hrs.Name
from Person.Person pp 
join HumanResources.EmployeeDepartmentHistory hredh on pp.BusinessEntityID = hredh.BusinessEntityID
join HumanResources.Shift hrs on hredh.ShiftID = hrs.ShiftID
order by 1,2,3
go

--5
select
	pp.Name
	,sso.Description
from Production.Product pp
join Sales.SpecialOfferProduct ssop on pp.ProductID = ssop.ProductID
join sales.SpecialOffer sso on ssop.SpecialOfferID = sso.SpecialOfferID
go

/*
1. Kierownik zastanawia siê, jak przydzieliæ pracowników do ró¿nych zmian. Postanawia rozpocz¹æ od wypisania wszystkich mo¿liwych kombinacji z ka¿dym pracownikiem na ka¿dej zmianie. 
Napisz polecenie, które wyœwietli imiê i nazwisko pracownika (FirstName i LastName z tabeli Person.Person) i nazwê zmiany (name z tabeli HumanResources.Shift)
2. Wyœwietl unikalne nazwy kolorów z tabeli Production.Product
3. Wyœwietl unikalne nazwy klas z tabeli Production.Product
4. Dyrektor firmy zastanawia siê jakie klasy produktów i kolorów nale¿y produkowaæ. Na pocz¹tek chce otrzymaæ kombinacjê wszystkich aktualnych klas i kolorów. 
W oparciu o poprzednie zapytania utwórz nowe, które po³aczy ka¿dy kolor z ka¿d¹ klas¹. 
5. Budujemy tabelê kompetencji pracowników. Ka¿dy pracownik ma mieæ swojego zastêpcê (w parach). Zaczynamy od stworzenia listy na podstawie Sales.SalesPerson, 
która poka¿e imiê i nazwisko pracownika i imiê i nazwisko jego potencjalnego zastêpcy. Wyœwietlaj¹c wyniki do³¹cz do tabeli Sales.SalesPerson tabelê Person.Person, 
sk¹d mo¿na pobraæ FirstName i LastName. Musisz to zrobiæ 2 razy - raz aby uzyskaæ imiê i nazwisko pracownika i raz aby uzyskaæ imiê i nazwisko zastêpcy,
6. Zmieñ zapytanie z poprzedniego zadania tak, aby wyœwietlane pary by³y unikalne. JeœliX zastêpuje Y, to nie pokazuj rekordu Y zastêpuje X
*/
go

--1
select 
	pp.FirstName
	,pp.LastName
	,hrs.Name
from Person.Person pp
cross join HumanResources.Shift hrs
order by 1,2,3

--2-4
select distinct
	pp.Color
	, pp2.Class
from Production.Product pp
cross join Production.Product pp2
where pp.Color is not null 
and pp2.Class is not null

--5
select
	pp.FirstName employee
	,pp.LastName employee
	,pp2.FirstName deputy
	,pp2.LastName deputy 
from Sales.SalesPerson ssp
join Person.Person pp on ssp.BusinessEntityID = pp.BusinessEntityID
cross join Sales.SalesPerson ssp2
join Person.Person pp2 on ssp2.BusinessEntityID = pp2.BusinessEntityID
where ssp.BusinessEntityID > ssp2.BusinessEntityID
order by 1,2,3,4
