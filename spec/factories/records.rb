FactoryGirl.define do
  factory :record do
    title { "Record title" }
    description { "Record Description" }
    user { Factory :user }
  end
end
