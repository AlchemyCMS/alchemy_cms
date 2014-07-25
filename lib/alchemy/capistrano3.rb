# This recipe contains Capistrano recipes for handling the uploads and picture cache files while deploying your application.
#
require 'fileutils'
require 'alchemy/tasks/helpers'
# Loading the current Rails app's env, so we can get the Alchemy mount point.
require './config/environment.rb'
require 'alchemy/mount_point'

include Alchemy::Tasks::Helpers
load File.expand_path('../tasks/alchemy.cap', __FILE__)
