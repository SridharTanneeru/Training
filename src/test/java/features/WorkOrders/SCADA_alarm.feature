@Maximo-API
Feature:
	Create Work Order - SCADA Alarm

	AUTHOR  : Venu Kadiri
	CREATED : 20/07/2020

	Background:
		* header Authorization = call read('classpath:basic-auth.js') { username: '#(USERNAME)', password: '#(PASSWORD)' }
		* header Content-Type = 'text/xml'
		* configure readTimeout = READTIMEOUT
		* configure retry = { count: 6, interval: 20000 }

		* def WOPayloadPath = 'classpath:features/WorkOrders/WO_Payloads/'

		* def testData = Java.type('utils.TestDataGenerator')
		* def failDate = testData.TimeInThePastByDays(2)
		
		* def WODesc = 'ALARM SPS192 SITE: SCADA Equipment.RTU.Outstation'
		* def WODesc_LongDesc = 'None Sewer.Brushy Creek.SPS192.SCADA Equipment.RTU.Outstation'
		* def externalRefID = 65869521
		* def location = 'SPS192'
		* def JPNum = 'COMMSFAIL'
		* def sourceSysID = 'SCADA'
		
	Scenario: Create a SCADA Alarm and verify the details
		Given url GBSWOBULKEndPoint
		And request read(WOPayloadPath + 'createWO_SCADAalarm_payload.xml')
		And soap action GBSWOBULKEndPoint
		Then status 200
		* def woNum = //WONUM
		
		### Verify the created WO details
		Given url YVWWORKORDEREndPoint
		And request read(WOPayloadPath + 'queryWO_YVWWO_payload.xml')
		And soap action YVWWORKORDEREndPoint
		Then status 200
		* match //WORKORDER/VENDOR == 'SAG003'
		* match //WORKORDER/CLASSSTRUCTUREID == JPNum
		* match //WORKORDER/DESCRIPTION == WODesc
		* match //WORKORDER/DESCRIPTION_LONGDESCRIPTION == WODesc_LongDesc
		* match //WORKORDER/EXTERNALREFID == externalRefID
		* match //WORKORDER/LOCATION == location
		* match //WORKORDER/JPNUM == JPNum
		* match //WORKORDER/SOURCESYSID == sourceSysID
		* match //WORKORDER/ORIGRECORDID == ''
		* match //WORKORDER/STATUS == 'APPR'
		
		### Verify the WO Activity's description 
		* match //WORKORDER/WOACTIVITY/DESCRIPTION == ['Investigate Alarm', 'Rectify Alarm', 'Complete Failure Report']
		
		### Verify that only one WO Activity contains GL Account
		* match //WORKORDER/WOACTIVITY[DESCRIPTION='Investigate Alarm']/GLACCOUNT/VALUE == '#present'
		* match //WORKORDER/WOACTIVITY[DESCRIPTION='Rectify Alarm']/GLACCOUNT/VALUE == '#notpresent'
		* match //WORKORDER/WOACTIVITY[DESCRIPTION='Complete Failure Report']/GLACCOUNT/VALUE == '#notpresent'
		
		### Verify the Task IDs for the 3 WO Activities
		* match //WORKORDER/WOACTIVITY[DESCRIPTION='Investigate Alarm']/TASKID == 10
		* match //WORKORDER/WOACTIVITY[DESCRIPTION='Rectify Alarm']/TASKID == 20
		* match //WORKORDER/WOACTIVITY[DESCRIPTION='Complete Failure Report']/TASKID == 30
		
		