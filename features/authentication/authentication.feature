Feature: Authentication
  To ensure the safety of the application
  A regular user of the system
  Must authenticate before using the app

  Scenario: Failed Login
    Given I am not authenticated
    When I go to /login
    And I fill in "email" with "a@a.com"
    And I fill in "password" with "pop"
    And I press "login"
    Then the login request should fail
    Then I should see an error message