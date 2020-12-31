SELECT
		camp_hh_stats.stats_dttm, camp_hh_stats.stats_hh, camp_hh_stats.pltfom_tp_code, camp_hh_stats.advrts_prdt_code, 
		camp_hh_stats.advrts_tp_code, camp_hh_stats.site_code, camp_hh_stats.itl_tp_code, camp_hh_stats.tot_eprs_cnt, 
		camp_hh_stats.click_cnt, camp_hh_stats.advrts_amt, site_cate_table.cate
FROM

	(SELECT stats_dttm, stats_hh, pltfom_tp_code, advrts_prdt_code, advrts_tp_code, site_code, itl_tp_code, tot_eprs_cnt, click_cnt, advrts_amt 
	FROM BILLING.MOB_CAMP_HH_STATS 
	where stats_dttm = 20200202 ) as camp_hh_stats
    
left outer join 

	(SELECT site_code, cate FROM dreamsearch.iadsite 
	UNION
	SELECT site_code, category AS cate FROM dreamsearch.target_category 
	UNION
	SELECT site_code, cate FROM dreamsearch.adsite) as site_cate_table
on site_cate_table.site_code = camp_hh_stats.site_code