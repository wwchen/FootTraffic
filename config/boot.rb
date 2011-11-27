require 'rubygems'

# Set up gems listed in the Gemfile.
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)

ENV['DATABASE_URL'] = 'postgres://foottraffic:fetooVahf3@iamchen.com/ft_development'

require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])
