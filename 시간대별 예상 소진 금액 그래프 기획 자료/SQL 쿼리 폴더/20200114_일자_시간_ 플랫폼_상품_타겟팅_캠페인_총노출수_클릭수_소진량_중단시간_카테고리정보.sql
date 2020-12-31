# DB ip : 192.168.2.81
# DB name : dreamsearch, billing
# 운영 DB

-- used table
SELECT * FROM BILLING.MOB_CAMP_HH_STATS LIMIT 10 ;
SELECT * FROM BILLING.TIME_CAMP_EXHS_STATS LIMIT 10 ;
SELECT * FROM dreamsearch.iadsite LIMIT 10 ;
SELECT * FROM dreamsearch.target_category LIMIT 10 ;
SELECT * FROM FROM dreamsearch.adsite LIMIT 10 ;
SELECT * FROM dreamsearch.MOB_CTGR_INFO LIMIT 10 ;

-- 쿼리목적: ??? <========== 간략히 적어주세요 !!
SELECT
	stats_cate_table.stats_dttm, stats_cate_table.stats_hh, stats_cate_table.pltfom_tp_code, stats_cate_table.advrts_prdt_code, stats_cate_table.site_code, stats_cate_table.tot_eprs_cnt, stats_cate_table.click_cnt, stats_cate_table.advrts_amt, stats_cate_table.stop_time, cate_info.*
	FROM (
		SELECT 
			stats_data.stats_dttm,stats_data.stats_Hh,stats_data.PLTFOM_TP_CODE,stats_data.ADVRTS_PRDT_CODE,stats_data.site_code,cate_table.cate,stats_data.tot_eprs_cnt,stats_data.click_cnt,stats_data.advrts_amt,CASE WHEN stats_data.stop_time IS NULL THEN 60 ELSE stats_data.stop_time END AS "stop_time"
			FROM (
				SELECT /* sitecode 기준 시간대 예산 통계 */ mchs.*, tces.stop_time
					FROM (
						SELECT stats_dttm, stats_hh, pltfom_tp_code, advrts_prdt_code,site_code,tot_eprs_cnt,click_cnt, advrts_amt
							FROM BILLING.MOB_CAMP_HH_STATS
							WHERE STATS_DTTM = 20200114 AND itl_tp_code = '01'
					) AS mchs
					LEFT OUTER JOIN (
						SELECT stats_dttm, pltfom_tp_code, advrts_prdt_code, site_code,HH_NO AS stats_hh, MINUTE(REG_DTTM) AS stop_time
							FROM BILLING.TIME_CAMP_EXHS_STATS
							WHERE stats_dttm = 20200114 AND ITL_TP_CODE = '01'
					) AS tces 
						ON tces.stats_dttm = mchs.stats_dttm 
							AND tces.pltfom_tp_code = mchs.pltfom_tp_code 
							AND tces.advrts_prdt_code = mchs.advrts_prdt_code 
							AND tces.site_code = mchs.site_code 
							AND tces.stats_hh = mchs.stats_hh
			) AS stats_data
			LEFT OUTER JOIN (
				/* sitecode-cate 매핑 조회 */
				SELECT site_code, cate FROM dreamsearch.iadsite UNION
				SELECT site_code, category AS cate FROM dreamsearch.target_category UNION
				SELECT site_code, cate FROM dreamsearch.adsite
			) AS cate_table 
				ON stats_data.site_code = cate_table.site_code
				
			WHERE cate_table.cate IS NULL  -- <========== cate null 이라서 매핑 안되는 sitecode 가 존재함, cate_table 사용 불가 !!
			
	) AS stats_cate_table
	LEFT OUTER JOIN (
		SELECT /* 3rd, 2nd, 1st 카테고리 seq-이름 맵핑 조회 */ -- <========== right, left 조인 섞어서 사용한 이유가 뭘까요 ???
			right_table.CTGR_SEQ AS third_cate, right_table.third_depth_name, right_table. second_depth AS second_cate, right_table.second_depth_name, left_table.CTGR_SEQ AS first_cate, left_table.CTGR_NM AS first_depth_name
			FROM (
				SELECT CTGR_SEQ, CTGR_NM, HIRNK_CTGR_SEQ
					FROM dreamsearch.MOB_CTGR_INFO
					WHERE CTGR_DEPT=1
			) AS left_table
			RIGHT OUTER JOIN (
				SELECT td.CTGR_SEQ, td.CTGR_DEPT AS third_depth, td.CTGR_NM AS third_depth_name,sd.CTGR_SEQ AS second_depth, sd.CTGR_NM AS second_depth_name,sd.HIRNK_CTGR_SEQ
					FROM (
						SELECT CTGR_SEQ,CTGR_NM, HIRNK_CTGR_SEQ, CTGR_DEPT
							FROM dreamsearch.MOB_CTGR_INFO
							WHERE CTGR_DEPT=3
					) AS td
					LEFT OUTER JOIN (
						SELECT CTGR_SEQ, HIRNK_CTGR_SEQ, CTGR_NM
						FROM dreamsearch.MOB_CTGR_INFO
						WHERE ctgr_dept=2
					) AS sd 
						ON td.HIRNK_CTGR_SEQ = sd.CTGR_SEQ
			) AS right_table 
				ON right_table.HIRNK_CTGR_SEQ = left_table.CTGR_SEQ
	) AS cate_info 
		ON stats_cate_table.cate = cate_info.third_cate
;

