FactoryGirl.define do
  factory :record do
    title { "Record title" }
    description { "Record Description" }
    user { FactoryGirl.create :user }
  end
end
