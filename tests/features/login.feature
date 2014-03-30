Feature: Login
  In order to use pepDB
  A user
  Needs to login with his credentials

  Scenario: Unauthenticated user tries to open data browsing
    Given The user is not logged in
    When The user opens 'libraries'
    Then The login page should show up
  
  Scenario: Unauthenticated user submit correct credentials
    Given The user is not logged in
    And The user visits the main page
    And The user fills "username" with "test1"
    And The user fills "password" with "test"
    When The user clicks "Login"
    Then The welcome page should show up

  Scenario: Unauthenticated user submits incorrect credentials
    Given The user is not logged in
    And The user visits the main page
    And The user fills "username" with "random_name"
    And The user fills "password" with "random_password"
    When The user clicks "Login"
    Then The message "Error! The username or password you entered is inccorect" should show up
