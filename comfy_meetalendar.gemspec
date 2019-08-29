# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "meetalendar/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "meetalendar"
  s.version     = Meetalendar::VERSION
  s.authors     = ["Andreas Schau @ HicknHack"]
  s.email       = ["andreas.schau@hicknhack-software.com"]
  s.homepage    = "https://www.hicknhack-software.com/"
  s.summary     = "To have a section on a website that allows gathering of meetup groups. So that their events can regularely be syncronized into a google calendar."
  s.description = "This gem prensents all the needed functionality to search for relevant groups on meetup, remember the chosen ones and offers a task that can be called regularely to transcribe the meetup-groups events to a google calendar. TLDR: It allows the user to subscribe to meetup-groups events."
  s.license     = "MIT"

  s.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|doc)/})
  end

  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 2.3.0"

  s.add_dependency 'rails', '~> 5.2', '>= 5.2.2'

  # httpclient for manual auth calls
  s.add_dependency 'httpclient', '~> 2.8', '>= 2.8.3'

  # google api for calendar event insetion
  s.add_dependency 'google-api-client', '~> 0.30.3'

  # helps encrypt and decrypt tokens from the database
  s.add_dependency 'attr_encrypted', '~> 3.1'

  # helps with exceptions
  s.add_dependency 'activeresource', '~> 5.1'

  # Asset processors
  s.add_dependency 'slim', '~> 4.0', '>= 4.0.1'
  s.add_dependency 'multi_json', '~> 1.13', '>= 1.13.1'
  s.add_dependency 'bootstrap-sass', '~> 3.3', '>= 3.3.7'
end
