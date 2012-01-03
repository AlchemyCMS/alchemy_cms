module Alchemy
	class PagesController < Alchemy::BaseController

		# We need to include this helper because we need the breadcrumb method.
		# And we cannot define the breadcrump method as helper_method, because rspec does not see helper_methods.
		# Not the best solution, but's working.
		# Anyone with a better idea please provide a patch.
		include Alchemy::BaseHelper

		before_filter :render_page_or_redirect, :only => [:show, :sitemap]
		before_filter :perform_search, :only => :show, :if => proc { configuration(:ferret) }

		filter_access_to :show, :attribute_check => true, :model => Alchemy::Page, :load_method => :load_page

		caches_action(
			:show,
			:cache_path => proc { show_page_url(:urlname => params[:urlname], :lang => multi_language? ? params[:lang] : nil) },
			:if => proc {
				if Alchemy::Config.get(:cache_pages)
					page = Page.find_by_urlname_and_language_id_and_public(
						params[:urlname],
						session[:language_id],
						true,
						:select => 'page_layout, language_id, urlname'
					)
					if page
						pagelayout = PageLayout.get(page.page_layout)
						pagelayout['cache'].nil? || pagelayout['cache']
					end
				else
					false
				end
			},
			:layout => false
		)

		layout :layout_for_page

		# Showing page from params[:urlname]
		# @page is fetched via before filter
		# @root_page is fetched via before filter
		# @language fetched via before_filter in alchemy_controller
		# querying for search results if any query is present via before_filter
		def show
			respond_to do |format|
				format.html { render }
				format.rss {
					if @page.contains_feed?
						render :action => "show.rss.builder", :layout => false
					else
						render :xml => { :error => 'Not found' }, :status => 404
					end
				}
			end
		end

		# Renders a Google conform sitemap in xml
		def sitemap
			@pages = Page.find_all_by_sitemap_and_public(true, true)
			respond_to do |format|
				format.xml { render :layout => "sitemap" }
			end
		end

	protected

		def load_page
			# we need this, because of a dec_auth bug (it calls this method after the before_filter again).
			return @page if @page
			if params[:urlname].blank?
				@page = Page.language_root_for(Language.get_default.id)
			else
				@page = Page.find_by_urlname_and_language_id(params[:urlname], session[:language_id])
				# try to find the page in another language
				if @page.nil?
					@page = Page.find_by_urlname(params[:urlname])
				else
					return @page
				end
			end
		end

		def render_page_or_redirect
			@page ||= load_page
			if User.admins.count == 0 && @page.nil?
				redirect_to signup_path
			elsif @page.blank?
				render_404
			elsif multi_language? && params[:lang].blank?
				redirect_page(:lang => session[:language_code])
			elsif multi_language? && params[:urlname].blank? && !params[:lang].blank? && configuration(:redirect_index)
				redirect_page(:lang => params[:lang])
			elsif configuration(:redirect_to_public_child) && !@page.public?
				redirect_to_public_child
			elsif params[:urlname].blank? && configuration(:redirect_index)
				redirect_page
			elsif !multi_language? && !params[:lang].blank?
				redirect_page
			elsif configuration(:url_nesting) && url_levels.any? && !levels_are_in_page_branch?
				render_404
			elsif configuration(:url_nesting) && should_be_nested? && !url_levels.any?
				redirect_page(params_for_nested_url)
			elsif !configuration(:url_nesting) && url_levels.any?
				redirect_page
			elsif @page.has_controller?
				redirect_to main_app.url_for(@page.controller_and_action)
			else
				# setting the language to page.language to be sure it's correct
				set_language_from(@page.language_id)
				if params[:urlname].blank?
					@root_page = @page
				else
					@root_page = Page.language_root_for(session[:language_id])
				end
			end
		end

		# Performs a search on EssenceRichtext and EssenceText for params['query'].
		# Only performing the search when ferret is enabled in the alchemy/config.yml and 
		# a Page gets found where the searchresults can be rendered. This Page gets found 
		# when a page_layout is marked for rendering searchresults: 
		# 'searchresults: true' in alchemy/page_layouts.yml
		def perform_search
			searchresult_page_layouts = PageLayout.get_all_by_attributes({:searchresults => true})
			if searchresult_page_layouts.any?
				@search_result_page = Page.find_by_page_layout_and_public_and_language_id(searchresult_page_layouts.first["name"], true, session[:language_id])
				if !params[:query].blank? && @search_result_page
					@search_results = []
					%w(Alchemy::EssenceText Alchemy::EssenceRichtext).each do |e|
						@search_results += e.constantize.includes(:contents => {:element => :page}).find_with_ferret(
							"*#{params[:query]}*",
							{:limit => :all},
							{:conditions => [
								'alchemy_pages.public = ? AND alchemy_pages.layoutpage = ? AND alchemy_pages.restricted = ?',
								true, false, false
							]}
						)
					end
					return @search_results.sort{ |y, x| x.ferret_score <=> y.ferret_score } if @search_results.any?
				end
			end
		end

		def find_first_public(page)
			if page.public == true
				return page
			end
			page.children.each do |child|
				result = find_first_public(child)
				if result != nil
					return result
				end
			end
			return nil
		end

		def redirect_to_public_child
			@page = find_first_public(@page)
			if @page.blank?
				render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
			else
				redirect_page
			end
		end

		def redirect_page(options={})
			defaults = {
				:lang => (multi_language? ? @page.language_code : nil),
				:urlname => @page.urlname
			}
			options = defaults.merge(options)
			redirect_to show_page_path(options.merge(additional_params)), :status => 301
		end

		def additional_params
			params.clone.delete_if do |key, value|
				["action", "controller", "urlname", "lang", "level1", "level2", "level3"].include?(key)
			end
		end

		def render_404
			render(:file => "#{Rails.root}/public/404.html", :status => 404, :layout => false)
		end

		def url_levels
			params.keys.grep(/^level[1-3]$/)
		end

		def levels_are_in_page_branch?
			nested_urlnames = breadcrumb(@page).collect(&:urlname)
			level_names = params.select { |k, v| url_levels.include?(k) }.map(&:second)
			level_names & nested_urlnames == level_names
		end

		def should_be_nested?
			!params_for_nested_url.blank?
		end

	end
end
