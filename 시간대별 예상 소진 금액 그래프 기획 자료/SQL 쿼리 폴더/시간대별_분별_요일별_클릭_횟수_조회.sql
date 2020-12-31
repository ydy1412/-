-- select
--     MAL.SVC_TP_CODE, MAL.ADVRTS_TP_CODE, MAL.day_of_month, MAL.hour, MAL.dayofweek, MAL.hour,
--     MAL.click_minute, SUM(MAL.non_shop_click) as no_shop_click_cnt, SUM(MAL.shop_click) as shop_click_cnt
-- from
-- (
    SELECT ACT_SEQ,
       SVC_TP_CODE,
       ADVRTS_TP_CODE,
       case
          when toDayOfMonth(REG_DTTM) < 10 then 1
          when toDayOfMonth(REG_DTTM) >= 10 and toDayOfMonth(REG_DTTM) < 20 then 2
        else 3
        end as day_of_month,
        toDayOfWeek(REG_DTTM) as dayofweek,
        toHour(REG_DTTM) as hour,
       case
           when toMinute(REG_DTTM) < 10 then 1
           when (toMinute(REG_DTTM) >= 10 and toMinute(REG_DTTM) < 20) then 2
           when (toMinute(REG_DTTM) >= 20 and toMinute(REG_DTTM) < 30) then 3
           when (toMinute(REG_DTTM) >= 30 and toMinute(REG_DTTM) < 40) then 4
           when (toMinute(REG_DTTM) >= 40 and toMinute(REG_DTTM) < 50) then 5
           else 6
           end as click_minute,
       if(PRDT_CODE is null,1,0) as non_shop_click,
       if(PRDT_CODE is not null,1,0) as shop_click
FROM MARIA_BILLING_LIVE_SLAVE.MOB_ACT_LOG
where YYYYMMDD = 20200520
--     ) as MAL
-- group by MAL.SVC_TP_CODE, MAL.ADVRTS_TP_CODE, MAL.day_of_month, MAL.hour, MAL.dayofweek, MAL.hour,
--          MAL.click_minute

