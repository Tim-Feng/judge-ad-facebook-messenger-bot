require 'spec_helper'

describe MatchTagService do
  describe "match cf" do
    Given(:sender_id) { 1 }
    Given { create(:tag) }
    context "return nothing when no match" do
      Given(:message) { "我不是關鍵字" }
      When {
        @result = MatchTagService.new.match(sender_id, message)
      }
      Then {
        @result == nil
      }
    end
  end
end