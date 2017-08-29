getsql <- function(server,query) {

  ODBC_string <- paste0("Driver={SQL Server};Server={",server,"};Trusted_Connection=true")

  conn <- RODBC::odbcDriverConnect(ODBC_string, readOnlyOptimize = T)

  df <- RODBC::sqlQuery(conn, query)

  RODBC::odbcClose(conn)

  return(df)
}


#df <- getsql('NZAKLGL-DB601\\STG',"select score from MAWORK.[CORP\\Mufeng.Zou].prs_monitoring_summary where scorecard='PRS' and score>-900")
#quantile(df$score,0:10/10,na.rm = T)

#df <- getsql('NZAKLGL-DB601\\STG',"select score from MAWORK.[CORP\\Mufeng.Zou].prs_monitoring_summary where scorecard='EVOPRS' and score>-900")
#quantile(df$score,0:10/10,na.rm = T)

