SELECT * FROM BILLING.MOB_COM_HH_STATS_INFO;
select
campaign_info.site_code, 
campaign_info.userid,
campaign_info.cate,
campaign_info.ADVRTS_PRDT_CODE
, MCC.CODE_ID as 'ADVRTS_TP_CODE'
from
(select site_code, userid, cate, 
gubun,
case svc_type
when 'banner' then '01'
when 'nt' then '07'
end as ADVRTS_PRDT_CODE
from dreamsearch.adsite) as campaign_info
join
(SELECT CODE_ID, CODE_VAL 
FROM dreamsearch.MOBON_COM_CODE 
where CODE_TP_ID = 'ADVRTS_TP_CODE') as MCC
on campaign_info.gubun = MCC.CODE_VAL;

SELECT * FROM dreamsearch.MOBON_COM_CODE;
select distinct svc_type from dreamsearch.adsite;
