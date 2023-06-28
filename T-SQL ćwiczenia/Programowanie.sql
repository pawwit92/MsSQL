USE AdventureWorks
GO

--Deklarowanie zmiennej i dzia³ania na zmiennych
DECLARE @a INT = 332, @color varchar(50)

SELECT 
	@color = pp.Color
FROM Production.Product pp 
WHERE pp.ProductID = @a

SELECT
	pp1.ProductID
	,pp1.Name
	,pp1.Color
FROM Production.Product pp1
WHERE pp1.Color = @color

PRINT @color
GO

-- Instrukcja warunkowa IF

DECLARE @Date DATE = '2023-06-11'

IF DATEPART(wk, @Date) = 6 OR DATEPART(wk, @Date) = 7
	BEGIN
		PRINT 'It is a weekend :)'
	END
ELSE
	BEGIN
		PRINT 'It is a working day :('
	END



CREATE TABLE TestWhile (id INT)
DECLARE @a INT = 1

WHILE @a < 1000
	BEGIN
		INSERT TestWhile VALUES (@a)
		SET @a +=1
END

SELECT
*
FROM TestWhile
GO

SET NOCOUNT OFF
DELETE TOP(13) FROM TestWhile
WHILE @@ROWCOUNT>0
BEGIN 
	DELETE TOP(13) FROM TestWhile
END

DECLARE @StartTime DATETIME = GETDATE()

DELETE TOP(13) FROM TestWhile
WHILE @@ROWCOUNT>0
BEGIN 
	WAITFOR DELAY '00:00:01'
	IF DATEADD(s, 10, @StartTime) < GETDATE()
	BEGIN
		PRINT 'Breaking loop - time exceeded...'
		BREAK
	END
	DELETE TOP(13) FROM TestWhile
END
GO


DECLARE @a INT = 1

WHILE @a < 1000
BEGIN 
	INSERT TestWhile VALUES (@a)
	SET @a +=1
END

WHILE @@ROWCOUNT>0
BEGIN 
	DELETE TOP(9) FROM TestWhile
END

SELECT * FROM TestWhile




IF OBJECT_ID('tempdb..TestWhile') IS NOT NULL
BEGIN 
	PRINT 'DROPPING TestWhile TABLE'
	DROP TABLE TestWhile
END

CREATE TABLE TestWhile (id INT)

SELECT * FROM TestWhile

DECLARE @a INT = 1

WHILE @a < 1000
BEGIN 
	INSERT TestWhile VALUES (@a)
	SET @a +=1
END

IF OBJECT_ID('tempdb..#TestWhile1') IS NOT NULL
BEGIN 
	PRINT 'DROPPING #TestWhile1 TABLE'
	DROP TABLE #TestWhile1
END

CREATE TABLE #TestWhile1 (id INT)

DECLARE @b int = (SELECT TOP(1) id FROM TestWhile WHERE len(id) = 1 ORDER BY 1 DESC)
WHILE @b < 1000000
	BEGIN 
		SET @b = @b * 2
		INSERT #TestWhile1 VALUES (@b)
	END

SELECT * FROM #TestWhile1

WHILE @@ROWCOUNT>0
	BEGIN 
		DELETE TOP(100) FROM #TestWhile1
	END

SELECT * FROM #TestWhile1