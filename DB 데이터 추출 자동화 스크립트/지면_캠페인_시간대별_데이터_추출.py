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
        base_dir = 'C:/Users/enliple/Desktop/EDA/분석용 데이터셋/'
    project_name = base_dir +'/' + input('Project name : ')
    start_dttm = input("start dttm :")
    last_dttm = input("last dttm : ")
    try :
        os.mkdir(project_name)
    except:
        print("folder {0} already exist".format(project_name))
    db_password = input("DB password :")

    B_db = pms.connect(host='192.168.100.108', port=3306, user='dyyang', password=db_password, db='dreamsearch',
                       charset='utf8')
    sql = """
    select stats_dttm,
        stats_hh,
        pltfom_tp_code,
        advrts_prdt_code,
        advrts_tp_code,
        media_script_no,
        adver_id,
        tot_eprs_cnt,
        par_eprs_cnt,
        click_cnt
        from BILLING.MOB_CAMP_MEDIA_STATS 
        where stats_dttm = {0}
        and advrts_prdt_code = '01'
        and advrts_tp_code = '01'
        and click_cnt > 0
        and stats_hh = {1}
        and tot_eprs_cnt > click_cnt;
    """
    dt_index = pd.date_range(start=start_dttm, end=last_dttm)
    dt_list = dt_index.strftime("%Y%m%d").tolist()
    advrts_prdt_code_list = ['0{0}'.format(i) for i in range(1, 8)]
    advrts_tp_code_list  = []
    for i in range(1,35) :
        if i < 10 :
            advrts_tp_code_list.append('0{0}'.format(i))
        else :
            advrts_tp_code_list.append('{0}'.format(i))
    advrts_tp_code_list.append('99')
    itl_tp_code_list = [i for i in range(1, 10)]
    itl_tp_code_list.append(99)
    day_of_week_list = [i for i in range(1, 8)]
    print(dt_list)
    for date in dt_list:
        data_list = []
        for stats_hh in range(0,24) :
            try:
                result = pd.read_sql(sql.format(date,stats_hh), B_db)
                data_list.append(result)
                print(date,stats_hh, " successe!")
            except:
                print(date,stats_hh, " : query failed")
        file_name = project_name + '/ms_stats_new_{0}.csv'.format(date)
        pd.concat(data_list).to_csv(file_name, mode='w')