# encoding: utf-8

module ActionView
  module Renderable #:nodoc:
    private
      def compile!(render_symbol, local_assigns)
        locals_code = local_assigns.keys.map { |key| "#{key} = local_assigns[:#{key}];" }.join

        source = <<-end_src
          def #{render_symbol}(local_assigns)
            old_output_buffer = output_buffer;#{locals_code};#{compiled_source}
          ensure
            self.output_buffer = old_output_buffer
          end
        end_src
        source.force_encoding(Encoding::UTF_8) if source.respond_to?(:force_encoding)

        begin
          ActionView::Base::CompiledTemplates.module_eval(source, filename, 0)
        rescue Errno::ENOENT => e
          raise e # Missing template file, re-raise for Base to rescue
        rescue Exception => e # errors from template code
          if logger = defined?(ActionController) && Base.logger
            logger.debug "ERROR: compiling #{render_symbol} RAISED #{e}"
            logger.debug "Function body: #{source}"
            logger.debug "Backtrace: #{e.backtrace.join("\n")}"
          end

          raise ActionView::TemplateError.new(self, {}, e)
        end
      end
  end
end
module Rack
  module Utils
    def escape(s)
      regexp = case
        when RUBY_VERSION >= "1.9" && s.encoding === Encoding.find('UTF-8')
          /([^ a-zA-Z0-9_.-]+)/u
        else
          /([^ a-zA-Z0-9_.-]+)/n
        end
      s.to_s.gsub(regexp) {
        '%'+$1.unpack('H2'*bytesize($1)).join('%').upcase
      }.tr(' ', '+')
    end
  end
end
