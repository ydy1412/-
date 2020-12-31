select
	over_exhs_tb.stats_dttm,mcms.advrts_tp_code, mcms.advrts_prdt_code, 
    over_exhs_tb.site_code,over_exhs_tb.itl_tp_code, over_exhs_tb.advrts_amt,
    over_exhs_tb.bdgt_amt, over_exhs_tb.over_exhs_amt, over_exhs_tb.BDGT_DSTB_TP_CODE, over_exhs_tb.REG_DTTM,over_exhs_tb.ALT_DTTM,
    mcms.media_script_no, mcms.tot_eprs_cnt, mcms.click_cnt, mcms.advrts_amt
from 
(select
	over_exhs_tb.stats_dttm,over_exhs_tb.REG_DTTM, over_exhs_tb.ALT_DTTM, over_exhs_tb.site_code, over_exhs_tb.itl_tp_code, 
    over_exhs_tb.bdgt_amt, over_exhs_tb.advrts_amt, over_exhs_tb.over_exhs_amt,over_exhs_tb.BDGT_DSTB_TP_CODE
from 
(
select
	tcs.stats_dttm, tcs.site_code, tcs.itl_tp_code,tcs.bdgt_amt, mcs.advrts_amt, ( tcs.bdgt_amt - mcs.advrts_amt ) / tcs.bdgt_amt * 100 as over_exhs_amt ,tcs.BDGT_DSTB_TP_CODE,
    YEAR(tcs.REG_DTTM) * 10000 + MONTH(tcs.REG_DTTM)* 100 + day(tcs.REG_DTTM) as REG_DTTM,
    YEAR(tcs.ALT_DTTM) * 10000 + MONTH(tcs.ALT_DTTM)* 100 + day(tcs.ALT_DTTM) as ALT_DTTM
    
from
(SELECT 
	stats_dttm, site_code, ITL_TP_CODE,sum(PMS_BDGT_AMT) as bdgt_amt, BDGT_DSTB_TP_CODE,REG_DTTM,
    ALT_DTTM
FROM BILLING.TIME_CAMP_STATS
where stats_dttm =  20200401
and BDGT_ULMT_YN = 'N'
and itl_tp_code = '01'
and PMS_BDGT_AMT >= 100 
group by stats_dttm , site_code) as tcs
join
(select stats_dttm, site_code, itl_tp_code, sum(ADVRTS_AMT) as advrts_amt from  BILLING.MOB_CAMP_STATS
where itl_tp_code = '01'
and stats_dttm = 20200401
group by stats_dttm, site_code) as mcs
on tcs.stats_dttm = mcs.stats_dttm
and tcs.site_code = mcs.site_code 
) as over_exhs_tb
where over_exhs_tb.over_exhs_amt <= -100 limit 10 ) as over_exhs_tb
join
(SELECT stats_dttm, advrts_prdt_code, advrts_tp_code,  site_code, itl_tp_code, media_script_no, tot_eprs_cnt, click_cnt, advrts_amt FROM BILLING.MOB_CAMP_MEDIA_STATS
where stats_dttm = 20200401
and itl_tp_code = '01' ) as mcms
on over_exhs_tb.stats_dttm = mcms.stats_dttm
and over_exhs_tb.site_code = mcms.site_code
where mcms.advrts_amt > 0
-- select 