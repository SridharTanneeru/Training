@Maximo-API
Feature: 
   Extend Field Access Notification (FAN) in Maximo

   #AUTHOR Arun Thomas
   #CREATED 23-July-2020

Background:
   * header Authorization = call read('classpath:basic-auth.js') { username: '#(USERNAME)', password: '#(PASSWORD)' }
   * configure readTimeout = READTIMEOUT
   
   * def testData = Java.type('utils.TestDataGenerator')
   * def schedFinishDate = testData.TimeInFutureByHours(4)
   * def targetFinish = testData.TimeInFutureByMinutes(45)
   * def targetExtend = testData.TimeInFutureByMinutes(150)
      
   * def FANStatus1 = 'INPROG'
   * def FANStatus2 = 'EXTEND'
   * def FANClass = 'SR'
   * def classStrID = 'PERMIT'
   * def srType = 'PERMIT'
   * def firstCustName = 'MAXIMO'
   * def secondCustName = 'Automation Test'
   * def description = 'EXTENDING'
   * def recordClass = 'WORKORDER'

   * def JPNum = 'WSTREPAIR'
   * def assetNum = '3036709'
   * def sAddressCode = '1628325'
   * def GLAccountValue = 'Y-A-63-W-5925-0517'
   * def glorder0 = GLAccountValue.split('-')[0]
   * def glorder1 = GLAccountValue.split('-')[1]
   * def glorder2 = GLAccountValue.split('-')[2]
   * def glorder3 = GLAccountValue.split('-')[3]
   * def glorder4 = GLAccountValue.split('-')[4]
   * def glorder5 = GLAccountValue.split('-')[5]
     
Scenario: Extend Field Access Notification (FAN)

   ## Create New Work Order
   Given url GBSWOBULKEndPoint
   And request read('classpath:features/WorkOrders/WO_Payloads/createWO_payload.xml')
   When soap action GBSWOBULKEndPoint
   Then status 200
   And def recordId = //WORKORDER/WONUM
     
   # Create New FAN 
   Given url CREATEFANEndPoint
   And request read('FAN_Payloads/createFAN_payload.xml')
   When soap action CREATEFANEndPoint
   Then status 200
   And def srNum = //SR/TICKETID
                  
   #Query FAN for Assertions
   Given url GBSSREndPoint
   And request read('FAN_Payloads/queryFAN_payload.xml')
   When soap action GBSSREndPoint
   Then status 200
   
   ########### Validations ##############
   
   ###---- Verify CLASS
   Then match //SR/CLASS == FANClass
         
   ###---- Verify sr
   Then match //SR/TICKETID == srNum
   
   ###----Verify workorder
   Then match //SR/ORIGRECORDCLASS == recordClass 
   
   ###----Verify recordId
   Then match //SR/ORIGRECORDID == recordId 
   
   ###---- Verify SR Status   
   Then match //SR/STATUS == FANStatus1
   
   ###---- Verify Class StructureID
   Then match //SR/CLASSSTRUCTUREID == classStrID
   
   # Update FAN - Extend
   Given url UPDATEFANEndPoint
   And request read('FAN_Payloads/updateFAN_Extend_payload.xml')
   When soap action  UPDATEFANEndPoint
   Then status 200

   #Query SR for FAN verification with extend
   Given url GBSSREndPoint
   And request read('FAN_Payloads/queryFAN_payload.xml')
   When soap action GBSSREndPoint
   Then status 200

   ########### Validations ##############
    
   ###---- Verify CLASS
   Then match //SR/CLASS == FANClass
         
   ###---- Verify sr
   Then match //SR/TICKETID == srNum
   
   ###---- Verify SR Status   
   Then match //SR/STATUS == FANStatus2
   
   ###---- Verify Class StructureID
   Then match //SR/CLASSSTRUCTUREID == classStrID
   
   ###---- Verify worklog description
   Then match //SR/WORKLOG/DESCRIPTION == description
   
   ###---- Verify worklog description
   Then match //SR/GBSCUSTOMERNAME == firstCustName
   
   ###---- Verify worklog description
   Then match //SR/GBSSECONDCUSTNAME == secondCustName

