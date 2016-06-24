FactoryGirl.define do
  factory :commercial_film do
    sequence(:title) { |n| "title #{n}"}
    video_url "https://www.google.com"
    short_url "https://goo.gl/boooo"
    thumbnail_url "https://www.google.com/test.jpg"
  end
end