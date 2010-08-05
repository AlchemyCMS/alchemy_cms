--- !ruby/object:Gem::Specification 
name: acts_as_ferret
version: !ruby/object:Gem::Version 
  prerelease: false
  segments: 
  - 0
  - 4
  - 6
  version: 0.4.6
platform: ruby
authors: 
- Jens Kraemer
autorequire: 
bindir: bin
cert_chain: []

date: 2010-05-29 00:00:00 +02:00
default_executable: aaf_install
dependencies: 
- !ruby/object:Gem::Dependency 
  name: ferret
  prerelease: false
  requirement: &id001 !ruby/object:Gem::Requirement 
    requirements: 
    - - ">="
      - !ruby/object:Gem::Version 
        segments: 
        - 0
        version: "0"
  type: :runtime
  version_requirements: *id001
description: Rails plugin that adds powerful full text search capabilities to ActiveRecord models.
email: jk@jkraemer.net
executables: 
- aaf_install
extensions: []

extra_rdoc_files: []

files: 
- acts_as_ferret.gemspec
- bin
- bin/aaf_install
- config
- config/ferret_server.yml
- doc
- doc/demo
- doc/demo/app
- doc/demo/app/controllers
- doc/demo/app/controllers/admin
- doc/demo/app/controllers/admin/backend_controller.rb
- doc/demo/app/controllers/admin_area_controller.rb
- doc/demo/app/controllers/application.rb
- doc/demo/app/controllers/contents_controller.rb
- doc/demo/app/controllers/searches_controller.rb
- doc/demo/app/helpers
- doc/demo/app/helpers/admin
- doc/demo/app/helpers/admin/backend_helper.rb
- doc/demo/app/helpers/application_helper.rb
- doc/demo/app/helpers/content_helper.rb
- doc/demo/app/helpers/search_helper.rb
- doc/demo/app/models
- doc/demo/app/models/comment.rb
- doc/demo/app/models/content.rb
- doc/demo/app/models/content_base.rb
- doc/demo/app/models/search.rb
- doc/demo/app/models/shared_index1.rb
- doc/demo/app/models/shared_index2.rb
- doc/demo/app/models/special_content.rb
- doc/demo/app/models/stats.rb
- doc/demo/app/views
- doc/demo/app/views/admin
- doc/demo/app/views/admin/backend
- doc/demo/app/views/admin/backend/search.rhtml
- doc/demo/app/views/contents
- doc/demo/app/views/contents/_form.rhtml
- doc/demo/app/views/contents/edit.rhtml
- doc/demo/app/views/contents/index.rhtml
- doc/demo/app/views/contents/new.rhtml
- doc/demo/app/views/contents/show.rhtml
- doc/demo/app/views/layouts
- doc/demo/app/views/layouts/application.html.erb
- doc/demo/app/views/searches
- doc/demo/app/views/searches/_content.html.erb
- doc/demo/app/views/searches/search.html.erb
- doc/demo/config
- doc/demo/config/boot.rb
- doc/demo/config/database.yml
- doc/demo/config/environment.rb
- doc/demo/config/environments
- doc/demo/config/environments/development.rb
- doc/demo/config/environments/production.rb
- doc/demo/config/environments/test.rb
- doc/demo/config/ferret_server.yml
- doc/demo/config/lighttpd.conf
- doc/demo/config/routes.rb
- doc/demo/db
- doc/demo/db/development_structure.sql
- doc/demo/db/migrate
- doc/demo/db/migrate/001_initial_migration.rb
- doc/demo/db/migrate/002_add_type_to_contents.rb
- doc/demo/db/migrate/003_create_shared_index1s.rb
- doc/demo/db/migrate/004_create_shared_index2s.rb
- doc/demo/db/migrate/005_special_field.rb
- doc/demo/db/migrate/006_create_stats.rb
- doc/demo/db/schema.sql
- doc/demo/doc
- doc/demo/doc/howto.txt
- doc/demo/doc/README_FOR_APP
- doc/demo/public
- doc/demo/public/.htaccess
- doc/demo/public/404.html
- doc/demo/public/500.html
- doc/demo/public/dispatch.cgi
- doc/demo/public/dispatch.fcgi
- doc/demo/public/dispatch.rb
- doc/demo/public/favicon.ico
- doc/demo/public/images
- doc/demo/public/images/rails.png
- doc/demo/public/index.html
- doc/demo/public/robots.txt
- doc/demo/public/stylesheets
- doc/demo/public/stylesheets/scaffold.css
- doc/demo/Rakefile
- doc/demo/README
- doc/demo/README_DEMO
- doc/demo/script
- doc/demo/script/about
- doc/demo/script/breakpointer
- doc/demo/script/console
- doc/demo/script/destroy
- doc/demo/script/ferret_server
- doc/demo/script/generate
- doc/demo/script/performance
- doc/demo/script/performance/benchmarker
- doc/demo/script/performance/profiler
- doc/demo/script/plugin
- doc/demo/script/process
- doc/demo/script/process/inspector
- doc/demo/script/process/reaper
- doc/demo/script/process/spawner
- doc/demo/script/process/spinner
- doc/demo/script/runner
- doc/demo/script/server
- doc/demo/test
- doc/demo/test/fixtures
- doc/demo/test/fixtures/comments.yml
- doc/demo/test/fixtures/contents.yml
- doc/demo/test/fixtures/remote_contents.yml
- doc/demo/test/fixtures/shared_index1s.yml
- doc/demo/test/fixtures/shared_index2s.yml
- doc/demo/test/functional
- doc/demo/test/functional/admin
- doc/demo/test/functional/admin/backend_controller_test.rb
- doc/demo/test/functional/contents_controller_test.rb
- doc/demo/test/functional/searches_controller_test.rb
- doc/demo/test/smoke
- doc/demo/test/smoke/drb_smoke_test.rb
- doc/demo/test/smoke/process_stats.rb
- doc/demo/test/test_helper.rb
- doc/demo/test/unit
- doc/demo/test/unit/comment_test.rb
- doc/demo/test/unit/content_test.rb
- doc/demo/test/unit/ferret_result_test.rb
- doc/demo/test/unit/multi_index_test.rb
- doc/demo/test/unit/remote_index_test.rb
- doc/demo/test/unit/shared_index1_test.rb
- doc/demo/test/unit/shared_index2_test.rb
- doc/demo/test/unit/sort_test.rb
- doc/demo/test/unit/special_content_test.rb
- doc/demo/vendor
- doc/demo/vendor/plugins
- doc/demo/vendor/plugins/will_paginate
- doc/demo/vendor/plugins/will_paginate/init.rb
- doc/demo/vendor/plugins/will_paginate/lib
- doc/demo/vendor/plugins/will_paginate/lib/will_paginate
- doc/demo/vendor/plugins/will_paginate/lib/will_paginate/collection.rb
- doc/demo/vendor/plugins/will_paginate/lib/will_paginate/core_ext.rb
- doc/demo/vendor/plugins/will_paginate/lib/will_paginate/finder.rb
- doc/demo/vendor/plugins/will_paginate/lib/will_paginate/view_helpers.rb
- doc/demo/vendor/plugins/will_paginate/LICENSE
- doc/demo/vendor/plugins/will_paginate/Rakefile
- doc/demo/vendor/plugins/will_paginate/README
- doc/demo/vendor/plugins/will_paginate/test
- doc/demo/vendor/plugins/will_paginate/test/array_pagination_test.rb
- doc/demo/vendor/plugins/will_paginate/test/boot.rb
- doc/demo/vendor/plugins/will_paginate/test/console
- doc/demo/vendor/plugins/will_paginate/test/finder_test.rb
- doc/demo/vendor/plugins/will_paginate/test/fixtures
- doc/demo/vendor/plugins/will_paginate/test/fixtures/admin.rb
- doc/demo/vendor/plugins/will_paginate/test/fixtures/companies.yml
- doc/demo/vendor/plugins/will_paginate/test/fixtures/company.rb
- doc/demo/vendor/plugins/will_paginate/test/fixtures/developer.rb
- doc/demo/vendor/plugins/will_paginate/test/fixtures/developers_projects.yml
- doc/demo/vendor/plugins/will_paginate/test/fixtures/project.rb
- doc/demo/vendor/plugins/will_paginate/test/fixtures/projects.yml
- doc/demo/vendor/plugins/will_paginate/test/fixtures/replies.yml
- doc/demo/vendor/plugins/will_paginate/test/fixtures/reply.rb
- doc/demo/vendor/plugins/will_paginate/test/fixtures/schema.sql
- doc/demo/vendor/plugins/will_paginate/test/fixtures/topic.rb
- doc/demo/vendor/plugins/will_paginate/test/fixtures/topics.yml
- doc/demo/vendor/plugins/will_paginate/test/fixtures/user.rb
- doc/demo/vendor/plugins/will_paginate/test/fixtures/users.yml
- doc/demo/vendor/plugins/will_paginate/test/helper.rb
- doc/demo/vendor/plugins/will_paginate/test/lib
- doc/demo/vendor/plugins/will_paginate/test/lib/activerecord_test_connector.rb
- doc/demo/vendor/plugins/will_paginate/test/lib/load_fixtures.rb
- doc/demo/vendor/plugins/will_paginate/test/pagination_test.rb
- doc/monit-example
- doc/README.win32
- init.rb
- install.rb
- lib
- lib/act_methods.rb
- lib/acts_as_ferret.rb
- lib/ar_mysql_auto_reconnect_patch.rb
- lib/blank_slate.rb
- lib/bulk_indexer.rb
- lib/class_methods.rb
- lib/ferret_extensions.rb
- lib/ferret_find_methods.rb
- lib/ferret_result.rb
- lib/ferret_server.rb
- lib/index.rb
- lib/instance_methods.rb
- lib/local_index.rb
- lib/more_like_this.rb
- lib/multi_index.rb
- lib/rdig_adapter.rb
- lib/remote_functions.rb
- lib/remote_index.rb
- lib/remote_multi_index.rb
- lib/search_results.rb
- lib/server_manager.rb
- lib/unix_daemon.rb
- lib/without_ar.rb
- LICENSE
- rakefile
- README
- recipes
- recipes/aaf_recipes.rb
- script
- script/ferret_daemon
- script/ferret_server
- script/ferret_service
- tasks
- tasks/ferret.rake
has_rdoc: true
homepage: http://github.com/jkraemer/acts_as_ferret
licenses: []

post_install_message: 
rdoc_options: []

require_paths: 
- lib
required_ruby_version: !ruby/object:Gem::Requirement 
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      segments: 
      - 0
      version: "0"
required_rubygems_version: !ruby/object:Gem::Requirement 
  requirements: 
  - - ">="
    - !ruby/object:Gem::Version 
      segments: 
      - 0
      version: "0"
requirements: []

rubyforge_project: acts_as_ferret
rubygems_version: 1.3.6
signing_key: 
specification_version: 3
summary: acts_as_ferret - Ferret based full text search for any ActiveRecord model
test_files: []

