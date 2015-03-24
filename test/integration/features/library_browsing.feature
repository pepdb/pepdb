Feature: Library browsing
  An authenticated user
  Can use libaray browsing to view the libraries stored in the database
  
  Scenario: The user wants to view the information on a specific library
    Given The user "full_access_user" is logged in with "full_access_userpw"
    And The user opens "/libraries"
    When The user finally selects library "lib1"
    Then The text "Summary of lib1" should show up 

  Scenario: The user wants to view the selections within a specific library
    Given The user "full_access_user" is logged in with "full_access_userpw"
    And The user opens "/libraries"
    When The user finally selects library "lib1"
    Then The text "Selections in Library lib1" should show up 

  @javascript
  Scenario: The user wants to view the information on a specific selection within a specific library
    Given The user "full_access_user" is logged in with "full_access_userpw"
    And The user opens "/libraries"
    And The user first selects library "lib1"
    When The user finally chooses selection "sel1"
    Then The text "Summary of sel1" should show up 

  @javascript
  Scenario: The user selected a selection and wants to continue to the selection browsing
    Given The user "full_access_user" is logged in with "full_access_userpw"
    And The user opens "/libraries"
    And The user first selects library "lib1"
    And The user then selects selection "sel2"
    When The user clicks "continue with Selection"
    Then The text "Browse by Selection" should show up

  Scenario: A user that may only access lib2 tries to access lib1
    Given The user "restricted_user" is logged in with "restricted_userpw"
    When The user opens "/libraries"
    Then The row "lib1" should not show up

  Scenario: A restricted user tries to directly access a restricted library
    Given The user "restricted_user" is logged in with "restricted_userpw"
    When The user opens "/libraries/lib1"
    Then The text "Summary of lib1" should not show up
    

