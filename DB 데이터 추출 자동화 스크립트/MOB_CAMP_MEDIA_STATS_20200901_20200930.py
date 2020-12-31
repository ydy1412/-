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

    MOBON_COM_CODE_sql = """
    SELECT CODE_TP_ID, CODE_ID, CODE_VAL, CODE_DESC
    FROM dreamsearch.MOBON_COM_CODE
    """
    result = pd.read_sql(MOBON_COM_CODE_sql, B_db)
    advrts_prdt_code_list = result[result['CODE_TP_ID']=='ADVRTS_PRDT_CODE']['CODE_ID']
    advrts_tp_code_list = result[result['CODE_TP_ID']=='ADVRTS_TP_CODE']['CODE_ID']
    itl_tp_code_list = result[result['CODE_TP_ID']=='ITL_TP_CODE']['CODE_ID']

    sql = """
    SELECT STATS_DTTM, PLTFOM_TP_CODE, ADVRTS_PRDT_CODE, ADVRTS_TP_CODE,
    SITE_CODE, MEDIA_SCRIPT_NO, TOT_EPRS_CNT, PAR_EPRS_CNT, CLICK_CNT, 
    ADVRTS_AMT, MEDIA_PYMNT_AMT FROM BILLING.MOB_CAMP_MEDIA_STATS
    where itl_tp_code = '03'
    and ADVRTS_PRDT_CODE ='01'
    and STATS_DTTM = {0}
    and PLTFOM_TP_CODE = '{1}';
    """

    dt_index = pd.date_range(start='20200901', end='20200930')
    dt_list = dt_index.strftime("%Y%m%d").tolist()
    day_of_week_list = [i for i in range(1, 8)]
    print(dt_list[0][4:6])
    for date in dt_list:
        data_list = []
        for pltfom_tp_code in ['01','02'] :
            try:
                result = pd.read_sql(sql.format(date,pltfom_tp_code), B_db)
                data_list.append(result)
                print(date,pltfom_tp_code, " successe!")
            except:
                print(date,pltfom_tp_code, " : query failed")
        file_name = project_name + '/MOB_CAMP_MEDIA_STATS_{0}.csv'.format(date)
        pd.concat(data_list).to_csv(file_name, mode='w')