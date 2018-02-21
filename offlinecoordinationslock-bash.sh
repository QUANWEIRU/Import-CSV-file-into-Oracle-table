#!/bin/sh
#
#
#
#
# -------------------- VERSION = 1.01 --------------------
#
#
#
# -------------------- MODIFICATIONS ---------------------
# 2018/02/21 10:15 AM - MACESPEDES - v1.01 - Last Revision of Everything
# 2018/02/20 11:27 AM - MACESPEDES - v1.00 - Creation of the Package
# --------------------------------------------------------
#
#
#
#
# --------------------------------------------------------
# CONFIG
# @description: set environment variable
# --------------------------------------------------------
	G_ORA_HOST='***********************'
	G_ORA_PROTOCOL='tcp'
	G_ORA_PORT='*****'
	G_ORA_SERVICENAME='*****'
	G_ORA_USER='****'
	G_ORA_PASSWORD='****'
	#
	G_TNS_CONNECTION="\"\(DESCRIPTION=\(ADDRESS=\(PROTOCOL=$G_ORA_PROTOCOL\)\(HOST=$G_ORA_HOST\)\(PORT=$G_ORA_PORT\)\)\(CONNECT_DATA=\(SERVICE_NAME=$G_ORA_SERVICENAME\)\)\)\""
	G_STR_CONNECTION="$G_ORA_USER/$G_ORA_PASSWORD@(DESCRIPTION=(ADDRESS=(PROTOCOL=$G_ORA_PROTOCOL)(HOST=$G_ORA_HOST)(PORT=$G_ORA_PORT))(CONNECT_DATA=(SERVICE_NAME=$G_ORA_SERVICENAME)))"
	#
	if [[ `uname` == 'MINGW64_NT-10.0' ]]; then
		G_LOGS='C:\data\ibk_ps_offlinecoordinationslock\01_MIGRATION-PROCESS-BASH\LOGS'
		G_INPUT='C:\data\ibk_ps_offlinecoordinationslock\01_MIGRATION-PROCESS-BASH\INPUT'
		G_OUTPUT='C:\data\ibk_ps_offlinecoordinationslock\01_MIGRATION-PROCESS-BASH\OUTPUT'
	else
		export ORACLE_HOME=/u02/app/oracle/product/11.2.0/dbhome_1
		export PATH=$PATH:$ORACLE_HOME/bin
		G_LOGS='/TC/AVPD106/DTB/LOGS'
		G_INPUT='/TC/AVPD106/DTB/INPUT'
		G_OUTPUT='/TC/AVPD106/DTB/OUTPUT'
	fi
#
#
#
#
# --------------------------------------------------------
# FN_MIGRATION
# @description: migration process to DB
# --------------------------------------------------------
FN_MIGRATION()
{
	sqlldr $G_ORA_USER/$G_ORA_PASSWORD@$G_TNS_CONNECTION control=query-migration.ctl log=$G_LOGS/offlinecoordinationslock-bash.log bad=$G_LOGS/offlinecoordinationslock-bash.err
}
#
#
#
#
# --------------------------------------------------------
# FN_CLEAN
# @description: 
# --------------------------------------------------------
FN_CLEAN(){
sqlplus -S $G_STR_CONNECTION<<END
TRUNCATE TABLE IBPYS.T_PSDISTRIBUTIONREPORT;
END
}
#
#
#
#
# --------------------------------------------------------
# FN_BUILD
# @description: 
# --------------------------------------------------------
FN_BUILD()
{
sqlplus -S $G_STR_CONNECTION<<END
set colsep ,
set headsep off
set pagesize 0
set trimspool on
set linesize 500
set numwidth 1

spool $G_OUTPUT\TC_DTB_20180220.csv

	SELECT TRIM(CODUNICOCLI_DTB) 
	|| ';' || TRIM(NRODOCTIT_DTB) 
	|| ';' || TRIM(NOMCLIENTE_DTB) 
	|| ';' || TRIM(NROTARJE_DTB)
	|| ';' || TRIM(NROCTA)
	|| ';' || TRIM(CODSEGUI)
	FROM IBPYS.T_PSDISTRIBUTIONREPORT;

spool off
END
}
#
#
#
#
# --------------------------------------------------------
# FN_TEST
# @description: 
# --------------------------------------------------------
FN_TEST()
{
echo ""
echo "G_LOGS       -> $G_LOGS"
echo "G_OUTPUT     -> $G_OUTPUT"
echo "G_CONNECTION -> $G_CONNECTION"
echo ""
sqlplus -S $G_STR_CONNECTION<<END
SELECT count(*) as Total FROM IBPYS.T_PSDISTRIBUTIONREPORT;
END
}
#
#
#
#
# --------------------------------------------------------
# MAIN
# @description: trigger
# --------------------------------------------------------
FN_CLEAN
FN_MIGRATION
#FN_BUILD
#FN_TEST
#
#
#
#
#
#