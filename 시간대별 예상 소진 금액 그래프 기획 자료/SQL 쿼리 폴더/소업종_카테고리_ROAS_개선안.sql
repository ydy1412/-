select
	mchnn.*, mahs.advrts_amt as "해당 시간대에 광고주에서 발생한 소진 금액"
from
( select
  changed_roas_table.CTGR_SEQ,  changed_roas_table.click_hh,
  changed_roas_table.last_click_dttm,  changed_roas_table.pltfom_tp_code, sum(changed_roas_table.ORDER_AMT) as order_amt 
from 
( select CTGR_SEQ, pltfom_tp_code, YEAR(CLICK_DTTM)*10000+month(CLICK_DTTM)*100+day(CLICK_DTTM) as 'last_click_dttm',
 hour(CLICK_DTTM) as click_hh, ORDER_AMT
from BILLING.MOB_CNVRS_HH_NCL_NEW
where CTGR_SEQ = 288 
and YEAR(CLICK_DTTM)*10000 + month(CLICK_DTTM)*100 + day(CLICK_DTTM)= 20200417
and hour(CLICK_DTTM) = 11
and MOB_CNVRS_YN = 'Y'
and site_code <> "" ) as changed_roas_table
group by  changed_roas_table.pltfom_tp_code) as mchnn
join
(SELECT stats_dttm, stats_hh, pltfom_tp_code, CTGR_SEQ,sum(advrts_amt) as advrts_amt FROM BILLING.MOB_CTGR_HH_STATS
where stats_dttm = 20200417
and stats_hh = 11
and CTGR_SEQ = 288
group by stats_dttm, stats_hh, pltfom_tp_code) as mahs
on mchnn.last_click_dttm = mahs.stats_dttm
and mchnn.pltfom_tp_code = mahs.pltfom_tp_code
and mchnn.click_hh = mahs.stats_hh
and mchnn.CTGR_SEQ = mahs.CTGR_SEQ