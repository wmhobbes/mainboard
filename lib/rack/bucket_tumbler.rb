#
# simple support for vhost-style buckets, takes the host-name and moves it in
# front of the PATH_INFO
#
module Rack
  class BucketTumbler

    def initialize(app, options = {})
      @app = app
      @domain = options[:domain]
    end

    def call(env)

      if(@domain)
        if env['HTTP_HOST'] =~ /^([-\w]+)\.#{@domain}$/
          bucket = $~.captures.first
          env['TUMBLER_BUCKET'] = bucket
          env['ORIGINAL_PATH_INFO'] = env['PATH_INFO'].dup

          env['PATH_INFO'] = "/#{bucket}#{env['PATH_INFO']}"
          env['REQUEST_URI'] = "/#{bucket}#{env['REQUEST_URI']}"
        end
      end

    ensure
      return @app.call env
    end

  end
end

