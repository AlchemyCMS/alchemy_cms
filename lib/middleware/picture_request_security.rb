require 'rack/utils'

module Alchemy
  module Middleware

    # == Security for picture rendering requests.
    #
    # Without the secret secure hash this middleware raises a bad request error (400).
    # The secure hash is SHA1 hash from your width, height and crop parameters that is
    # salted with a secret (Your +Rails.configuration.secret_token+).
    #
    class PictureRequestSecurity

      def initialize(app)
        @app = app
        @secret = Rails.configuration.secret_token
      end

      def call(env)
        @env = env
        response = catch(:halt) do
          @path = env['REQUEST_PATH']
          ensure_secure_picture_params if @path =~ /pictures\/\d+\/(show|thumbnails|zoom)/
        end
        response || @app.call(env)
      end

      def ensure_secure_picture_params
        query = ::Rack::Utils.parse_query(@env['QUERY_STRING'])
        token = query['sh']
        @params = Alchemy::Engine.routes.recognize_path(@env['ORIGINAL_FULLPATH'].gsub(/#{Alchemy.mount_point}/, ''))
        digest = Digest::SHA1.hexdigest(secured_params)[0..15]
        throw(:halt, bad_request) unless token && (token == digest)
      end

      def bad_request
        body = "Bad picture parameters in #{@path}"
        [400, {"Content-Type" => "text/plain", "Content-Length" => body.size.to_s}, [body]]
      end

    private

      def secured_params
        [@params[:id], @params[:size], @params[:crop], @params[:crop_from], @params[:crop_size], @secret].join('-')
      end

    end

  end
end
