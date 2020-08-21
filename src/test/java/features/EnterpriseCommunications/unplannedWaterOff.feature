@Maximo-API 
Feature:
	Enterprise Communications - Create an Unplanned Water Off Work Order in MAXIMO application

	AUTHOR  : Venu Kadiri
	CREATED : 13/07/2020

	Background:
		* header Authorization = call read('classpath:basic-auth.js') { username: '#(USERNAME)', password: '#(PASSWORD)' }
		* header Content-Type = 'text/xml'
		* configure readTimeout = READTIMEOUT

		* def WOPayloadPath = 'classpath:features/WorkOrders/WO_Payloads/'
		
		* def testData = Java.type('utils.TestDataGenerator')
		* def currentTime = testData.TimeInFutureByDays(0)
		* def schedFinishDate = testData.TimeInFutureByDays(7)
		* def plannedOff = testData.TimeInThePastByMinutes(120)
		* def plannedOn = testData.TimeInFutureByMinutes(30)
		* def notificationDate = testData.TimeInThePastByDays(8)
		* def actualOff = testData.TimeInThePastByMinutes(30)
		
		* def JPNum = 'WMNREPAIR'
		* def GLAccountValue = 'Y-A-63-W-5925-0517'
		* def glorder0 = GLAccountValue.split('-')[0]
		* def glorder1 = GLAccountValue.split('-')[1]
		* def glorder2 = GLAccountValue.split('-')[2]
		* def glorder3 = GLAccountValue.split('-')[3]
		* def glorder4 = GLAccountValue.split('-')[4]
		* def glorder5 = GLAccountValue.split('-')[5]
		* def sAddressCode = '1628325'
		* def outageStatusOFF = 'OFF'
		* def outageStatusON = 'ON'
		* def isOutagePlanned = 0
		* def instanceNum = 1
		* def isActive = 1
		* def GBSVendor = 'VEN005'
		* def classStructureID = 'WRBRST'
		* def assetNum = 3036709

	Scenario: Create an Unplanned Work Order - Water On/Off
		### Create Work Order
		Given url YVWWORKORDEREndPoint
		And request read(WOPayloadPath + 'createWO_YVWWO_payload.xml')
		And soap action YVWWORKORDEREndPoint
		Then status 200
		* def woNum = //WONUM
		
		### Update WO - Add Water Off
		Given url YVWWORKORDEREndPoint
		And request read(WOPayloadPath + 'updateWO_AddWaterOff_payload.xml')
		And soap action YVWWORKORDEREndPoint
		Then status 200
		
		### Update WO - Add SLIDS
		Given url YVWWORKORDEREndPoint
		And request read(WOPayloadPath + 'updateWO_AddSLIDS_unplanned_payload.xml')
		And soap action YVWWORKORDEREndPoint
		Then status 200
		
		### Verification - WO Status
		Given url YVWWORKORDEREndPoint
		And request read(WOPayloadPath + 'queryWO_YVWWO_payload.xml')
		And soap action YVWWORKORDEREndPoint
		Then status 200
		* match //WORKORDER/GBSWATEROUTAGES/INSTANCENUM == instanceNum
		* match //WORKORDER/GBSWATEROUTAGES/ISACTIVE == isActive
		* match //WORKORDER/GBSWATEROUTAGES/PLANNED == isOutagePlanned
		* match //WORKORDER/GBSWATEROUTAGES/STATUS == outageStatusOFF
		* match //WORKORDER/VENDOR == GBSVendor
		* match //WORKORDER/CLASSSTRUCTUREID == classStructureID
		* match //WORKORDER/ASSETNUM == assetNum
		### Validate WORKORDERID is generated and is not null, and ORIGRECORDID, PROBLEMCODE are null
		* match //WORKORDER/GBSWATEROUTAGES/WORKORDERID == '#present'
		* match //WORKORDER/ORIGRECORDID == ''
		* match //WORKORDER/PROBLEMCODE == ''
		
		### Update WO - Add Water On
		Given url YVWWORKORDEREndPoint
		And request read(WOPayloadPath + 'updateWO_AddWaterOn_payload.xml')
		And soap action YVWWORKORDEREndPoint
		Then status 200
		
		### Verification - WO Status - after Water ON
		Given url YVWWORKORDEREndPoint
		And request read(WOPayloadPath + 'queryWO_YVWWO_payload.xml')
		And soap action YVWWORKORDEREndPoint
		Then status 200
		* match //WORKORDER/GBSWATEROUTAGES/INSTANCENUM == instanceNum
		* match //WORKORDER/GBSWATEROUTAGES/ISACTIVE == isActive
		* match //WORKORDER/GBSWATEROUTAGES/PLANNED == isOutagePlanned
		* match //WORKORDER/GBSWATEROUTAGES/STATUS == outageStatusON
		* match //WORKORDER/VENDOR == GBSVendor
		* match //WORKORDER/CLASSSTRUCTUREID == classStructureID
		* match //WORKORDER/ASSETNUM == assetNum
		### Validate WORKORDERID is generated and is not null, and ORIGRECORDID, PROBLEMCODE are null
		* match //WORKORDER/GBSWATEROUTAGES/WORKORDERID == '#present'
		* match //WORKORDER/ORIGRECORDID == ''
		* match //WORKORDER/PROBLEMCODE == ''
		