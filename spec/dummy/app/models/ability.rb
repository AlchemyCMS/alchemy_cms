class Ability
  include CanCan::Ability

  def initialize(user)
    can :manage, Event
    can :index, :admin_events
    can :manage, Location
    can :index, :admin_locations
    can :manage, Series
    can :index, :admin_series
  end
end
