# This rails template installs Alchemy and all depending gems.
require File.expand_path("../../../alchemy/version", __FILE__)

gem "alchemy_cms",    github: "AlchemyCMS/alchemy_cms",    branch: "3.1-stable"
gem "alchemy-devise", github: "AlchemyCMS/alchemy-devise", branch: "2.1-stable"

gem "capistrano", "~> 2.15.5", group: "development"
