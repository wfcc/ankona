class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    user ||= User.new # guest user (not logged in)

    can [:read, :json], Author
    can [:index, :read, :create], Competition
    can :manage, Competition, user_id: user.id
    can :manage, Section, user_id: user.id
    can :manage, Section, competition: {user_id: user.id}
    can [:mark, :judge], Section, users: {id: user.id}
    can :manage, Diagram, user_id: user.id
    can :read, Faq
    can :index, Piece
#    can :update, Diagram do |diagram|
#      diagram.user == user
#    end

    #can :judge, Section, user

    @user = user
    user.roles.each { |role| send(role.name) }
    
    admin if user.has_role? :admin

  end

  def admin
    can :manage, :all
  end

  def director
    can :manage, Competition, user_id: @user.id
  end
  
  def nobody
  end
  
  def judge
  end

    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
end
