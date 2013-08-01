module Alchemy

  # Alchemy's permissions
  #
  # These are CanCan abilities, but to prevent any naming collusions we named it permissions.
  #
  class Permissions
    include CanCan::Ability

    def initialize(user)
      set_action_aliases
      @user ||= user
      @user ? user_rules : guest_user_rules
    end

    def guest_user_rules
      can([:show, :download], Attachment) { |a| !a.restricted? }
      can :show,              Element,    public: true, page: { restricted: false }
      can :show,              Page,       restricted: false, public: true
      can :see,               Page,       restricted: false, visible: true
      can([:show, :download], Picture)    { |p| !p.restricted? }
    end

    # == Registered user rules
    #
    # Includes guest users rules
    #
    def registered_rules
      guest_user_rules

      # Resources
      can [:show, :download], Attachment
      can :show,              Element,   public: true, page: { restricted: true }
      can :show,              Page,      public: true
      can :see,               Page,      restricted: true, visible: true
      can [:show, :download], Picture
      can :update,            User,      id: @user.id
    end

    # == Author rules
    #
    # Includes registered users rules
    #
    def author_rules
      registered_rules

      # Navigation
      can :index, [
        :alchemy_admin_attachments,
        :alchemy_admin_dashboard,
        :alchemy_admin_layoutpages,
        :alchemy_admin_pages,
        :alchemy_admin_pictures,
        :alchemy_admin_tags
      ]

      # Controller actions
      can [:info, :update_check],         :alchemy_admin_dashboard
      can [:index, :clear],               :trash

      # Resources
      can [:read, :download],             Attachment
      can :manage,                        Clipboard
      can :manage,                        Content
      can :manage,                        Element
      can :manage,                        EssenceFile
      can :manage,                        EssencePicture
      can :edit_content,                  Page
      can [:read, :thumbnail, :info],     Picture
      can :autocomplete,                  Tag
    end

    # == Editor rules
    #
    # Includes author rules
    #
    def editor_rules
      author_rules

      # Navigation
      can :index, [
        :alchemy_admin_languages,
        :alchemy_admin_users
      ]

      # Resources
      can :manage, Page
      can :manage, Picture
      can :manage, Attachment
      can :read,   User
      can :manage, Tag
    end

    # == Admin rules
    #
    # Includes editor rules
    #
    def admin_rules
      editor_rules

      # Navigation
      can :index,  [:alchemy_admin_sites]

      # Resources
      can :manage, User
      can :manage, Language
      can :manage, Site
    end

  private

    def user_rules
      @user.roles.each do |role|
        exec_role_rules(role) if @user.roles.include?(role)
      end
    end

    def exec_role_rules(role)
      meth = :"#{role}_rules"
      send(meth) if respond_to?(meth)
    end

    def set_action_aliases
      alias_action :read, :edit, :fold, :link, :visit, :unlock, :publish,
        to: :edit_content
    end
  end
end
