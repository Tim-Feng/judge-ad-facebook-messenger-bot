FactoryGirl.define do
  factory :commercial_film do
    sequence(:title) { |n| "title #{n}"}
    video_url "https://www.google.com"
    thumbnail_url "https://www.google.com/test.jpg"
  end
end