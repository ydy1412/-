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

    dr_db = pms.connect(host='192.168.2.81', port=3306, user='dyyang', password=db_password, db='dreamsearch',
                        charset='utf8')
    B_db = pms.connect(host='192.168.2.81', port=3306, user='dyyang', password=db_password, db='BILLING',
                       charset='utf8')
    sql = """
    SELECT 
        stats_dttm, dayofweek(stats_dttm) as "WEEK", stats_hh, pltfom_tp_code, site_code, 
        MEDIA_SCRIPT_NO, adver_id,
        MEDIA_ID,
        TOT_EPRS_CNT, CLICK_CNT  
        FROM 
         BILLING.MOB_CAMP_MEDIA_HH_STATS
        where stats_dttm = {0}
        and stats_hh = '{1}'
        and advrts_prdt_code = '01'
        and advrts_tp_code = '01'
        and itl_tp_code = '01'
        and TOT_EPRS_CNT > 30;
        """

    # Loop property 관련 변수 선언
    dt_index = pd.date_range(start='20200711', end='20200724')
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
        file_name = project_name + '/stats_dttm_{0}.csv'.format(stats_dttm)
        for stats_hh in stats_hh_list :
            try:
                result = pd.read_sql(sql.format(stats_dttm, stats_hh), B_db)
                data_list.append(result)
                print(stats_dttm,stats_hh, " successe!")
            except:
                print(stats_dttm,stats_hh, " : query failed")
        pd.concat(data_list).to_csv(file_name, mode='w')
    print("complete")