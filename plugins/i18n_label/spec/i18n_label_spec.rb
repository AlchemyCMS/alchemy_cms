require File.dirname(__FILE__) + '/spec_helper'

# give a model to play with
class Reply < ActiveRecord::Base
  attr_accessor :title
end

describe ActionView::Helpers do

  # NOTE gives deprication warning in RSpec 1.1.4:
  # Modules will no longer be automatically included in RSpec version 1.1.4.  Called from ./spec/i18n_label_spec.rb:15
  it "label should make a call to human_attribute_name" do
    Reply.should_receive(:human_attribute_name).with('title').and_return("translated title")
    reply = mock_model(Reply)
    fields_for(reply) do |f|
      f.label(:title).should == "<label for=\"reply_title\">translated title</label>"
    end
  end

end
