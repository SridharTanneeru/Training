@Maximo-APIDB
Feature: 
	Connect to Maximo DB and return the WO value for the top record

Background:
        # use jdbc to validate
		* def config = { username: 'maximo_ro', password: 'maximo_ro', url: 'jdbc:oracle:thin:@//oradb-az01:1521/YVWMXTST', driverClassName: 'oracle.jdbc.OracleDriver' }
		* def DbUtils = Java.type('utils.DBUtils')
		* def db = new DbUtils(config)

        Scenario: Connect to DB and retrieve WO number 
		
		* def relType = 'FOLLOWUP'
		* def app = 'APPR'
		* def query = db.readRows('select wo.wonum from maximo.workorder wo inner join maximo.relatedrecord rr on wo.wonum = rr.recordkey and wo.wonum not in (select recordkey from maximo.relatedrecord where relatetype =' + "'" + relType + "'" + ') and Status = ' + "'" + app + "'" + ' order by wo.changedate desc')
		* def woNum = query[0].WONUM.toString() 
		* print 'wo number from the DB is ', woNum