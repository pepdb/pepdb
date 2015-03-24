Feature: Cluster browsing
  An authenticated user
  Can use cluster browsing to view the cluster stored in the database
 
  @javascript 
  Scenario: The user wants to view the information on a specific sequencing dataset
    Given The user "full_access_user" is logged in with "full_access_userpw"
    And The user opens "/clusters"
    And The user selects cluster "desltv" in library "lib1", selection "sel1" and dataset "set1"
    When The user finally selects peptide "GEDLTRA"
    Then The text "Summary of GEDLTRA" should show up 

  Scenario: A user without access to lib1 cannot access cluster below this library
    Given The user "restricted_user" is logged in with "restricted_userpw"
    When The user opens "/clusters"
    Then The node "lib1" should not show up

