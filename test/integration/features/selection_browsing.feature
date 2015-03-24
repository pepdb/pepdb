Feature: Selection browsing
  An authenticated user
  Can use selection browsing to view the selections stored in the database
  
  Scenario: The user wants to view the information on a specific selection
    Given The user "full_access_user" is logged in with "full_access_userpw"
    And The user opens "/selections"
    When The user finally selects selection "sel1"
    Then The text "Summary of sel1" should show up 

  Scenario: The user wants to view the sequencing datasets within a specific selection
    Given The user "full_access_user" is logged in with "full_access_userpw"
    And The user opens "/selections"
    When The user finally selects selection "sel1"
    Then The text "Sequencing Datasets in Selection sel1" should show up 

  @javascript
  Scenario: The user wants to view the information on a specific sequencing datasets within a specific selection
    Given The user "full_access_user" is logged in with "full_access_userpw"
    And The user opens "/selections"
    And The user first selects library "sel1"
    When The user finally chooses sequencing datasets "set1"
    Then The text "Summary of set1" should show up 

  @javascript
  Scenario: The user selected a sequencing dataset and wants to continue to the sequencing dataset browsing
    Given The user "full_access_user" is logged in with "full_access_userpw"
    And The user opens "/selections"
    And The user first selects selection "sel1"
    And The user then selects sequencing dataset "set2"
    When The user clicks "continue with Sequencing Dataset"
    Then The text "Browse by Selection" should show up

  Scenario: A user that may only access sel3 and sel4 tries to access sel1
    Given The user "restricted_user" is logged in with "restricted_userpw"
    When The user opens "/selections"
    Then The row "sel1" should not show up

  Scenario: A restricted user tries to directly access a restricted selection
    Given The user "restricted_user" is logged in with "restricted_userpw"
    When The user opens "/selections/sel1"
    Then The text "Summary of sel1" should not show up
    

