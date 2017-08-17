gini <- function(odbc, tbl, score, gbf) {
  conn <- RODBC::odbcConnect(odbc)
  
  q <- paste0('select ',score,', ',gbf,' from ',tbl,' where ',gbf," in ('G','B') and ",score,' > -900')
  
  df <- RODBC::sqlQuery(conn, q)
  
  RODBC::odbcClose(conn)

  df2 <- df[df[[gbf]] %in% c('G', 'B') & df[[score]]>-900,]
  auc <- pROC::auc(df2[[gbf]], df2[[score]], levels = c('G', 'B'))
  return(auc*2-1)  
}

gini('mawork_stg','myout','c090_master_scale','x_gbf_c090')
gini('mawork_stg','myout','c360_master_scale','x_gbf_c360')
