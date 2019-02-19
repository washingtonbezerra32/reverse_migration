module ReverseMigration
  class Engine < ::Rails::Engine
    require 'Migrate'
  end
end
