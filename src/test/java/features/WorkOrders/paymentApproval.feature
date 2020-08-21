@Maximo-API 
Feature:
	Create Work Order - Payment Approval in MAXIMO application

	AUTHOR  : Venu Kadiri
	CREATED : 08/07/2020

	Background:
		* header Authorization = call read('classpath:basic-auth.js') { username: '#(USERNAME)', password: '#(PASSWORD)' }
		* header Content-Type = 'text/xml'
		* configure readTimeout = READTIMEOUT

		* def WOPayloadPath = 'classpath:features/WorkOrders/WO_Payloads/'
		
		* def testData = Java.type('utils.TestDataGenerator')
		* def currentTime = testData.TimeInFutureByMinutes(0)
		* def awarenessDate = testData.TimeInThePastByHours(2) 
		* def containedDate = testData.TimeInThePastByHours(1) 
		* def schedFinishDate = testData.TimeInFutureByHours(4) 
		* def schedStartDate = testData.TimeInThePastByHours(1) 

		### Create Work Order
		* def JPNum = 'SGHCLRBLK'
		* def assetNum = '364673'
		* def GLAccountValue = 'Y-A-63-W-5925-0517'
		* def glorder0 = GLAccountValue.split('-')[0]
		* def glorder1 = GLAccountValue.split('-')[1]
		* def glorder2 = GLAccountValue.split('-')[2]
		* def glorder3 = GLAccountValue.split('-')[3]
		* def glorder4 = GLAccountValue.split('-')[4]
		* def glorder5 = GLAccountValue.split('-')[5]
		* def sAddressCode = '1628325'
		
		### Add Costs
		* def costingGLAccount = 'Y-A-63-W-5928-0517'
		* def costingglorder0 = costingGLAccount.split('-')[0]
		* def costingglorder1 = costingGLAccount.split('-')[1]
		* def costingglorder2 = costingGLAccount.split('-')[2]
		* def costingglorder3 = costingGLAccount.split('-')[3]
		* def costingglorder4 = costingGLAccount.split('-')[4]
		* def costingglorder5 = costingGLAccount.split('-')[5]
		* def GBSVendor = 'VEN005'
		
		### Add Soft Surface Task
		* def classStructureID = 'REINSTSOFT'
		* def WOActivityDescription = 'Soft Surface: - Road = 1m x 500mm Footpath 1m by 350mm \\'
		
		### Add Work Order Specifications
		* def AddSpecClassStructureID = 'SCLBLKHCB'
		* def description = 'Sewer Gravity HCB Clear Blockage'
		* def statusPayAppr = 'PAYAPPR'

	Scenario: Create Work Order - Payment Approval
		### Create Work Order
		Given url YVWWORKORDEREndPoint
		And request read(WOPayloadPath + 'createWO_YVWWO_payload.xml')
		And soap action YVWWORKORDEREndPoint
		Then status 200
		* def woNum = //WONUM
		
		### Update WO - Add SLIDS
		Given url YVWWORKORDEREndPoint
		And request read(WOPayloadPath + 'updateWO_AddSLIDS_payload.xml')
		And soap action YVWWORKORDEREndPoint
		Then status 200
		
		### Update WO - Add Sewer Spill
		Given url YVWWORKORDEREndPoint
		And request read(WOPayloadPath + 'updateWO_AddSewerSpill_payload.xml')
		And soap action YVWWORKORDEREndPoint
		Then status 200
		
		### Update WO - Add Soft Surface Task
		Given url YVWWORKORDEREndPoint
		And request read(WOPayloadPath + 'updateWO_addSurfaceTask_payload.xml')
		And soap action YVWWORKORDEREndPoint
		Then status 200
	
		### Update WO - Add Costs
		Given url YVWWORKORDEREndPoint
		And request read(WOPayloadPath + 'updateWO_AddCosts_payload.xml')
		And soap action YVWWORKORDEREndPoint
		Then status 200
		
		### Update WO - Add Problem Cause & Remedy
		Given url YVWWORKORDEREndPoint
		And request read(WOPayloadPath + 'updateWO_AddProblemCauseRemedy_payload.xml')
		And soap action YVWWORKORDEREndPoint
		Then status 200		

		### Update WO - Add Work Order Specifications
		Given url YVWWORKORDEREndPoint
		* def WOActivityClassStructID = classStructureID
		* def classStructureID = AddSpecClassStructureID
		And request read(WOPayloadPath + 'updateWO_AddSpecifications_payload.xml')
		And soap action YVWWORKORDEREndPoint
		Then status 200
		
		### Update WO - AWCOMP Work Order
		Given url YVWWORKORDEREndPoint
		And request read(WOPayloadPath + 'updateWO_StatusAWCOMP_paymentApproval_payload.xml')
		And soap action YVWWORKORDEREndPoint
		Then status 200	
		
		### Update WO - Update Status - PAYAPPR
		Given url YVWWORKORDEREndPoint
		And request read(WOPayloadPath + 'updateWO_StatusPAYAPPR_payload.xml')
		And soap action YVWWORKORDEREndPoint
		Then status 200	
		
		### Verification for the WO
		Given url YVWWORKORDEREndPoint
		And request read(WOPayloadPath + 'queryWO_YVWWO_payload.xml')
		And soap action YVWWORKORDEREndPoint
		Then status 200
		
		### Validations
		* match //WORKORDER/STATUS == statusPayAppr
		* match //WORKORDER/JPNUM == JPNum
		* match //WORKORDER/ASSETNUM == assetNum
		* match //WORKORDER/DESCRIPTION == description
		* match //WORKORDER/GLACCOUNT/VALUE == GLAccountValue
		* match //WORKORDER/CLASSSTRUCTUREID == AddSpecClassStructureID
		* match //WORKORDER/WOSERVICEADDRESS/SADDRESSCODE == sAddressCode
		* match //WORKORDER/SERVRECTRANS/GLDEBITACCT/VALUE == costingGLAccount
		* match //WORKORDER/SERVRECTRANS/GBSVENDOR == GBSVendor
		* match //WORKORDER/WOACTIVITY/CLASSSTRUCTUREID == WOActivityClassStructID
		* match //WORKORDER/WOACTIVITY/DESCRIPTION == WOActivityDescription
		
		