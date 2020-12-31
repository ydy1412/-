select
	taes.stats_dttm, taes.stats_hh, taes.advrts_prdt_code, taes.advrts_tp_code,
    taes.ADVER_ID, taes.pltfom_tp_code, taes.itl_tp_code,
    case when mahs.ADVRTS_AMT = 0 then 0 else taes.EXPT_ADVRTS_AMT/mahs.ADVRTS_AMT end as over_advrts_ratio
from
(SELECT * FROM BILLING.TIME_ADVER_EXHS_STATS
where stats_dttm = 20200515 
and stats_hh = 0
and pltfom_tp_code = '01') as taes
join
(select * from BILLING.MOB_ADVER_HH_STATS
where stats_dttm = 20200515
and stats_hh = 0
and pltfom_tp_code = '01') as mahs
on taes.stats_dttm = mahs.stats_dttm
and taes.stats_hh = mahs.stats_hh
and taes.pltfom_tp_code = mahs.pltfom_tp_code
and taes.advrts_prdt_code = mahs.advrts_prdt_code
and taes.adver_id = mahs.adver_id
and taes.itl_tp_code = mahs.itl_tp_code