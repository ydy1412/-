select 
	stats_hh,dayofweek(stats_dttm), pltfom_tp_code, advrts_prdt_code, advrts_tp_code, site_code, sum(tot_eprs_cnt)/count(stats_dttm) as avr_tot_eprs_cnt, 
    case 
		when sum(tot_eprs_cnt) = 0 then 0
		else sum(advrts_amt)/sum(tot_eprs_cnt)
	end as cpv,
    case 
		when sum(tot_eprs_cnt) = 0 then 0
		else sum(click_cnt)/sum(tot_eprs_cnt)
	end as ctr
from BILLING.MOB_CAMP_HH_STATS 
where stats_dttm between DATE_ADD(20200301, interval -3 month) AND 20200301
and dayofweek(stats_dttm) = dayofweek(20200301) and advrts_prdt_code in ('02','03')
and  PLTFOM_TP_CODE='02'
group by stats_hh, advrts_prdt_code,advrts_tp_code,site_code