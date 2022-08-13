# DriverScrew

Check_Records_Before_20210628.m: check whether Omega big table has bug

Fisrt_Spike.m: calculate Omega first spike depth

Omega_fcsv.m and Patamon_fcsv: get fcsv files from 1 to 200 screws

RunDriverUnit.m: read single unit or muti unit channel number from excel

RunRecords.m: read all omega excel records and get screws and depth of every day

RunSelectGoodData.m: define good data as len(SU) > 8 && len(SU)+len(MU) >= 20, return good data date
