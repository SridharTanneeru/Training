@Maximo-API
Feature:
	Create Work Order - Minor Plumbing Works

	AUTHOR  : Venu Kadiri
	CREATED : 27/07/2020

	Background:
		* header Authorization = call read('classpath:basic-auth.js') { username: '#(USERNAME)', password: '#(PASSWORD)' }
		* header Content-Type = 'text/xml'
		* configure readTimeout = READTIMEOUT
		
		* def testData = Java.type('utils.TestDataGenerator')
		* def targetStartDate = testData.TimeInFutureByDays(2)
		* def targetCompDate = testData.TimeInFutureByDays(3)
		
		* def sAddressCode = 1628325
		* def WOStatus = 'APPR'
		* def contractNumber = 15300
		* def workType = 'CM'
		* def jobCategory = 'OTHER'
		
	Scenario Outline: Create a Minor Plumbing Works WO and verify the details - Job Plan <JPNum>
		Given url YVWCREATEWOEndPoint
		And request read('WO_Payloads/createWO_minorPlumbWorks_payload.xml')
		And soap action YVWCREATEWOEndPoint
		Then status 200
		* def woNum = //WONUM
		
		### Verify the created WO details
		Given url YVWWORKORDEREndPoint
		And request read('WO_Payloads/queryWO_YVWWO_payload.xml')
		And soap action YVWWORKORDEREndPoint
		Then status 200
		* match //WONUM == woNum
		* match //WORKORDER/STATUS == WOStatus
		* match //WORKORDER/DESCRIPTION == '<WODesc>'
		* match //WORKORDER/CLASSSTRUCTUREID == '<ClassStructureID>'
		* match //WORKORDER/WORKTYPE == workType
		* match //WORKORDER/GBSJOBCATEGORY == jobCategory
		* match //WORKORDER/GBSCONTRACTNUM == contractNumber
		* match //WORKORDER/WOPRIORITY == '<Priority>'
		* match //WORKORDER/JPNUM == '<JPNum>'
		* match //WORKORDER/GLACCOUNT/VALUE == '<GLAccount>'
		* match //WORKORDER/VENDOR == '<Vendor>'
		
		Examples:
		|		JPNum	|	ClassStructureID	|			GLAccount	|	Vendor	| Priority	|									WODesc						|
		| P_WATAUD_S	|		PLUMB_AUDIT		|	Y-C-33-C-7302-0561	|	INT058	|	3		|	Plumbing_Water Audit Standard								|
		| P_WATAUD_U	|		PLUMB_AUDIT		|	Y-C-33-C-7302-0561	|	INT058	|	3		|	Plumbing_Water Audit Urgent									|
		| P_CHRP_W_S	|		CHRP_WORK		|	Y-C-33-C-3629-0561	|	INT058	|	3		|	Plumbing_Community Housing Rebate Program_Work Standard		|
		| P_CHRP_W_U	|		CHRP_WORK		|	Y-C-33-C-3629-0561	|	INT058	|	1		|	Plumbing_Community Housing Rebate Program_Work Urgent		|
		| P_CHRP_Q_S	|		QUOTE			|	Y-C-33-C-3629-0561	|	INT058	|	3		|	Plumbing_Community Housing Rebate Program_Quote Standard	|
		| P_CHRP_Q_U	|		QUOTE			|	Y-C-33-C-3629-0561	|	INT058	|	1		|	Plumbing_Community Housing Rebate Program_Quote Urgent		|

		

		
		