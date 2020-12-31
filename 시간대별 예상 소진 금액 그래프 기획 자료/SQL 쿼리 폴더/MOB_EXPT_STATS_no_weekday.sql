select
	big_table.stats_hh,
    sum(big_table.expt_advrts_amt) as tot_expt_advrts_amt,
    sum(big_table.expt_eprs_cnt) as tot_expt_eprs_cnt,
    sum(big_table.tot_eprs_cnt) as tot_eprs_cnt,
    sum(big_table.advrts_amt) as tot_advrts_amt
from
(
SELECT 
	mchs.*,
	case 
		when tces.stop_time is not null then mchs.tot_eprs_cnt * 60/ tces.stop_time
		else mchs.tot_eprs_cnt
	end as expt_eprs_cnt,
    case
		when tces.stop_time is not null then mchs.advrts_amt * 60 / tces.stop_time
        else mchs.advrts_amt
	end as expt_advrts_amt
FROM 
	(select 
		stats_dttm, stats_hh, pltfom_tp_code,advrts_prdt_code, advrts_tp_code, site_code,itl_tp_code,tot_eprs_cnt, click_cnt, advrts_amt
	from
	BILLING.MOB_CAMP_HH_STATS
	where stats_dttm >=  20200229
	and itl_tp_code = '01'
	and pltfom_tp_code ='01'
	and advrts_prdt_code = '01'
	and advrts_tp_code = '01' ) as mchs
left outer join 
	(select stats_dttm, HH_NO as stats_hh, pltfom_tp_code, site_code, itl_tp_code, minute(REG_DTTM) as stop_time
	from BILLING.TIME_CAMP_EXHS_STATS
	where minute(REG_DTTM) <> 0
	and itl_tp_code = '01'
	and advrts_prdt_code = '01'
	and stats_dttm >= 20200229
	and pltfom_tp_code = '01') as tces
on mchs.stats_dttm = tces.stats_dttm
and mchs.stats_hh = tces.stats_hh
and mchs.pltfom_tp_code = tces.pltfom_tp_code
and mchs.site_code = tces.site_code
and mchs.itl_tp_code = tces.itl_tp_code ) as big_table
group by stats_hh