Feature: Peptide Property Search
  An authenticated user
  Can use the property search to for specific peptides in the selected sequencing datsets

  @javascript
  Scenario: The user performs a simple search for a specific peptide
    Given The user "full_access_user" is logged in with "full_access_userpw"
    And The user opens "/property-search"
    And The user selects "complete sequence" as "search type"
    And The user fills "query sequence" with "NDVRAVS"
    When The user clicks "search" and selects peptide "NDVRAVS" from the results
    Then The text "Summary of NDVRAVS" should show up

  @javascript
  Scenario: The user performs a similarity search for a specific peptide
    Given The user "full_access_user" is logged in with "full_access_userpw"
    And The user opens "/property-search"
    And The user selects "complete sequence" as "search type"
    And The user fills "query sequence" with "ERSYLSI"
    And The user fills "number of similar sequences" with "10"
    And The user fills "minimal similarity quotient" with "0.3"
    When The user clicks "search" and selects peptide "ERSGAQL" from the similar sequences
    Then The text "Summary of ERSGAQL" should show up

  @javascript
  Scenario: The user performs a search given a partial peptide sequence 
    Given The user "full_access_user" is logged in with "full_access_userpw"
    And The user opens "/property-search"
    And The user selects "partial sequence" as "search type"
    And The user fills "query sequence" with "er"
    When The user clicks "search" and selects peptide "TERSGFT" from the results
    Then The text "Summary of TERSGFT" should show up
  
  @javascript
  Scenario: The user performs a wildcard search 
    Given The user "full_access_user" is logged in with "full_access_userpw"
    And The user opens "/property-search"
    And The user selects "wildcard sequence" as "search type"
    And The user fills "query sequence" with "BZ+"
    When The user clicks "search" and selects peptide "DSRYLHD" from the results
    Then The text "Summary of DSRYLHD" should show up
    
  @javascript
  Scenario: The user performs a reverse wildcard search 
    Given The user "full_access_user" is logged in with "full_access_userpw"
    And The user opens "/property-search"
    And The user selects "reverse wildcard sequence" as "search type"
    And The user fills "query sequence" with "NDVRAVS"
    When The user clicks "search" and selects peptide "AVARLLP" from the results
    Then The text "Summary of AVARLLP" should show up

  
  @javascript
  Scenario: A user that may only access lib2 may only receive results from this library 
    Given The user "restricted_user" is logged in with "restricted_userpw"
    And The user opens "/property-search"
    And The user selects "complete sequence" as "search type"
    And The user fills "query sequence" with "DPLLSVQ"
    When The user clicks "search"
    Then The text "set1" should not show up
