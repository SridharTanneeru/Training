Feature: First test

  Background:
    * url 'https://restcountries.eu'

#  Scenario: 1. GET request to return all countries details in the API response
#    Given path '/rest/v2/all'
#    When method GET
#    Then status 200
#    * print 'response result is ', response
#    * match response[*].name contains 'Australia'

    Scenario Outline: GET the response for the country Australia
      Given path 'rest/v2/name/<country>'
      And param fullText = true
      When method GET
      Then status 200
      * match response[0].capital == "<capital>"
      Examples:
      | country | capital |
      | Australia | Canberra |
      | New Zealand | Wellington |
      | India       | New Delhi 1 |
      | China       | Beijing1    |


