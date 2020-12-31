select
    MAL.SVC_TP_CODE, MAL.ADVRTS_TP_CODE,
--        MAL.day_of_month, MAL.hour, MAL.dayofweek, MAL.hour,
--     MAL.click_minute,
    SUM(MAL.non_shop_click) as no_shop_click_cnt, SUM(MAL.shop_click) as shop_click_cnt
from
(
    SELECT ACT_SEQ,
       SVC_TP_CODE,
       ADVRTS_TP_CODE,
       if(PRDT_CODE is null,1,0) as non_shop_click,
       if(PRDT_CODE is not null,1,0) as shop_click
FROM MARIA_BILLING_LIVE_SLAVE.MOB_ACT_LOG
where YYYYMMDD >= 20200501
    ) as MAL
group by MAL.SVC_TP_CODE, MAL.ADVRTS_TP_CODE

