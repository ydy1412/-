SELECT 
	left_big_table.stats_dttm,
    left_big_table.stats_hh,
    left_big_table.pltfom_tp_code, 
    left_big_table.advrts_prdt_code, 
    left_big_table.advrts_tp_code, 
    left_big_table.site_code,
    left_big_table.itl_tp_code,
    left_big_table.tot_eprs_cnt,
    case 
		when (left_big_table.stop_time is null) or (left_big_table.tot_eprs_cnt = 0 ) then left_big_table.tot_eprs_cnt 
        else left_big_table.tot_eprs_cnt * 60 / left_big_table.stop_time
	end as expt_eprs_cnt,
	left_big_table.advrts_amt,
    case 
		when (left_big_table.stop_time is null) or (left_big_table.tot_eprs_cnt = 0 ) then left_big_table.advrts_amt 
        else left_big_table.advrts_amt + left_big_table.tot_eprs_cnt/left_big_table.stop_time * ( 60 - left_big_table.stop_time ) * ctr_cpc_data.ctr * ctr_cpc_data.cpc
	end as expt_advrts_amt
FROM 
	(select 
		mchs.*,tces.stop_time
	from
		(select 
			stats_dttm, stats_hh, pltfom_tp_code,advrts_prdt_code, advrts_tp_code, site_code,itl_tp_code,tot_eprs_cnt, click_cnt, advrts_amt
			from BILLING.MOB_CAMP_HH_STATS
			where stats_dttm >=  20200229
			and dayofweek(stats_dttm) in ('2','3','4','5','6')
			and itl_tp_code = '01'
			and pltfom_tp_code ='01'
			and advrts_prdt_code = '01'
			and advrts_tp_code = '01' ) as mchs
	left outer join 
			(select stats_dttm, hh_no as stats_hh, pltfom_tp_code,itl_tp_code, site_code, minute(REG_DTTM) as stop_time
			from BILLING.TIME_CAMP_EXHS_STATS
			where minute(REG_DTTM) <> 0
			and dayofweek(stats_dttm) in ('2','3','4','5','6')
			and itl_tp_code = '01'
			and advrts_prdt_code = '01'
			and stats_dttm >= 20200229
			and pltfom_tp_code = '01') as tces
	on mchs.stats_dttm = tces.stats_dttm
	and mchs.stats_hh = tces.stats_hh
	and mchs.pltfom_tp_code = tces.pltfom_tp_code
	and mchs.site_code = tces.site_code
	and mchs.itl_tp_code = tces.itl_tp_code) as left_big_table

left outer join

	(SELECT 
		dayofweek(stats_dttm) as day_of_week, stats_hh, pltfom_tp_code, itl_tp_code,site_code,
		case 
			when sum(tot_eprs_cnt) = 0 then 0
			else sum(CLICK_CNT)/sum(tot_EPRS_CNT)
		end as ctr,
		case
			when sum(click_cnt) = 0 then 0 
			else sum(advrts_amt) / sum(click_cnt)
		end as cpc
	FROM BILLING.MOB_CAMP_HH_STATS
	where dayofweek(stats_dttm) in ('2','3','4','5','6')
	and itl_tp_code = '01'
	and pltfom_tp_code ='01'
	and advrts_prdt_code = '01'
	and advrts_tp_code = '01'
	group by stats_hh,dayofweek(stats_dttm), site_code, pltfom_tp_code, itl_tp_code) as ctr_cpc_data
    
on dayofweek(left_big_table.stats_dttm) = ctr_cpc_data.day_of_week
and left_big_table.site_code = ctr_cpc_data.site_code
and left_big_table.pltfom_tp_code = ctr_cpc_data.pltfom_tp_code
and left_big_table.itl_tp_code = ctr_cpc_data.itl_tp_code
and left_big_table.stats_hh = ctr_cpc_data.stats_hh


