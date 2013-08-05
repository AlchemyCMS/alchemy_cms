module Alchemy
  module Upgrader::ThreePointZero

  private

    def rename_registered_role_into_member
      desc "Rename registered user's role into member"
      users = User.all.where("roles LIKE '%registered%'")
      if users.count == 0
        log "No users with registered role found.", :skip
      else
        users.each do |user|
          user.roles = user.roles.each { |r| r.gsub!(/\bregistered\b/, 'member') }
          if user.save
            log "User ##{user.id} converted"
          else
            log "User ##{user.id} not converted", :error
          end
        end
      end
    end

  end
end
