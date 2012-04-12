@javascript
Feature: Dashboard
  As a Ŝelr user
  I would like to have dashboard
  In order to view latest activity

  Scenario: display lastest comments
    Given there are following records
      | title         | fixture | user     |
      | hello world   | ls.json | antono   |
    And "hello world" record has 3 comments
    And I signed in
    And I am the owner of "hello world" record
    When I visit "/dashboard" page
    Then I should see 3 comments

  Scenario: not logged in user wants to see dashboard
    When I visit "/dashboard" page
    Then I should be on "/records" page

  Scenario: not logged in user should not see dashboard link in top menu
    When I visit "/records" page
    Then I should not see "Home"
