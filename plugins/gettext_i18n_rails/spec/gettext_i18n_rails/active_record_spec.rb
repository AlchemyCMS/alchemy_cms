require File.expand_path("../spec_helper", File.dirname(__FILE__))

FastGettext.silence_errors

ActiveRecord::Base.establish_connection({
  :adapter => "sqlite3",
  :database => ":memory:",
})

ActiveRecord::Schema.define(:version => 1) do
  create_table :car_seats, :force=>true do |t|
    t.string :seat_color
  end
end

class CarSeat < ActiveRecord::Base
  validates_presence_of :seat_color, :message=>"translate me"
end

describe ActiveRecord::Base do
  before do
    FastGettext.current_cache = {}
  end

  it "has a human name that is translated through FastGettext" do
    CarSeat.expects(:_).with('car seat').returns('Autositz')
    CarSeat.human_name.should == 'Autositz'
  end

  it "translates attributes through FastGettext" do
    CarSeat.expects(:s_).with('CarSeat|Seat color').returns('Sitz farbe')
    CarSeat.human_attribute_name(:seat_color).should == 'Sitz farbe'
  end

  it "translates error messages" do
    FastGettext.stubs(:current_repository).returns('translate me'=>"Übersetz mich!")
    FastGettext._('translate me').should == "Übersetz mich!"
    c = CarSeat.new
    c.valid?
    c.errors.on(:seat_color).should == "Übersetz mich!"
  end

  it "translates scoped error messages" do
    FastGettext.stubs(:current_repository).returns('activerecord.errors.translate me'=>"Übersetz mich!")
    FastGettext._('activerecord.errors.translate me').should == "Übersetz mich!"
    c = CarSeat.new
    c.valid?
    c.errors.on(:seat_color).should == "Übersetz mich!"
  end
end