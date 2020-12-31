select 
    RIGHT_BIG_TABLE.*, 
    LEFT_BIG_TABLE.avr_tot_eprs_cnt,
	LEFT_BIG_TABLE.cpc,
    LEFT_BIG_TABLE.ctr

from

	(select 
	stats_hh, pltfom_tp_code, advrts_prdt_code, advrts_tp_code, site_code, sum(tot_eprs_cnt)/count(stats_dttm) as avr_tot_eprs_cnt, 
    case 
		when sum(click_cnt) = 0 then 0
		else sum(advrts_amt)/sum(click_cnt)
	end as cpc,
    case 
		when sum(tot_eprs_cnt) = 0 then 0
		else sum(click_cnt)/sum(tot_eprs_cnt)
	end as ctr
	from BILLING.MOB_CAMP_HH_STATS 
	where stats_dttm between DATE_ADD(20200301, interval -3 month) AND 20200301
	and dayofweek(stats_dttm) = dayofweek(20200301) and advrts_prdt_code in ('01','05','07')
	and  PLTFOM_TP_CODE='02'
	group by stats_hh, advrts_prdt_code,advrts_tp_code,site_code) as LEFT_BIG_TABLE

right outer join

	(select
		stop_camp.*,camp_stats.advrts_tp_code, camp_stats.tot_eprs_cnt,camp_stats.click_cnt
	from
		(select STATS_DTTM, HH_NO as stats_hh, pltfom_tp_code,advrts_prdt_code,site_code, itl_tp_code,
		ROUND(minute(reg_dttm),-1) as stop_time
		from BILLING.TIME_CAMP_EXHS_STATS 
		where stats_dttm = 20200301
		and advrts_prdt_code in ('01','05','07')
		and pltfom_tp_code = '02' ) as stop_camp
        
	left outer join

		(select STATS_HH, PLTFOM_TP_CODE, ADVRTS_PRDT_CODE, ADVRTS_TP_CODE, SITE_CODE, TOT_EPRS_CNT, CLICK_CNT 
		from BILLING.MOB_CAMP_HH_STATS
		where stats_dttm = 20200301
		and advrts_prdt_code in ('01','05','07')
		and pltfom_tp_code = '02') as camp_stats
	on stop_camp.stats_hh = camp_stats.stats_hh
	and stop_camp.site_code = camp_stats.site_code
	and stop_camp.PLTFOM_TP_CODE = camp_stats.PLTFOM_TP_CODE ) as RIGHT_BIG_TABLE

    
on LEFT_BIG_TABLE.site_code = RIGHT_BIG_TABLE.site_code
and LEFT_BIG_TABLE.pltfom_tp_code = RIGHT_BIG_TABLE.pltfom_tp_code
and LEFT_BIG_TABLE.stats_hh = RIGHT_BIG_TABLE.stats_hh