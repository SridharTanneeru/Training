@Maximo-API
Feature: 
	  Create a Purchase Contract
		AUTHOR Arun
		CREATED 27/07/2020

Background:
		* header Authorization = call read('classpath:basic-auth.js') { username: '#(USERNAME)', password: '#(PASSWORD)' }
		* configure readTimeout = READTIMEOUT
		
		* def testData = Java.type('utils.TestDataGenerator')
		* def changeDate = testData.TimeInFutureByDays(7)
		* def enterDate = testData.TimeInThePastByDays(7)
    
		* def contractType = 'PURCHASE'
		* def externalREFid = Math.floor((Math.random() + Math.floor(Math.random()*7)+1) * Math.pow(8, 6))
		* def contractNum = Math.floor((Math.random() + Math.floor(Math.random()*4)+1) * Math.pow(6, 4))
		* def contractDescrption1 = 'Interflow Civil Sewer Rehabilitation Services Contract_123'
		* def contractDescrption2 = 'CLAMP S/S 175-185 x 200 LONG - 20mm TAPPING'
		* def contractLineID = '60268'
		* def itemNum = '72181'
		* def vendor = 'DET002'
		* def revStatus = 'ADDED'
		* def contractStatus = 'APPR'
   
Scenario: Create a Purchase Contract

		# Create a Purchase Contract
		Given url PurchaseContractEndPoint
		And request read('PC_Payloads/createPC_payload.xml')
		When soap action PurchaseContractEndPoint
		Then status 200
	
		# Query purchase contract
		Given url PurchaseContractEndPoint
		And request read('PC_Payloads/queryPC_payload.xml')
		When soap action PurchaseContractEndPoint
		Then status 200

		########## Validations ##############
		###---- Verify contract Type
		Then match //PURCHVIEW/CONTRACTTYPE == contractType
		
		###---- Verify Status
		Then match //PURCHVIEW/STATUS == contractStatus

		###---- Verify DESCRIPTION 1
		Then match //PURCHVIEW/DESCRIPTION == contractDescrption1
		
		###---- Verify DESCRIPTION 2
		Then match //PURCHVIEW/CONTRACTLINE/DESCRIPTION == contractDescrption2
			
		###---- Verify Item Num
		Then match //PURCHVIEW/CONTRACTLINE/ITEMNUM == itemNum
		
		###---- Verify contract line Id
		Then match //PURCHVIEW/CONTRACTLINE/CONTRACTLINEID == '#notnull'
		
		###---- Verify contract num
		Then match //PURCHVIEW/CONTRACTNUM == contractNum
		
		###---- Verify vendor
		Then match //PURCHVIEW/VENDOR == vendor
		
		###---- Verify revstatus
		Then match //PURCHVIEW/CONTRACTLINE/REVSTATUS == revStatus
