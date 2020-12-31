select 
stats_dttm, dayofweek(stats_dttm) as day_of_week, HH_NO as stats_hh, 
pltfom_tp_code, advrts_prdt_code, site_code, itl_tp_code,
BDGT_AMT, 
( select SUM(o.BDGT_AMT) from BILLING.TIME_CAMP_BDGT_STATS as o 
where o.stats_dttm =  tcbs.stats_dttm 
and o.pltfom_tp_code = tcbs.PLTFOM_TP_CODE 
and o.site_code = tcbs.site_code
and o.itl_tp_code = tcbs.itl_tp_code
and o.HH_NO <= tcbs.HH_NO) as cum_sum
from BILLING.TIME_CAMP_BDGT_STATS as tcbs
where stats_dttm = 20200202

