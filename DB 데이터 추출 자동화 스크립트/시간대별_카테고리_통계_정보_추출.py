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
    project_name = base_dir + input('project name : ') + '/'
    try:
        os.mkdir(project_name)
    except:
        print("folder {0} already exist".format(project_name))

    db_password = input("DB password :")

    dr_db = pms.connect(host='192.168.100.108', port=3306, user='dyyang', password=db_password, db='dreamsearch',
                        charset='utf8')
    B_db = pms.connect(host='192.168.100.108', port=3306, user='dyyang', password=db_password, db='BILLING',
                       charset='utf8')
    sql = """
     select
        CTGR_2_stats.stats_dttm,
        CTGR_2_stats.stats_hh,
        CTGR_2_stats.pltfom_tp_code,
        CTGR_2_stats.advrts_prdt_code,
        CTGR_2_stats.CTGR_2,
        sum(CTGR_2_stats.CLICK_CNT ) as CLICK_CNT,
        sum(CTGR_2_stats.TOT_EPRS_CNT ) as TOT_EPRS_CNT
     from
        ( select
            ctgr_stats.*, ctgr_info.CTGR_2
        from
            ( SELECT stats_dttm,
                stats_hh, pltfom_tp_code, advrts_prdt_code,
                CTGR_SEQ, CLICK_CNT, TOT_EPRS_CNT, ( CLICK_CNT / TOT_EPRS_CNT ) as CTR FROM BILLING.MOB_CTGR_HH_STATS
                where pltfom_tp_code = '{2}'
                and stats_hh = '{1}'
                and itl_tp_code = '01'
                and advrts_prdt_code = '01'
                and stats_dttm = {0}) as ctgr_stats
        join
            (select third_depth.CTGR_SEQ_NEW as CTGR_3, third_depth.CTGR_NM as CTGR_3_NAME,
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
                 and USER_TP_CODE = '01' ) as ctgr_info
        on ctgr_stats.CTGR_SEQ = ctgr_info.CTGR_3) as CTGR_2_stats
        group by CTGR_2_stats.CTGR_2
        order by sum(CTGR_2_stats.CLICK_CNT )/sum(CTGR_2_stats.TOT_EPRS_CNT ) desc;
        """

    # Loop property 관련 변수 선언
    dt_index = pd.date_range(start='20200629', end='20200713')
    stats_dttm_list = dt_index.strftime("%Y%m%d").tolist()
    week_list = [i for i in range(1,8)]
    stats_hh_list = ['0{0}'.format(i) if i < 10 else str(i) for i in range(24)]
    advrts_prdt_code_list = ['0{0}'.format(i) for i in range(1, 8)]
    advrts_tp_code_list = [i for i in range(35)]
    advrts_tp_code_list.append(99)
    itl_tp_code_list = [i for i in range(1, 10)]

    itl_tp_code_list.append(99)
    day_of_week_list = [i for i in range(1, 8)]

    for stats_dttm in stats_dttm_list:
        data_list = []
        file_name = project_name + '/CTGR_STATS_{0}.csv'.format(stats_dttm)
        for stats_hh in stats_hh_list :
            for pltfom_tp_code in ['01','02'] :
                try:
                    result = pd.read_sql(sql.format(stats_dttm, stats_hh, pltfom_tp_code), B_db)
                    data_list.append(result)
                    print(stats_dttm,stats_hh, " successe!")
                except:
                    print(stats_dttm,stats_hh, " : query failed")
        pd.concat(data_list).to_csv(file_name, mode='w')
    print("complete")