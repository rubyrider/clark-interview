require 'strscan'

class Parser
  # Hold the regular expression to help string scanners to find the datetime
  # from the current input string. Example:
  #   str = Parser.new("2018-06-12 09:41 A recommends B")
  #   2.7.1 :003 > str.call
  #   => #<Parser:0x00007f965c963d28 @input=#<StringScanner fin>, @datetime="2018-06-12 09:41", @invited_by="A", @status="recommends", @invited_to="B">
  #   str.datetime
  #    => "2018-06-12 09:41"
  DATE_TIME_PARSER = /\d{4}-\d{2}-\d{2} \d{2}\:\d{2}/

  # Hold the regular expression to help string scanners to find the invitee and invitor
  # from the current input string. Example:
  #   str = Parser.new("2018-06-12 09:41 A recommends B")
  #   2.7.1 :003 > str.call
  #   => #<Parser:0x00007f965c963d28 @input=#<StringScanner fin>, @datetime="2018-06-12 09:41", @invited_by="A", @status="recommends", @invited_to="B">
  #   str.invited_by
  #   => "A"
  #   str.invited_to
  #   => "B"
  INVITATION_PEOPLE = /([A-Z])/

  # Hold the regular expression to help string scanners to find the statuses
  # from the current input string. Example:
  #   str = Parser.new("2018-06-12 09:41 A recommends B")
  #   2.7.1 :003 > str.call
  #   => #<Parser:0x00007f965c963d28 @input=#<StringScanner fin>, @datetime="2018-06-12 09:41", @invited_by="A", @status="recommends", @invited_to="B">
  #   str.status
  #    => "recommends"
  STATUSES = /recommends|accepts/
  
  private_constant :INVITATION_PEOPLE
  private_constant :STATUSES
  
  attr_reader :input, :datetime, :invited_by, :invited_to, :status
  
  # Constructor for the parser service
  # Builds string buffer using StringScanner in order the parse the string
  #
  # @param input [String] basically a single line from input file
  #
  # @return [Parser] object, requires #call to do the parse operation and assign
  def initialize(input)
    @input = StringScanner.new(input)
  end
  
  # The main operation to parse a string and return the
  # token/values as expected
  #
  # The operation also cleans up unnecessary spaces
  #
  # The first approach is to find the datetime
  # The second approach is to find the invited_by or who accepted the invitation
  # The third approach is to find the status
  # The forth approach is to find the inviting_person # optional in case of accepted message
  #
  # @return [Parser] with the value assigned/
  def call
    @datetime = input.scan_until(DATE_TIME_PARSER)
    input.skip(/\s+/)
    @invited_by = input.scan_until(INVITATION_PEOPLE)
    input.skip(/\s+/)
    @status = input.scan_until(STATUSES)
    input.skip(/\s+/)
    @invited_to = input.scan_until(INVITATION_PEOPLE)&.strip
    
    self
  end
end
