class Api::V1::Ability
  # All API users are authorized using this class
  include CanCan::Ability

  def initialize(user, opts = {})
    user ||= User.new # guest user (not logged in)

    # See wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
    
    unless user.new_record?
      if user.is_sysadmin?
        can :manage, :all
      else
        editions = user.roles.with_role(:apifull).collect(&:edition_id)
        templates = user.roles.includes(:edition => :phase).with_role(:apifull).collect { |r| r.edition.phase.template_id }

        unless editions.blank?
          can [:read, :users, :usersCERIF], Edition, id: editions
          can [:read], PhaseEditionInstance, edition_id: editions
          can [:read, :update], Answer, phase_edition_instance: { edition_id: editions }
          can [:create], Plan
          can [:create], TemplateInstance, template_id: templates
        end

      end
    end

  end
end
