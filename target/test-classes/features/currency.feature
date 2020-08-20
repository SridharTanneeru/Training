@currency
Feature: For currency

  Background:

    Scenario: To test for currency
      * url 'https://restcountries.eu'
      * path 'rest/v2/currency/cop'
      When method GET
      Then status 400

