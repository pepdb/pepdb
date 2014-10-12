Feature: Add Data
  An Admin
  Can use the add data option to store new entries in the database

  @javascript
  Scenario: An admin adds the data for a new library
    Given The user "admin" is logged in with "adminpw"
    And The user opens "/add-data"
    And The user selects to add "library"
    And The user enters all relevant data for "lib3"
    When The user saves without errors
    Then "lib3" should show up under "/libraries"

  @javascript
  Scenario: An admin tries to add the same library twice
    Given The user "admin" is logged in with "adminpw"
    And The user opens "/add-data"
    And The user selects to add "library"
    And The user enters all relevant data for "lib3"
    When The user saves
    #Then The message "Given name not unique" should show up
    Then The message "Success!" should show up

  @javascript
  Scenario: An admin adds the data for a new selection
    Given The user "admin" is logged in with "adminpw"
    And The user opens "/add-data"
    And The user selects to add "selection"
    And The user enters all relevant data for "sel5"
    When The user saves without errors
    Then "sel5" should show up under "/selections"

  @javascript
  Scenario: An admin tries to add the same selection twice
    Given The user "admin" is logged in with "adminpw"
    And The user opens "/add-data"
    And The user selects to add "selection"
    And The user enters all relevant data for "sel5"
    When The user saves
    Then The message "Given name not unique" should show up

  @javascript
  Scenario: An admin adds the data for a new sequencing dataset
    Given The user "admin" is logged in with "adminpw"
    And The user opens "/add-data"
    And The user selects to add "sequencing dataset"
    And The user enters all relevant data for "set9"
    When The user saves without errors
    Then "set9" should show up under "/datasets"

  Scenario: An admin adds the data for a new cluster
    Given The user "admin" is logged in with "adminpw"
    And The user opens "/add-data"
  Scenario: An admin tries to add the same cluster twice
  Scenario: An admin adds the data for a new motif list
    Given The user "admin" is logged in with "adminpw"
    And The user opens "/add-data"
  Scenario: An admin tries to add the same motif list twice
  Scenario: An admin adds the data for a new target 
    Given The user "admin" is logged in with "adminpw"
    And The user opens "/add-data"
  Scenario: An admin tries to add the same target twice
  Scenario: An admin adds the data for a new peptide performance 
    Given The user "admin" is logged in with "adminpw"
    And The user opens "/add-data"
  Scenario: An admin tries to add the same peptide performace twice

  Scenario: An authenticated user cannot access the add data pages
    Given The user "full_access_user" is logged in with "full_access_userpw"
    When The user opens "/edit-data"
    Then The welcome page should show up
