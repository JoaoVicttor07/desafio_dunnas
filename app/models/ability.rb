# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user

    if user.administrator?
      can :manage, :all
    elsif user.collaborator?
      can :read, :all
      can :manage, Ticket
    else
      can :read, Block
      can :read, Unit
      can :manage, Ticket, user_id: user.id
    end
  end
end
