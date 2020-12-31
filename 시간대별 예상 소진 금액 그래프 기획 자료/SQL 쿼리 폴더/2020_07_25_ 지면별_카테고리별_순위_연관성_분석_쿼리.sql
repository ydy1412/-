SELECT 
stats_dttm, dayofweek(stats_dttm) as "WEEK", stats_hh, pltfom_tp_code, site_code, 
MEDIA_SCRIPT_NO, adver_id,
MEDIA_ID,
TOT_EPRS_CNT, CLICK_CNT  
FROM 
 BILLING.MOB_CAMP_MEDIA_HH_STATS
where stats_dttm = 20200711
and stats_hh = '11'
and advrts_prdt_code = '01'
and advrts_tp_code = '01'
and itl_tp_code = '01'
and TOT_EPRS_CNT > 30;


# 매체 정보 추출 쿼리
SELECT * FROM dreamsearch.media_site;

# 지면 상태 정보 추출 쿼리
-- select * from dreamsearch.media_script;

# 캠페인 정보 추출 쿼리
select site_code, userid, kpi_no, cate, gubun, svc_type 
from dreamsearch.adsite;

# 지면 정보 추출 쿼리
select 
	*
from dreamsearch.PAR_PRDT_MGMT;
-- where 1=1
-- and advrts_prdt_code = '01';

# TP_CODE 매핑 정보 추출 쿼리
SELECT CODE_TP_ID, CODE_ID, CODE_VAL, CODE_DESC
FROM dreamsearch.MOBON_COM_CODE;

# 광고주 카테고리 3,2,1차 카테고리 매핑 쿼리
   select third_depth.CTGR_SEQ_NEW as CTGR_3, third_depth.CTGR_NM as CTGR_3_NAME,
     second_depth.CTGR_SEQ_NEW as CTGR_2, second_depth.CTGR_NM as CTGR_2_NAME,
     second_depth.HIRNK_CTGR_SEQ as CTGR_1,first_depth.CTGR_NM as CTGR_1_NAME
    from 
    (select USER_TP_CODE, CTGR_SEQ_NEW, HIRNK_CTGR_SEQ, CTGR_NM from dreamsearch.MOB_CTGR_INFO where CTGR_DEPT = 3) as third_depth
    join
    (select CTGR_SEQ_NEW, HIRNK_CTGR_SEQ,CTGR_NM from dreamsearch.MOB_CTGR_INFO where CTGR_DEPT = 2 ) as second_depth
    join
    (select CTGR_SEQ_NEW, HIRNK_CTGR_SEQ,CTGR_NM from dreamsearch.MOB_CTGR_INFO where CTGR_DEPT = 1 ) as first_depth
    on third_depth.HIRNK_CTGR_SEQ = second_depth.CTGR_SEQ_NEW
    and first_depth.CTGR_SEQ_NEW = second_depth.HIRNK_CTGR_SEQ
    and USER_TP_CODE = '01';

# 매체 카테고리 3,2,1차 카테고리 매핑 쿼리.
select 
third_depth.CTGR_SEQ_NEW as CTGR_3, third_depth.CTGR_NM as CTGR_3_NAME,
 second_depth.CTGR_SEQ_NEW as CTGR_2, second_depth.CTGR_NM as CTGR_2_NAME,
 second_depth.HIRNK_CTGR_SEQ as CTGR_1
from 
(select CTGR_SEQ_NEW, HIRNK_CTGR_SEQ, CTGR_NM from dreamsearch.MOB_CTGR_INFO 
where CTGR_DEPT = 2
and USER_TP_CODE = '02'
) as third_depth
join
(select CTGR_SEQ_NEW, HIRNK_CTGR_SEQ, CTGR_NM from dreamsearch.MOB_CTGR_INFO 
where CTGR_DEPT = 1
and USER_TP_CODE = '02' ) as second_depth
on third_depth.HIRNK_CTGR_SEQ = second_depth.CTGR_SEQ_NEW;

select userid, cate from dreamsearch.admember
where cate <> '';

select * from dreamsearch.MOB_CTGR_INFO;