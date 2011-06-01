Mainboard.helpers do

      def aws_authenticate
        auth = AWS::S3::Authentication::Request.new(request)
        @amz_headers = auth.amz_headers

        @account = Account.first(:conditions => {:key => auth.key})
        if @account && !auth.validate_secret(@account.secret)
          raise BadAuthentication
        end

        logger.debug "- authenticated as #{@account.identity}" if @account
        logger.debug @amz_headers.pretty_inspect
      end

      def anonymous_request?
        @account.nil?
      end

      def only_authorized
       raise AccessDenied unless @account
      end

      def only_superusers
       raise AccessDenied unless @account.admin?
      end

      def only_can_read(object)
       raise AccessDenied unless object.readable_by? @account
      end

      def only_can_write(object)
       raise AccessDenied unless object.writable_by? @account
      end

      def only_owner_of(object)
       raise AccessDenied unless object.owned_by? @account
      end


      def hmac_sha1(key, s)
        return Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new("sha1"), key, s)).strip
      end

end
