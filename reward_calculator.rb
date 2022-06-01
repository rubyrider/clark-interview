require 'rubygems'
require 'bundler/setup'

Bundler.require

require 'date'
require 'tree'

# Auto loaders for the other services!
autoload :Validators, "./validators"
autoload :InputFileHandler, "./input_file_handler.rb"
autoload :Invitation, "./invitation"
autoload :Parser, "./parser"

# The entry point service for this assignment
#
# Basically this calculator will take the input
# and return the expected output
#
# Hit the bin/console and see the followings by entering
#
#   file = File.new('./sample.txt')
#   r = RewardCalculator.new(file)
#   r.call
#   # => {"A"=>1.75, "B"=>1.5, "C"=>1}
class RewardCalculator
  include Validators
  
  attr_reader :input_file, :invitations, :friends, :rewards, :input_handler
  
  # Takes an input file to process the result
  #
  # @param [File] input_file in txt format
  #
  # @return [RewardCalculator] service object
  def initialize(input_file = nil)
    @input_file    = input_file
    @input_handler = InputFileHandler.new(input_file)
    @invitations   = []
    @friends       = Tree::TreeNode.new('')
    @rewards       = {}
  end
  
  # Calculate accepted_invitation on runtime!
  #
  # @return [Array] of accepted invitations
  def accepted_invitations
    invitations.select { |accepted_invitation| accepted_invitation.accepted? }
  end
  
  # The main access point method to build up streams from the input file and calculate
  #
  # Also validates all inputs/invitations etc
  #
  # Build the referral tree histories
  #
  # and the return the @rewards hash
  #
  # @return [Hash|Boolean] @reward or a false class. In case of validation failed, please
  # check @errors attributes for the details error message
  def call
    validate!
  
    collect_inputs!
    
    return errors unless valid?
    
    map_recommendations!
    
    @rewards
  end
  
  private
    
    # Find the referrer, earliest one is the priority
    #
    # @return[Invitation] object with recommendation status
    def referred_for(friend)
      invitations.find { |invitation| invitation.invited_to == friend.invited_to }
    end
    
    # The main call that reward a friend and their parents
    #
    # @return [Void]
    def reward!(friend)
      referrer = referred_for(friend).invited_by
      
      return false unless referrer
      
      friends_connection = Tree::TreeNode.new(friend.invited_to)
      position           = find_referrer_position(referrer)
      position << friends_connection
      
      reward_parents(position)
    end
    
    # The process to rewards and distribute
    # rewards to parents
    #
    # @return [Tree::TreeNode]
    def reward_parents(parent, depth = 0, reward = 0.5)
      return if depth > 2
      return if parent.nil?
      return if parent.name.empty?
      
      parent.content ||= 1
      parent.content += (reward/depth) if depth > 0
      
      @rewards[parent.name] = parent.content
      
      reward_parents(parent.parent, (depth.next))
    end


    # The process to find referrer's position the reward network tree
    #
    # @return [Tree::TreeNode]
    def find_referrer_position(referrer)
      referrer_node = nil
      
      @friends.each do |a_friend|
        break referrer_node = a_friend if a_friend.name == referrer
      end
      
      referrer_node || @friends << Tree::TreeNode.new(referrer)
    end
    
    # Allocate accepted invitations to receive the reward!
    #
    # @return [Array]
    def map_recommendations!
      accepted_invitations.map { |acceptance| reward!(acceptance) }
    end
    
    # Just another validators!
    def validate!
      super do
        file_format_validator!(input_file, '.txt') { Error.new('InputFile', 'invalid format, only txt file is allowed') }
        file_size_validator!(input_file) { Error.new('InputFile', 'should be maximum 2mb') }
      end
    end
    
    # Collect and pass the input lines from the yielded input by the input file handler
    def collect_inputs!
      @input_handler.call { |input| @invitations << build_invitation(input) }

      Error.new('Input', 'data is not valid') if invitations.find(&:invalid?)&.exist?
    end
    
    # Builds invitation object, call parser to find the appropriate values
    # @see Parser service object for details
    def build_invitation(input)
      parser = Parser.new(input).call
      
      if parser.status == 'recommends'
        Invitation.new(parser.datetime, parser.status, parser.invited_to, parser.invited_by)
      else
        Invitation.new(parser.datetime, parser.status, parser.invited_by)
      end
    end
end
