@Maximo-API
Feature:
	Asset Creation GIS Integration

	AUTHOR  : Venu Kadiri
	CREATED : 22/07/2020

	Background:
		* header Authorization = call read('classpath:basic-auth.js') { username: '#(USERNAME)', password: '#(PASSWORD)' }
		* header Content-Type = 'text/xml'
		* configure readTimeout = READTIMEOUT
	
		* def testData = Java.type('utils.TestDataGenerator')
		* def statusDate = testData.TimeInThePastByDays(2)
		* def installDate = testData.TimeInThePastByDays(270)
		
		### Timestamp - to make GBSGISID unique for every execution 
		* def GBSGISID = testData.uniqueID()
		
		* def classStructureID = 'S_GRVTY_MAIN'
		* def description = 'W Hydrant - HYDRANT BELOW GROUND DIRECT ' + GBSGISID
		* def longDescription = 'W Hydrant'
		* def GBSGISFeature = 521
		* def location = 'S_GRVTY_MAIN'
		* def initStatus = 'OPERATING'
		* def siteID = 'YVW'
		* def orgID = 'YVWORG'
		* def sAddressCode = 5173898

	Scenario: Create a GIS Asset and verify the details
		### Create a GIS asset
		Given url GBSASSETEndPoint
		And request read('AM_Payloads/createAsset_GIS_payload.xml')
		And soap action GBSASSETEndPoint
		Then status 200
		* def assetNum = //ASSET/ASSETNUM
		
		### Verify the created GIS Asset details
		Given url GBSASSETEndPoint
		And request read('AM_Payloads/queryAsset_GBSAsset_payload.xml')
		And soap action GBSASSETEndPoint
		Then status 200
		* match //ASSET/ASSETNUM == assetNum
		* match //ASSET/CLASSSTRUCTUREID == classStructureID
		* match //ASSET/DESCRIPTION == description
		* match //ASSET/DESCRIPTION_LONGDESCRIPTION == longDescription
		* match //ASSET/GBSGISFEATURE == GBSGISFeature
		* match //ASSET/GBSGISID == GBSGISID
		* match //ASSET/LOCATION == location
		* match //ASSET/ORGID == orgID
		* match //ASSET/SADDRESSCODE == sAddressCode
		* match //ASSET/SITEID == siteID
		* match //ASSET/STATUS == initStatus
		
		