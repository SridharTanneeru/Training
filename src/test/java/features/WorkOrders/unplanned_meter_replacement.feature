@Maximo-API
Feature: 
    Create a Work Order for Unplanned Meter Replacement in Maximo
    
		 AUTHOR Sridhar Tanneeru
		 CREATED 01/07/2020
		
		# MR1, MR5 on hold and skip MR10 At the moment (James and Sri on 03/07/2020)
	Background:
		* header Authorization = call read('classpath:basic-auth.js') { username: '#(USERNAME)', password: '#(PASSWORD)' }
		* configure readTimeout = READTIMEOUT
		
		* def WOPayloadPath = 'classpath:features/WorkOrders/WO_Payloads/'
		
		* def testData = Java.type('utils.TestDataGenerator')
		* def reportDate = testData.TimeInThePastByDays(7)
		* def startDate = testData.TimeInThePastByHours(4)
		* def actualStart = testData.TimeInThePastByMinutes(30)
		* def actualFinishDate = testData.TimeInFutureByMinutes(0)
		* def targetFinish = testData.TimeInFutureByDays(4)
		
		* def classStructureID = 'UNPLANMETERREPL'
		* def worklogDescription = 'Log Description'
		* def worklogLongDescription = 'Log Entry for NPS'
		* def clientNote = 'FOLLOWUP'
		* def orgID = 'YVWORG'
		
	Scenario Outline: Create and Verify a WOBULK Work Order for Meter replacement type <MR_Type>
		
		# Create New Work Order
		Given url GBSWOBULKEndPoint
		And request read(WOPayloadPath + 'createWO_UnplannedMtrReplace_payload.xml')
		When soap action GBSWOBULKEndPoint
		Then status 200
		And def woNum = //WORKORDER/WONUM
		
		# Query and verify if new Work Order has been updated
		Given url GBSWOBULKEndPoint
		And request read(WOPayloadPath + 'updateWO_UnplannedMtrRepl_AddWorkLog_UpdateStatus_payload.xml')
		When soap action GBSWOBULKEndPoint
		Then status 200
		
		# Update Work Order Status & add Work Log
		Given url GBSWOBULKEndPoint
		And request read(WOPayloadPath + 'updateWO_ApproveWO_payload.xml')
		When soap action GBSWOBULKEndPoint
		Then status 200
		
		# # Initiate WO Work Flow (James to check with Arun around the timeout issue with this endpoint)
		# Given url INITIATEWOEndPoint
		# And request
		# """
		# <InitiateWOWF_AUTO> 
		# 	<WORKORDERMboKey>
		# 		<WORKORDER>
		# 			<WONUM>#(woNum)</WONUM>
		# 			<SITEID>YVW</SITEID>
		# 		</WORKORDER>
		# 	</WORKORDERMboKey>
		# </InitiateWOWF_AUTO>
		
		# """
		# When soap action INITIATEWOEndPoint
		# Then status 200
		
		################ Below request is commented as it is duplicated
		# TEMP: Approve WO manually (Until the Initiate WO end point is fixed)
		#Given url GBSWOBULKEndPoint
		#And request read(WOPayloadPath + 'createWO_UnplannedMtrReplace_payload.xml')
		#"""
		#<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:max="http://www.ibm.com/maximo">
		   #<soapenv:Header/>
		   #<soapenv:Body>
		      #<max:UpdateGBSWOBULK>
		         #<max:GBSWOBULKSet>
		            #<max:WORKORDER action="Change">
		             #	<max:SITEID>YVW</max:SITEID>
		#			<max:STATUS>APPR</max:STATUS>
		#			<max:WONUM>#(woNum)</max:WONUM>
		#		</max:WORKORDER>
		#		</max:GBSWOBULKSet>
		 #	</max:UpdateGBSWOBULK>
		   #</soapenv:Body>
		#</soapenv:Envelope>
		#
		#"""
		#When soap action GBSWOBULKEndPoint
		#Then status 200
		
		# NPS Inbound - Start Work Order (Required, combine it with the Add worklog, payloads can be put together)
		Given url MRWOEndPoint
		And request read(WOPayloadPath + 'updateWO_AddWorkLog_UpdateStatus_payload.xml')
		When soap action MRWOEndPoint
		Then status 200
		
		# Query to verify WO status inprogress and Work Log added
		Given url YVWWORKORDEREndPoint
		And request read(WOPayloadPath + '/queryWO_YVWWO_payload.xml')
		When soap action YVWWORKORDEREndPoint
		Then status 200
		
		
		########### Validations ##############
		###---- Verify work log Details
		* match karate.get("//WORKORDER/WORKLOG[LOGTYPE[text()='FOLLOWUP']]/DESCRIPTION") == worklogDescription
		* match karate.get("//WORKORDER/WORKLOG[LOGTYPE[text()='FOLLOWUP']]/ORGID") == orgID
   		* match karate.get("//WORKORDER/WORKLOG[DESCRIPTION[text()='Log Description']]/LOGTYPE") == clientNote 
   	
		###---- Verify workorder details
		* match //WORKORDER/CLASSSTRUCTUREID == classStructureID
		* match //WORKORDER/DESCRIPTION == 'Unplanned Meter Replacement'
		* match //WORKORDER/JPNUM == 'SS_UMTRR'		
		
		# NPS Inbound AWComp WO, add specs and Add costings - Combined
		Given url MRWOEndPoint
		And def mrType = '<MR_Type>'
		And request read(WOPayloadPath + 'updateWO_AddSpecsAndCosting_payload.xml')
		When soap action MRWOEndPoint
		Then status 200
		
		# Query WO - Verification - WO Status -AWCOMP and Specs
		Given url YVWWORKORDEREndPoint
		And request read(WOPayloadPath + '/queryWO_YVWWO_payload.xml')
		When soap action YVWWORKORDEREndPoint
		Then status 200
		
		############ Validations ##############
		###---- Verify Correct Status - AWCOMP
		* match //WORKORDER/STATUS == 'AWCOMP'
		
		###---- VerifyWork order Specification details
		* match karate.get("//WORKORDER/WORKORDERSPEC[ASSETATTRID[text()='CYBLENUM']]/ORGID") == orgID
		* match karate.get("//WORKORDER/WORKORDERSPEC[ASSETATTRID[text()='CYBLENUM']]/CLASSSTRUCTUREID") == classStructureID
		* match karate.get("//WORKORDER/WORKORDERSPEC[ASSETATTRID[text()='COMPCODE']]/ALNVALUE") == MR_Type
		* match karate.get("//WORKORDER/WORKORDERSPEC[ASSETATTRID[text()='COMPCODE']]/ASSETATTRID") == 'COMPCODE'
		* match karate.get("//WORKORDER/SERVRECTRANS/STATUS[@maxvalue='COMP']") == 'COMP'
		
		
	# Last step for NPS inbounds AWComp and Add Costings
	Examples:
		| MR_Type |
		| MR2 |
		| MR3 |
		| MR4 |
		| MR9 |



