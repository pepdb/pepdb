Feature: Add Data
  An Admin
  Can use the add data option to store new entries in the database

  Scenario: An admin adds the data for a new library
    Given The user "admin" is looged in with "adminpw"
    And The user opens "/add-data"
    And The user selects to add "library"
  Scenario: An admin adds the data for a new selection
    Given The user "full_access_user" is looged in with "full_access_userpw"
    And The user open "/edit-data"
  Scenario: An admin adds the data for a new sequencing dataset
    Given The user "full_access_user" is looged in with "full_access_userpw"
    And The user open "/edit-data"
  Scenario: An admin adds the data for a new cluster
    Given The user "full_access_user" is looged in with "full_access_userpw"
    And The user open "/edit-data"
  Scenario: An admin adds the data for a new motif list
    Given The user "full_access_user" is looged in with "full_access_userpw"
    And The user open "/edit-data"
  Scenario: An admin adds the data for a new target 
    Given The user "full_access_user" is looged in with "full_access_userpw"
    And The user open "/edit-data"
  Scenario: An admin adds the data for a new peptide performance 
    Given The user "full_access_user" is looged in with "full_access_userpw"
    And The user open "/edit-data"

  Scenario: An authenticated user cannot access the add data pages
    Given The user "full_access_user" is looged in with "full_access_userpw"
    When The user opens "/edit-data"
    Then The welcome page should show up
