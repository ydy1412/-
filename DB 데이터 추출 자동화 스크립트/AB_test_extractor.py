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
        SELECT * 
        FROM BILLING.AB_COM_STATS
        where 1=1
        and AB_TEST_TY like 'C%'
        and STATS_DTTM >= 20200401
        and STATS_DTTM <= 20200501;
        """

    # Loop property 관련 변수 선언
    dt_index = pd.date_range(start='20200710', end='20200713')
    stats_dttm_list = dt_index.strftime("%Y%m%d").tolist()
    week_list = [i for i in range(1,8)]
    stats_hh_list = ['0{0}'.format(i) if i < 10 else str(i) for i in range(24)]
    advrts_prdt_code_list = ['0{0}'.format(i) for i in range(1, 8)]
    advrts_tp_code_list = ['0{0}'.format(i) if i < 10 else str(i) for i in range(35)]
    advrts_tp_code_list.append('99')
    itl_tp_code_list = [i for i in range(1, 10)]

    itl_tp_code_list.append(99)
    day_of_week_list = [i for i in range(1, 8)]

    result = pd.read_sql(sql, B_db)
    file_name = project_name + '/AB_test_20200401_20200501.csv'
    result.to_csv(file_name, mode='w')
    print("success")