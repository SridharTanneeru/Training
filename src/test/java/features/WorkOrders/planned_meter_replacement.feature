@Maximo-API
Feature:
	Create a Planned Meter Replacement Work Order - MR4 in MAXIMO application

	AUTHOR  : Venu Kadiri
	CREATED : 01/07/2020

	Background:
		* header Authorization = call read('classpath:basic-auth.js') { username: '#(USERNAME)', password: '#(PASSWORD)' }
		* header Content-Type = 'text/xml'
		* configure readTimeout = READTIMEOUT

		* def WOPayloadPath = 'classpath:features/WorkOrders/WO_Payloads/'

		* def testData = Java.type('utils.TestDataGenerator')
		* def startDate = testData.TimeInFutureByDays(7)
		* def pastDate = testData.TimeInThePastByDays(1)
		* def currentTime = testData.TimeInFutureByMinutes(0)
		* def actualStart = testData.TimeInThePastByDays(1)
		* def reportDate = testData.TimeInThePastByMinutes(0)
		
		* def subOffDate = '07/06/2019 11:30 AM'
		* def lastMTRRead = '3.000000'
		* def badgeNumber = 'YBF008172'
		* def newMeter = 'YAAD039683'
		* def servicePointID = 8935362838
		* def meterAssetNum = 2593318
		* def SLID = 1672401
		* def worklogDescription = 'SoapUI Test'
		* def worklogLongDescription = 'SoapUI Testing Work Log Entry for NPS'
		* def initialWorklogDescription = 'SoapUI Planned Meter Replacement'
		* def initialWorklogLongDescription = 'SoapUI Planned Meter Replacement MR4 Scenario'
		* def classStructureID = 'PLANMETERREPL'
		* def clientNote = 'FOLLOWUP'
		* def createBy = 'SOAPUI'
		* def orgID = 'YVWORG'

	Scenario: Create and verify WO for Planned Meter Replacement
		### Create Planned Meter replacement WO
		Given url GBSWOBULKEndPoint
		And request read(WOPayloadPath + 'createWO_PlannedMtrReplace_payload.xml')
		And soap action GBSWOBULKEndPoint
		Then status 200
		* def woNum = //WONUM

		## Approve the created WO
		Given url GBSWOBULKEndPoint
		And request read(WOPayloadPath + 'updateWO_ApproveWO_payload.xml')
		And soap action GBSWOBULKEndPoint
		Then status 200


		### NPS Inbound - Start Work Order + Add work log
		Given url MRWOEndPoint
		And request read(WOPayloadPath + 'updateWO_AddWorkLog_UpdateStatus_payload.xml')
		And soap action MRWOEndPoint
		Then status 200

		### Verification - WO Status and Work log added
		Given url YVWWORKORDEREndPoint
		And request read(WOPayloadPath + '/queryWO_YVWWO_payload.xml')
		And soap action YVWWORKORDEREndPoint
		Then status 200
		Then match //WORKORDER/STATUS == 'INPRG'
		###---- Verify Follow Up Log Added
		* match karate.get("//WORKORDER/WORKLOG[LOGTYPE[text()='FOLLOWUP']]/DESCRIPTION") == worklogDescription
		* match karate.get("//WORKORDER/WORKLOG[LOGTYPE[text()='FOLLOWUP']]/DESCRIPTION_LONGDESCRIPTION") == worklogLongDescription
		###---- Verify Follow Up Log Added
		* match karate.get("//WORKORDER/WORKLOG[LOGTYPE[text()='WORK']]/DESCRIPTION_LONGDESCRIPTION") == initialWorklogLongDescription
		* match karate.get("//WORKORDER/WORKLOG[LOGTYPE[text()='WORK']]/DESCRIPTION") == initialWorklogDescription

		### NPS Inbound - AWCOMP WO and Add Specs + Add Costings
		Given url YVWWORKORDEREndPoint
		And request read(WOPayloadPath + 'updateWO_WOComp_PlannedMtrReplace_payload.xml')
		And soap action YVWWORKORDEREndPoint
		Then status 200

		### Verification - WO Status - AWCOMP and Specs +(plus)
		### Verification - WO Status - COMP and Meter Replacement file for CCB created
		Given url YVWWORKORDEREndPoint
		And request read(WOPayloadPath + '/queryWO_YVWWO_payload.xml')
		And soap action YVWWORKORDEREndPoint
		Then status 200

		############ Validations ##############
		###---- Verify Correct Status - AWCOMP
		Then match //WORKORDER/STATUS == 'AWCOMP'

		###---- Verify New Meter Number in Specs
		* match karate.get("//WORKORDER/WORKORDERSPEC[ALNVALUE[text()='" + newMeter + "']]/ASSETATTRID") == 'WS14'

		###---- Verify Old Meter Number in Specs
		* match karate.get("//WORKORDER/WORKORDERSPEC[ALNVALUE[text()='" + badgeNumber + "']]/ASSETATTRID") == 'WS13'

		###---- Verify Substitution Date in Specs
		* match karate.get("//WORKORDER/WORKORDERSPEC[ALNVALUE[text()='" + subOffDate + "']]/ASSETATTRID") == 'WS12'

		###---- Verify Comp Code in Specs
		* match karate.get("//WORKORDER/WORKORDERSPEC[ALNVALUE[text()='MR3']]/ASSETATTRID") == 'COMPCODE'

		###---- Verify Correct Job Status - COMP
		* match karate.get("//WORKORDER/SERVRECTRANS/STATUS[@maxvalue='COMP']") == 'COMP'

