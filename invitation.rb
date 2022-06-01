# An invitation class that represents a single invitation request or status
#
#   Example: invitation = Invitation.new(...)
#            invitation.valid? => false
#            invitation.status => "recommended"
class Invitation
  include Validators
  
  # List of valid statuses only!
  STATUSES = %q[recommends accepts]
  
  private_constant :STATUSES
  
  attr_reader :date, :status, :invited_to, :invited_by, :errors, :accepted_for
  
  # Build invitation object from the input
  #
  # @param date [String] takes the date time string of the invitation
  # @param status [String] takes the status string of the invitation, accepted or recommended?
  # @param invited_to [String] takes the invitee name or identity for this invitation
  # @param invited_by [String] takes the inviter name or identity for this invitation
  #
  # @return [Invitation] object based on the given inputs/params
  def initialize(date = nil, status = nil, invited_to = nil, invited_by = nil)
    @date = date
    @status = status
    @invited_by = invited_by
    @invited_to = invited_to
    @accepted_for = nil
  end
  
  # Is invitation recommended?
  #
  # @return [Boolean] value based on the status
  def recommended?
    @status === "recommends"
  end
  
  # Is invitation accepted?
  #
  # @return [Boolean] value based on the accepted
  def accepted?
    @status === "accepts"
  end

  # Build invitation object from the input
  #
  #
  # @return [Boolean] object to give the invitation a validation, valid or invalid invitation?
  def validate!
    super do
      presence_validator!(status) { Error.new("status", "should be present") }
      presence_validator!(date) { Error.new("date", "should be present") }
      presence_validator!(invited_to) { Error.new("Invitee", "not present") } if recommended?
      date_validator!(date) { Error.new("date", "is not a valid date") }
      inclusion_validator!(status, STATUSES) { Error.new("status", "is not valid") }
    end
  end
end
