Feature: Login feature

  Scenario: As a valid user I can log into my app
    When I enter the username
    And I enter the password
    Then I press view with id "login"
    Then I wait up to 3 seconds to see "Logged into GitHub"
