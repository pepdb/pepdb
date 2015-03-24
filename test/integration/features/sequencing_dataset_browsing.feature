Feature: Sequencing Dataset browsing
  An authenticated user
  Can use sequencing dataset browsing to view the sequencing datasets stored in the database
  
  Scenario: The user wants to view the information on a specific sequencing dataset
    Given The user "full_access_user" is logged in with "full_access_userpw"
    And The user opens "/datasets"
    When The user finally selects sequencing datasets "set1"
    Then The text "Summary of set1" should show up 

  Scenario: The user wants to view the peptides within a specific sequencing dataset
    Given The user "full_access_user" is logged in with "full_access_userpw"
    And The user opens "/datasets"
    When The user finally selects selection "set1"
    Then The text "Peptides in Sequencing Dataset set1" should show up 

  @javascript
  Scenario: The user wants to view the information on a specific peptide within a specific sequencing dataset
    Given The user "full_access_user" is logged in with "full_access_userpw"
    And The user opens "/datasets"
    And The user first selects sequencing dataset "set1"
    When The user finally chooses peptide "DPLLSVQ"
    Then The text "Summary of DPLLSVQ" should show up 

  Scenario: A user that may not access sequencing dataset set1 tries to access it
    Given The user "restricted_user" is logged in with "restricted_userpw"
    When The user opens "/datasets"
    Then The row "set1" should not show up

  Scenario: A restricted user tries to directly access a restricted selection
    Given The user "restricted_user" is logged in with "restricted_userpw"
    When The user opens "/datasets/set1"
    Then The text "Summary of set1" should not show up
    

