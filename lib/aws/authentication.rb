
module AWS
  module S3

    module Authentication
      constant :ENV_AMAZON_HEADER_PREFIX, 'http_x_amz_'
      constant :AMAZON_HEADER_PREFIX, 'x-amz-'


      class Request

        attr_reader :request, :auth, :key, :secret

        def initialize(request)

          @request = request
          extract_auth
          @canonical = CanonicalString.new(request)
        end

        def validate_secret(secret_access_key)
          return false if secret_access_key.blank?
          encoded_canonical(secret_access_key) == secret
        end

        def amz_headers
          @canonical.headers
        end

        def env
          request.env
        end

      private

        def extract_auth
          @auth, @key, @secret = *env['HTTP_AUTHORIZATION'].to_s.match(/^AWS (\w+):(.+)$/)
        end

        def encoded_canonical(secret_access_key)
          digest   = OpenSSL::Digest::Digest.new('sha1')
          b64_hmac = [OpenSSL::HMAC.digest(digest, secret_access_key, @canonical)].pack("m").strip
        end

      end



      class CanonicalString < String #:nodoc:
        class << self
          def default_headers
            %w(content_type content_md5)
          end

          def interesting_headers
            ['content_md5', 'content_type', 'date', amazon_header_prefix]
          end

          def amazon_header_prefix
            /^#{ENV_AMAZON_HEADER_PREFIX}/io
          end
        end

        attr_reader :request, :headers

        def initialize(request, options = {})
          super()
          @request = request
          @headers = {}
          @options = options
          # "For non-authenticated or anonymous requests. A NotImplemented error result code will be returned if
          # an authenticated (signed) request specifies a Host: header other than 's3.amazonaws.com'"
          # (from http://docs.amazonwebservices.com/AmazonS3/2006-03-01/VirtualHosting.html)
          build
        end

        def env
          request.env
        end


        private
        def build
          self << "#{request_method}\n"

          read_headers
          read_http_date

          headers.sort_by {|k, _| k}.each do |key, value|
            value = value.to_s.strip
            self << (key =~ self.class.amazon_header_prefix ? "#{canonicalize(key)}:#{value}" : value)
            self << "\n"
          end
          self << path
        end

        def canonicalize(key)
          key.sub(ENV_AMAZON_HEADER_PREFIX, AMAZON_HEADER_PREFIX).gsub('_', '-')
        end

        def request_method
          env['REQUEST_METHOD']
        end

        def request_path
          env['ORIGINAL_PATH_INFO'] || env['PATH_INFO']
        end

        def query_string
          env['QUERY_STRING']
        end

        def date
          env['HTTP_DATE']
        end

        def read_headers
          identify_interesting_headers
          set_default_headers
        end

        def identify_interesting_headers
          request.env.each do |key, value|
            key = key.downcase # Can't modify frozen string so no bang
            if self.class.interesting_headers.any? {|header| header === key}
              self.headers[key] = value.to_s.strip
            end
          end
        end

        def set_default_headers
          self.class.default_headers.each do |header|
            self.headers[header] ||= ''
          end
        end

        def read_http_date
          self.headers['date'] ||= date
        end

        def path
          [request_path, extract_significant_parameter].compact.join('?')
        end

        def extract_significant_parameter
          query_string[/(acl|torrent|logging|versioning|location)(?:&|=|$)/, 1]
        end

      end
    end
  end
end
