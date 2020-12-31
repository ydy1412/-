select 
	RIGHT_BIG_TABLE.stats_dttm,
    RIGHT_BIG_TABLE.stats_hh,
    RIGHT_BIG_TABLE.pltfom_tp_code,
    RIGHT_BIG_TABLE.advrts_prdt_code,
	RIGHT_BIG_TABLE.advrts_tp_code,
    RIGHT_BIG_TABLE.site_code,
    RIGHT_BIG_TABLE.itl_tp_code,
    ROUND(RIGHT_BIG_TABLE.stop_time,-1) as stop_time,
    ROUND((RIGHT_BIG_TABLE.TOT_EPRS_CNT + (60-RIGHT_BIG_TABLE.stop_time) / 60*LEFT_BIG_TABLE.avr_tot_eprs_cnt),0) as EXP_TOT_EPRS_CNT,
	ROUND((RIGHT_BIG_TABLE.CLICK_CNT + (60-RIGHT_BIG_TABLE.stop_time) / 60*LEFT_BIG_TABLE.avr_tot_eprs_cnt * LEFT_BIG_TABLE.ctr),0) as EXP_CLICK_CNT,
    ROUND(((RIGHT_BIG_TABLE.TOT_EPRS_CNT + (60-RIGHT_BIG_TABLE.stop_time) / 60*LEFT_BIG_TABLE.avr_tot_eprs_cnt) * LEFT_BIG_TABLE.cpv),0) as EXP_ADVRTS_AMT
from

	(select 
	stats_hh, pltfom_tp_code, advrts_prdt_code, advrts_tp_code, site_code, sum(tot_eprs_cnt)/count(stats_dttm) as avr_tot_eprs_cnt, 
    
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
	group by stats_hh, advrts_prdt_code,advrts_tp_code,site_code) as LEFT_BIG_TABLE

right outer join

	(select
		stop_camp.*,camp_stats.advrts_tp_code, camp_stats.tot_eprs_cnt,camp_stats.click_cnt
	from
		(select STATS_DTTM, HH_NO as stats_hh, pltfom_tp_code,advrts_prdt_code,site_code, itl_tp_code,
		minute(reg_dttm) as stop_time
		from BILLING.TIME_CAMP_EXHS_STATS 
		where stats_dttm = 20200301
		and advrts_prdt_code in ('02','03')
		and pltfom_tp_code = '02' ) as stop_camp
        
	left outer join

		(select STATS_HH, PLTFOM_TP_CODE, ADVRTS_PRDT_CODE, ADVRTS_TP_CODE, SITE_CODE, TOT_EPRS_CNT, CLICK_CNT 
		from BILLING.MOB_CAMP_HH_STATS
		where stats_dttm = 20200301
		and advrts_prdt_code in ('02','03')
		and pltfom_tp_code = '02') as camp_stats
	on stop_camp.stats_hh = camp_stats.stats_hh
	and stop_camp.site_code = camp_stats.site_code
	and stop_camp.PLTFOM_TP_CODE = camp_stats.PLTFOM_TP_CODE ) as RIGHT_BIG_TABLE

    
on LEFT_BIG_TABLE.site_code = RIGHT_BIG_TABLE.site_code
and LEFT_BIG_TABLE.pltfom_tp_code = RIGHT_BIG_TABLE.pltfom_tp_code
and LEFT_BIG_TABLE.stats_hh = RIGHT_BIG_TABLE.stats_hh
