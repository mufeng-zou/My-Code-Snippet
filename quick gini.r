gini <- function(odbc, tbl, score, gbf, by) {

  if (missing(by)) {

    conn <- RODBC::odbcConnect(odbc)

    q <- paste0('select ',score,', ',gbf,' from ',tbl,' where ',gbf," in ('G','B') and ",score,' > -900')

    df <- RODBC::sqlQuery(conn, q)

    RODBC::odbcClose(conn)

#    df2 <- df[df[[gbf]] %in% c('G', 'B') & df[[score]]>-900,]
    gini <- pROC::auc(df[[gbf]], df[[score]], levels = c('G', 'B')) * 2 - 1
    return(gini)

  } else {

    conn <- RODBC::odbcConnect(odbc)

    q <- paste0('select ',score,', ',gbf,', ',by,' from ',tbl,' where ',gbf," in ('G','B') and ",score,' > -900')

    df <- RODBC::sqlQuery(conn, q)

    RODBC::odbcClose(conn)

    segments <- unique(df[[by]])
    ginis <- numeric()
    i <- 0
    for (segment in segments) {
      i <- i + 1
      ginis[i] <- pROC::auc(df[df[[by]]==segment,gbf], df[df[[by]]==segment,score], levels = c('G', 'B')) * 2 - 1
    }
    gini_all <- pROC::auc(df[[gbf]], df[[score]], levels = c('G', 'B')) * 2 - 1

    df_auc <- data.frame(by=segments,gini=ginis)
    df_auc <- rbind(data.frame(by='ALL',gini=gini_all),df_auc)
    return(df_auc)

  }
}

#gini('mawork_stg','myout','c090_master_scale','x_gbf_c090')
#gini('mawork_stg','myout','c360_master_scale','x_gbf_c360')

#gini(odbc='mawork_stg',tbl='nztemp_temp',score='fitted_value',gbf='gbf_temp',by='segment')
