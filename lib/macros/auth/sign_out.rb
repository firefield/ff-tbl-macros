# frozen_string_literal: true

module Macros
  class Auth
    # Signout the given user. The user can be passed in the context.
    #
    # @example signout a user specified in the context (:scope or :model)
    #   step Macros::Auth::SignOut()
    #
    # @example signout the user passed in ctx[:impersonated_user]
    #   step Macros::Auth::SignOut(user_key: :impersonated_user)
    class SignOut < Macros::Base
      # @return [Macro::Auth::SignOut] step macro instance
      # @param user_key [Hash] ctx key under which is the user which we want to signout
      def initialize(user_key: nil)
        @user_key = user_key
        @user = nil
      end

      # Performs a step by signout the given user
      # @param ctx [Trailblazer::Skill] tbl context hash
      def call(ctx, warden:, **)
        @user = ctx[@user_key] if @user_key

        ctx[:scope] = scope(ctx)
        warden_user = warden.user(scope: ctx[:scope], run_callbacks: false)
        ctx[:model] = warden_user unless @user
        warden.logout(ctx[:scope])
        warden.clear_strategies_cache!(scope: ctx[:scope])
        true
      end

      def scope(ctx)
        resource_or_scope = if @user
                              @user
                            elsif ctx[:scope]
                              ctx[:scope]
                            elsif ctx[:model]
                              ctx[:model]
                            else
                              :user
                            end

        Devise::Mapping.find_scope!(resource_or_scope)
      end
    end
  end
end
