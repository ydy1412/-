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
        base_dir = 'D:/데이터셋 저장 폴더'
    project_name = base_dir +'/' + input('Project name : ')
    try :
        os.mkdir(project_name)
    except:
        print("folder {0} already exist".format(project_name))
    db_password = input("DB password :")

    dr_db = pms.connect(host='192.168.2.81', port=3306, user='dyyang', password=db_password, db='dreamsearch',
                        charset='utf8')
    B_db = pms.connect(host='192.168.2.81', port=3306, user='dyyang', password=db_password, db='BILLING',
                       charset='utf8')
    shop_db = pms.connect(host='192.168.2.58', port=3306, user='dyyang', password=db_password, db='dreamsearch',
                          charset='utf8')
    sql = """
    SELECT NO, USERID, PCODE, PRICE 
    FROM dreamsearch.MOB_SHOP_DATA
    where NO >= {0}
    order by NO asc
    limit {1}
        """
    dt_index = pd.date_range(start='20200505', end='20200526')
    dt_list = dt_index.strftime("%Y%m%d").tolist()
    advrts_prdt_code_list = ['0{0}'.format(i) for i in range(1, 8)]
    advrts_tp_code_list = [i for i in range(35)]
    advrts_tp_code_list.append(99)
    itl_tp_code_list = [i for i in range(1, 10)]
    itl_tp_code_list.append(99)
    day_of_week_list = [i for i in range(1, 8)]
    initial_no = 33216930579
    i = 10000
    seq = 5701
    max_no = 33417240911
    temp_list = []
    log_file_name = project_name + "/MOB_SHOP_DATA_{0}.csv"
    while initial_no <= max_no:
        print(initial_no)
        try:
            result = pd.read_sql(sql.format(initial_no, i), shop_db)
            initial_no = result.NO.max()+1
            seq += 1
            temp_list.append(result)
            print(seq)
        except:
            print(initial_no, " : query failed")
        time.sleep(2)
        if seq % 100 == 0:
            pd.concat(temp_list).to_csv(log_file_name.format(seq), mode='w')
            temp_list = []
            print(seq, "file saved successe!")