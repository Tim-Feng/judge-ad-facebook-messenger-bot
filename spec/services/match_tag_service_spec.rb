require 'spec_helper'

describe MatchTagService do
  describe "match cf" do
    Given(:sender_id) { 1 }
    context "return nothing when no match" do
      Given(:message) { "我不是關鍵字" }
      When {
        @result = MatchTagService.new.match(sender_id, message)
      }
      Then {
        @result == nil
      }
    end
    context "match message/tag" do
      Given { @tag_1 = create(:tag) }
      Given { @commercial_film_1 = create(:commercial_film) }
      Given { create(:commercial_film_tagship, tag_id: @tag_1.id, commercial_film_id: @commercial_film_1.id) }

      context "return corresponding CF" do
        Given(:message) { "m1" }
        When {
          @result = MatchTagService.new.match(sender_id, message)
        }
        Then {
          @result == {
            attachment: {
              type: "template",
              payload: {
                template_type: "generic",
                elements: [
                  { :title => @commercial_film_1.title,
                    :image_url => @commercial_film_1.thumbnail_url,
                    :buttons => [
                      {
                        :type => "web_url",
                        :url => @commercial_film_1.video_url,
                        :title => "立刻觀看"
                      }, {
                        :type => "postback",
                        :title => "影片標籤",
                        :payload => "CF_TAGS_OF_1"
                      }
                    ]
                  }
                ]
              }
            }
          }
        }
      end
      context "create user if message matched" do
        context "create user if no corresponding facebook_user_id" do
          Given(:message) { "m1" }
          Given(:sender_id) { "12345678" }
          When {
            @result = MatchTagService.new.match(sender_id, message)
          }
          Then {
            User.first.facebook_user_id == sender_id
          }
        end
        context "don't create user if got corresponding facebook_user_id" do
          Given(:message) { "m1" }
          Given(:user) { create(:user, facebook_user_id: "12345678") }
          Given(:sender_id) { "12345678" }
          When {
            @result = MatchTagService.new.match(sender_id, message)
          }
          Then {
            User.all.size == 1
          }
        end
      end
      context "add tag searched_count if matched" do
        Given(:message) { "m1" }
        Given(:sender_id) { "12345678" }
        When {
          result = MatchTagService.new.match(sender_id, message)
        }
        Then {
          @tag_1.reload.searched_count == 1
        }
      end
      context "add user searched_tag_and_count if matched, from 0 to 1" do
        Given(:message) { "m1" }
        Given(:sender_id) { "12345678" }
        When {
          result = MatchTagService.new.match(sender_id, message)
        }
        Then {
          User.find_by(facebook_user_id: sender_id).searched_tag_and_count == {
            @tag_1.name => 1
          }
        }
      end

      context "add user searched_tag_and_count if matched" do
        Given(:message) { "m1" }
        Given(:sender_id) { "12345678" }
        When {
          result = MatchTagService.new.match(sender_id, message)
        }
        Then {
          User.find_by(facebook_user_id: sender_id).searched_tag_and_count == {
            @tag_1.name => 1
          }
        }
      end
    end
  end
end