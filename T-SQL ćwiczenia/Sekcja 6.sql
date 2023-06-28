/*
1. Wy�wietl:
	z tabeli Person.Person: FirstName i LastName
	z tabeli Sales.SalesPerson: Bonus
	kolumn� ��cz�c� jest BusinessEntityId
2. Wy�wietl:
	z tabeli Sales.SalesOrderHeader: SalesOrderId, OrderDate i SalesOrderNumber
	z tabeli SalesOrderDetail: ProductId, OrderQty, UnitPrice
	kolumn� ��cz�c� jest SalesOrderId
3. Wy�wietl:
	z tabeli Production.Product: Name
	z tabeli Sales.SalesOrderDetails: warto�� zam�wienia z rabatem (UnitPrice - UnitPriceDiscount)*OrderQty
	kolumna ��cz�ca to ProductId
4. Bazuj�c na poprzednim zapytaniu wyznacz jaka jest ca�kowita warto�� sprzeda�y okre�lonych produkt�w, tzn. w wyniku masz zobaczy�:
	nazw� produktu
	ca�kowit� warto�� sprzeda�y tego produktu
	wynik posortuj wg wysoko�ci sprzeda�y malej�co
5. Wy�wietl
	z tabeli Production.Category: Name
	z tabeli Production.SubCategory: Name
	zaaliasuj kolumny, aby by�o wiadomo, co w nich si� znajduje
6. Na podstawie poprzedniego zapytania przygotuj nast�pne, kt�re poka�e ile podkategorii ma ka�da kategoria. Wy�wietl:
	nazw� kategorii
	ilo�� podkategorii
	posortuj wg nazwy kategorii
7. Wy�wietl:
	z tabeli Production.Product: name
	oraz ilo�� recencji produku (tabela Production.ProductReview)
8. Ustal, kt�rzy pracownicy pracowali na wi�kszej ilo�ci zmian. W tym celu po��cz tabele:
	HumanResources.EmployeeDepartmentHistory z
	Person.Person
	wy�wietl:
	imi� i nazwisko (FirstName i LastName)
	oraz ilo�� dopasowanych rekord�w
	Wybierz tylko te wiersze, w kt�rych wyznaczona ilo�� COUNT(*) jest wi�ksza ni� 1
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
1. Wy�wietl:
	z tabeli Person.Person: LastName i FirstName
	z tabeli Person.PersonPhone: PhoneNumber
	wy�wietlaj r�wnie� te osoby, kt�re nie poda�y numeru telefonu (je�li takie s�)
2. Zmodyfikuj poprzednie polecenie tak, aby wy�wietlone zosta�y tylko te osoby, kt�re nie poda�y numeru telefonu (je�li takie s�)
3. Wy�wietl:
	z tabeli Production.Product: Name
	z tabeli Production.ProductDocument: DocumentNode
	uwzgl�dnij w tym r�wnie� te produkty, kt�re nie maj� "pasuj�cego rekordu"
4. Zmodyfikuj poprzednie polecenie tak, aby wy�wietlone zosta�y tylko te produkty, kt�re nie maj� 'pasuj�cego' rekordu w tabeli dokument�w
5. (*Wymagane dwukrotne do��czenie tej samej tabeli z r�nymi aliasami!)
W tym zadaniu szukamy, czy s� takie jednostki miary, kt�re nie s� wykorzystywane w tabeli produkt�w, bo np. chcemy usun�� niepotrzebne jednostki miary z tabeli
wy�wietl:
z tabeli Production.UnitMeasure: Name, UnitMeasureCode
napis "Is used as a size" je�eli uda�o si� znale�� "pasuj�cy" rekord w tabeli Production.Product ��cz�c tabele UnitMeasure z tabel� Product korzystaj�c z kolumny SizeUnitMeasureCode
napis "Is used as a weight" je�eli uda�o si� znale�� "pasuj�cy" rekord w tabeli Production.Product ��cz�c tabele UnitMeasure z tabel� Product korzystaj�c z kolumny WeightUnitMeasureCode

6. Zmodyfikuj poprzednie polecenie tak, aby wy�wietlone zosta�y tylko te jednostki miary, kt�re nie s� u�ywane ani do okre�lenia rozmiaru produktu, ani do okre�lnenia wagi
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
1. Po��cz tabele Production.Product z Sales.SalesOrderDetail (kolumna ProductId)  i z Sales.SalesOrderHeader (kolumna SalesOrderId). 
	Wy�wietl:
	nazw� produktu (Name)
	dat� zam�wienia (OrderDate)
2. W oparciu o poprzednie zapytanie wy�wietl informacj�o ostatniej dacie sprzeda�y produktu. Wynik uporz�dkuj wg ostatniej daty zam�wienia malej�co
3. Zmodyfikuj poprzednie zapytanie tak, aby uwzgl�dnione zosta�y r�wnie� produkty, kt�re nigdy nie by�y sprzedane
4. Sprad� na jakich zmianach pracuj� pracownicy firmy
	Wy�wietl
	z tabeli Person.Person: LastName i FirstName
	z tabeli HumanResources.Shift: Name
	do z��czenia przyda si� jeszcze tabela HumanResources.EmployeeDepartmentHistory. Odgadnij nazwy kolumn ��cz�ce te tabele ze sob�
5. Sprawd� w ramach jakich promocji s� sprzedawane produkty
	Wy�wietl
	z tabeli Production.Product: Name
	z tabeli Sales.SpecialOffer: Description
	do z�aczenia przyda si� tabela Sales.SpecialOfferProduct. Odgadnij nazwy kolumn ��cz�ce te tabele
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
1. Kierownik zastanawia si�, jak przydzieli� pracownik�w do r�nych zmian. Postanawia rozpocz�� od wypisania wszystkich mo�liwych kombinacji z ka�dym pracownikiem na ka�dej zmianie. 
Napisz polecenie, kt�re wy�wietli imi� i nazwisko pracownika (FirstName i LastName z tabeli Person.Person) i nazw� zmiany (name z tabeli HumanResources.Shift)
2. Wy�wietl unikalne nazwy kolor�w z tabeli Production.Product
3. Wy�wietl unikalne nazwy klas z tabeli Production.Product
4. Dyrektor firmy zastanawia si� jakie klasy produkt�w i kolor�w nale�y produkowa�. Na pocz�tek chce otrzyma� kombinacj� wszystkich aktualnych klas i kolor�w. 
W oparciu o poprzednie zapytania utw�rz nowe, kt�re po�aczy ka�dy kolor z ka�d� klas�. 
5. Budujemy tabel� kompetencji pracownik�w. Ka�dy pracownik ma mie� swojego zast�pc� (w parach). Zaczynamy od stworzenia listy na podstawie Sales.SalesPerson, 
kt�ra poka�e imi� i nazwisko pracownika i imi� i nazwisko jego potencjalnego zast�pcy. Wy�wietlaj�c wyniki do��cz do tabeli Sales.SalesPerson tabel� Person.Person, 
sk�d mo�na pobra� FirstName i LastName. Musisz to zrobi� 2 razy - raz aby uzyska� imi� i nazwisko pracownika i raz aby uzyska� imi� i nazwisko zast�pcy,
6. Zmie� zapytanie z poprzedniego zadania tak, aby wy�wietlane pary by�y unikalne. Je�liX zast�puje Y, to nie pokazuj rekordu Y zast�puje X
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
