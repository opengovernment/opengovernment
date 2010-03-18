

ERB::Util.module_eval do  # :nodoc:

  def html_escape_with_output_safety(value)
    # Values which don't respond to html_safe, should be checked
    if value.respond_to?(:html_safe?) && value.html_safe?
      value
    else
      html_escape_without_output_safety(value).html_safe!
    end
  end
  
  alias_method_chain :html_escape, :output_safety
  alias h html_escape

  module_function :html_escape
  module_function :html_escape_without_output_safety
  module_function :h
end