select
	mchnn.*, mahs.advrts_amt as "해당 시간대에 광고주에서 발생한 소진 금액"
from
( select
  changed_roas_table.*
from 
( select adver_id, pltfom_tp_code, YEAR(CLICK_DTTM)*10000+month(CLICK_DTTM)*100+day(CLICK_DTTM) as 'last_click_dttm', hour(CLICK_DTTM) as click_hh, ORDER_AMT,
stats_dttm as "모비온 광고에 영향을 받은 후 전환이 일어난 일자", stats_hh as "전환이 일어난 시간"  
from BILLING.MOB_CNVRS_HH_NCL_NEW
where adver_id = 'dabagirl' ) as changed_roas_table
order by changed_roas_table.last_click_dttm, changed_roas_table.click_hh ASC ) as mchnn
join
(SELECT
	stats_dttm, stats_hh, pltfom_tp_code, adver_id, sum(advrts_amt) as advrts_amt
FROM BILLING.MOB_ADVER_HH_STATS
where adver_id = 'dabagirl'
group by stats_dttm, stats_hh, adver_id, pltfom_tp_code ) as mahs
on mchnn.last_click_dttm = mahs.stats_dttm
and mchnn.pltfom_tp_code = mahs.pltfom_tp_code
and mchnn.click_hh = mahs.stats_hh limit 10