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
