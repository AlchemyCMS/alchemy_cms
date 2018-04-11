# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    can :manage, Event
    can :index, :admin_events
    can :manage, Location
    can :index, :admin_locations
  end
end
