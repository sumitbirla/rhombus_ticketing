$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "rhombus_ticketing/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "rhombus_ticketing"
  s.version     = RhombusTicketing::VERSION
  s.authors     = ["Sumit Birla"]
  s.email       = ["sbirla@tampahost.net"]
  s.homepage    = "http://github.com/sumitbirla/rhombus_ticketing"
  s.summary     = "Ticketing (customer service) plugin for Rhombus"
  s.description = "Rhombus is a rails framework to quickly spin up website with different sets of functionality."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

end
