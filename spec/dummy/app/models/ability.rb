class Ability
  include CanCan::Ability

  def initialize(user)
    can :manage, Event
    can :index, :admin_events
  end

end
