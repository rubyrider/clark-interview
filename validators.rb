# A plain old Ruby validators that will be used across the solution
# to validate various parameters.
# Straight forward, expressive and minimal
#
# Example: For details also look at Invitation
#
#   class Invitation
#     include Validators
#
#     ...
#
#     def validate!
#       super do
#         validate_presence!(status) { Error.new("status", "should be present") }
#         validate_presence!(date) { Error.new("date", "should be present") }
#         validate_presence!(invited_to) { Error.new("Invitee", "not present") }
#         validate_date!(date) { Error.new("date", "is not a valid date") }
#         validate_inclusion!(status, STATUSES) { Error.new("status", "is not valid") }
#       end
#     end
#   end
#
#  invitation = Invitation.new(...)
#  invitation.valid? => false
#  invitation.errors => [<Error>...<Error>]
#
module Validators
  # The basic Error struct to hold error message with minimal structure
  #
  # @return [Error] object with the field/subject and error message attributes
  Error = Struct.new(:on, :message, :type) do
    def to_json
      {
        on: self.on,
        message: self.message
      }.to_json
    end
  end
  
  def self.included(base)
    base.attr_accessor :errors, :valid
  end

  # Runs the validate! command, the main simple
  #   validator of this validator
  #
  # @return [Boolean] if the validation process
  #   is successful or not
  def valid?
    @valid ||= validate!
  end
  
  def invalid?
    !valid?
  end
  
  private
    # Designed to build the errors object when a validation is failed
    # through out the validators
    #
    # @return [Array] of the errors objects
    def to_errors
      @errors ||= []
    end
  
    # Scope to run validators by the included class
    # every class that inherit validators module should implement this
    #
    # The purpose of the interface to implement each kind validators (#validate_presence! validate_inclusion! etc)
    # as per need inside the body of this method so that the simple #valid? could call this method and deliver
    # validation based on the validation logic implementation
    #
    # @yield validation block [Block] that receives the one or multiple validations rules defined by the inherited class
    #
    # Example:
    #     def validate!
    #       super do
    #         validate_presence!(status) { Error.new("status", "should be present") }
    #         validate_presence!(date) { Error.new("date", "should be present") }
    #         validate_presence!(invited_to) { Error.new("Invitee", "not present") }
    #         validate_date!(date) { Error.new("date", "is not a valid date") }
    #         validate_inclusion!(status, STATUSES) { Error.new("status", "is not valid") }
    #       end
    #     end
    #
    # @return [Boolean] if the validation process
    #   is successful or not
    def validate!
      yield
      
      @valid = to_errors.count.zero?
    end
    
    # Just check the presence of the value
    #
    # takes a block to build error messages by the
    # inheriting class as per his own need
    # and append to errors block if validation fails
    #
    #
    # @return [Boolean]
    def presence_validator!(given_value)
      return true if given_value

      to_errors << yield
    end

    # Just check the inclusion of the value
    #
    # takes a block to build error messages by the
    # inheriting class as per his own need
    # and append to errors block if validation fails
    #
    # @return [Boolean]
    def inclusion_validator!(to_be_included, inclusions)
      return true if inclusions.include?(to_be_included)

      to_errors << yield
    end

    # Just check the valid date string of the value
    #
    # takes a block to build error messages by the
    #   inheriting class as per his own need
    #   and append to errors block if validation fails
    #
    # @return [Boolean]
    def date_validator!(given_date)
      return true if given_date.match(Parser::DATE_TIME_PARSER) && DateTime.parse(given_date)

      to_errors << yield
    rescue Date::Error, TypeError => e
      to_errors << yield(e)
    end

    # Just another validators to ensure the right file (with extension)
    #
    # takes a block to build error messages by the
    #   inheriting class as per his own need
    #   and append to errors block if validation fails
    #
    # @return [Boolean]
    def file_format_validator!(file, format)
      return true if File.extname(file) == format

      to_errors << yield
    end

    # Just another validators to ensure the right file size (maximum upload capacity)
    #
    # takes a block to build error messages by the
    #   inheriting class as per his own need
    #   and append to errors block if validation fails
    #
    # @return [Boolean]
    def file_size_validator!(file, maximum_size = InputFileHandler::MAXIMUM_FILE_SIZE)
      return true if File.new(file).size <= maximum_size

      to_errors << yield
    end
end
