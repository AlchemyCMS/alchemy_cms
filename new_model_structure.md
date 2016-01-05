# Alchemy::Link

## Attributes:

* url              :string(255)
* robot_follow     :boolean
* title_tag        :string(255)
* canonical        :boolean

## Associations

* belongs_to :resource, polymorphic: true

## Validations

* validates :canonical, uniqueness: {scope: :resource}

## Template

`<a href="/path" robot=follow title="title_tag">#{name}</a>`


# Alchemy::MetaDatum

* META_DATA_TYPES = %w(keywords description robots)

## Attributes

* attr_name        :string (default: name)
* attr_value       :string
* content          :text

## Associations

* belongs_to :page

## Template

`<meta name="" content="">`


# Alchemy::Page

## Attributes:

* title          :string
* layout         :string
* public_on      :datetime
* public_until   :datetime
* locked_by      :integer
* reader_roles   :text # "editor admin moritz"

## Associations:

* has_many :meta_data
* has_many :nodes, as: :resource
* has_many :urls, as: :resource
* has_one :canonical_url, -> { where(canonical: true) }, as: :resource
* has_many :elements
* belongs_to :language

### Methods

* def public?; public_on < Date.current > public_until; end

## Delete

* language_code
* language_root
* visible
* layoutpage
* sitemap

## More

* rename `page_layouts.yml` => `pages.yml`
  * rename `:name` key into `:layout` key


# Alchemy::Node

* name      :string
* parent_id :integer
* lft       :integer
* rgt       :integer
* depth     :integer

## Associations:

* belongs_to :url
* belongs_to :language
* belongs_to :resource, polymorphic: true
