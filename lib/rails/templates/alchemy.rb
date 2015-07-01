# This rails template installs Alchemy and all depending gems.
require File.expand_path("../../../alchemy/version", __FILE__)

gem "alchemy_cms",    github: "AlchemyCMS/alchemy_cms",    branch: "3.2-stable"
gem "alchemy-devise", github: "AlchemyCMS/alchemy-devise", branch: "3.2-stable"

gem "capistrano-alchemy", github: "AlchemyCMS/capistrano-alchemy", branch: "master", group: "development"
