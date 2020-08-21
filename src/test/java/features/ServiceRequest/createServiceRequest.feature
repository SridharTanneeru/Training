@Maximo-API
Feature:
	Create a Service Request in Maximo
	
	AUTHOR James Carter
	CREATED 13/02/2020
	UPDATED 14/02/2020 Added Data Driven SR Creation Tests
	UPDATED 14/02/2020 Added Negative Tests
	Sridhar Tanneeru : UPDATED 29/06/2020 moved pay loads onto separate files under this feature
	Sridhar Tanneeru : UPDATED 29/06/2020 moved credentials onto reusable json file in the classpath

	Background:
	
		* header Authorization = call read('classpath:basic-auth.js') { username: '#(USERNAME)', password: '#(PASSWORD)' }
		* configure readTimeout = READTIMEOUT
	
	Scenario Outline: Create Service Requests for type <srType>
		# Create New Service Request
	
		Given url GBSSREndPoint
		And def addressCode = '<addressCode>'
		And def definitionPRODUCT = '<definitionPRODUCT>'
		And def definitionASSET = '<definitionASSET>'
		And def definitionPLACE = '<definitionPLACE>'
		And def definitionSYMPTOM = '<definitionSYMPTOM>'
		And def definitionEXPECTATION = '<definitionEXPECTATION>'
		And def definitionEFFECT = '<definitionEFFECT>'
		And def srType = '<srType>'
		And request read('SR_Payloads/createSR_payload.xml')
		When soap action GBSSREndPoint
		Then status 200
		And match //SR/CLASS == 'SR'
		And def srNum = //SR/TICKETID
	
		# Query Service Request
		Given url GBSSREndPoint
		And request read('SR_Payloads/querySR_payload.xml')
		When soap action GBSSREndPoint
		Then status 200
		And match //SR/CLASS == 'SR'
		And match //SR/TICKETID == srNum
		And match //SR/STATUS == 'NEW'
	
		# Submit Service Request via HTTP
		Given url SRSubmitEndPoint
		And request read('SR_Payloads/viaHTTP_payload.xml')
		When method post
		Then status 200
	
		Examples:
			| addressCode | definitionPRODUCT | definitionASSET| definitionPLACE| definitionSYMPTOM | definitionEXPECTATION | definitionEFFECT | srType    |
	        | 1710532     | 10002             | 10014          | 10322          | 11792             | 17056                 | 43975            | FAULT     |
	        | 5031674     | 10002          	  | 10014          | 10324          | 11805             | 17104             	| 44383            | FAULT     |
	        | 5049984     | 10003          	  | 10036          | 10212          | 11222             | 14482             	| 29706            | FAULT     |
	        | 5041275     | 10003          	  | 10023          | 10145          | 10929             | 13136             	| 21713            | FAULT     |
	        | 5052396     | 10003          	  | 10028          | 10242          | 11435             | 15523                	| 36463            | FAULT     |
	        | 5061238     | 10005          	  | 10059          | 10098          | 10620             | 12411                	| 19318            | FAULT     |
	        | 5052295     | 10004          	  | 10048          | 10389          | 12124             | 18207             	| 49063            | FAULT     |
	        | 1353843     | 10005          	  | 10058          | 10092          | 10591             | 12287             	| 18883            | ENQUIRY   |
	        | 5042446     | 10004             | 10050          | 10408          | 12202             | 18631                 | 50228            | COMPLAINT |
	
	
		Scenario Outline: Negative Tests Via Data Table for <ScenarioType>
	
			Given url GBSSREndPoint
			And def addressCode = '<addressCode>'
			And def definitionPRODUCT = '<definitionPRODUCT>'
			And def srType = '<srType>'
			And request read('SR_Payloads/negativeTestsPayLoad.xml')
			When soap action GBSSREndPoint
			Then status 500
			And match //Fault/faultcode == 'soapenv:Server'
			And match //Fault/faultstring contains '<faultString>'
			
			Examples:
			| ScenarioType    |  addressCode | definitionPRODUCT | srType      | faultString                                                                                                                  |
			| Invalid SLID    |  1122334455  | 10002             | FAULT       | BMXAA4191E - The value 1122334455 is not valid for Service Address (SLID). Specify a valid value for Service Address (SLID). |
			| Invalid Product | 1710532      | 11223344          | FAULT       | BMXAA4191E - The value 11223344 is not valid for Product Type. Specify a valid value for Product Type.                       |
			| Wrong SRType    | 1710532      | 10002             | WRONGSRTYPE | MXAA4190E - SR Type WRONGSRTYPE is not in the value list. 




