class SitemapError < StandardError
  attr_reader :page, :counter

  def initialize(msg = nil, page:, counter:)
    super(msg)
    @page = page
    @counter = counter
  end
end

##
# @param [Alchemy::Page] page
# @param [Integer] counter
# @return [Object]
def traverse_children(page, counter, save: false)
  page.children.order(lft: :asc).each do |child_page|
    counter += 1
    if child_page.lft != counter
      if save
        child_page.update_column(:lft, counter)
        puts "Updated page #{child_page.id} => #{child_page.lft} (lft)"
      else
        raise SitemapError.new("Wrong page lft", page: child_page, counter:)
      end
    end

    counter = traverse_children(child_page, counter, save:) unless child_page.leaf?

    counter += 1
    if child_page.rgt != counter
      if save
        puts "Updated page #{child_page.id} => #{child_page.rgt} (rgt)"
        child_page.update_column(:rgt, counter)
      else
        raise SitemapError.new("Wrong page rgt", page: child_page, counter:)
      end
    end
  end

  counter
end

##
# @param [Alchemy::Page] page
# @return [Array<number>]
def missing_counts(page)
  parent = page.parent
  counter_values = (parent.lft + 1..parent.rgt - 1).to_a

  parent.descendants.each do |descendant|
    counter_values.delete_at(counter_values.index(descendant.lft)) if counter_values.index(descendant.lft)
    counter_values.delete_at(counter_values.index(descendant.rgt)) if counter_values.index(descendant.rgt)
  end
  counter_values
end

def test_lft_rgt_counter
  # @type [Alchemy::Page] root_page
  Alchemy::Page.roots.each do |root_page|
    traverse_children(root_page, root_page.lft)
  end
  puts "No sitemap lft/rgt - issues found! 🥳\n\n"
rescue SitemapError => error
  puts "#{error.message}\n\n"
  missing_counts = missing_counts(error.page)
  puts "Page #{error.page.id} (#{error.page.urlname})\nPosition: #{error.page.lft} (lft) - #{error.page.rgt} (rgt)\n"
  if missing_counts.length == 1
    puts "Calculated Position: #{missing_counts.first}"
  else
    puts "Counted Position: #{error.counter}\nMissing Counts: #{missing_counts.join(", ")}"
  end
end

def test_page_level
  wrong_depth = []

  Alchemy::Page.each_with_level(Alchemy::Page.root.self_and_descendants) do |page, level|
    if level != page.depth
      wrong_depth.push("Page #{page.urlname} => Level: #{level} Depth: #{page.depth}")
    end
  end

  if wrong_depth.empty?
    puts "The depth of all page nodes is correct! 🥳\n\n"
  else
    puts "#{wrong_depth.length} pages don't have the correct page depth:\n\n"
    wrong_depth.each do |entry|
      puts entry
    end
  end
end

namespace :sitemap do
  desc "Get an overview over sitemap issues"
  task anomalies: [:environment] do
    test_lft_rgt_counter
    test_page_level
  end

  namespace :anomalies do
    desc "Get an overview over sitemap left right issues"
    task lft_rgt: [:environment] do
      test_lft_rgt_counter
    end

    desc "Get an overview over sitemap depth issues"
    task page_level: [:environment] do
      test_page_level
    end
  end

  desc "Fix lft/rgt values for a specific page and it descendants"
  task fix_lft_rgt_values: [:environment] do
    Alchemy::Page.roots.each do |root_page|
      traverse_children(root_page, root_page.lft, save: true)
    end
  end

  desc "Fix page depth if the calculated level is not equal database depth entry"
  task fix_page_depth: [:environment] do
    Alchemy::Page.each_with_level(Alchemy::Page.root.self_and_descendants) do |page, level|
      if level != page.depth
        page.update_column(:depth, level)
        print "."
      end
    end
    puts "\nUpdated page depth!"
  end
end
