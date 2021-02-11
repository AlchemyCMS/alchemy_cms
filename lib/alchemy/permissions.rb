# frozen_string_literal: true

module Alchemy
  # ## Alchemy's permissions
  #
  # These are CanCan abilities, but to prevent any naming collusions we named it permissions.
  #
  # Alchemy user rules are modules that can be included in your app's/engine's Ability class.
  #
  # ### Example:
  #
  #     # app/models/ability.rb
  #     class Ability
  #       include CanCan::Ability
  #       include Alchemy::Permissions::EditorUser
  #
  #       def initialize(user)
  #         return if user.nil?
  #         @user ||= user
  #         if @user.has_role?(:demo)
  #           alchemy_editor_rules # alchemy editor roles
  #           # your own rules
  #         end
  #       end
  #     end
  #
  class Permissions
    include CanCan::Ability

    def initialize(user)
      set_action_aliases
      @user ||= user
      @user ? user_role_rules : alchemy_guest_user_rules
    end

    module GuestUser
      def alchemy_guest_user_rules
        can([:show, :download], Alchemy::Attachment) { |a| !a.restricted? }

        can :read, Alchemy::Content, Alchemy::Content.available.not_restricted do |c|
          c.public? && !c.restricted?
        end

        can :read, Alchemy::Element, Alchemy::Element.available.not_restricted do |e|
          e.public? && !e.restricted?
        end

        can :read, Alchemy::Page, Alchemy::Page.published.not_restricted do |p|
          p.public? && !p.restricted?
        end
      end
    end

    # == Member rules
    #
    # Includes guest users rules
    #
    module MemberUser
      include Alchemy::Permissions::GuestUser

      def alchemy_member_rules
        alchemy_guest_user_rules

        # Resources
        can [:show, :download], Alchemy::Attachment

        can :read, Alchemy::Content, Alchemy::Content.available do |c|
          c.public?
        end

        can :read, Alchemy::Element, Alchemy::Element.available do |e|
          e.public?
        end

        can :read, Alchemy::Page, Alchemy::Page.published do |p|
          p.public?
        end
      end
    end

    # == Author rules
    #
    # Includes member users rules
    #
    module AuthorUser
      include Alchemy::Permissions::MemberUser

      def alchemy_author_rules
        alchemy_member_rules

        # Navigation
        can :index, [
          :alchemy_admin_attachments,
          :alchemy_admin_dashboard,
          :alchemy_admin_layoutpages,
          :alchemy_admin_nodes,
          :alchemy_admin_pages,
          :alchemy_admin_pictures,
          :alchemy_admin_tags,
          :alchemy_admin_users,
        ]

        # Controller actions
        can :leave,                 :alchemy_admin
        can [:info, :help],         :alchemy_admin_dashboard
        can :manage,                :alchemy_admin_clipboard
        can :edit,                  :alchemy_admin_layoutpages
        can :tree,                  :alchemy_admin_pages

        # Resources
        can [:read, :download],     Alchemy::Attachment
        can :manage,                Alchemy::Content
        can :manage,                Alchemy::Element
        can :manage,                Alchemy::EssenceFile
        can :manage,                Alchemy::EssencePicture
        can :manage,                Alchemy::LegacyPageUrl
        can :manage,                Alchemy::Node
        can :read,                  Alchemy::Picture
        can [:read, :autocomplete], Alchemy::Tag
        can(:edit_content,          Alchemy::Page) { |p| p.editable_by?(@user) }
      end
    end

    # == Editor rules
    #
    # Includes author rules
    #
    module EditorUser
      include Alchemy::Permissions::AuthorUser

      def alchemy_editor_rules
        alchemy_author_rules

        # Navigation
        can :index, [
          :alchemy_admin_languages,
          :alchemy_admin_users,
        ]

        # Resources
        can [
          :copy,
          :copy_language_tree,
          :flush,
          :order,
          :sort,
          :switch_language,
        ], Alchemy::Page

        # Resources which may be locked via template permissions
        #
        #     # config/alchemy/page_layouts.yml
        #     - name: contact
        #       editable_by:
        #         - freelancer
        #         - admin
        #
        can([
          :create,
          :destroy,
        ], Alchemy::Page) { |p| p.editable_by?(@user) }

        can(:publish, Alchemy::Page) do |page|
          page.language.public? && page.editable_by?(@user)
        end

        can :manage, Alchemy::Picture
        can :manage, Alchemy::Attachment
        can :manage, Alchemy::Tag
        can :index,  Alchemy::Language
      end
    end

    # == Admin rules
    #
    # Includes editor rules
    #
    module AdminUser
      include Alchemy::Permissions::EditorUser

      def alchemy_admin_rules
        alchemy_editor_rules

        # Navigation
        can :index,                 [:alchemy_admin_sites, :alchemy_admin_styleguide]

        # Controller actions
        can [:info, :update_check], :alchemy_admin_dashboard

        # Resources
        can :manage,                Alchemy::Language
        can :manage,                Alchemy::Site
      end
    end

    private

    def user_role_rules
      return alchemy_guest_user_rules if @user.alchemy_roles.blank?

      @user.alchemy_roles.each do |role|
        exec_role_rules(role)
      end
    end

    def exec_role_rules(role)
      meth = :"alchemy_#{role}_rules"
      send(meth) if respond_to?(meth)
    end

    def set_action_aliases
      alias_action :configure,
        :fold,
        :info,
        :link,
        :read,
        :update,
        :unlock,
        :visit,
        :tree,
        to: :edit_content
    end

    # Include the role specific permissions.
    include GuestUser
    include MemberUser
    include AuthorUser
    include EditorUser
    include AdminUser
  end
end
