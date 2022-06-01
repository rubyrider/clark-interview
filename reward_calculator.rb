require 'rubygems'
require 'bundler/setup'

Bundler.require

# Auto loaders for the other services!
autoload :InputFileHandler, "./input_file_handler.rb"
autoload :Invitation, "./invitation"

# The entry point service for this assignment
#
# Basically this calculator will take the input
# and return the expected output
class RewardCalculator

end
