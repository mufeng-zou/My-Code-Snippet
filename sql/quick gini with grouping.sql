declare @table varchar(max) = 'dsol_monitoring.[CORP\Mufeng.Zou].[monitoring_vs12yx_summary_dev]'
declare @score varchar(max) = 'score'
declare @gbf varchar(max) = 'gbf'
declare @group_field varchar(max) = ''
declare @sqlquery varchar(max) = case when @group_field <>'' then '
SELECT groups
, (sum(goods * (cum_bads - bads)) - sum(bads * (cum_goods - goods))) / sum((goods * (cum_bads - bads)) + (goods * bads) + (bads * (cum_goods - goods))) AS GINI
, case when max(sum_bads)=0 or max(sum_goods)=0 then NULL else max(abs(cum_bads / sum_bads - cum_goods / sum_goods)) end AS KS
FROM (
SELECT groups
,score
,goods
,bads
,cast(sum(goods) OVER (partition by groups ORDER BY score ASC rows unbounded preceding) AS FLOAT) AS cum_goods
,cast(sum(bads) OVER (partition by groups ORDER BY score ASC rows unbounded preceding) AS FLOAT) AS cum_bads
,cast(sum(goods) OVER (partition by groups) AS FLOAT) AS sum_goods
,cast(sum(bads) OVER (partition by groups) AS FLOAT) AS sum_bads
FROM (
SELECT '+@group_field+' as groups
,'+@score+' AS score
,sum(CASE WHEN '+@gbf+' = ''G'' THEN 1 ELSE 0 END) AS goods
,sum(CASE WHEN '+@gbf+' = ''B'' THEN 1 ELSE 0 END) AS bads
FROM '+@table+'
WHERE '+@gbf+' IN (''G'' ,''B'')
GROUP BY '+@group_field+','+@score+'
) a
) b group by groups
' else '
SELECT (sum(goods * (cum_bads - bads)) - sum(bads * (cum_goods - goods))) / sum((goods * (cum_bads - bads)) + (goods * bads) + (bads * (cum_goods - goods))) AS GINI
, case when max(sum_bads)=0 or max(sum_goods)=0 then NULL else max(abs(cum_bads / sum_bads - cum_goods / sum_goods)) end AS KS
FROM (
SELECT score
,goods
,bads
,cast(sum(goods) OVER (ORDER BY score ASC rows unbounded preceding) AS FLOAT) AS cum_goods
,cast(sum(bads) OVER (ORDER BY score ASC rows unbounded preceding) AS FLOAT) AS cum_bads
,cast(sum(goods) OVER () AS FLOAT) AS sum_goods
,cast(sum(bads) OVER () AS FLOAT) AS sum_bads
FROM (
SELECT '+@score+' AS score
,sum(CASE WHEN '+@gbf+' = ''G'' THEN 1 ELSE 0 END) AS goods
,sum(CASE WHEN '+@gbf+' = ''B'' THEN 1 ELSE 0 END) AS bads
FROM '+@table+'
WHERE '+@gbf+' IN (''G'' ,''B'')
GROUP BY '+@score+'
) a
) b
' end
exec (@sqlquery)