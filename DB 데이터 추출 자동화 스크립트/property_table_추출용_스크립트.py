import pymysql as pms
import pandas as pd
import numpy as np
import os
import sys
import time
import pickle as pkl
import datetime

if __name__ == "__main__":
    os_dir = input('base dir [1 : change] : ')
    if os_dir == '1':
        base_dir = input('os_dir : ')
    else:
        base_dir = 'C:/Users/enliple/Desktop/EDA/분석용 데이터셋/'
        property_table_dir = "C:/Users/enliple/Desktop/EDA/분석용 데이터셋/Property table/"
    project_name = base_dir + input('project name : ')
    try:
        os.mkdir(project_name)
    except:
        print("folder {0} already exist".format(project_name))

    db_password = input("DB password :")

    B_db = pms.connect(host='192.168.100.108', port=3306, user='dyyang', password=db_password, db='dreamsearch',
                       charset='utf8')

    PAR_PROPERTY_INFO_sql = """
    select 
        ms.no as media_script_no,
        mediasite_no,
        ms.userid,
        case when w_type='w' then '01'
        when w_type='m' then '02'
        end as "PLTFOM_TP_CODE",
        mpi.script_tp_code,
        mpi.MEDIA_SIZE_CODE,
        product_type "엔딩 구분",
        s_type as "지면 구분 (배너/플로팅/토스트)",
        m_bacon_yn as "바콘 사용 여부",
        PAR_SORT_TP_CODE as "PAR_SORT_TP_CODE",
        ADVRTS_STLE_TP_CODE as "ADVRTS_STLE_TP_CODE",
        media_cate_info.scate as "카테고리 매핑 번호",
        media_cate_info.ctgr_nm as "카테고리 매핑 이름"
        from dreamsearch.media_script as ms
        join
        (
        SELECT no, userid, scate, ctgr_nm
        FROM dreamsearch.media_site as ms
        join
        (SELECT mpci.CTGR_SEQ, CTGR_SORT_NO, mci.CTGR_NM
        FROM dreamsearch.MEDIA_PAR_CTGR_INFO as mpci
        join dreamsearch.MOB_CTGR_INFO as mci
        on mpci.CTGR_SEQ = mci.CTGR_SEQ_NEW) as media_ctgr_info
        on ms.scate = media_ctgr_info.CTGR_SORT_NO) as media_cate_info
        join
        (select PAR_SEQ, ADVRTS_PRDT_CODE,SCRIPT_TP_CODE, MEDIA_SIZE_CODE 
        from dreamsearch.MEDIA_PAR_INFO
        where PAR_EVLT_TP_CODE ='04') as mpi
        on ms.mediasite_no = media_cate_info.no
        and media_cate_info.scate = {0}
        and mpi.par_seq = ms.no;
    """
    result_list = []
    for i in range(1, 18):
        result = pd.read_sql(PAR_PROPERTY_INFO_sql.format(i), B_db)
        result_list.append(result)
        print('PAR_PROPERTY_INFO_sql ', i)
    pd.concat(result_list).to_csv(property_table_dir + "PAR_PROPERTY_INFO.csv", mode='w')
    print("PAR_PROPERTY_INFO completed")

    SCRIPT_TP_sql = """
    select 
        case when CODE_TP_ID = 'SCRIPT_TP_CODE' then CODE_ID
        else 0 
        end as 'SCRIPT_TP_CODE',CODE_VAL,CODE_DESC
        from dreamsearch.MOBON_COM_CODE
        where 1=1
        and CODE_TP_ID= 'SCRIPT_TP_CODE';
    """
    result = pd.read_sql(SCRIPT_TP_sql, B_db)
    result.to_csv(property_table_dir + "SCRIPT_TP_INFO.csv", mode='w')

    print("SCRIPT_TP_INFO completed")

    MEDIA_SIZE_sql = """
        select 
            case when CODE_TP_ID = 'MEDIA_SIZE_CODE' then CODE_ID
            else 0 
            end as 'MEDIA_SIZE_CODE',CODE_VAL,CODE_DESC
            from dreamsearch.MOBON_COM_CODE
            where 1=1
            and CODE_TP_ID= 'MEDIA_SIZE_CODE'
            and CODE_VAL <> 'mangolife'
            and CODE_VAL <> "이미지없음";
        """
    result = pd.read_sql(MEDIA_SIZE_sql, B_db)
    result.to_csv(property_table_dir + "MEDIA_SIZE_INFO.csv", mode='w')

    print("MEDIA_SIZE_INFO completed")

    ADVER_CTGR_INFO_sql = """
        SELECT distinct ADVER_ID, ADVER_CATE_CODE 
        FROM BILLING.MOB_CAMP_ECPM_STATS;
     """
    result = pd.read_sql(ADVER_CTGR_INFO_sql, B_db)
    result.to_csv(property_table_dir + "ADVER_CTGR_INFO.csv", mode='w')

    print("ADVER_CTGR_INFO_sql completed")

    MOBON_COM_CODE_sql = """
     SELECT CODE_TP_ID, CODE_ID, CODE_VAL, CODE_DESC
     FROM dreamsearch.MOBON_COM_CODE;
     """
    result = pd.read_sql(MOBON_COM_CODE_sql, B_db)
    result.to_csv(property_table_dir + "MOBON_COM_CODE.csv", mode='w')

    print("MOBON_COM_CODE_sql completed")
    #
    # ADSITE_sql = """
    #      select site_code, userid, kpi_no, cate, gubun, svc_type
    #      from dreamsearch.adsite;
    #      """
    # result = pd.read_sql(ADSITE_sql, B_db)
    # result.to_csv(property_table_dir + "ADSITE_INFO.csv", mode='w')

    # print("ADSITE_sql completed")

    # AD_CATE_INFO_sql = """
    # select
    #     userid,
    #     gubun,
    #     case gubun
    #         when 11 then "광고주"
    #         when 12 then "파트너"
    #         when 13 then "매체"
    #     end as user_type, cate
    # from dreamsearch.admember;
    # """
    # result = pd.read_sql(AD_CATE_INFO_sql, B_db)
    # result.to_csv(property_table_dir + "AD_CATE_INFO.csv", mode='w')

    print("complete!")