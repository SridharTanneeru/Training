@Maximo-API
Feature: 
	Create a Field Access Notification (FAN) in Maximo
    
	# AUTHOR James Carter
	# CREATED 01/02/2020
	# UPDATED by Sridhar Tanneeru
	# On 10/07/2020 - to include Aus Melbourne timezone for the current time to fix the issue with Jenkins instance time diff 
 
	Background:
		* header Authorization = call read('classpath:basic-auth.js') { username: '#(USERNAME)', password: '#(PASSWORD)' }
		* configure readTimeout = READTIMEOUT

		* def testData = Java.type('utils.TestDataGenerator')
	
	Scenario: Create & Deactivate a FAN 

		* def targetFinish = testData.TimeInFutureByMinutes(45)
		* def FANClass = 'SR'
		* def classStrID = 'PERMIT'
		* def srType = 'PERMIT'
		* def firstCustName = 'MAXIMO'
		* def secondCustName = 'Automation Test'
		* def recordClass = 'WORKORDER' 
		* def recordId = '7062738'

		# Create New FAN 
		Given url CREATEFANEndPoint
		And request read('FAN_Payloads/createFAN_payload.xml')
		When soap action  CREATEFANEndPoint
		Then status 200
		And match //SR/CLASS == 'SR'
		And match //SR/TICKETID != ''
		And def srNum = //SR/TICKETID
		
		# Deativate FAN
		Given url UPDATEFANEndPoint
		And request read('FAN_Payloads/deactivateFAN_payload.xml')
		When soap action UPDATEFANEndPoint
		Then status 200
		
		# Query FAN for Assertions
		Given url GBSSREndPoint
		And request read('FAN_Payloads/queryFAN_payload.xml')
		When soap action GBSSREndPoint
		Then status 200
		And match //SR/CLASS == 'SR'
		And match //SR/TICKETID == srNum
		And match //SR/STATUS == 'RESOLVED'
	
	Scenario: Create a FAN - Negative Test 
	
		* def targetFinish = testData.TimeInFutureByMinutes(5)
		
		# Create New FAN - Negative Test
		Given url CREATEFANEndPoint
		And request read('FAN_Payloads/createFAN_NegativeTest_payload.xml')
		When soap action  CREATEFANEndPoint
		Then status 500
		And match //Fault/faultcode == 'soapenv:Server'
		And match //Fault/faultstring == 'BMXZZ2147E - Estimated Finish time needs to be at least 10 minutes in the future'
