select
	media_script_stats.stats_dttm, media_script_stats.advrts_prdt_code, media_script_stats.pltfom_tp_code, media_script_stats.site_code,over_camp_stats.camp_status,
    media_script_stats.media_script_no,media_script_stats.tot_eprs_cnt,media_script_stats.click_cnt, media_script_stats.req_cnt,
    (media_script_stats.web_par_eprs_cnt + media_script_stats.mobile_par_eprs_cnt) as par_eprs_cnt , media_script_stats.advrts_amt,  over_camp_stats.web_advrts_amt, over_camp_stats.mobile_advrts_amt,
    over_camp_stats.tot_advrts_amt, over_camp_stats.bdgt_amt
from
#### left table
	(select
		mcms.*, par_req_cnt.req_cnt
	from
		(SELECT stats_dttm, media_script_no, sum(req_cnt) as req_cnt FROM dreamsearch.ADVRTS_PAR_REQ_MNG 
		where stats_dttm = 20200301
		group by stats_dttm, media_script_no ) as par_req_cnt
	right outer join
		(select
			mcms.*, daily_eprs_cnt.web_par_eprs_cnt, daily_eprs_cnt.mobile_par_eprs_cnt
		from
			(select
				pltfom_eprs_cnt.stats_dttm, pltfom_eprs_cnt.advrts_tp_code, pltfom_eprs_cnt.media_script_no,
				sum(pltfom_eprs_cnt.web_par_eprs_cnt) as web_par_eprs_cnt,
				sum(pltfom_eprs_cnt.mobile_par_eprs_cnt) as mobile_par_eprs_cnt
			from
				(select stats_dttm,advrts_tp_code, media_script_no, 
				case when pltfom_tp_code = '01' then par_eprs_cnt else 0 end as web_par_eprs_cnt,
				case when pltfom_tp_code = '02' then par_eprs_cnt else 0 end as mobile_par_eprs_cnt
				from BILLING.MOB_MEDIA_SCRIPT_STATS 
				where advrts_tp_code = '19' and stats_dttm = 20200301 and itl_tp_code = '01' ) as pltfom_eprs_cnt
				group by pltfom_eprs_cnt.stats_dttm, pltfom_eprs_cnt.media_script_no ) as daily_eprs_cnt
		right outer join
			(SELECT 
				stats_dttm, advrts_prdt_code, pltfom_tp_code, site_code, media_script_no, tot_eprs_cnt, click_cnt, advrts_amt
			FROM 
				BILLING.MOB_CAMP_MEDIA_STATS 
			where  stats_dttm = 20200301 and itl_tp_code = '01' and advrts_tp_code = '19' and advrts_amt > 0) as mcms
		on daily_eprs_cnt.media_script_no = mcms.media_script_no
		and daily_eprs_cnt.stats_dttm = mcms.stats_dttm) as mcms
		on par_req_cnt.media_script_no = mcms.media_script_no
		and par_req_cnt.stats_dttm = mcms.stats_dttm ) as media_script_stats
join
### right table
	( select
		advrts_bdgt_stats.stats_dttm, advrts_bdgt_stats.advrts_prdt_code, advrts_bdgt_stats.site_code, advrts_bdgt_stats.camp_status,
		advrts_bdgt_stats.web_advrts_amt, advrts_bdgt_stats.mobile_advrts_amt, advrts_bdgt_stats.tot_advrts_amt, advrts_bdgt_stats.bdgt_amt
	from
		(select
			tcs.stats_dttm, mcs.advrts_prdt_code, mcs.site_code,tcs.camp_status,mcs.web_advrts_amt, mcs.mobile_advrts_amt, mcs.tot_advrts_amt, tcs.bdgt_amt
		from
			(SELECT 
				stats_dttm, site_code, SUM(PMS_BDGT_AMT) as bdgt_amt,
				case 
					when YEAR(REG_DTTM)* 10000 + MONTH(REG_DTTM)*100 + DAY(REG_DTTM) = STATS_DTTM then 'new'
					when ( YEAR(REG_DTTM)* 10000 + MONTH(REG_DTTM)*100 + DAY(REG_DTTM) <> STATS_DTTM ) and ( YEAR(ALT_DTTM)* 10000 + MONTH(ALT_DTTM)*100 + DAY(ALT_DTTM) = STATS_DTTM ) then 'old_changed'
					else 'old'
				end camp_status 
			FROM BILLING.TIME_CAMP_STATS
			where  BDGT_ULMT_YN='N' and stats_dttm = 20200301 and itl_tp_code = '01' and advrts_tp_code = '19'
			group by  stats_dttm, site_code) as tcs
		join
			(select
				camp_advrt_amt.stats_dttm,camp_advrt_amt.advrts_prdt_code , camp_advrt_amt.site_code,
				sum(camp_advrt_amt.web_advrts_amt) as web_advrts_amt, sum(camp_advrt_amt.mobile_advrts_amt) as mobile_advrts_amt,
				sum(camp_advrt_amt.web_advrts_amt+camp_advrt_amt.mobile_advrts_amt) as tot_advrts_amt
			from
				(select 
				stats_dttm, advrts_prdt_code, site_code,
				case when pltfom_tp_code = '01' then advrts_amt else  0 end as web_advrts_amt,
				case when pltfom_tp_code = '02' then advrts_amt else  0 end as mobile_advrts_amt
				from BILLING.MOB_CAMP_STATS
				where stats_dttm = 20200301 and itl_tp_code = '01' and advrts_tp_code = '19') as camp_advrt_amt
				group by camp_advrt_amt.stats_dttm , camp_advrt_amt.site_code) as mcs
		on tcs.stats_dttm = mcs.stats_dttm
		and tcs.site_code = mcs.site_code ) as advrts_bdgt_stats
	where advrts_bdgt_stats.tot_advrts_amt > advrts_bdgt_stats.bdgt_amt * 1.2 ) as over_camp_stats
on over_camp_stats.site_code = media_script_stats.site_code 
and media_script_stats.stats_dttm = over_camp_stats.stats_dttm 