@Maximo-API 
Feature: 
	Enterprise communications Work Order update for Reinstatements(Hard & Soft)

	AUTHOR Arun
	CREATED 13/07/2020

Background:

	* header Authorization = call read('classpath:basic-auth.js') { username: '#(USERNAME)', password: '#(PASSWORD)' }
	* configure readTimeout = READTIMEOUT
	
	* def WOPayloadPath = 'classpath:features/WorkOrders/WO_Payloads/'

	* def testData = Java.type('utils.TestDataGenerator')
	* def currentTime = testData.TimeInFutureByDays(0)
	* def awarenessDate = testData.TimeInThePastByMinutes(120)
	* def containedDate = testData.TimeInThePastByMinutes(60)
	* def schedFinishDate = testData.TimeInFutureByDays(7)
	* def actualFinishDate = testData.TimeInThePastByMinutes(30)
	* def actualStartDate = testData.TimeInThePastByMinutes(45)
	
	* def JPNum = "WSTREPAIR"
	* def assetNum = "3036709"
	* def sAddressCode = "1628325"
	* def GLAccountValue = "Y-A-63-W-5925-0517"
	* def glorder0 = GLAccountValue.split('-')[0]
	* def glorder1 = GLAccountValue.split('-')[1]
	* def glorder2 = GLAccountValue.split('-')[2]
	* def glorder3 = GLAccountValue.split('-')[3]
	* def glorder4 = GLAccountValue.split('-')[4]
	* def glorder5 = GLAccountValue.split('-')[5]
	* def statusAWCOMP = 'AWCOMP'

Scenario Outline: Enterprise communications - Create and Verify Work Order for Reinstatements type <Reinstatements_Type>

	# Create New Work Order
	Given url YVWWORKORDEREndPoint
	And request read(WOPayloadPath + 'createWO_YVWWO_payload.xml')
	When soap action YVWWORKORDEREndPoint
	Then status 200
	* def woNum = //WONUM
		
	
	# Update WO - Add Sewer Spill
	Given url YVWWORKORDEREndPoint
	And request read(WOPayloadPath + 'updateWO_AddSewerSpill_payload.xml')
	When soap action YVWWORKORDEREndPoint
	Then status 200


	# Update WO - Add Reinstatement - Hard Surface
	Given url YVWWORKORDEREndPoint
	And request read(WOPayloadPath + 'updateWO_addSurfaceTask_payload.xml')
	When soap action YVWWORKORDEREndPoint
	Then status 200

	# Update WO - Update Status - AWCOMP
	Given url YVWWORKORDEREndPoint
	And request read(WOPayloadPath + 'updateWO_StatusAWCOMP_payload.xml')
	When soap action YVWWORKORDEREndPoint
	Then status 200

	# Query WO - Verification - WO Status -AWCOMP
	Given url YVWWORKORDEREndPoint
	And request read(WOPayloadPath + 'queryWO_YVWWO_payload.xml')
	When soap action YVWWORKORDEREndPoint
	Then status 200
	
	########### Validations ##############

	###---- Verify Correct Status - AWCOMP
	Then match //WORKORDER/STATUS == statusAWCOMP
	
	###---- Verify ASSETNUM
	Then match //WORKORDER/ASSETNUM == assetNum
  
	###---- Verify JPNUM
	Then match //WORKORDER/JPNUM == JPNum

	###---- Verify ADDRESSCODE
	Then match //WORKORDER/WOSERVICEADDRESS/SADDRESSCODE == sAddressCode

	###---- Verify GLACCOUNT
	Then match //WORKORDER/GLACCOUNT/VALUE == GLAccountValue

	###---- Verify Class StructureID for Soft & hard surface Reinstatements
	Then match //WORKORDER/WOACTIVITY/CLASSSTRUCTUREID == classStructureID

	###---- Verify wo activity description for Soft & hard surface Reinstatements
	Then match //WORKORDER/WOACTIVITY/DESCRIPTION == WOActivityDescription

		

Examples:
| Reinstatements_Type | classStructureID 	|			 WOActivityDescription 																 |
| Hard 								| REINSTHARDP1 			|	 	Hard Surface: - Road = 1m x 500mm Footpath 1m by 350mm \\|
| Soft 								|	REINSTSOFT  			|   Soft Surface: - Road = 1m x 500mm Footpath 1m by 350mm \\|
