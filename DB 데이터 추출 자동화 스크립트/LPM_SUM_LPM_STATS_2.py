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
    pltfom_tp_code_list = result[result['CODE_TP_ID']=='PLTFOM_TP_CODE']['CODE_ID']
    advrts_prdt_code_list = result[result['CODE_TP_ID']=='ADVRTS_PRDT_CODE']['CODE_ID']
    advrts_tp_code_list = result[result['CODE_TP_ID']=='ADVRTS_TP_CODE']['CODE_ID']
    itl_tp_code_list = result[result['CODE_TP_ID']=='ITL_TP_CODE']['CODE_ID']

    sql = """
    SELECT STATS_MTH, PLTFOM_TP_CODE,
        ADVRTS_PRDT_CODE,
        ADVRTS_TP_CODE,
        SITE_CODE,
        MEDIA_PAR_NO, 
        ITl_TP_CODE,
        ADVER_ID,
        MEDIA_ID,
        TOT_EPRS_CNT,
        PAR_EPRS_CNT,
        CLICK_CNT,
        ADVRTS_AMT,
        MEDIA_PYMNT_AMT
    FROM BILLING.MOB_CAMP_PAR_MTH_STATS
    WHERE STATS_MTH = {0}
        and pltfom_tp_code='{1}'
        and advrts_prdt_code = '{2}'
        and advrts_tp_code = '{3}'
        and itl_tp_code = '{4}';
    """

    month_index = pd.date_range(start='20190101', end='20191231',freq='M')
    month_list = month_index.strftime("%Y%m").tolist()
    # dt_list = dt_index.strftime("%Y%m%d").tolist()
    day_of_week_list = [i for i in range(1, 8)]
    data_list = []

    for STATS_MTH in month_list:
        for pltfom_tp_code in pltfom_tp_code_list :
            for advrts_prdt_code in advrts_prdt_code_list :
                for advrts_tp_code in advrts_tp_code_list :
                    for itl_tp_code in itl_tp_code_list :
                        try:
                            result = pd.read_sql(sql.format(STATS_MTH, pltfom_tp_code,
                                                            advrts_prdt_code, advrts_tp_code, itl_tp_code), B_db)
                            file_name = project_name + '/MOB_CAMP_PAR_MTH_STATS_{0}_{1}_{2}_{3}_{4}.csv'.format(STATS_MTH, pltfom_tp_code,
                                                                                                                advrts_prdt_code, advrts_tp_code,itl_tp_code)
                            if result.shape[0] == 0 :
                                continue
                            result.to_csv(file_name,mode='w')
                            print(STATS_MTH,pltfom_tp_code, advrts_prdt_code,advrts_tp_code,itl_tp_code, " successe!")
                        except:
                            B_db = pms.connect(host='192.168.100.108', port=3306, user='dyyang', password=db_password,
                                               db='BILLING',
                                               charset='utf8')
                            print(STATS_MTH,pltfom_tp_code, advrts_prdt_code,advrts_tp_code,itl_tp_code, " : query failed")


