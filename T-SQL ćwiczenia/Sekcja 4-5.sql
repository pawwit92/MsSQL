use AdventureWorks
go 

--Funkcje znakowe
---------------------------------------------------------------------------------------------------------------------------------
/* 
W tych zadaniach w ka¿dym punkcie nale¿y skonstruowaæ odpowiednie polecenie SELECT. 
Dla wygody wyœwietlaj z tabeli oryginaln¹ wartoœæ kolumny i wartoœæ przekszta³con¹ zgodnie z opisem. 
Pozwoli to na weryfikacjê, czy przekszta³cenia zosta³y napisane prawid³owo.

1. Tabela Sales.CreditCard - z kolumny CardNumber wytnij tylko 3 pierwsze literki
2. Tabela Person.Address - z kolumny AddressLine1 wytnij napis od pocz¹tku do pierwszej spacji
3. Tabela Sales.SalesOrderHeader - wyœwietl datê zamówienia (OrderDate) w postaci Miesi¹c/Rok (z pominiêciem dnia)
4. Tabela Sales.SalesOrderDetail - sformatuj wyra¿enie OrderQty*UnitPrice tak, aby wyœwietlany by³ tylko jeden znak po przecinku
5. Tabela Production.Product - zamieñ w kolumnie ProductNumber znak '-'  na napis pusty
6. Tabela Sales.SalesOrderHeader - zmieñ formatowanie kolumny TotalDue tak, aby:
	-wynikowy napis zajmowa³ w sumie 17 znaków
	-koñczy³ siê dwoma gwiazdkami **
	-w œrodku zawiera³ wartoœæ TotalDue z tylko 2 miejscami po przecinku
	-z przodu by³ uzupe³niony gwiazdkami (gwiazdek ma byæ tyle, ¿eby stworzony napis mia³ d³ugoœæ 17 znaków)
*/
go

-- 1
select
	scc.CardNumber
	, left(scc.CardNumber,3)
from Sales.CreditCard scc
go

--2
select
	pa.AddressLine1
	, left(pa.AddressLine1, charindex(' ', pa.AddressLine1))
from Person.Address pa
go

--3 
select
	format( ssoh.OrderDate, 'MM-yyyy')
from Sales.SalesOrderHeader ssoh
go

--4
select
	ssod.OrderQty
	,ssod.UnitPrice
	,format(ssod.OrderQty*ssod.UnitPrice, '0.0')
from Sales.SalesOrderDetail ssod
go

--5
select
	pp.ProductNumber
	,replace(pp.ProductNumber, '-', '')
from Production.Product pp
go

--6
select
	len(replicate('*', 17 - len(concat(format(ssoh.TotalDue, '0.00'),'**'))) + concat(format(ssoh.TotalDue, '0.00'),'**'))
from Sales.SalesOrderHeader ssoh
go

--Funkcje daty i czasu
---------------------------------------------------------------------------------------------------------------------------------

/*
1. Wyœwietl datê dzisiejsz¹
2. Z tabeli Sales.SalesOrderHeader wyœwietl:
	-SalesOrderId
	-orderDate
	-rok z daty OrderDate
	-miesi¹c z daty OrderDate
	-dzieñ z daty OrderDate
	-numer dnia tygodnia
	-numer tygodnia w roku
3. Poprzednie polecenie zmieñ tak, aby miesi¹c i dzieñ tygodnia by³y wyœwietlane jako tekst a nie jako liczba
4.  (* - wymaga deklarowania zmiennej) - wyœwietl w jaki dzieñ tygodnia siê urodzi³eœ/³aœ
5. Pracownicy, którzy w danym miesi¹cu maj¹ urodziny, w formie nagrody nie pracuj¹ na nocn¹ zmianê ;) . Trzeba przygotowaæ raport, w którym bêd¹ podane daty, kiedy pracownik nie mo¿e pracowaæ na nocce. Wyœwietl z tabeli HumanResources.Employee:
	-LoginID
	-BirthDate,
	-datê pocz¹tku miesi¹ca w którym pracownik ma urodziny
	-datê koñca miesi¹ca, w ktorym pracownik ma urodziny
6. Zobacz ile czasu trwa realizowanie zamówieñ. Z tabeli Sales.SalesOrderHeader wyœwietl:
	-SalesOrderID
	-OrderDate
	-DueDate
	-ró¿nice w dniach miêdzy OrderDate a DueDate
7. (* - wymaga deklarowania zmiennej) Wylicz swój wiek w latach i w dniach
*/
go

--1
select
	GetDate()
	, SYSDATETIME()
go

--2
select
	ssoh.SalesOrderID
	, ssoh.OrderDate
	, year(ssoh.OrderDate)
	, month(ssoh.OrderDate)
	, day(ssoh.OrderDate)
	, datepart(dw, ssoh.OrderDate) [weekday]
	, datepart(wk, ssoh.OrderDate) [week]
	, datename(dw, ssoh.OrderDate) [day]    --3
	, datename(mm, ssoh.OrderDate) [month]  --3
from Sales.SalesOrderHeader ssoh
go

--4
declare @birthday date = '1992-10-09'
select
	DATENAME(dw, @birthday)
go

--5
select
	hre.LoginID
	, format(hre.BirthDate, 'MM-dd') [MM-DD]
	, concat(format(hre.BirthDate, 'MM'),'-01')
	, format(eomonth(hre.BirthDate), 'MM-dd') [MM-DD]
from HumanResources.Employee hre
go

--6
select
	ssoh.SalesOrderID
	, format(ssoh.OrderDate, 'yyyy-MM-dd')
	, format(ssoh.DueDate, 'yyyy-MM-dd')
	, datediff(day, ssoh.OrderDate, ssoh.DueDate)
from Sales.SalesOrderHeader ssoh
go

--7

declare @birthday date = '09.10.1992'
declare @today date = GetDate()

select
	datediff(year, @birthday, @today) years	
	,datediff(day, @birthday, @today) days
go

/*
1. Zamówienia nale¿y podzieliæ ze wzglêdu na wysokoœæ podatku, 
jaki jest do zap³acenia. Wyœwietl z tabeli Sales.SalesOrderHeader kolumny: SalesOrderId, TaxAmt 
oraz:
-liczbê 0 je¿eli podatek jest < 1000
-liczbe 1000 je¿eli podatek jest >= 1000 and < 2000
-itd.
Wskazówka: Skorzystaj z funkcji FLOOR wyliczanej dla TaxAmt dzielonego przez 1000. Otrzymany wynik mnó¿ przez 1000.

2. Napisz polecenie losuj¹ce liczbê z zakresu 1-49. Skorzystaj z funkcji RAND i CEILING. Wylosowane liczby mo¿esz wykorzystaæ w totolotku :)

3. Zaokr¹glij kwoty podatku z tabeli Sales.SalesOrderHeader (kolumna TaxAmt) do pe³nych z³otych/dolarów :)

4. Zaokr¹glij kwoty podatku z tabeli Sales.SalesOrderHeader (kolumna TaxAmt) do tysiêcy z³otych/dolarów :)
*/
go

--1
select 
	ssoh.SalesOrderID
	,floor(ssoh.TaxAmt/1000)*1000
	,round(ssoh.TaxAmt,-3,1)
from Sales.SalesOrderHeader ssoh
go

--2 
select
	ceiling(rand()*49)
go

--3
select
	format(round(ssoh.TaxAmt,0),'0')
from Sales.SalesOrderHeader ssoh
go

--4
select
	format(round(ssoh.TaxAmt,-3),'0')
from Sales.SalesOrderHeader ssoh
go

/*
1. Tabela HumanResources.Shift zawiera wykaz zmian w pracy i godzinê rozpoczêcia i zakoñczenia zmiany. 
Wyœwietl test powsta³y z po³¹czenia sta³ych napisów i danych w tabeli w postaci:
Shift .......... starts at ..........
np. Shift Day starts at 07:00
2. Korzystaj¹c z funkcji Convert napisz zapytanie do tabeli HumanResources.Employee, 
które wyœwietli LoginId oraz datê HireDate w postaci DD.MM.YYYY (najpierw dzieñ, 
potem miesi¹c i na koñcu rok zapisany 4 cyframi, porozdzielany kropkami)
3. (* wymagana deklaracja zmiennej). Zapisz do zmiennej tekstowej typu VARCHAR(30) swoj¹ datê urodzenia 
w formacie d³ugim np '18 sierpnia 1979'. Korzystaj¹c z funkcji PARSE skonwertuj j¹ na datê. 
Zapis daty jaki zostanie "zrozumiany" zale¿y od wersji jêzykowej serwera i jego ustawieñ regionalnych i jêzykowych.
4. W dacie pope³nij literówkê (np. wymyœl œmieszn¹ nazwê miesi¹ca). Jak teraz koñczy siê konwersja?
Zmieñ polecenie z poprzedniego zadania tak, aby korzysta³o z funkcji TRY_PARSE. Jak teraz siê koñczy konwersja?
*/

--1
select
	concat('Shift', ' ', hrs.Name, ' ', 'starts at', ' ', cast(left(hrs.StartTime, 5) as varchar(10))) shifts
from HumanResources.Shift hrs
go

--2
select
	hre.LoginID
	, convert(varchar(20), hre.HireDate,104)
from HumanResources.Employee hre

/*
1. W firmie AdventureWorks wymyœlono, ¿e pracownikom bêd¹ nadawane "Rangi". 
Napisz zapytanie, które wyœwietli rekordy z tabeli HumanResources.
Employee i je¿eli ró¿nica miêdzy dat¹ zatrudnienia a dat¹ dzisiejsz¹ jest >10 lat, 
to wyœwietli napis 'Old stager'. W przeciwnym razie ma wyœwietlaæ 'Adept'
2. Zmieñ zapytanie z poprzedniego æwiczenia tak, ¿e:
	-pracownicy ze sta¿em >10 lat maj¹ range 'Old stager'
	-pracownicy ze sta¿em >8 lat maj¹ rangê 'Veteran'
	-pozostali maj¹ rangê 'Adept'
3. Nale¿y przygotowaæ raport zamówieñ z tabeli Sales.SalesOrderHeader. Zestawienie ma zawieraæ:
	SalesOrderId,
	OrderDate,
	Nazwê dnia tygodnia po... hiszpañsku
	Skorzystaj z funkcji DATEPART i CHOOSE i napisz odpowiednie zapytanie
	Oto lista nazw dni tygodnia po hiszpañsku:

	poniedzia³ek - lunes
	wtorek - martes
	œroda - miércoles
	czwartek - jueves 
	pi¹tek - viernes
	sobota - sábado
	niedziela - domingo
*/

--1
select
	iif(datediff(year, hre.HireDate, GetDate())>10, 'Old stager', 'Adept')
from HumanResources.Employee hre

--2
select
	case
		when datediff(year, hre.HireDate, GetDate())>10 then 'Old stager'
		when datediff(year, hre.HireDate, GetDate())>8 then 'Veteran'
		else 'Adept'
	end
from HumanResources.Employee hre
go

--3
select
	ssoh.SalesOrderId
	,format(ssoh.OrderDate, 'yyyy-MM-dd')
	,choose(datepart(dw, ssoh.OrderDate), 'lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo') day_name
	, case datepart(dw, ssoh.OrderDate)
		when 1 then 'lunes'
		when 2 then 'martes'
		when 3 then 'miércoles'
		when 4 then 'jueves'
		when 5 then 'viernes'
		when 6 then 'sábado'
		when 7 then 'domingo'
	end
from Sales.SalesOrderHeader ssoh
go

/*
1. W tabeli Person.PhoneNumberType znajduj¹ siê opisy rodzajów telefonów. Na potrzeby raportu nale¿y:
-wyœwietliæ  'mobile phone' gdy nazwa to 'cell'
-wyœwietliæ 'Stationary' gdy nazwa to 'Home' lub 'Work'
-w pozosta³ych przypadkach wyœwietliæ 'Other'
2. W poprzednim zadaniu wykorzysta³eœ jedn¹ z dopuszczalnych sk³adni CASE. Napisz teraz zapytanie, które wykorzysta drug¹ dopuszczaln¹ sk³adniê
3. W tabeli Production.Product, niektóre produkty maj¹ okreœlony rozmiar. Napisz zapytanie, które wyœwietli:

ProductID
Name
Size
oraz now¹ kolumnê, w której pojawi siê:
gdy size to 'S' to 'SMALL'
gdy size to 'M' to 'MEDIUM'
gdy size to  'L' to 'LARGE'
gdy size to  'XL' to 'EXTRA LARGE'
*/

--1 
select
	case
		when ppnt.Name like '%cell%' then 'mobile phone'
		when ppnt.Name like '%home%' or ppnt.Name like '%work%'  then 'stationary'
		else 'Other'
	end
from Person.PhoneNumberType ppnt
go

--2
select
	case ppnt.Name
		when 'cell' then 'mobile phone'
		when 'home' then 'stationary'
		when 'work' then 'stationary'
		else 'Other'
	end
from Person.PhoneNumberType ppnt
go

--3
select
	pp.ProductID
	, pp.Name
	, pp.Size
	, case
		when pp.Size = 'S' then 'SMALL'
		when pp.Size = 'M' then 'MEDIUM'
		when pp.Size = 'L' then 'LARGE'
		when pp.Size = 'XL' then 'EXTRA LARGE'
		else 'UNKNOWN'
	end
from Production.Product pp
go

/*
1. Pracujemy na tabeli Person.Person
	-oblicz iloœæ rekordów
	-oblicz ile osób poda³o swoje drugie imiê (kolumna MiddleName)
	-oblicz ile osób poda³o swoje pierwsze imiê (kolumna FirstName)
	-oblicz ile osób wyrazi³o zgodê na otrzymywanie maili (kolumna EmailPromotion ma byæ równa 1)
2. Pracujemy na tabeli Sales.SalesOrderDetail
	-wyznacz ca³kowit¹ wielkoœæ sprzeda¿y bez uwzglêdnienia rabatów - suma UnitPrice * OrderQty
	-wyznacz ca³kowit¹ wielkoœæ sprzeda¿y z uwzglêdnieniiem rabatów - suma (UnitPrice-UnitPriceDiscount) * OrderQty
3. Pracujemy na tabeli Production.Product.
	-dla rekordów z podkategorii 14
	-wylicz minimaln¹ cenê, maksymaln¹ cenê, œredni¹ cenê i odchylenie standardowe dla ceny (u¿yj funkcji STDEV)
4. Pracujemy na tabeli Sales.SalesOrderHeader.
	-wyznacz iloœæ zamówieñ zrealizowanych przez poszczególnych pracowników (kolumna SalesPersonId)
5. Wynik poprzedniego polecenia posortuj wg wyliczonej iloœci malej¹co
6. Wynik poprzedniego polecenia ogranicz do zamówieñ z 2012 roku
7. Wynik poprzedniego polecenia ogranicz tak, aby prezentowani byli te rekordy, gdzie wyznaczona suma jest wiêksza od 100000
8. Pracujemy na tabeli Sales.SalesOrderHeader. 
	- Policz ile zamówieñ by³o dostarczanych z wykorzystaniem ró¿nych metod dostawy (kolumna ShipMethodId)
9. Pracujemy na tabeli Production.Product
	Napisz zapytanie, które wyœwietla:
	-ProductID
	-Name
	-StandardCost
	-ListPrice
	-ró¿nicê miêdzy ListPrice a StandardCost. Zaaliasuj j¹ "Profit"
	-w wyniku opuœæ te produkty które maj¹ ListPrice lub StandardCost <=0
Bazuj¹c na poprzednim zapytaniu, spróbujemy wyznaczyæ jakie kategorie produktów s¹ najbardziej zyskowne.
Dla ka¿dej podkategorii wyznacz œredni, minimalny i maksymalny profit. Uporz¹dkuj wynik w kolejnoœci œredniego profitu malej¹co
*/
go

--1
select
	count(*)
	, count(pp.MiddleName)
	, sum(pp.EmailPromotion)
	, sum(iif(pp.EmailPromotion = 1, 1, 0))
from Person.Person pp
go


--2 
select
	sum(ssod.UnitPrice * ssod.OrderQty) excl_discount
	, sum((ssod.UnitPrice - (ssod.UnitPrice * ssod.UnitPriceDiscount)) * ssod.OrderQty) incl_discount
from Sales.SalesOrderDetail ssod
go

--3
select
	min(pp.ListPrice)
	, max(pp.ListPrice)
	, avg(pp.ListPrice)
	, stdev(pp.ListPrice)
from Production.Product pp
where pp.ProductSubcategoryID = 14
go

--4 - 7
select
	ssoh.SalesPersonID
	, count(*)
	,sum(ssoh.TotalDue)
from Sales.SalesOrderHeader ssoh
where datepart(year,ssoh.OrderDate) = 2012
group by ssoh.SalesPersonID, datepart(year,ssoh.OrderDate)
having sum(ssoh.TotalDue) > 100000
order by 2 desc
go

--8
select
	ssoh.ShipMethodID
	, count(*)
from sales.SalesOrderHeader ssoh
group by ssoh.ShipMethodID
go

--9
select
	pp.ProductID
	,pp.Name
	,pp.StandardCost
	,pp.ListPrice
	,pp.ListPrice - pp.StandardCost
from Production.Product pp
where pp.ListPrice > 0 or pp.StandardCost > 0
go

--10
select
	pp.ProductSubcategoryID
	,min(pp.ListPrice - pp.StandardCost)
	,avg(pp.ListPrice - pp.StandardCost)
	,max(pp.ListPrice - pp.StandardCost)
from Production.Product pp
where pp.ListPrice > 0 or pp.StandardCost > 0
group by pp.ProductSubcategoryID
order by 3 desc
go

/*
1. Wyœwietl rekordy z tabeli Person.Person, gdzie nie podano drugiego imienia (MiddleName)
2. Wyœwietl rekordy z tabeli Person.Person, gdzie drugie imiê jest podane
3. Wyœwietl z tabeli Person.Person:
	-FirstName
	-MiddleName
	-LastName
	-napis z po³¹czenia ze sob¹ FirstName ' ' MiddleName ' ' i  LastName
4. Jeœli jeszcze tego nie zrobi³eœ dodaj wyra¿enie, które obs³u¿y sytuacjê, gdy MiddleName jest NULL. W takim przypadku chcemy prezentowaæ tylko FirstName ' ' i LastName
5. Jeœli jeszcze tego nie zrobi³eœ - wyeliminuj podwój¹ spacjê, jaka mo¿e siê pojawiæ miêdzy FirstName i LastNamr gdy MiddleName jest NULL.
6. Firma podpisuje umowê z firm¹ kuriersk¹. Cena us³ugi ma zale¿eñ od rozmiaru w drugiej kolejnoœci ciê¿aru, a gdy te nie s¹ znane od wartoœci wysy³anego przedmiotu.
	Napisz zapytanie, które wyœwietli z tabeli Production.Product:
	-productId
	-Name
	-size, weight i listprice
	-i kolumnê wyliczan¹, która poka¿e size (jeœli jest NOT NULL), lub weight (jeœli jest NOT NULL) lub listprice w przeciwnym razie
7. Firma kurierska oczekuje aby informacja w ostatniej kolumnie by³a dodatkowo oznaczona:
	-jeœli zawiera informacje o rozmiarze, to ma byæ poprzedzona napisem S:
	-jeœli zawiera informacje o ciê¿arze, to ma byæ poprzedzone napisem W:
	-w przeciwnym razie ma siê pojawiaæ L:
*/
go
--1
select
	*
from Person.Person pp
where pp.MiddleName is null
go

--2
select
	*
from Person.Person pp
where pp.MiddleName is not null
go

--3 
select
	pp.FirstName
	,pp.MiddleName
	,pp.LastName
	,concat(rtrim(concat(pp.FirstName, ' ', pp.MiddleName)), ' ', pp.LastName) --4 5
	,pp.FirstName + ' ' + isnull(pp.MiddleName + ' ','') + pp.LastName --4 5
from Person.Person pp
where pp.MiddleName is null
go

--6
select
	pp.ProductID
	,pp.Name
	,pp.Size
	,pp.Weight
	,pp.ListPrice
	, case
		when pp.Size is not null then pp.size
		when pp.size is null and pp.Weight is not null then cast(pp.Weight as varchar(15))
		else cast(pp.ListPrice as varchar(15))
	end
	, case
		when pp.Size is not null then 'S'
		when pp.size is null and pp.Weight is not null then 'W'
		else 'L'
	end
from Production.Product pp
go

/*
1. Z tabeli Person.Address wyœwietl unikalne miasta  (City)
2. Z tej samej tabeli wyœwietl unikalne kody pocztowe (PostalCode)
3. Z tej samej tabeli wyœwietl unikalne kombinacje miast i kodów pocztowych
4. Z tabeli Sales.SalesPerson wyœwietl BusinessEntityId i Bonus dla 4 pracowników z najwiêkszym bonusem
5. Je¿eli s¹ jeszcze inne rekordy o takiej wartoœci jak ostatnia zwrócona w poprzednim zadaniu, to maj¹ siê one te¿ wyœwietliæ
6. Wyœwietl 20% rekordów z najwy¿szymi Bonusami
7. Je¿eli wartoœci siê powtarzaj¹ to równie¿ nale¿y je pokazaæ
*/
go

--1
select distinct
	pa.City
from Person.Address pa

--2
select distinct
	pa.PostalCode
from Person.Address pa

--3
select distinct
	pa.City
	,pa.PostalCode
from Person.Address pa

--4,5
select top(4) with ties
	ssp.BusinessEntityID
	, ssp.Bonus
from Sales.SalesPerson ssp
order by 2 desc

--6,7
select top(20) percent with ties
	ssp.BusinessEntityID
	, ssp.Bonus
from Sales.SalesPerson ssp
order by 2 desc
go

/*
1. Napisz zapytanie do tabeli Sales.SalesOrderHeader. Wyfiltruj rekordy, które:
	-Datê zamówienia (OrderDate) maj¹ miêdzy 2012-01-01 a 2012-03-31
	-SalesPersonId ma mieæ wartoœæ (czyli nie jest null)
	-TerritoryID  ma mieæ wartoœæ (czyli nie jest null)
	W wyniku ma byæ wyœwietlony:
	-Miesi¹c z daty zamówienia
	-SalesPersonId
	-TerritoryID
	-Suma z kolumny SubTotal
2. Zmieñ zapytanie tak, aby wyœwietlane by³y tak¿e podsumowania dla:
	-Miesi¹c i SalesPersonId
	-Miesi¹c
	-Ogó³em
3. Zmieñ zapytanie tak aby widoczne by³y tak¿e sumy dla:
	-Miesi¹c i TerritoryId
	-SalesPersonId i TerritoryId
	-SalesPersonId
	-TerritoryId
4. Zmieñ zapytanie tak, aby wyœwietli³y siê tylko sumy:
	-miesi¹ca 
	-miesi¹ca, SalesPersonId, TerritoryId
*/
go

--1
select
	datepart(month, ssoh.OrderDate) mth
	, ssoh.SalesPersonID
	, ssoh.TerritoryID
	, sum(ssoh.SubTotal)
from Sales.SalesOrderHeader ssoh
where ssoh.OrderDate between '2012-01-01' and '2012-03-31'
and ssoh.SalesPersonID is not null
and ssoh.TerritoryID is not null
group by datepart(month, ssoh.OrderDate), ssoh.SalesPersonID, ssoh.TerritoryID
go

--2
select
	datepart(month, ssoh.OrderDate) mth
	, ssoh.SalesPersonID
	, ssoh.TerritoryID
	, sum(ssoh.SubTotal)
from Sales.SalesOrderHeader ssoh
where ssoh.OrderDate between '2012-01-01' and '2012-03-31'
and ssoh.SalesPersonID is not null
and ssoh.TerritoryID is not null
group by rollup (datepart(month, ssoh.OrderDate), ssoh.SalesPersonID, ssoh.TerritoryID)
go

--3
select
	datepart(month, ssoh.OrderDate) mth
	, ssoh.SalesPersonID
	, ssoh.TerritoryID
	, sum(ssoh.SubTotal)
from Sales.SalesOrderHeader ssoh
where ssoh.OrderDate between '2012-01-01' and '2012-03-31'
and ssoh.SalesPersonID is not null
and ssoh.TerritoryID is not null
group by cube (datepart(month, ssoh.OrderDate), ssoh.SalesPersonID, ssoh.TerritoryID)
go

--4
select
	datepart(month, ssoh.OrderDate) mth
	, ssoh.SalesPersonID
	, ssoh.TerritoryID
	, sum(ssoh.SubTotal)
from Sales.SalesOrderHeader ssoh
where ssoh.OrderDate between '2012-01-01' and '2012-03-31'
and ssoh.SalesPersonID is not null
and ssoh.TerritoryID is not null
group by grouping sets (datepart(month, ssoh.OrderDate), (ssoh.SalesPersonID, ssoh.TerritoryID))
go

--3
select
	datepart(month, ssoh.OrderDate) mth
	,grouping_id(datepart(month, ssoh.OrderDate)) mth_grouping_id
	,ssoh.SalesPersonID AggregateBySalesPersonID
	,grouping_id(ssoh.SalesPersonID) AggregateBySalesPersonId_id
	,ssoh.TerritoryID AggregateByTerritoryID
	,grouping_id(ssoh.TerritoryID) AggregateByTerritoryID_id
	,sum(ssoh.SubTotal)
	,grouping_id(datepart(month, ssoh.OrderDate),SalesPersonID,TerritoryID)
from Sales.SalesOrderHeader ssoh
where ssoh.OrderDate between '2012-01-01' and '2012-03-31'
group by cube (datepart(month, ssoh.OrderDate), ssoh.SalesPersonID, ssoh.TerritoryID)
go