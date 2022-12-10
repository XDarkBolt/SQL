/****** Script for OEE  ******/
USE u9737940_BUKRA
GO
 
DECLARE @Counter INT , @MaxId INT , @Time INT , @TotalTime INT , @Availability INT , @MachineId INT,
        @MachineStartTime DATETIME , @MachineStopTime DATETIME , @Today DATETIME , @LastStopTime DATETIME


SET @Today = '2021-12-03';
SET @MachineId = 1453;

SET @Counter = 1;
SET @TotalTime = 0;
SET @Availability = 0;
SET @MaxId = 0;

DECLARE @ListofTime TABLE(ID INT IDENTITY(1,1) NOT NULL , Machine_Start_Time DATETIME , Machine_Stop_Time DATETIME);

INSERT INTO @ListofTime (Machine_Start_Time , Machine_Stop_Time) SELECT Machine_Start_Time , Machine_Stop_Time FROM SampleMachineData
WHERE Machine_Start_Time IS NOT NULL AND ((Machine_Start_Time >= @Today AND Machine_Start_Time <= DATEADD(DAY,1,@Today)) OR (Machine_Stop_Time >= @Today AND Machine_Stop_Time <= DATEADD(DAY,1,@Today)))

SELECT * FROM @ListofTime
SELECT @MaxId = COUNT(ID) FROM @ListofTime

WHILE(@Counter IS NOT NULL AND @MaxId IS NOT NULL AND @Counter <= @MaxId)
BEGIN
   SELECT	@MachineStartTime = Machine_Start_Time,
			@MachineStopTime = Machine_Stop_Time
   FROM @ListofTime WHERE ID = @Counter

	IF @MachineStopTime < DATEADD(DAY,1,@Today)
		IF @MachineStartTime < @Today
			SET @Time = DATEDIFF(minute, @Today, @MachineStopTime)
		ELSE
			SET @Time = DATEDIFF(minute, @MachineStartTime, @MachineStopTime)
	ELSE
		SET @Time = DATEDIFF(minute, @MachineStartTime, DATEADD(DAY,1,@Today))

   SET @TotalTime = @TotalTime + @Time;

   PRINT CONVERT(VARCHAR,@Counter) + '.TIME is ' + CONVERT(VARCHAR,@Time) + ' Start at ' + CONVERT(VARCHAR,@MachineStartTime) + ' Stop at ' + CONVERT(VARCHAR,@MachineStopTime)

   SET @Counter  = @Counter  + 1        
END

SELECT TOP 1 @LastStopTime = Machine_Stop_Time FROM SampleMachineData WHERE Machine_Start_Time < @Today ORDER BY ID DESC
IF @MaxId <= 0
	IF @LastStopTime <= DATEADD(DAY,1,@Today)
		SET @TotalTime = 60;
	ELSE
		SET @TotalTime = 1440;

SET @Availability = 100 * @TotalTime / 1440;

UPDATE SampleOEE SET Accessibility = @Availability WHERE Machine_ID = @MachineId

PRINT 'TOTAL TIME is ' + CONVERT(VARCHAR,@TotalTime)
PRINT 'AVAILABILITY is ' + CONVERT(VARCHAR,@Availability)
PRINT 'LAST STOP TIME is ' + CONVERT(VARCHAR,@LastStopTime)
PRINT 'MAX ID is ' + CONVERT(VARCHAR,@MaxId)