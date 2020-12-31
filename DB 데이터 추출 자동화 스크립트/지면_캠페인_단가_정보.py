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
        al.no as kno,
        al.site_code,
        al.script_no,
        am.acprice, 
        camp_price_info.camp_price
        from
        (select no, site_code, script_no  from dreamsearch.adlink) as al
        join
        (select msno, acprice 
        from dreamsearch.acount_media
        where actype = 'CP') as am 
        join
        (select 
        ads.site_code, 
        if(ads.c_price=0, ap.AD,ads.c_price) as camp_price
        from
        (select 
            site_code,userid, c_price
        from dreamsearch.adsite
        where gubun = 'AD'
        and svc_type = 'banner'
        and RAND() < 0.01
        limit 100 ) as ads
        join
        (select userid, AD
        from dreamsearch.admember_price) as ap
        on ads.userid = ap.userid ) as camp_price_info
        on al.site_code = camp_price_info.site_code
        and al.script_no = am.msno;
    """
    result_list = []
    for i in range(30) :
        result = pd.read_sql(sql, B_db)
        result_list.append(result)
        print(i)

    file_name = project_name + '/media_camp_cost_info.csv'
    pd.concat(result_list).to_csv(file_name, mode='w')
    # 지면별 단가 가중치 정보
    sql_2 = """
    select PAR_SEQ as script_no, ADVRTS_WGHTVAL_VAL 
        from dreamsearch.MEDIA_PAR_DTL_INFO
        where advrts_tp_code = '01'; 
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
    result = pd.read_sql(sql_2, B_db)
    file_name = project_name + '/media_cost_ratio_info.csv'
    result.to_csv(file_name,mode='w')