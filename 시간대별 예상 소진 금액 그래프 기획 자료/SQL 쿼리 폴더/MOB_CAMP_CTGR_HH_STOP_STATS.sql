select
	LEFT_BIG_TABLE.*, 
    case 
    when RIGHT_BIG_TABLE.stop_time is null then 60
    else RIGHT_BIG_TABLE.stop_time
    end as stop_time
from
(select
	distinct mchs.*, site_cate_table.cate
from
(select 
	stats_dttm,stats_hh,pltfom_tp_code, advrts_prdt_code,advrts_tp_code, site_code,
    itl_tp_code,advrts_amt, TOT_EPRS_CNT, click_cnt
	from BILLING.MOB_CAMP_HH_STATS
	where stats_dttm >=  20200229
    and dayofweek(stats_dttm) in ('2','3','4','5','6')
	and itl_tp_code = '01'
	and pltfom_tp_code ='01'
	and advrts_prdt_code = '01'
	and advrts_tp_code = '01' ) as mchs
left outer join
	(select *
    from
		(SELECT site_code, cate FROM dreamsearch.iadsite 
		UNION
		SELECT site_code, category AS cate FROM dreamsearch.target_category 
		UNION
		SELECT site_code, cate FROM dreamsearch.adsite ) as site_cate_table
    group by site_code
    ) as site_cate_table
on mchs.site_code = site_cate_table.site_code) as LEFT_BIG_TABLE
left outer join
(select stats_dttm, pltfom_tp_code, site_code,itl_tp_code, minute(reg_dttm) as stop_time, HH_NO as stats_hh 
from BILLING.TIME_CAMP_EXHS_STATS
where stats_dttm >= 20200229
and dayofweek(stats_dttm) in ('2','3','4','5','6')
and itl_tp_code = '01'
and pltfom_tp_code ='01'
and advrts_prdt_code = '01'
and minute(reg_dttm) <> 0) as RIGHT_BIG_TABLE
on LEFT_BIG_TABLE.stats_hh = RIGHT_BIG_TABLE.stats_hh
and LEFT_BIG_TABLE.pltfom_tp_code = RIGHT_BIG_TABLE.pltfom_tp_code
and LEFT_BIG_TABLE.site_code = RIGHT_BIG_TABLE.site_code
and LEFT_BIG_TABLE.itl_tp_code = RIGHT_BIG_TABLE.itl_tp_code
and LEFT_BIG_TABLE.stats_dttm = RIGHT_BIG_TABLE.stats_dttm
