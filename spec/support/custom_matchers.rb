module CustomMatchers
  class ErrorOn
    def initialize(expected)
      @expected = expected
    end

    def matches?(actual)
      @actual = actual
      @valid = @actual.valid?
      !@actual.errors.on(@expected).nil?
    end

    def failure_message_for_should
      message = []
      message << "expected '#{@actual.class}' to error on '#{@expected}'"
      message << ", but encountered the following errors instead: \n\t#{@actual.errors.full_messages.join("\n\t")}" unless @valid
      message << ", but the object doesn't contain any error" if @valid

      message.join
    end

    def failure_message_for_should_not
      "expected '#{@actual.class}' not to error on #{@expected}, but it did"
    end
  end

  def error_on(expected)
    ErrorOn.new(expected)
  end
end
