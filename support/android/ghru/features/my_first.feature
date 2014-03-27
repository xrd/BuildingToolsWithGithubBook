Feature: Login and post

  Scenario: As a valid user I can log into my app and post to my blog
    When I enter the username
    And I enter the password
    Then I press button number 1
    Then I wait up to 10 seconds to see "Logged into GitHub"
    Then I enter "I'm doing great today!" into field number 1
    Then I press button number 1
    Then I wait up to 10 seconds to see "Successful jekyll post"
