use AdventureWorks
go 

--Funkcje znakowe
---------------------------------------------------------------------------------------------------------------------------------
/* 
W tych zadaniach w ka�dym punkcie nale�y skonstruowa� odpowiednie polecenie SELECT. 
Dla wygody wy�wietlaj z tabeli oryginaln� warto�� kolumny i warto�� przekszta�con� zgodnie z opisem. 
Pozwoli to na weryfikacj�, czy przekszta�cenia zosta�y napisane prawid�owo.

1. Tabela Sales.CreditCard - z kolumny CardNumber wytnij tylko 3 pierwsze literki
2. Tabela Person.Address - z kolumny AddressLine1 wytnij napis od pocz�tku do pierwszej spacji
3. Tabela Sales.SalesOrderHeader - wy�wietl dat� zam�wienia (OrderDate) w postaci Miesi�c/Rok (z pomini�ciem dnia)
4. Tabela Sales.SalesOrderDetail - sformatuj wyra�enie OrderQty*UnitPrice tak, aby wy�wietlany by� tylko jeden znak po przecinku
5. Tabela Production.Product - zamie� w kolumnie ProductNumber znak '-'  na napis pusty
6. Tabela Sales.SalesOrderHeader - zmie� formatowanie kolumny TotalDue tak, aby:
	-wynikowy napis zajmowa� w sumie 17 znak�w
	-ko�czy� si� dwoma gwiazdkami **
	-w �rodku zawiera� warto�� TotalDue z tylko 2 miejscami po przecinku
	-z przodu by� uzupe�niony gwiazdkami (gwiazdek ma by� tyle, �eby stworzony napis mia� d�ugo�� 17 znak�w)
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
1. Wy�wietl dat� dzisiejsz�
2. Z tabeli Sales.SalesOrderHeader wy�wietl:
	-SalesOrderId
	-orderDate
	-rok z daty OrderDate
	-miesi�c z daty OrderDate
	-dzie� z daty OrderDate
	-numer dnia tygodnia
	-numer tygodnia w roku
3. Poprzednie polecenie zmie� tak, aby miesi�c i dzie� tygodnia by�y wy�wietlane jako tekst a nie jako liczba
4.  (* - wymaga deklarowania zmiennej) - wy�wietl w jaki dzie� tygodnia si� urodzi�e�/�a�
5. Pracownicy, kt�rzy w danym miesi�cu maj� urodziny, w formie nagrody nie pracuj� na nocn� zmian� ;) . Trzeba przygotowa� raport, w kt�rym b�d� podane daty, kiedy pracownik nie mo�e pracowa� na nocce. Wy�wietl z tabeli HumanResources.Employee:
	-LoginID
	-BirthDate,
	-dat� pocz�tku miesi�ca w kt�rym pracownik ma urodziny
	-dat� ko�ca miesi�ca, w ktorym pracownik ma urodziny
6. Zobacz ile czasu trwa realizowanie zam�wie�. Z tabeli Sales.SalesOrderHeader wy�wietl:
	-SalesOrderID
	-OrderDate
	-DueDate
	-r�nice w dniach mi�dzy OrderDate a DueDate
7. (* - wymaga deklarowania zmiennej) Wylicz sw�j wiek w latach i w dniach
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
1. Zam�wienia nale�y podzieli� ze wzgl�du na wysoko�� podatku, 
jaki jest do zap�acenia. Wy�wietl z tabeli Sales.SalesOrderHeader kolumny: SalesOrderId, TaxAmt 
oraz:
-liczb� 0 je�eli podatek jest < 1000
-liczbe 1000 je�eli podatek jest >= 1000 and < 2000
-itd.
Wskaz�wka: Skorzystaj z funkcji FLOOR wyliczanej dla TaxAmt dzielonego przez 1000. Otrzymany wynik mn� przez 1000.

2. Napisz polecenie losuj�ce liczb� z zakresu 1-49. Skorzystaj z funkcji RAND i CEILING. Wylosowane liczby mo�esz wykorzysta� w totolotku :)

3. Zaokr�glij kwoty podatku z tabeli Sales.SalesOrderHeader (kolumna TaxAmt) do pe�nych z�otych/dolar�w :)

4. Zaokr�glij kwoty podatku z tabeli Sales.SalesOrderHeader (kolumna TaxAmt) do tysi�cy z�otych/dolar�w :)
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
1. Tabela HumanResources.Shift zawiera wykaz zmian w pracy i godzin� rozpocz�cia i zako�czenia zmiany. 
Wy�wietl test powsta�y z po��czenia sta�ych napis�w i danych w tabeli w postaci:
Shift .......... starts at ..........
np. Shift Day starts at 07:00
2. Korzystaj�c z funkcji Convert napisz zapytanie do tabeli HumanResources.Employee, 
kt�re wy�wietli LoginId oraz dat� HireDate w postaci DD.MM.YYYY (najpierw dzie�, 
potem miesi�c i na ko�cu rok zapisany 4 cyframi, porozdzielany kropkami)
3. (* wymagana deklaracja zmiennej). Zapisz do zmiennej tekstowej typu VARCHAR(30) swoj� dat� urodzenia 
w formacie d�ugim np '18 sierpnia 1979'. Korzystaj�c z funkcji PARSE skonwertuj j� na dat�. 
Zapis daty jaki zostanie "zrozumiany" zale�y od wersji j�zykowej serwera i jego ustawie� regionalnych i j�zykowych.
4. W dacie pope�nij liter�wk� (np. wymy�l �mieszn� nazw� miesi�ca). Jak teraz ko�czy si� konwersja?
Zmie� polecenie z poprzedniego zadania tak, aby korzysta�o z funkcji TRY_PARSE. Jak teraz si� ko�czy konwersja?
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
1. W firmie AdventureWorks wymy�lono, �e pracownikom b�d� nadawane "Rangi". 
Napisz zapytanie, kt�re wy�wietli rekordy z tabeli HumanResources.
Employee i je�eli r�nica mi�dzy dat� zatrudnienia a dat� dzisiejsz� jest >10 lat, 
to wy�wietli napis 'Old stager'. W przeciwnym razie ma wy�wietla� 'Adept'
2. Zmie� zapytanie z poprzedniego �wiczenia tak, �e:
	-pracownicy ze sta�em >10 lat maj� range 'Old stager'
	-pracownicy ze sta�em >8 lat maj� rang� 'Veteran'
	-pozostali maj� rang� 'Adept'
3. Nale�y przygotowa� raport zam�wie� z tabeli Sales.SalesOrderHeader. Zestawienie ma zawiera�:
	SalesOrderId,
	OrderDate,
	Nazw� dnia tygodnia po... hiszpa�sku
	Skorzystaj z funkcji DATEPART i CHOOSE i napisz odpowiednie zapytanie
	Oto lista nazw dni tygodnia po hiszpa�sku:

	poniedzia�ek - lunes
	wtorek - martes
	�roda - mi�rcoles
	czwartek - jueves 
	pi�tek - viernes
	sobota - s�bado
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
	,choose(datepart(dw, ssoh.OrderDate), 'lunes', 'martes', 'mi�rcoles', 'jueves', 'viernes', 's�bado', 'domingo') day_name
	, case datepart(dw, ssoh.OrderDate)
		when 1 then 'lunes'
		when 2 then 'martes'
		when 3 then 'mi�rcoles'
		when 4 then 'jueves'
		when 5 then 'viernes'
		when 6 then 's�bado'
		when 7 then 'domingo'
	end
from Sales.SalesOrderHeader ssoh
go

/*
1. W tabeli Person.PhoneNumberType znajduj� si� opisy rodzaj�w telefon�w. Na potrzeby raportu nale�y:
-wy�wietli�  'mobile phone' gdy nazwa to 'cell'
-wy�wietli� 'Stationary' gdy nazwa to 'Home' lub 'Work'
-w pozosta�ych przypadkach wy�wietli� 'Other'
2. W poprzednim zadaniu wykorzysta�e� jedn� z dopuszczalnych sk�adni CASE. Napisz teraz zapytanie, kt�re wykorzysta drug� dopuszczaln� sk�adni�
3. W tabeli Production.Product, niekt�re produkty maj� okre�lony rozmiar. Napisz zapytanie, kt�re wy�wietli:

ProductID
Name
Size
oraz now� kolumn�, w kt�rej pojawi si�:
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
	-oblicz ilo�� rekord�w
	-oblicz ile os�b poda�o swoje drugie imi� (kolumna MiddleName)
	-oblicz ile os�b poda�o swoje pierwsze imi� (kolumna FirstName)
	-oblicz ile os�b wyrazi�o zgod� na otrzymywanie maili (kolumna EmailPromotion ma by� r�wna 1)
2. Pracujemy na tabeli Sales.SalesOrderDetail
	-wyznacz ca�kowit� wielko�� sprzeda�y bez uwzgl�dnienia rabat�w - suma UnitPrice * OrderQty
	-wyznacz ca�kowit� wielko�� sprzeda�y z uwzgl�dnieniiem rabat�w - suma (UnitPrice-UnitPriceDiscount) * OrderQty
3. Pracujemy na tabeli Production.Product.
	-dla rekord�w z podkategorii 14
	-wylicz minimaln� cen�, maksymaln� cen�, �redni� cen� i odchylenie standardowe dla ceny (u�yj funkcji STDEV)
4. Pracujemy na tabeli Sales.SalesOrderHeader.
	-wyznacz ilo�� zam�wie� zrealizowanych przez poszczeg�lnych pracownik�w (kolumna SalesPersonId)
5. Wynik poprzedniego polecenia posortuj wg wyliczonej ilo�ci malej�co
6. Wynik poprzedniego polecenia ogranicz do zam�wie� z 2012 roku
7. Wynik poprzedniego polecenia ogranicz tak, aby prezentowani byli te rekordy, gdzie wyznaczona suma jest wi�ksza od 100000
8. Pracujemy na tabeli Sales.SalesOrderHeader. 
	- Policz ile zam�wie� by�o dostarczanych z wykorzystaniem r�nych metod dostawy (kolumna ShipMethodId)
9. Pracujemy na tabeli Production.Product
	Napisz zapytanie, kt�re wy�wietla:
	-ProductID
	-Name
	-StandardCost
	-ListPrice
	-r�nic� mi�dzy ListPrice a StandardCost. Zaaliasuj j� "Profit"
	-w wyniku opu�� te produkty kt�re maj� ListPrice lub StandardCost <=0
Bazuj�c na poprzednim zapytaniu, spr�bujemy wyznaczy� jakie kategorie produkt�w s� najbardziej zyskowne.
Dla ka�dej podkategorii wyznacz �redni, minimalny i maksymalny profit. Uporz�dkuj wynik w kolejno�ci �redniego profitu malej�co
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
1. Wy�wietl rekordy z tabeli Person.Person, gdzie nie podano drugiego imienia (MiddleName)
2. Wy�wietl rekordy z tabeli Person.Person, gdzie drugie imi� jest podane
3. Wy�wietl z tabeli Person.Person:
	-FirstName
	-MiddleName
	-LastName
	-napis z po��czenia ze sob� FirstName ' ' MiddleName ' ' i  LastName
4. Je�li jeszcze tego nie zrobi�e� dodaj wyra�enie, kt�re obs�u�y sytuacj�, gdy MiddleName jest NULL. W takim przypadku chcemy prezentowa� tylko FirstName ' ' i LastName
5. Je�li jeszcze tego nie zrobi�e� - wyeliminuj podw�j� spacj�, jaka mo�e si� pojawi� mi�dzy FirstName i LastNamr gdy MiddleName jest NULL.
6. Firma podpisuje umow� z firm� kuriersk�. Cena us�ugi ma zale�e� od rozmiaru w drugiej kolejno�ci ci�aru, a gdy te nie s� znane od warto�ci wysy�anego przedmiotu.
	Napisz zapytanie, kt�re wy�wietli z tabeli Production.Product:
	-productId
	-Name
	-size, weight i listprice
	-i kolumn� wyliczan�, kt�ra poka�e size (je�li jest NOT NULL), lub weight (je�li jest NOT NULL) lub listprice w przeciwnym razie
7. Firma kurierska oczekuje aby informacja w ostatniej kolumnie by�a dodatkowo oznaczona:
	-je�li zawiera informacje o rozmiarze, to ma by� poprzedzona napisem S:
	-je�li zawiera informacje o ci�arze, to ma by� poprzedzone napisem W:
	-w przeciwnym razie ma si� pojawia� L:
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
1. Z tabeli Person.Address wy�wietl unikalne miasta  (City)
2. Z tej samej tabeli wy�wietl unikalne kody pocztowe (PostalCode)
3. Z tej samej tabeli wy�wietl unikalne kombinacje miast i kod�w pocztowych
4. Z tabeli Sales.SalesPerson wy�wietl BusinessEntityId i Bonus dla 4 pracownik�w z najwi�kszym bonusem
5. Je�eli s� jeszcze inne rekordy o takiej warto�ci jak ostatnia zwr�cona w poprzednim zadaniu, to maj� si� one te� wy�wietli�
6. Wy�wietl 20% rekord�w z najwy�szymi Bonusami
7. Je�eli warto�ci si� powtarzaj� to r�wnie� nale�y je pokaza�
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
1. Napisz zapytanie do tabeli Sales.SalesOrderHeader. Wyfiltruj rekordy, kt�re:
	-Dat� zam�wienia (OrderDate) maj� mi�dzy 2012-01-01 a 2012-03-31
	-SalesPersonId ma mie� warto�� (czyli nie jest null)
	-TerritoryID  ma mie� warto�� (czyli nie jest null)
	W wyniku ma by� wy�wietlony:
	-Miesi�c z daty zam�wienia
	-SalesPersonId
	-TerritoryID
	-Suma z kolumny SubTotal
2. Zmie� zapytanie tak, aby wy�wietlane by�y tak�e podsumowania dla:
	-Miesi�c i SalesPersonId
	-Miesi�c
	-Og�em
3. Zmie� zapytanie tak aby widoczne by�y tak�e sumy dla:
	-Miesi�c i TerritoryId
	-SalesPersonId i TerritoryId
	-SalesPersonId
	-TerritoryId
4. Zmie� zapytanie tak, aby wy�wietli�y si� tylko sumy:
	-miesi�ca 
	-miesi�ca, SalesPersonId, TerritoryId
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