@Maximo-API
Feature: 
		Create a Work Order in Maximo
    
		AUTHOR James Carter
		CREATED 01/02/2020

Background:
		* header Authorization = call read('classpath:basic-auth.js') { username: '#(USERNAME)', password: '#(PASSWORD)' }
		* configure readTimeout = READTIMEOUT
		
		* def testData = Java.type('utils.TestDataGenerator')
		* def schedFinishDate = testData.TimeInFutureByDays(7)
		
		* def JPNum = 'WSTREPAIR'
		* def assetNum = '3036709'
		* def sAddressCode = '1628325'
		* def GLAccountValue = 'Y-A-63-W-5925-0517'
		* def glorder0 = GLAccountValue.split('-')[0]
		* def glorder1 = GLAccountValue.split('-')[1]
		* def glorder2 = GLAccountValue.split('-')[2]
		* def glorder3 = GLAccountValue.split('-')[3]
		* def glorder4 = GLAccountValue.split('-')[4]
		* def glorder5 = GLAccountValue.split('-')[5]

Scenario: Create and Verify a Work Order

		# Create New Work Order
		Given url GBSWOBULKEndPoint
		And request read('WO_Payloads/createWO_payload.xml')
		When soap action GBSWOBULKEndPoint
		Then status 200
		And def woNum = //WORKORDER/WONUM
		
		# Query and verify new Work Order
		Given url GBSWOBULKEndPoint
		And request read('WO_Payloads/queryWO_payload.xml')
		When soap action GBSWOBULKEndPoint
		Then status 200
		And match //WORKORDER/WONUM == woNum
		And match //WORKORDER/CLASSSTRUCTUREID == 'WRPLST'
		And match //WORKORDER/ASSETNUM == '3036709'
		And match //WORKORDER/DESCRIPTION == 'Water Repair Stop Tap'
		And match //WORKORDER/FAILURECODE == 'DWRM'
		And match //WORKORDER/GBSJOBCATEGORY == 'CIVIL-WATER'
		And match //WORKORDER/JPNUM == 'WSTREPAIR'
		And match //WORKORDER/STATUS == 'APPR'
		And match //WORKORDER/VENDOR == 'VEN005'
		
		# Update Work Order Status & add Work Log
		Given url GBSWOBULKEndPoint
		And request read('WO_Payloads/updateWO_payload.xml')
		When soap action GBSWOBULKEndPoint
		Then status 200
		
		# Query and verify new Work Order updates
		Given url GBSWOBULKEndPoint
		And request read('WO_Payloads/queryWO_payload.xml')
		When soap action GBSWOBULKEndPoint
		Then status 200
		And match //WORKORDER/WORKLOG/CREATEBY == 'SVC-MAXIMO-IFACE' 
		And match //WORKORDER/WORKLOG/DESCRIPTION == 'SoapUI Test'
		And match //WORKORDER/WORKLOG/DESCRIPTION_LONGDESCRIPTION == 'SOAPUI - CCB Create WO'
		And match //WORKORDER/WORKLOG/LOGTYPE == 'WORK'
		And match //WORKORDER/STATUS == 'INPRG'
		
		Scenario Outline: Create Work Order - Data Driven Negative Tests
		Given url GBSWOBULKEndPoint
		And def addressCode = '<addressCode>'
		And def asset = '<asset>'
		And def jobPlan = '<jobPlan>'
		And def priority = '<priority>'
		And request read('WO_Payloads/createWO_negativetest_payload.xml')
		When soap action GBSWOBULKEndPoint
		Then status 500
		And match //Fault/faultcode == 'soapenv:Server'
		And match //Fault/faultstring contains '<faultString>'
		
		Examples:  
		| addressCode | asset       | jobPlan      | priority   | faultString |
		| 1122334455  | 3036709     | WSTREPAIR    | 2          | BMXAA4191E - The value 1122334455 is not valid for Service Address (SLID). Specify a valid value for Service Address (SLID). |
		| 1628325     | WRONGASSET  | WSTREPAIR    | 2          | BMXAA0090E - Asset WRONGASSET is not a valid asset, or its status is not an operating status. |
		| 1628325     | 3036709     | WRONGJOBPLAN | 2          | BMXAA6199E - Job Plan WRONGJOBPLAN is not valid, its status is not active or is not valid on this site. |    
		| 1628325     | 3036709     | WSTREPAIR    | 0          | BMXAA4190E - Priority 0 is not in the value list. |
