SELECT * FROM BILLING.MOB_COM_HH_STATS_INFO;
select
campaign_info.site_code, 
campaign_info.userid,
campaign_info.cate as CTGR_3,
campaign_info.CTGR_2,
campaign_info.CTGR_1,
campaign_info.ADVRTS_PRDT_CODE
, MCC.CODE_ID as 'ADVRTS_TP_CODE'
from
(select
campaign_data.*, ctgr_info.CTGR_2, ctgr_info.CTGR_1
from
(select site_code, userid, cate, 
gubun,
case svc_type
when 'banner' then '01'
when 'nt' then '07'
end as ADVRTS_PRDT_CODE
from dreamsearch.adsite 
where userid = 'varram'
and KPI_NO = '3453'
) as campaign_data
join
(select third_depth.CTGR_SEQ_NEW as CTGR_3, second_depth.CTGR_SEQ_NEW as CTGR_2, second_depth.HIRNK_CTGR_SEQ as CTGR_1
from 
(select CTGR_SEQ_NEW, HIRNK_CTGR_SEQ from dreamsearch.MOB_CTGR_INFO where CTGR_DEPT = 3) as third_depth
join
(select CTGR_SEQ_NEW, HIRNK_CTGR_SEQ from dreamsearch.MOB_CTGR_INFO where CTGR_DEPT = 2 ) as second_depth
on third_depth.HIRNK_CTGR_SEQ = second_depth.CTGR_SEQ_NEW ) as ctgr_info
on campaign_data.cate = ctgr_info.CTGR_3) as campaign_info
join
(SELECT CODE_ID, CODE_VAL 
FROM dreamsearch.MOBON_COM_CODE 
where CODE_TP_ID = 'ADVRTS_TP_CODE') as MCC
on campaign_info.gubun = MCC.CODE_VAL;

### iadsite sql 쿼리
select
campaign_info.site_code, 
campaign_info.userid,
campaign_info.cate as CTGR_3,
campaign_info.CTGR_2,
campaign_info.CTGR_1,
campaign_info.ADVRTS_PRDT_CODE
, MCC.CODE_ID as 'ADVRTS_TP_CODE'
from
(select
campaign_data.*, ctgr_info.CTGR_2, ctgr_info.CTGR_1
from
(select site_code, userid, cate, 
gubun,
case svc_type
when '' then '03'
when 'sky' then '02'
when 'scn' then '04'
when 'pl' then '06'
when 'scm' then '04'
end as ADVRTS_PRDT_CODE
from dreamsearch.iadsite 
where userid = 'varram'
and KPI_NO = '3453'
) as campaign_data
join
(select third_depth.CTGR_SEQ_NEW as CTGR_3, second_depth.CTGR_SEQ_NEW as CTGR_2, second_depth.HIRNK_CTGR_SEQ as CTGR_1
from 
(select CTGR_SEQ_NEW, HIRNK_CTGR_SEQ from dreamsearch.MOB_CTGR_INFO where CTGR_DEPT = 3) as third_depth
join
(select CTGR_SEQ_NEW, HIRNK_CTGR_SEQ from dreamsearch.MOB_CTGR_INFO where CTGR_DEPT = 2 ) as second_depth
on third_depth.HIRNK_CTGR_SEQ = second_depth.CTGR_SEQ_NEW ) as ctgr_info
on campaign_data.cate = ctgr_info.CTGR_3) as campaign_info
join
(SELECT CODE_ID, CODE_VAL 
FROM dreamsearch.MOBON_COM_CODE 
where CODE_TP_ID = 'ADVRTS_TP_CODE') as MCC
on campaign_info.gubun = MCC.CODE_VAL;

SELECT * FROM dreamsearch.MOBON_COM_CODE;
select distinct svc_type from dreamsearch.iadsite;
