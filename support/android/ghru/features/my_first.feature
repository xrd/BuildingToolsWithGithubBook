Feature: Login and post

  Scenario: As a valid user I can log into my app and post to my blog
    When I enter the username
    And I enter the password
    And I press button number 1
    Then I wait up to 10 seconds to see "Logged into GitHub"
    Then I choose my blog
    And I enter my current mood status
    And I press button number 1
    Then I wait up to 10 seconds to see "Successful jekyll post"
    And I have a new jekyll post with my mood status
