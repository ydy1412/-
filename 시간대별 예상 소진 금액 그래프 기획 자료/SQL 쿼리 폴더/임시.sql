select
left_table.*,right_table.tot_eprs_cnt
from
(SELECT * FROM BILLING.TIME_CAMP_EXHS_STATS) as left_table
left outer join
(SELECT * FROM BILLING.MOB_CAMP_HH_STATS) as right_table
on left_table.HH_NO = cast(right_table.stats_hh as int)
and left_table.site_code = right_table.site_code
and left_table.pltfom_tp_code = right_table.pltfom_tp_code
and left_table.stats_dttm = right_table.stats_dttm