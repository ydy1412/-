select
	ctgr_hh_table.stats_dttm, ctgr_hh_table.stats_hh,
    sum(order_amt) as order_amt, sum(advrts_amt) as advrts_amt,
    case when CTGR_SEQ = 288 then order_amt else 0 end as "심플 베이직 매출",
    case when CTGR_SEQ = 288 then advrts_amt else 0 end as "심플 베이직 매출"
from
(select
	CTGR_STATS_DATA.stats_dttm,
    CTGR_STATS_DATA.stats_hh,
    CTGR_STATS_DATA.CTGR_SEQ,
    CTGR_INFO.CTGR_NM,
    CTGR_INFO.HIRNK_CTGR_SEQ,
    CTGR_INFO.HIRNK_NM,
    
    CTGR_STATS_DATA.pltfom_tp_code, 
    case when CTGR_STATS_DATA.CTGR_SEQ = 288 then CTGR_STATS_DATA.order_amt else 0 end as "288",
    case when CTGR_STATS_DATA.CTGR_SEQ <> 288 then CTGR_STATS_DATA.order_amt else 0 end as "288x",
    case when CTGR_STATS_DATA.CTGR_SEQ = 288 then CTGR_STATS_DATA.advrts_amt else 0 end as "288",
    case when CTGR_STATS_DATA.CTGR_SEQ <> 288 then CTGR_STATS_DATA.advrts_amt else 0 end as "288x"
from
(
select
	mchs.*,
    case when MCCHS.order_amt is null then 0
    else  MCCHS.order_amt
    end as 'order_amt'
from
(select stats_dttm, stats_hh, pltfom_tp_code,CTGR_SEQ, sum(ORDER_AMT) as order_amt
from BILLING.MOB_CNVRS_HH_NCL_NEW 
where stats_dttm = 20200417
and site_code <> ''
and MOB_CNVRS_YN = 'Y'
group by pltfom_tp_code,CTGR_SEQ
) as MCCHS
right outer join
(
select stats_dttm, stats_hh, CTGR_SEQ, pltfom_tp_code, round(sum(ADVRTS_AMT)) as advrts_amt from BILLING.MOB_CTGR_HH_STATS
where stats_dttm = 20200417
group by stats_dttm, stats_hh, CTGR_SEQ, pltfom_tp_code) as mchs
on MCCHS.stats_dttm = mchs.stats_dttm
and MCCHS.stats_hh = mchs.stats_hh
and MCCHS.CTGR_SEQ = mchs.CTGR_SEQ
and MCCHS.pltfom_tp_code = mchs.pltfom_tp_code
 ) as CTGR_STATS_DATA
join
(
select CTGR_SEQ, CTGR_NM, HIRNK_CTGR_SEQ, ( select CTGR_NM from dreamsearch.MOB_CTGR_INFO where CTGR_SEQ = 75) as HIRNK_NM from
dreamsearch.MOB_CTGR_INFO
where HIRNK_CTGR_SEQ=75 ) as CTGR_INFO
group by ctgr_hh_table.stats_hh, ctgr_hh_table.pltfom_tp_code

