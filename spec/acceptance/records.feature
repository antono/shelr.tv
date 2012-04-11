@javascript
Feature: Records
  As a Ŝelr user
  I would like to browse and publish records
  In order to know something new or impress my friends

  Background:
    Given there are following records
      | title         | fixture | user     |
      | hello world   | ls.json | antono   |
      | goodbye world | ls.json | ntanyone |
      | shelr manual  | ls.json | antono   |
    And I signed in

  Scenario: browsing records
    When I visit "/records" page
    And I click link "hello world"
    Then I should see player for "hello world"
    When I visit "/records" page
    And I click link "goodbye world"
    Then I should see player for "goodbye world"

  Scenario: private records are hidden
    Given record "hello world" is private
    When I visit "/records" page
    Then I should not see "hello world"
    When I visit "/" page
    Then I should not see "hello world"

  Scenario: visiting private records without access key
    Given record "hello world" is private
    When I visit "hello world" record page
    Then I should not see "hello world"
    Then I should see "No such record"

  Scenario: visiting private record with access key
    Given record "hello world" is private
    When I visit "hello world" record page with access key
    Then I should not see player for "hello world"
