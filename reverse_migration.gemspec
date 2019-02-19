$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "reverse_migration/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "reverse_migration"
  s.version     = ReverseMigration::VERSION
  s.authors     = ["washingtonbezerra"]
  s.email       = ["washingtonbezerra25@gmail.com"]
  s.homepage    = "http://www.invtera.com.br"
  s.summary     = "#{s.homepage}: Summary of ReverseMigration."
  s.description = "#{s.homepage}: Description of ReverseMigration."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.require_path = 'lib'

  #s.add_dependency "rails", "~> 4.2.3"

  #s.add_development_dependency "sqlite3"
end
