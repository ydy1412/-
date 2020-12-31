import os

import pandas as pd
import pymysql as pms

if __name__ == "__main__":
    os_dir = input('base dir [1 : change] : ')
    if os_dir == '1':
        base_dir = input('os_dir : ')
    else:
        base_dir = 'C:/Users/enliple/Desktop/EDA/분석용 데이터셋'
    project_name = base_dir + '/' + input('Project name : ')
    try:
        os.mkdir(project_name)
    except:
        print("folder {0} already exist".format(project_name))
    db_password = input("DB password :")

    dr_db = pms.connect(host='192.168.100.108', port=3306, user='dyyang', password=db_password, db='dreamsearch',
                        charset='utf8')
    B_db = pms.connect(host='192.168.100.108', port=3306, user='dyyang', password=db_password, db='BILLING',
                       charset='utf8')
    # shop_db = pms.connect(host='192.168.100.108', port=3306, user='dyyang', password=db_password, db='dreamsearch',
    #                       charset='utf8')
    sql = """
    select 
    stats_dttm, stats_hh, pltfom_tp_code, advrts_prdt_code, advrts_tp_code,
    site_code, tot_eprs_cnt, click_cnt, click_cnt/tot_eprs_cnt as ctr
     from BILLING.MOB_CAMP_HH_STATS
    where advrts_prdt_code = '01'
    and stats_dttm = {0}
    and itl_tp_code = '01'
    and tot_eprs_cnt > 0;
    """
    dt_index = pd.date_range(start='20200710', end='20200801')
    dt_list = dt_index.strftime("%Y%m%d").tolist()
    advrts_prdt_code_list = ['0{0}'.format(i) for i in range(1, 8)]
    advrts_tp_code_list = [i for i in range(35)]
    advrts_tp_code_list.append(99)
    itl_tp_code_list = [i for i in range(1, 10)]
    itl_tp_code_list.append(99)
    day_of_week_list = [i for i in range(1, 8)]
    print(dt_list[0][4:6])
    for date in dt_list:
        data_list = []
        try:
            result = pd.read_sql(sql.format(date), B_db)
            data_list.append(result)
            print(date, " successe!")
        except:
            print(date, " : query failed")
        file_name = project_name + '/camp_hh_stats_{0}.csv'.format(date)
        pd.concat(data_list).to_csv(file_name, mode='w')
