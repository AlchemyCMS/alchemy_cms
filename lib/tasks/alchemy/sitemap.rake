class SiteMapIssueFinder
  attr_reader :save
  attr_accessor :depth_issue_page_ids, :lft_rgt_issue_page_ids

  def initialize(save: false)
    @save = save
    @depth_issue_page_ids = Set.new
    @lft_rgt_issue_page_ids = Set.new
  end

  def depth_issues
    puts "\nFind Page Depth Issues"
    puts "======================\n"

    Alchemy::Page.each_with_level(Alchemy::Page.root.self_and_descendants) do |page, level|
      not_the_same_level = level != page.depth
      print not_the_same_level ? "F" : "."
      if not_the_same_level
        depth_issue_page_ids << page.id
        page.update_column(:depth, level) if save
      end
    end

    print_conclusion(depth_issue_page_ids, "depth")
  end

  def lft_rgt_issues
    puts "\nFind Page Left/Right Value Issues"
    puts "=================================\n"

    Alchemy::Page.roots.each do |root_page|
      traverse_children(root_page, root_page.lft)
    end

    print_conclusion(lft_rgt_issue_page_ids, "left/right value")
  end

  private

  def print_conclusion(page_ids, field_description)
    puts "\n\n"
    if page_ids.length > 0
      if save
        puts "Found and corrected #{field_description} for #{page_ids.length} page(s)!"
      else
        puts "Following Pages have an incorrect #{field_description}: #{page_ids.join(", ")}"
      end
    else
      puts "All pages have the correct #{field_description}!\n"
    end
    puts "\n"
  end

  def fix_page_field(page, field, counter)
    wrong_counter = page[field] != counter
    print wrong_counter ? "F" : "."
    if wrong_counter
      lft_rgt_issue_page_ids << page.id
      page.update_column(field, counter) if save
    end
  end

  ##
  # @param [Alchemy::Page] page
  # @param [Integer] counter
  # @return [Integer]
  def traverse_children(page, counter)
    page.children.order(lft: :asc).each do |child_page|
      counter += 1
      fix_page_field(child_page, :lft, counter)
      counter = traverse_children(child_page, counter) unless child_page.leaf?

      counter += 1
      fix_page_field(child_page, :rgt, counter)
    end

    counter
  end
end

namespace :alchemy do
  namespace :sitemap do
    desc "Get an overview over all sitemap issues"
    task anomalies: [:environment] do
      finder = SiteMapIssueFinder.new
      finder.lft_rgt_issues
      finder.depth_issues
    end

    desc "Fix nested set sitemap issues"
    task fix: [:environment] do
      finder = SiteMapIssueFinder.new(save: true)
      finder.lft_rgt_issues
      finder.depth_issues
    end
  end
end
