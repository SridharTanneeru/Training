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
		* def changeDate = testData.TimeInThePastByDays(30)
		* def siteID = 'YVW'
		* def initStatus = 'OPERATING'

	Scenario: Import a Water Meter Asset and verify the details
		### Import New Asset - Water Meter
		Given url ASSETCreationEndPoint
		* def assetNum = 'YCA003119'
		* def assetType = 'WMTR'
		* def assetDesc = 'CUSTOMER METER - ' + assetNum
		* def classStructureID = 'CUSTMR_METR'
		* def location = 'DW_CMTR'
		* def sAddressCode = 1078174
		* def assetMeterID = '115062997'
		* def measureUnitID = 'L/MIN'
		* def meterName = 'LD6A'
		
		And request read('AM_Payloads/createAsset_WaterMeter_payload.xml')
		And soap action ASSETCreationEndPoint
		Then status 200
		
		### Verify the created GIS Asset details
		Given url GBSASSETEndPoint
		And request read('AM_Payloads/queryAsset_GBSAsset_payload.xml')
		And soap action GBSASSETEndPoint
		Then status 200
		* match //ASSET/ASSETNUM == assetNum
		* match //ASSET/ASSETTYPE == assetType
		* match //ASSET/CLASSSTRUCTUREID == classStructureID
		* match //ASSET/DESCRIPTION == assetDesc
		* match //ASSET/DESCRIPTION_LONGDESCRIPTION == ''
		* match //ASSET/GBSGISFEATURE == ''
		* match //ASSET/GBSGISID == ''
		* match //ASSET/LOCATION == location
		* match //ASSET/SADDRESSCODE == sAddressCode
		* match //ASSET/SITEID == siteID
		* match //ASSET/STATUS == initStatus
		* match //ASSET/ASSETMETER/ASSETMETERID == assetMeterID
		* match //ASSET/ASSETMETER/MEASUREUNITID == measureUnitID
		* match //ASSET/ASSETMETER/METERNAME == meterName
		* match //ASSET/GBSMULTISERVICEADDRESS/ADDRESSCODE == sAddressCode
		* match //ASSET/GBSMULTISERVICEADDRESS/RECORDKEY == assetNum

	Scenario: Import a Hydrant Asset and verify the details		
		### Import New Asset - Hydrant
		Given url GBSASSETEndPoint
		* def classStructureID = 'DW_HYDRANT'
		* def GBSGISFeature = 521
		* def orgID = 'YVWORG'
		* def GBSGISID = testData.uniqueID()
		* def description = 'W Hydrant - HYDRANT BELOW GROUND DIRECT ' + GBSGISID
		* def longDescription = 'W Hydrant'
		* def location = 'DW_PIPE'
		* def sAddressCode = 5166906
		* def installDate = testData.TimeInThePastByDays(270)
		And request read('AM_Payloads/createAsset_Hydrant_payload.xml')
		And soap action GBSASSETEndPoint
		Then status 200
		
		### Verify the created GIS Asset details
		Given url GBSASSETEndPoint
		And request read('AM_Payloads/queryAsset_GBSGISID_payload.xml')
		And soap action GBSASSETEndPoint
		Then status 200
		* match //ASSET/ASSETNUM != ''
		* def assetNum = //ASSET/ASSETNUM 
		* match //ASSET/CLASSSTRUCTUREID == classStructureID
		* match //ASSET/DESCRIPTION == description
		* match //ASSET/DESCRIPTION_LONGDESCRIPTION == longDescription
		* match //ASSET/GBSGISFEATURE == GBSGISFeature
		* match //ASSET/GBSGISID == GBSGISID
		* match //ASSET/LOCATION == location
		* match //ASSET/SADDRESSCODE == sAddressCode
		* match //ASSET/SITEID == siteID
		* match //ASSET/STATUS == initStatus
		* match //ASSET/GBSMULTISERVICEADDRESS/ADDRESSCODE == sAddressCode
		* match //ASSET/GBSMULTISERVICEADDRESS/RECORDKEY == assetNum
		
		