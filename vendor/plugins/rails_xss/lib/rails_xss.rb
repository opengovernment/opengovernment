# RailsXss
module RailsXss
  class Erubis < ::Erubis::Eruby
    def add_preamble(src)
      src << "@output_buffer = ActionView::SafeBuffer.new;\n"
    end

    def add_text(src, text)
      src << "@output_buffer << ('" << escape_text(text) << "'.html_safe!);"
    end
    
    def add_expr_literal(src, code)
      src << '@output_buffer << ((' << code << ').to_s);'
    end

    def add_expr_escaped(src, code)
      src << '@output_buffer << ' << escaped_expr(code) << ';'
    end
    
    def add_postamble(src)
      src << '@output_buffer.to_s'
    end
    
  end

  module SafeHelpers
    def safe_helper(*names)
      names.each do |helper_method_name|
        aliased_target, punctuation = helper_method_name.to_s.sub(/([?!=])$/, ''), $1
        module_eval <<-END
          def #{aliased_target}_with_xss_safety#{punctuation}(*args, &block)
            raw(#{aliased_target}_without_xss_safety#{punctuation}(*args, &block))
          end
        END
        alias_method_chain helper_method_name, :xss_safety
      end
    end
  end
end