@Maximo-API 
Feature:
	Create Service Request - Stoppage Plumber in MAXIMO application

	AUTHOR  : Venu Kadiri
	CREATED : 10/07/2020

	Background:
		* header Authorization = call read('classpath:basic-auth.js') { username: '#(USERNAME)', password: '#(PASSWORD)' }
		* header Content-Type = 'text/xml'
		* configure readTimeout = READTIMEOUT
		* configure retry = { count: 6, interval: 20000 }

		* def WOPayloadPath = 'classpath:features/WorkOrders/WO_Payloads/'

		* def testData = Java.type('utils.TestDataGenerator')
		
		* def currentTime = testData.TimeInFutureByMinutes(0)
		* def awarenessDate = testData.TimeInThePastByHours(2)
		* def containedDate = testData.TimeInThePastByHours(1)
		* def schedFinishDate = testData.TimeInFutureByHours(4)
		* def schedStartDate = testData.TimeInThePastByHours(1)
		* def actualFinishDate = testData.TimeInThePastByHours(1)
		* def actualStartDate = testData.TimeInThePastByHours(2)

		* def assetNum = '1128007'
		* def addressCode = 1459708
		* def product = 10003
		* def asset = 10036
		* def place = 10212
		* def symptom = 11222
		* def expectation = 14482
		* def effect = 29706
		* def SRType = 'FAULT'

		### Query WO - Get WO Number from SR
		* def JPNum = 'SGMCLRBLK'
		* def classStructureID = 'SCLBLKRETIC'
		* def GLAccountValue = 'Y-A-63-S-H478-0517'
		* def GBSVendor = 'VEN005'

		### Query WO - Get Spotters Fee WO Number from SR
		* def JPNumStopPlum = 'STOPPLUM'
		* def classStructureIDStopPlum = 'STOPPLUMBER'
		* def spottersFeeGLAccount = 'Y-A-35-S-3787-0526'
		
		### Update WO - Add Work Log
		* def worklogDescription = 'SoapUI Test'
		* def worklogLongDescription = 'SoapUI Test Create SR - Blocked HCB - Stoppage Plumber'
		
		### Add Costs
		* def costingGLAccount = 'Y-A-63-W-5928-0517'
		* def costingglorder0 = costingGLAccount.split('-')[0]
		* def costingglorder1 = costingGLAccount.split('-')[1]
		* def costingglorder2 = costingGLAccount.split('-')[2]
		* def costingglorder3 = costingGLAccount.split('-')[3]
		* def costingglorder4 = costingGLAccount.split('-')[4]
		* def costingglorder5 = costingGLAccount.split('-')[5]
		
		* def statusAWCOMP = 'AWCOMP'

	Scenario: Create Service Request - Stoppage Plumber
		### Create SR - Create Service Request
		Given url GBSSREndPoint
		And request read('SR_Payloads/createSR_StoppagePlumber_payload.xml')
		And soap action GBSSREndPoint
		Then status 200
		* def srNum = //TICKETID
		
		### Submit Service Request via HTTP
		Given url SRSubmitEndPoint
		And request read('SR_Payloads/viaHTTP_payload.xml')
		When method post
		Then status 200
		
		### Query WO - Get WO Number from SR
		Given url YVWWORKORDEREndPoint
		And request read(WOPayloadPath + 'queryWO_usingSR_payload.xml')
		And retry until karate.get("//WORKORDER[JPNUM[text()='" + JPNum + "']]/VENDOR") == GBSVendor
		When soap action YVWWORKORDEREndPoint
		Then status 200
		
		* def woNum = karate.get("//WORKORDER[JPNUM[text()='" + JPNum + "']]/WONUM")
		* match karate.get("//WORKORDER[JPNUM[text()='" + JPNum + "']]/VENDOR") == GBSVendor
		* match karate.get("//WORKORDER[JPNUM[text()='" + JPNum + "']]/CLASSSTRUCTUREID") == classStructureID
		* match karate.get("//WORKORDER[JPNUM[text()='" + JPNum + "']]/GBSJOBCATEGORY") == 'CIVIL-SEWER'
		* match karate.get("//WORKORDER[JPNUM[text()='" + JPNum + "']]/DESCRIPTION") == 'Fault,Sewerage Works,Manhole'
		* match karate.get("//WORKORDER[JPNUM[text()='" + JPNum + "']]/GBSCONTRACTNUM") == '1072'
		* match karate.get("//WORKORDER[JPNUM[text()='" + JPNum + "']]/GLACCOUNT/VALUE") == GLAccountValue
		* match karate.get("//WORKORDER[JPNUM[text()='" + JPNum + "']]/JPNUM") == JPNum
		* match karate.get("//WORKORDER[JPNUM[text()='" + JPNum + "']]/WPSERVICE/DESCRIPTION") == 'Civil Sewer-Blockage Clearance of Sewer Main by through pipe method'
		* match karate.get("//WORKORDER[JPNUM[text()='" + JPNum + "']]/WORKLOG[DESCRIPTION[text()='SR Classification Path and Location Comments']]/DESCRIPTION_LONGDESCRIPTION") contains 'FAULT \\ SEWER \\ MHOLE \\ NTRSTRP \\ OVRFLW \\ URGNT \\ ENTRGDRN'
		
		### Query WO - Get Spotters Fee WO Number from SR
		Given url YVWWORKORDEREndPoint
		And request read(WOPayloadPath + 'queryWO_SpottersFeeWOusingSR_payload.xml')
		When soap action YVWWORKORDEREndPoint
		Then status 200
		* def woNum_SpottersFee = //WONUM
		* match karate.get("//WORKORDER[JPNUM[text()='" + JPNumStopPlum + "']]/CLASSSTRUCTUREID") == classStructureIDStopPlum
		* match karate.get("//WORKORDER[JPNUM[text()='" + JPNumStopPlum + "']]/GBSJOBCATEGORY") == 'OTHER'
		* match karate.get("//WORKORDER[JPNUM[text()='" + JPNumStopPlum + "']]/STATUS") == 'WAPPR'
		
		### Update WO - Add Scheduled Start and Finish Dates
		Given url YVWWORKORDEREndPoint
		And request read(WOPayloadPath + 'updateWO_AddSchedStartEndDates_payload.xml')
		When soap action YVWWORKORDEREndPoint
		Then status 200

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
		
		### Update WO - Add Work Log
		Given url YVWWORKORDEREndPoint
		And request read(WOPayloadPath + 'updateWO_AddWorkLog_payload.xml')
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
		And request read(WOPayloadPath + 'updateWO_AddSpecifications_payload.xml')
		And soap action YVWWORKORDEREndPoint
		Then status 200	
		
		### Update WO - AWCOMP Work Order
		Given url YVWWORKORDEREndPoint
		And request read(WOPayloadPath + 'updateWO_StatusAWCOMP_payload.xml')
		And soap action YVWWORKORDEREndPoint
		Then status 200	
		
		### Update WO - COMP Work Order
		Given url YVWWORKORDEREndPoint
		* def newStatus = 'COMP'
		And request read(WOPayloadPath + 'updateWO_StatusUpdate_payload.xml')
		And soap action YVWWORKORDEREndPoint
		Then status 200	
		
		### Update WO - Update Status - PAYAPPR
		Given url YVWWORKORDEREndPoint
		* def newStatus = 'PAYAPPR'
		And request read(WOPayloadPath + 'updateWO_StatusUpdate_payload.xml')
		And soap action YVWWORKORDEREndPoint
		Then status 200	

		### Verification - WO Status
		Given url YVWWORKORDEREndPoint
		And request read(WOPayloadPath + 'queryWO_YVWWO_payload.xml')
		And soap action YVWWORKORDEREndPoint
		Then status 200
		* match //WORKORDER/VENDOR == GBSVendor
		* match //WORKORDER/CLASSSTRUCTUREID == classStructureID
		* match //WORKORDER/ORIGRECORDID == srNum
		* match //WORKORDER/PROBLEMCODE == 'BLOCKAGE'
		* match //WORKORDER/STATUS == 'PAYAPPR'
		* match //WORKORDER/FAILUREREPORT[TYPE[text()='PROBLEM']]/FAILURECODE == 'BLOCKAGE'
		* match //WORKORDER/FAILUREREPORT[TYPE[text()='CAUSE']]/FAILURECODE == 'TREEROOT'
		* match //WORKORDER/FAILUREREPORT[TYPE[text()='REMEDY']]/FAILURECODE == 'DIGOUT'
		
		### Verification - Spotters Fee WO Status
		Given url YVWWORKORDEREndPoint
		* def woNum = woNum_SpottersFee
		And request read(WOPayloadPath + 'queryWO_YVWWO_payload.xml')
		And soap action YVWWORKORDEREndPoint
		Then status 200
		* match //WORKORDER/VENDOR == ''
		* match //WORKORDER/CLASSSTRUCTUREID == classStructureIDStopPlum
		* match //WORKORDER/ORIGRECORDID == srNum
		* match //WORKORDER/GLACCOUNT/VALUE == spottersFeeGLAccount
		* match //WORKORDER/STATUS == 'WAPPR'
		* match //WORKORDER/WPSERVICE/DESCRIPTION == 'Plumber Spotters Fee'
		* match //WORKORDER/WPSERVICE/VENDOR == 'ABI002'
		
		
		