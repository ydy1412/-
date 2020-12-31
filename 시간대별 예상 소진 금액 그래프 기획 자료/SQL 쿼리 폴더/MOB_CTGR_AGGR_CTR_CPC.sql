SELECT dayofweek(stats_dttm) as day_of_week,stats_hh,CTGR_SEQ, 
case 
	when PAR_EPRS_CNT = 0 then 0
    else CLICK_CNT/PAR_EPRS_CNT
end as ctr
FROM BILLING.MOB_CTGR_HH_STATS 
where stats_dttm >= 20200229
and dayofweek(stats_dttm) in ('2','3','4','5','6')
and pltfom_tp_code = '01'
and advrts_prdt_code = '01'
and advrts_tp_code = '01'
and itl_tp_code = '01'
group by stats_dttm, stats_hh,CTGR_SEQ,dayofweek(stats_dttm) 