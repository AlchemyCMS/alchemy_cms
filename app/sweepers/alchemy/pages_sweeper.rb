module Alchemy
	class PagesSweeper < ActionController::Caching::Sweeper

		observe Page

		def after_update(page)
			unless page.layoutpage?
				expire_page(page)
				check_multipage_elements(page)
			end
		end

		def after_destroy(page)
			unless page.layoutpage?
				expire_page(page)
				check_multipage_elements(page)
			end
		end

	private

		def check_multipage_elements(page)
			page.elements.each do |element|
				# are their pages beneath mine?
				if !element.to_be_sweeped_pages.detect{ |p| p != page }.nil?
					# yepp! there are more pages then mine
					pages = element.to_be_sweeped_pages.find_all_by_public_and_locked(true, false)
					if !pages.blank?
						# expire current page, even if it's locked
						pages.push(page).each do |page|
							expire_page(page)
						end
					end
				end
			end
		end

		def expire_page(page)
			return if page.do_not_sweep
			expire_action(
				:controller => '/alchemy/pages',
				:action => :show,
				:urlname => page.urlname_was,
				:lang => multi_language? ? page.language_code : nil
			)
		end

	end
end
