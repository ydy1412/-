SELECT 
	mchs.*,
	case 
		when tces.stop_time is not null then mchs.tot_eprs_cnt * 60/ tces.stop_time
		else mchs.tot_eprs_cnt
	end as expt_eprs_cnt
    ,
    case 
		when tces.stop_time is null then 60
		else tces.stop_time
	end as stop_time
FROM 
	(select 
		stats_dttm, stats_hh, pltfom_tp_code,advrts_prdt_code, advrts_tp_code, site_code,itl_tp_code,tot_eprs_cnt, click_cnt, advrts_amt
	from
	BILLING.MOB_CAMP_HH_STATS
	where stats_dttm >=  20200229
    and dayofweek(stats_dttm) in ('2','3','4','5','6')
	and itl_tp_code = '01'
	and pltfom_tp_code ='01'
	and advrts_prdt_code = '01'
	and advrts_tp_code = '01' ) as mchs
left outer join 
	(select stats_dttm, HH_NO as stats_hh, pltfom_tp_code, site_code, itl_tp_code, minute(REG_DTTM) as stop_time
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
and mchs.itl_tp_code = tces.itl_tp_code