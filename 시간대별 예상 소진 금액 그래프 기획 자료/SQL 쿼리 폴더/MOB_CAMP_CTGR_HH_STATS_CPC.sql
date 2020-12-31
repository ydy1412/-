select
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
on mchs.site_code = site_cate_table.site_code

