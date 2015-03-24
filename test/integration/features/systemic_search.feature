Feature: Systemic Search
  An authenticated user
  Can use the systemic search to list all peptide from multiple sequencing datasets

  @javascript
  Scenario: The user selects two sequencing datasets and selects a peptide from the results
    Given The user "full_access_user" is logged in with "full_access_userpw"
    And The user opens "/systemic-search"
    And The user checks "lib1" checkbox
    And The user checks "sel1" checkbox
    And The user checks "set1" checkbox
    And The user checks "set2" checkbox
    When The user clicks "search" and selects peptide "QARGTAE" from the results
    Then The text "Summary of QARGTAE" should show up

  @javascript
  Scenario: A user that may only access lib2 cannot choose lib1
    Given The user "full_access_user" is logged in with "full_access_userpw"
    And The user opens "/systemic-search"
    When The user finally checks "all" checkbox
    Then The text "sel1" should not show up
