# DB ip : 192.168.2.81
# DB name : billing
# 운영 DB

-- used table
-- SELECT * FROM BILLING.MOB_CAMP_HH_STATS LIMIT 10 ;

SELECT 
		stats_dttm, pltfom_tp_code, advrts_prdt_code, site_code, hh_no, itl_tp_code,
	case 
		when (minute(REG_DTTM) >= 0 and minute(REG_DTTM) < 10) then 10
		when (minute(REG_DTTM) >= 10 and minute(REG_DTTM) < 20) then 20
		when (minute(REG_DTTM) >= 20 and minute(REG_DTTM) < 30) then 30
		when (minute(REG_DTTM) >= 30 and minute(REG_DTTM) < 40) then 40
		when (minute(REG_DTTM) >= 40 and minute(REG_DTTM) < 50) then 50
		else 60
	end as stop_time  
FROM BILLING.TIME_CAMP_EXHS_STATS 
where stats_dttm = 20200202