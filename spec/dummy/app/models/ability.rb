# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(*)
    can :manage, Event
    can :index, :admin_events
    can :manage, Location
    can :index, :admin_locations
  end
end
