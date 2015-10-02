class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if user.has_role? :admin
      can :access, :rails_admin
      can :dashboard
      
      can :manage, :all
    end
  end
end
