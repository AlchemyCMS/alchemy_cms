# This rails template installs Alchemy and all depending gems.
require File.expand_path("../../../alchemy/version", __FILE__)

gem "alchemy_cms",    github: "AlchemyCMS/alchemy_cms",    branch: "master"
gem "alchemy-devise", github: "AlchemyCMS/alchemy-devise", branch: "master"

gem "capistrano-alchemy", github: "AlchemyCMS/capistrano-alchemy", branch: "master", group: "development"
