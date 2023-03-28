# frozen_string_literal: true

def dragonfly_test_app(name = nil)
  app = Dragonfly::App.instance(name)
  app.datastore = Dragonfly::MemoryDataStore.new
  app.secret = "test secret"
  app
end
