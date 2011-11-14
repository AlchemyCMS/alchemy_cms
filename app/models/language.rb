class Language < ActiveRecord::Base

  validates_presence_of :name
  validates_presence_of :code
  validates_presence_of :page_layout
  validates_presence_of :frontpage_name
  validates_uniqueness_of :code
  validate :presence_of_default_language
  validate :publicity_of_default_language
  has_many :pages
  after_destroy :delete_language_root_page
  validates_format_of :code, :with => /^[a-z]{2}$/
  before_destroy :check_for_default
  after_update :set_pages_language, :if => proc { |m| m.code_changed? }
  before_save :remove_old_default, :if => proc { |m| m.default_changed? && m != Language.get_default }

  scope :published, where(:public => true)

  def self.all_for_created_language_trees
    find(Page.language_roots.collect(&:language_id))
  end

  def self.all_codes_for_published
    self.published.collect(&:code)
  rescue
    []
  end

  def self.get_default
    self.find_by_default(true)
  end

  def label(attrib)
    if attrib.to_sym == :code
      self.code
    else
      I18n.t("name", :scope => "alchemy.languages.#{self.code}", :default => self.name)
    end
  end

private

  def publicity_of_default_language
    if self.default? && !self.public?
      errors.add(:base, N_("Defaut language has to be public"))
      return false
    else
      return true
    end
  end

  def presence_of_default_language
    if Language.get_default == self && self.default_changed?
      errors.add(:base, N_("we_need_at_least_one_default"))
      return false
    else
      return true
    end
  end

  def remove_old_default
    lang = Language.get_default
    return true if lang.nil?
    lang.default = false
    lang.save(:validate => false)
  end

  def set_pages_language
    pages.map { |page| page.language_code = self.code; page.save(:validate => false) }
  end

  def check_for_default
    raise "Default language not deletable" if self.default?
  end

  def delete_language_root_page
    page = Page.language_root_for(id)
    page.destroy if page
    layoutroot = Page.layout_root_for(id)
    layoutroot.destroy if layoutroot
  end

end
