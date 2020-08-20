@ignore
Feature: first test for simple GET call to retrieve all countries info
  Background:
    * url 'https://restcountries.eu'
    * header Content-Type = 'application/json'

  Scenario: 1. GET request to return all countries details in the API response
    Given path '/rest/v2/all'
    When method GET
    Then status 200
    * print 'response result is ', response
    * match response[*].name contains 'Australia'

  Scenario: 2. GET request to return an individual country details in the API response
    Given path '/rest/v2/name/Aus'
    When method GET
    Then status 200
    * match $[0].capital == "Canberra"

  Scenario: 3. GET request to return an individual country details in the API response
    Given path '/rest/v2/name/Australia'
    And param fullText = true
    When method GET
    Then status 200