Feature: Peptide Comparative Search
  An authenticated user
  Can use the comparative peptide search to compare sequencing datasets by their peptides

  @javascript
  Scenario: The user compares one sequencing dataset against two different ones
    Given The user "full_access_user" is logged in with "full_access_userpw"
    And The user opens "/comparative-search"
    And The user checks "c_lib1" checkbox
    And The user checks "c_sel1" checkbox
    And The user chooses "c_set1" radiobutton
    And The user checks "r_lib1" checkbox
    And The user checks "r_sel1" checkbox
    And The user checks "r_sel2" checkbox
    And The user checks "r_set2" checkbox
    And The user checks "r_set3" checkbox
    When The user clicks "compare selected" and selects peptide "DPLLSVQ" from the peptide comparison
    Then The text "Summary of DPLLSVQ" should show up "2" times

  @javascript
  Scenario: A user that may only access lib2 may only select datasets from this library 
    Given The user "restricted_user" is logged in with "restricted_userpw"
    And The user opens "/comparative-search"
    When The user finally checks "r_all_lib" checkbox
    Then The text "set1" should not show up
