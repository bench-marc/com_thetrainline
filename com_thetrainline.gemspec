# frozen_string_literal: true

require_relative "lib/com_thetrainline/version"

Gem::Specification.new do |spec|
  spec.name = "com_thetrainline"
  spec.version = ComThetrainline::VERSION
  spec.authors = ["Marc Diehlmann"]
  spec.email = ["marc.diehlmann@gmail.com"]

  spec.summary = "thetrainline client"
  spec.description = "gets prices from thetrainline"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency "faraday"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
