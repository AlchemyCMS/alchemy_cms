module Alchemy
  mattr_accessor :exception_handler

  class ExceptionHandler
    def call(exception, context = nil)
      raise(exception) if Rails.env.test? || is_page_preview?(context)
      exception_logger(exception)
      show_error_notice(exception, context)
    end

    private

    def is_page_preview?(controller)
      controller.controller_path == 'alchemy/admin/pages' && controller.action_name == 'show'
    end

    def exception_logger(error)
      Rails.logger.error("\n#{error.class} #{error.message} in #{error.backtrace.first}")
      Rails.logger.error(error.backtrace[1..50].each { |line|
        line.gsub(/#{Rails.root.to_s}/, '')
      }.join("\n"))
    end

    def show_error_notice(error, controller)
      controller.instance_variable_set('@error', error)
      # truncate the message, because very long error messages (i.e from mysql2) causes cookie overflow errors
      controller.instance_variable_set('@notice', error.message[0..255])
      controller.instance_variable_set('@trace', error.backtrace[0..50])
      if controller.request.xhr?
        controller.send(:render, action: "error_notice")
      else
        controller.send(:render, '500', status: 500)
      end
    end
  end
end

Alchemy.exception_handler = Alchemy::ExceptionHandler.new
