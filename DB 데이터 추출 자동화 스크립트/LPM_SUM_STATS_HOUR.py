import pymysql as pms
import pandas as pd
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
        base_dir = 'C:/Users/enliple/Desktop/EDA/분석용 데이터셋'
    project_name = base_dir +'/' + input('Project name : ')
    try :
        os.mkdir(project_name)
    except:
        print("folder {0} already exist".format(project_name))
    db_password = input("DB password :")

    B_db = pms.connect(host='192.168.100.108', port=3306, user='dyyang', password=db_password, db='BILLING',
                       charset='utf8')

    sql = """
    SELECT
            STAT.STATS_DTTM
            , STAT.STATS_HH
            , STAT.SITE_CODE
            , CASE WHEN T2.SCATE='01' THEN '01' WHEN T2.SCATE IN ('10', '13') THEN '13' ELSE '90' END AS MEDIA_CATE_CODE
            , CASE WHEN T2.SCATE IN ('10', '13') THEN '03' ELSE CASE WHEN STAT.PLTFOM_TP_CODE IN ('01','02') THEN STAT.PLTFOM_TP_CODE ELSE '01' END END AS PLTFOM_TP_CODE
            , CASE WHEN T2.SCATE IN ('10', '13') THEN 'App' ELSE CASE WHEN STAT.PLTFOM_TP_CODE='01' THEN 'Web' WHEN STAT.PLTFOM_TP_CODE='02' THEN 'Mobile' ELSE 'None' END END AS DEVICE
            , STAT.ADVRTS_PRDT_CODE
            , STAT.ADVRTS_TP_CODE
            , MCC.CODE_VAL AS TARGETING_NAME
            , STAT.ADVRTS_PRDT_CODE
            , STAT.ITL_TP_CODE
            , STAT.ADVER_ID AS ADVER_ID
            , IFNULL(T1.CTGR_SEQ, 'NONE') AS ADVER_CATE_CODE
            , IFNULL(SUM(STAT.TOT_EPRS_CNT), 0) AS TOT_EPRS_CNT
            , IFNULL(SUM(STAT.PAR_EPRS_CNT), 0) AS PAR_EPRS_CNT
            , IFNULL(SUM(STAT.CLICK_CNT), 0) AS CLICK_CNT
            , IFNULL(SUM(STAT.ADVRTS_AMT), 0) AS ADVRTS_AMT
        FROM BILLING.MOB_CAMP_MEDIA_HH_STATS STAT
        LEFT JOIN (
            SELECT
                asub.USER_ID, CTGR_SEQ, CTGR_NM
            FROM dreamsearch.MOB_CTGR_INFO
            LEFT JOIN (
                SELECT
                    CI.HIRNK_CTGR_SEQ, CUI.USER_ID
                FROM dreamsearch.MOB_CTGR_USER_INFO AS CUI
                LEFT JOIN dreamsearch.MOB_CTGR_INFO AS CI ON (CUI.CTGR_SEQ = CI.CTGR_SEQ)
                LEFT JOIN dreamsearch.MOB_CTGR_INFO AS CIN ON (CI.CTGR_SEQ_NEW = CIN.CTGR_SEQ)
                WHERE
                    CI.CTGR_SEQ IS NOT NULL
                    AND CI.CTGR_NM IS NOT NULL
                    AND CI.CTGR_DEPT = '3'
                GROUP BY CUI.USER_ID
            ) asub ON CTGR_SEQ = asub.HIRNK_CTGR_SEQ
            WHERE CTGR_DEPT=2
        ) T1 ON STAT.ADVER_ID = T1.USER_ID
        LEFT JOIN (
            SELECT
                A.NO, if(B.SCATE IS NULL OR B.SCATE='', '', LPAD(B.SCATE,2,'0')) AS SCATE
            FROM dreamsearch.media_script A
            LEFT JOIN dreamsearch.media_site B ON A.MEDIASITE_NO=B.NO
            LEFT JOIN dreamsearch.MEDIA_PAR_INFO C ON A.no = C.PAR_SEQ
            WHERE
                A.no NOT IN (385761, 385755, 385756)
                OR (
                    C.ADVRTS_PRDT_CODE = '01'
                    AND A.w_type = 'm'
                    AND C.SCRIPT_TP_CODE IN (03, 14)
                )
        ) T2 ON STAT.MEDIA_SCRIPT_NO = T2.NO
        LEFT JOIN dreamsearch.MOBON_COM_CODE MCC ON STAT.ADVRTS_TP_CODE=MCC.CODE_ID AND CODE_TP_ID='ADVRTS_TP_CODE'
        WHERE
            STAT.STATS_DTTM = {0}
            AND STAT.STATS_HH = '{1}'
            AND STAT.ADVRTS_PRDT_CODE = '01'
            AND STAT.ITL_TP_CODE IN ('01')
            AND STAT.ADVRTS_TP_CODE IN ('01')
            AND T2.SCATE IN ('01', '02', '03', '04', '06', '10', '13', '14', '15')
        GROUP BY
            STATS_DTTM, SITE_CODE, MEDIA_CATE_CODE, PLTFOM_TP_CODE, ADVRTS_TP_CODE, ADVRTS_PRDT_CODE, ITL_TP_CODE, ADVER_ID;
    """
    dt_index = pd.date_range(start='20200909', end='20200923')
    dt_list = dt_index.strftime("%Y%m%d").tolist()
    advrts_prdt_code_list = ['0{0}'.format(i) for i in range(1, 8)]
    advrts_tp_code_list = [i for i in range(35)]
    advrts_tp_code_list.append(99)
    itl_tp_code_list = [i for i in range(1, 10)]
    itl_tp_code_list.append(99)
    day_of_week_list = [i for i in range(1, 8)]
    stats_hh_list =  ['0{0}'.format(i) if i < 10 else str(i) for i in range(0,24) ]
    print(dt_list[0][4:6])
    for date in dt_list:
        data_list = []
        for stats_hh in stats_hh_list :
            try:
                result = pd.read_sql(sql.format(date,stats_hh), B_db)
                data_list.append(result)
                print(date,stats_hh, " successe!")
            except:
                print(date,stats_hh, " : query failed")
        file_name = project_name + '/LPM_DATA_{0}.csv'.format(date)
        pd.concat(data_list).to_csv(file_name, mode='w')