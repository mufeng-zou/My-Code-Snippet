echo off
REM ===============================================================================================
REM Program Name : NZ Monitoring.bat
REM Create Date  : August 31, 2016
REM Description  : NZ Parameterised Monitoring Batch (Client and Internal)
REM Release      : August 31, 2016
REM Modified on  : June 30, 2017
REM
REM Change logs are at the end
REM ===============================================================================================
@ECHO OFF
setlocal enabledelayedexpansion

REM ===============================================================================================
REM                         DEFAULT VALUES
REM ===============================================================================================
rem set DSOL_META_NZ_PROG= "S:\Score_AN\File templates\Macros & Tools\Dev\scoring_tools_nz\controller\dsol_meta\"
set DSOL_META_NZ_PROG= "S:\Score_AN\TEMP\TimSujanto\scoring_tools_nz\controller\dsol_meta\"
set DSOL_META_NZ_TEST_PROG= "S:\Score_AN\TEMP\TimSujanto\scoring_tools_nz\controller\dsol_meta\"
set CUR_PROG= "%~dp0"

REM default values::
rem defaul dates are set to be last month
set MON_M=%date:~7,2%
set MON_Y=%date:~10,4%
rem get rid of the leading zero first for calculation
IF %MON_M:~0,1% EQU 0 (SET MON_M=%MON_M:~1,1%)
rem get quarter
IF %MON_M% GTR 9 (
	SET MON_Q=3
) ELSE (
	IF %MON_M% GTR 6 (
		SET MON_Q=2
	) ELSE (
		IF %MON_M% GTR 3 (
			SET MON_Q=1
		) ELSE (
			SET MON_Q=4
			SET /a MON_Y=%MON_Y%-1
		)
	)
)

set SERVER=nzaklgl-db601\stg
set MAWORK=MAWORK
set INBOUND=Y
set RUNEXTRACT=Y
set GENARATETABLES=Y
set UPDATETABLES=N

SET STARTTIME=%date% %time%
SQLCMD -b -E -S %SERVER% -d %MAWORK% -Q "exec mawork.dbo.msg 'Start Process',-1" || goto :error

REM for regression test
IF /I "%1%" NEQ "" (
	SET INPUT=%1%
	IF /I "%2%" NEQ "" (
		SET MON_Q=%2%
		IF /I "%3%" NEQ "" (
			SET MON_Y=%3%
			IF /I "%4%" NEQ "" (
				SET UPDATETABLES=%4%
			)
		)
	)
	goto regression_test
	EXIT
)

REM ===============================================================================================
REM                              MENU
REM ===============================================================================================
:MENU
CLS
ECHO =================================================================
ECHO =====================RELEASE 31 August 2016======================
ECHO =================================================================
ECHO -------------------------NZ Monitoring---------------------------
ECHO  0.  Update Executive Summary
ECHO.
ECHO  1.  VSP and VedaEvo Monitoring
ECHO  2.  PRS and EvoPRS Monitoring - in UAT
ECHO  3.  DRS090 and DRS360 Monitoring
ECHO.
ECHO =================================================================
ECHO ==========           CHANGE EXTRACT SETTINGS          ===========
ECHO =================================================================
ECHO  a.  Monitoring Quarter            : %MON_Q%
ECHO  b.  Monitoring Year               : %MON_Y%
ECHO  c.  Generate Inbound              : %INBOUND%
ECHO  d.  Run Extract                   : %RUNEXTRACT%
ECHO  e.  Generate Monitoring Tables    : %GENARATETABLES%
ECHO  f.  Update Monitoring Tables      : %UPDATETABLES%
ECHO.
ECHO =================================================================
ECHO.
ECHO ========================='q' To Quit=============================
ECHO.

SET INPUT=
SET /P INPUT=Please enter your selection then 'Enter' to continue:
:regression_test
IF /I '%INPUT%'=='0'  GOTO ExecutiveSummary

IF /I '%INPUT%'=='1'  GOTO RunExtract
IF /I '%INPUT%'=='2'  GOTO RunExtract
IF /I '%INPUT%'=='3'  GOTO RunExtract

IF /I '%INPUT%'=='a' GOTO QuarterSetting
IF /I '%INPUT%'=='b' GOTO YearSetting
IF /I '%INPUT%'=='c' GOTO InboundSetting
IF /I '%INPUT%'=='d' GOTO ExtractSetting
IF /I '%INPUT%'=='e' GOTO TableSetting
IF /I '%INPUT%'=='f' GOTO UpdateSetting

IF /I '%INPUT%'=='q' GOTO Quit

CLS
ECHO.
ECHO.
ECHO        =======================INVALID INPUT===========================
ECHO.
ECHO        Please pick a valid selection from the Main Menu.
ECHO        ==================PRESS ANY KEY TO CONTINUE====================
ECHO.

PAUSE > NUL
GOTO MENU


REM ===============================================================================================
REM                              Main Code
REM ===============================================================================================
:RunExtract
SET STARTTIME=%date% %time%
SQLCMD -b -E -S %SERVER% -d %MAWORK% -Q "exec mawork.dbo.msg 'Start Process',-1" || goto :error

IF /I "%INBOUND%" == "Y" (
	SET ACTION=Generating inbound
	ECHO ========...Generating myid...=========
	
        IF /I '%INPUT%'=='1' (
			SQLCMD -b -E -S %SERVER% -d %MAWORK% -i %CUR_PROG%Batch_Codes\VSP_monitoring_inbound.sql  || goto :error
			SQLCMD -b -E -S %SERVER% -d %MAWORK% -Q "exec mawork.dbo.createInbound 'CONS','vsp_monitoring_inbound2','%MAWORK%'" || goto :error
		)
        IF /I '%INPUT%'=='2' (
			SQLCMD -b -E -S %SERVER% -d %MAWORK% -i %CUR_PROG%Batch_Codes\PRS_monitoring_inbound.sql  || goto :error
			SQLCMD -b -E -S %SERVER% -d %MAWORK% -Q "exec mawork.dbo.createInbound 'CONS','prs_monitoring_inbound','%MAWORK%'" || goto :error
		)
		IF /I '%INPUT%'=='3' (
			SQLCMD -b -E -S %SERVER% -d %MAWORK% -i %CUR_PROG%Batch_Codes\DRS_monitoring_inbound.sql  || goto :error
			SQLCMD -b -E -S %SERVER% -d %MAWORK% -Q "exec mawork.dbo.createInbound 'CONS','drs_monitoring_inbound','%MAWORK%'" || goto :error
        )
		
	ECHO ========...Finished generating myid...=========
ECHO.
) 
IF /I "%RUNEXTRACT%" == "Y" (
	SET ACTION=Running VedaEvo extract
	ECHO ========...Running VedaEvo extract...=========

	    IF /I '%INPUT%'=='1' (
			CALL %DSOL_META_NZ_PROG%nzrunme.bat 11 || goto :error
		)
	    IF /I '%INPUT%'=='2' (
			CALL %DSOL_META_NZ_PROG%nzrunme.bat 21 || goto :error
		)
	    IF /I '%INPUT%'=='3' (
			CALL %DSOL_META_NZ_PROG%nzrunme.bat 8 || goto :error
		)
		
	ECHO ========...Finished Running VedaEvo extract...=========
)
IF /I "%GENARATETABLES%" == "Y" (
	SET ACTION=Generating Monitoring tables
	ECHO ========...Generating Monitoring tables...=========
	
	    IF /I '%INPUT%'=='1' (
			SQLCMD -b -E -S %SERVER% -d %MAWORK% -i %CUR_PROG%Batch_Codes\VSP_monitoring_summary_chars.sql  || goto :error
			SQLCMD -b -E -S %SERVER% -d %MAWORK% -i %CUR_PROG%Batch_Codes\EVO_monitoring_summary_chars.sql  || goto :error
		)
	    IF /I '%INPUT%'=='2' (
			SQLCMD -b -E -S %SERVER% -d %MAWORK% -i %DSOL_META_NZ_PROG%monitoring\monitoring_21_prs.sql  || goto :error
		)
	    IF /I '%INPUT%'=='3' (
		rem change after moved to prod
			SQLCMD -b -E -S %SERVER% -d %MAWORK% -i %DSOL_META_NZ_PROG%monitoring\monitoring_drs.sql  || goto :error
		)
		
	ECHO ========...Finished generating Monitoring tables...=========
	ECHO.
)
IF /I "%UPDATETABLES%" == "Y" (
	SET ACTION=Updating Monitoring tables
	ECHO ========...Updating Monitoring tables...=========
	    
		IF /I '%INPUT%'=='1' (
			SQLCMD -b -E -S %SERVER% -d %MAWORK% -i %CUR_PROG%Batch_Codes\update_VSP_EVO_tables.sql  || goto :error
		)
		IF /I '%INPUT%'=='2' (
			SQLCMD -b -E -S %SERVER% -d %MAWORK% -i %CUR_PROG%Batch_Codes\update_PRS_EVOPRS_tables.sql  || goto :error
		)
	    IF /I '%INPUT%'=='3' (
			SQLCMD -b -E -S %SERVER% -d %MAWORK% -i %CUR_PROG%Batch_Codes\update_DRS_tables.sql  || goto :error
		)
		
	ECHO ========...Finished updating Monitoring tables...=========
	ECHO.
)
ECHO.
ECHO ===============================================================================================
ECHO Started : %STARTTIME%
ECHO Finished: %date% %time%
SQLCMD -b -E -S %SERVER% -d %MAWORK% -Q "exec mawork.dbo.msg 'Finished Process'" || goto :error
ECHO ===============================================================================================
ECHO ======FINISHED RUNNING EXTRACT=======
ECHO ======
ECHO ======PRESS ANY KEY TO CONTINUE======
ECHO ===============================================================================================

PAUSE > NUL
GOTO MENU

:ExecutiveSummary
SET STARTTIME=%date% %time%
SQLCMD -b -E -S %SERVER% -d %MAWORK% -Q "exec msg 'Start Process',-1"

SQLCMD -b -E -I -S %SERVER% -d %MAWORK% -i "%~dp0"Batch_Codes\update_executive_summary.sql || goto :error
			
ECHO.
ECHO ================================================================================
ECHO Started : %STARTTIME%
ECHO Finished: %date% %time%
SQLCMD -b -E -S %SERVER% -d %MAWORK% -Q "exec msg 'Finished Process'"
ECHO ================================================================================
ECHO ==========FINISHED UPDATING==========
ECHO ======PRESS ANY KEY TO CONTINUE======
ECHO ================================================================================

PAUSE > NUL
GOTO MENU

:QuarterSetting
ECHO.
ECHO ============CHANGING DEFAULT VALUE============
ECHO ============...enter new value    ============
SET /p MON_Q="Input quarter: " %=%
IF /I %MON_Q% GTR 4 (
	set MON_Y=%date:~10,4%
	IF %MON_M% GTR 9 (
		SET MON_Q=3
	) ELSE (
		IF %MON_M% GTR 6 (
			SET MON_Q=2
		) ELSE (
			IF %MON_M% GTR 3 (
				SET MON_Q=1
			) ELSE (
				SET MON_Q=4
				SET /a MON_Y=%MON_Y%-1
			)
		)
	)
	ECHO.
	ECHO.
	ECHO ======
	ECHO Make sure you choose a valid quarter
	ECHO There are only 4...
	ECHO ======
	ECHO.
	PAUSE > NUL
	CLS
	GOTO MENU
)
IF /I %MON_Q% LSS 1 (
	set MON_Y=%date:~10,4%
	IF %MON_M% GTR 9 (
		SET MON_Q=3
	) ELSE (
		IF %MON_M% GTR 6 (
			SET MON_Q=2
		) ELSE (
			IF %MON_M% GTR 3 (
				SET MON_Q=1
			) ELSE (
				SET MON_Q=4
				SET /a MON_Y=%MON_Y%-1
			)
		)
	)
	ECHO.
	ECHO.
	ECHO ======
	ECHO Make sure you choose a valid quarter
	ECHO There are only 4...
	ECHO ======
	ECHO.
	PAUSE > NUL
	CLS
	GOTO MENU
)
CLS
GOTO MENU

:YearSetting
ECHO.
ECHO ============CHANGING DEFAULT VALUE============
ECHO ============...enter new value    ============
SET /p MON_Y="Input year (use yyyy format): " %=%
IF /I %MON_Y% LSS 1000 (
	set MON_Y=%date:~10,4%
	ECHO.
	ECHO.
	ECHO ======
	ECHO Please use yyyy format!
	ECHO ======
	ECHO.
	PAUSE > NUL
	CLS
	GOTO MENU
)
IF /I %MON_Y% GTR 9999 (
	set MON_Y=%date:~10,4%
	ECHO.
	ECHO.
	ECHO ======
	ECHO Please use yyyy format!
	ECHO ======
	ECHO.
	PAUSE > NUL
	CLS
	GOTO MENU
)
CLS
GOTO MENU

:InboundSetting
IF /I "%INBOUND%" == "Y" (
	SET INBOUND=N
) ELSE (
	SET INBOUND=Y
)
CLS
GOTO MENU

:ExtractSetting
IF /I "%RUNEXTRACT%" == "Y" (
	SET RUNEXTRACT=N
) ELSE (
	SET RUNEXTRACT=Y
)
CLS
GOTO MENU

:TableSetting
IF /I "%GENARATETABLES%" == "Y" (
	SET GENARATETABLES=N
) ELSE (
	SET GENARATETABLES=Y
)
CLS
GOTO MENU

:UpdateSetting
IF /I "%UPDATETABLES%" == "Y" (
	SET UPDATETABLES=N
) ELSE (
	SET UPDATETABLES=Y
)
CLS
GOTO MENU

REM ==================================
REM Error Handlers
REM ==================================
:ERROR
ECHO Started : %STARTTIME%
ECHO Finished: %date% %time%
SQLCMD -b -E -S %SERVER% -d %MAWORK% -Q "exec mawork.dbo.msg 'Finished Process'" || goto :error
ECHO.
echo An Error Occurred While %ACTION% ( #%errorlevel% ).
ECHO.**exit /b %errorlevel%

ECHO ======PRESS ANY KEY TO CONTINUE======
PAUSE > NUL
GOTO MENU

REM ==============================================================================================================================================================================================
REM Change Log
REM Changed on  : June 30, 2017   				By: MUFENG
REM Changes     : Added DRS
REM ==============================================================================================================================================================================================
