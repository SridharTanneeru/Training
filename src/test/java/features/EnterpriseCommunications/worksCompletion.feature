@Maximo-API 
Feature: 
    Enterprise communications work completion

		AUTHOR Arun
 		CREATED 17/07/2020

Background:

	* header Authorization = call read('classpath:basic-auth.js') { username: '#(USERNAME)', password: '#(PASSWORD)' }
	* configure readTimeout = READTIMEOUT

	* def WOPayloadPath = 'classpath:features/WorkOrders/WO_Payloads/'

	* def testData = Java.type('utils.TestDataGenerator')
	* def currentTime = testData.TimeInFutureByDays(0)	
	* def awarenessDate = testData.TimeInThePastByHours(2)
	* def containedDate = testData.TimeInThePastByHours(1)
	* def schedFinishDate = testData.TimeInFutureByDays(7)
	* def actualFinishDate = testData.TimeInThePastByHours(2)
	* def actualStartDate = testData.TimeInThePastByHours(7)
	
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
	* def WOActivityDescriptionHard = "Hard Surface: - Road = 1m x 500mm Footpath 1m by 350mm \\"
	* def WOActivityDescriptionSoft = "Soft Surface: - Road = 1m x 500mm Footpath 1m by 350mm \\"
	* def classStructureIDHard = "REINSTHARDP1"
	* def classStructureIDSoft = "REINSTSOFT"

Scenario: Enterprise communications works completion

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
	* def classStructureID = classStructureIDHard
	* def WOActivityDescription = WOActivityDescriptionHard
	And request read(WOPayloadPath + 'updateWO_addSurfaceTask_payload.xml')
	When soap action YVWWORKORDEREndPoint
	Then status 200


	# Update WO - Add Reinstatement - Soft Surface
	Given url YVWWORKORDEREndPoint
	* def classStructureID = classStructureIDSoft
	* def WOActivityDescription = WOActivityDescriptionSoft
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
	Then match //WORKORDER/WOACTIVITY/CLASSSTRUCTUREID == [#(classStructureIDHard), #(classStructureIDSoft)]

	###---- Verify wo activity description for Soft & hard surface Reinstatements
	* def descHardReint =  karate.get("//WORKORDER/WOACTIVITY[CLASSSTRUCTUREID='" + classStructureIDHard + "']/DESCRIPTION")
	Then match descHardReint == WOActivityDescriptionHard
	
	* def descSoftReint =  karate.get("//WORKORDER/WOACTIVITY[CLASSSTRUCTUREID='" + classStructureIDSoft + "']/DESCRIPTION")
	Then match descSoftReint == WOActivityDescriptionSoft
		
	
	
	
	
	
	
	
