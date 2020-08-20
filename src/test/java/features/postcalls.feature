@post
Feature: post call

  Background: background for a post call to create a user
    * url 'https://reqres.in'

    Scenario: post call to create a user
      Given path 'api/users'
      And request read('userData.json')
      When method POST
      Then status 201
      * print 'response result is ', response
      * match response.job == 'leader'
      * match response == read('responseUserData.json')


