@Maximo-API
Feature:
	Create Work Order - BEA Meter Installation

	AUTHOR  : Venu Kadiri
	CREATED : 24/07/2020

	Background:
		* header Authorization = call read('classpath:basic-auth.js') { username: '#(USERNAME)', password: '#(PASSWORD)' }
		* header Content-Type = 'text/xml'
		* configure readTimeout = READTIMEOUT
		
		* def testData = Java.type('utils.TestDataGenerator')
		* def reportDate = testData.TimeInThePastByDays(2)
		* def targetCompDate = testData.TimeInFutureByDays(1)
		* def changeDate = testData.TimeInThePastByDays(1)
		
		* def WODesc = 'Customer Installation Request'
		* def WOStatus = 'APPR'
		* def ALNValue = 361071
		* def assetAttrID = 'EAAPPID'
		* def JPNum = 'SS_MT_INST'
		* def sourceSysID = 'BEA'
		* def sAddressCode = 5203704
		* def vendor = 'DAT019'
		* def classStructureID = 'SS_METERINSTALL'
		* def finalStatus = 'AWCOMP'
		* def servRecTrans1 = 'PLV20P'
		* def servRecTrans2 = 'PLV20R'
		* def servRecTrans3 = 'COMBPR'
		
	Scenario: Create a BEA Meter Installation WO and verify the details
		Given url GBSWOBULKEndPoint
		And request read('WO_Payloads/createWO_BEAMeterInstallation_payload.xml')
		And soap action GBSWOBULKEndPoint
		Then status 200
		* def woNum = //WONUM
		
		### Verify the created WO details
		Given url YVWWORKORDEREndPoint
		And request read('WO_Payloads/queryWO_YVWWO_payload.xml')
		And soap action YVWWORKORDEREndPoint
		Then status 200
		* match //WONUM == woNum
		* match //WORKORDER/VENDOR == vendor
		* match //WORKORDER/CLASSSTRUCTUREID == classStructureID
		* match //WORKORDER/DESCRIPTION == WODesc
		* match //WORKORDER/JPNUM == JPNum
		* match //WORKORDER/SOURCESYSID == sourceSysID
		* match //WORKORDER/STATUS == WOStatus
		* match //WORKORDER/WOSERVICEADDRESS/SADDRESSCODE == sAddressCode 
		* match //WORKORDER/DESCRIPTION_LONGDESCRIPTION == ''
		* match //WORKORDER/EXTERNALREFID == ''
		* match //WORKORDER/LOCATION == ''
		* match //WORKORDER/ORIGRECORDID == ''
		* match //WORKORDER/ACTSERVCOST == '0.0'
		* match //WORKORDER/GBSACTTOTALCOST == '0.0'
		
		### Verify the Work Order Spec values
		* match //WORKORDER/WORKORDERSPEC/ALNVALUE == ALNValue
		* match //WORKORDER/WORKORDERSPEC/ASSETATTRID == assetAttrID
		* match //WORKORDER/WORKORDERSPEC/CLASSSTRUCTUREID == classStructureID
		
		## Update the created WO
		Given url GBSWOBULKEndPoint
		And request read('WO_Payloads/updateWO_BEAMeterInstallation_payload.xml')
		And soap action GBSWOBULKEndPoint
		Then status 200
		
		### Verify the updated WO details
		Given url YVWWORKORDEREndPoint
		And request read('WO_Payloads/queryWO_YVWWO_payload.xml')
		And soap action YVWWORKORDEREndPoint
		Then status 200
		* match //WONUM == woNum
		* match //WORKORDER/STATUS == finalStatus
		* match //WORKORDER/VENDOR == vendor
		* match //WORKORDER/CLASSSTRUCTUREID == classStructureID
		* match //WORKORDER/DESCRIPTION == WODesc
		* match //WORKORDER/JPNUM == JPNum
		* match //WORKORDER/SOURCESYSID == sourceSysID
		* match //WORKORDER/WOSERVICEADDRESS/SADDRESSCODE == sAddressCode 
		* match //WORKORDER/DESCRIPTION_LONGDESCRIPTION == ''
		* match //WORKORDER/EXTERNALREFID == ''
		* match //WORKORDER/LOCATION == ''
		* match //WORKORDER/ORIGRECORDID == ''
		
		### Verify the Work Order Spec values
		* match //WORKORDER/WORKORDERSPEC/ALNVALUE == ALNValue
		* match //WORKORDER/WORKORDERSPEC/ASSETATTRID == assetAttrID
		* match //WORKORDER/WORKORDERSPEC/CLASSSTRUCTUREID == classStructureID
		
		### Verify the ServRecTrans values
		* match //WORKORDER/ACTSERVCOST != '0.0'
		* match //WORKORDER/GBSACTTOTALCOST != '0.0'
		* match //WORKORDER/FIRSTAPPRSTATUS == WOStatus		
		* match //WORKORDER/SERVRECTRANS/ITEMNUM == [#(servRecTrans1), #(servRecTrans2), #(servRecTrans3)]
		