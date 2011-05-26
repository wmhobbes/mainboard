Mainboard.helpers do

      def aws_authenticate
        auth = AWS::S3::Authentication::Request.new(request)
        @amz_headers = auth.amz_headers

        @account = Account.first(:conditions => {:key => auth.key})
        return if @account && auth.validate_secret(@account.secret)
        raise BadAuthentication
      end

#      def login_required
#       if session[:user].nil?
#         redirect '/control/login'
#       end
#      end

      def unset_current_account
       session[:account] = nil
       return true
      end

      def only_authorized
       raise AccessDenied unless @account
      end

      def only_superusers
       raise AccessDenied unless current_account.admin?
      end

      def only_can_read(bucket)
       raise AccessDenied unless bucket.readable_by? current_account
      end

      def only_can_write(bucket)
       raise AccessDenied unless bucket.writable_by? current_account
      end

      def only_owner_of(bucket)
       raise AccessDenied unless bucket.owned_by? current_account
      end

      def aws_only_owner_of(bucket)
       raise AccessDenied unless bucket.owned_by? @account
      end

      def aws_only_can_read(bucket)
       raise AccessDenied unless bucket.readable_by? @account
      end

      def check_credentials(username, password)
       account = Account.first(:login => username)
       if account && account.password == hmac_sha1(password, account.secret)
         session[:account] = account
         return true
       else
         return false
       end
      end


      def hmac_sha1(key, s)
        return Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new("sha1"), key, s)).strip
      end

end