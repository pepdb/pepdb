Feature: Library browsing
  An authenticated user
  Can use libaray browsing to view the libraries stored in the database
  
  Scenario: The user wants to view the information on a specific library
    Given The user "test1" is logged in with "test"
    And The user opens "/libraries"
    When The user selects library "X7-105"
    Then The "Summary of X7-105" should show up 

  Scenario: The user wants to view the selections within a specific library
    Given The user "test1" is logged in with "test"
    And The user opens "/libraries"
    When The user selects library "X7-105"
    Then The "Selections in Library X7-105" should show up 

  @javascript
  Scenario: The user wants to view the information on a specific selection within a specific library
    Given The user "test1" is logged in with "test"
    And The user opens "/libraries"
    And The user selects library "X7-105"
    When The user selects selection "Lung 4d"
    Then The "Summary of Lung 4d" should show up 
