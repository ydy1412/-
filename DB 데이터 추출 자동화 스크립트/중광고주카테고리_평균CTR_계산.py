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
    select 
    WEEK, STATS_HH, pltfom_tp_code, itl_tp_code, advrts_prdt_code,
    advrts_tp_code, adver_id, AVG_CTR
     from BILLING.TIME_CAMP_HH_CTR_STATS
    where advrts_prdt_code <> '03' and advrts_tp_code ='01'
    and AVG_CTR <> 0
    and AVG_CTR < 50
    and TOT_EPRS_CNT >30;
    """
    dt_index = pd.date_range(start='20200510', end='20200520')
    dt_list = dt_index.strftime("%Y%m%d").tolist()
    advrts_prdt_code_list = ['0{0}'.format(i) for i in range(1, 8)]
    advrts_tp_code_list = [i for i in range(35)]
    advrts_tp_code_list.append(99)
    itl_tp_code_list = [i for i in range(1, 10)]
    itl_tp_code_list.append(99)
    day_of_week_list = [i for i in range(1, 8)]
    print(dt_list[0][4:6])
    result = pd.read_sql(sql, B_db).to_csv(project_name +'/요일별_CTR.csv',mode='w')
