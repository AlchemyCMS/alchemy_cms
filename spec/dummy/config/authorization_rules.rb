authorization do

	role :admin do
		has_permission_on :admin_events, :to => [:manage]
	end

end