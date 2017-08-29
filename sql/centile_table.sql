with a as (
SELECT *, case when PERCENT_RANK() over (order by score)=0 then 1 else ceiling(PERCENT_RANK() over (order by score)*100) end as perc
FROM [DSOL_Monitoring].[dbo].[v_monitoring_summary]
where scorecard='COMMPRS_COM' and score>-900 and gbf!='E' and obs_date between '20150701' and '20150930' and [recent?]=0
)
select perc as percentile,
min(score) as Minimum_Score,
max(score) as Maximum_Score,
count(*) as Total,
sum(case when gbf='G' then 1 end) as Goods,
sum(case when gbf='B' then 1 end) as Bads,
cast(sum(case when gbf='G' then 1 end) as decimal)/sum(case when gbf='B' then 1 end) as Good_Bad_Odds,
cast(sum(case when gbf='B' then 1 end) as decimal)/sum(case when gbf in ('G','B') then 1 end) as Bad_Rate,
avg(score) as Average_Score,
(
 (SELECT MAX(score) FROM
   (SELECT TOP 50 PERCENT score FROM a t_in where t_in.perc=t_out.perc ORDER BY score) AS BottomHalf)
 +
 (SELECT MIN(Score) FROM
   (SELECT TOP 50 PERCENT score FROM a t_in where t_in.perc=t_out.perc ORDER BY score DESC) AS TopHalf)
) / 2 as Median_Score
--into #temp
from a t_out
group by perc
order by perc