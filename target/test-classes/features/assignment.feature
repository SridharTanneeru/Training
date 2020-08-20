Feature: assignment 1

  Scenario: scenario 1
    * url 'https://restcountries.eu/rest/v2/alpha/col'
    * method GET
    * status 200
    * def code = response.numericCode
    * print ' code value is ', response
    * match response.numericCode == 171