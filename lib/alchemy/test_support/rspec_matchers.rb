RSpec::Matchers.define :have_link_with_tooltip do |content|
  match do |session|
    session.has_css?(%([content="#{content}"] a))
  end
end

# Here's a tiny custom matcher making it a bit easier to check the
# current session for a language configuration.
#
RSpec::Matchers.define :include_language_information_for do |expected|
  match do |actual|
    actual[:alchemy_language_id] == expected.id
  end
end

# This matcher checks for the presence of an alchemy-select component with a given label.
RSpec::Matchers.define :have_alchemy_select do |expected|
  match do |session|
    label = session.find(:css, "label", exact_text: expected)
    label.has_sibling?(%(select[is="alchemy-select"]), visible: :all)
  end
end
