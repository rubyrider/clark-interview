# This plain old ruby service is responsible for
# to handle the file input, validates and return a yielding
# method to receive a block to process the input
class InputFileHandler
  attr_reader :file, :inputs
  
  # Maximum Allowed File Size
  MAXIMUM_FILE_SIZE = 2048 # bytes
  
  include Validators
  
  # Takes a file to construct the input builder service
  #
  # @param [File] file as an input source, only .txt file is allowed
  # @see #validate!
  def initialize(file)
    @file = file
    @inputs = []
  end
  
  # the entrypoint call/methods once the validation
  # is done. Basically yields each line to the caller
  def call
    if valid?
      @input_file = File.readlines(@file).each do |line|
        yield(line)
      end
    end
  end

  private
  
    # Just another validate call,
    # @@see Validator module for details
  def validate!
    super do
      file_format_validator!(file, '.txt')
      file_size_validator!(file, MAXIMUM_FILE_SIZE)
    end
  end
end
