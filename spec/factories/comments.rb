# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :comment do
    body { "comment body" }
    user { Factory :user }
  end
end
