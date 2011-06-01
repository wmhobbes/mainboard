module AWS
  module S3

    module ErrorCodes
      AccessDenied                 = [403, 'Access Denied.']
      AccountProblem               = [403, 'There is a problem with your AWS account that prevents the operation from completing successfully.']
      AllAccessDisabled            = [401, 'All access to this object has been disabled.']
      AmbiguousGrantByEmailAddress = [400, 'The e-mail address you provided is associated with more than one account.']
      BadAuthentication            = [401, 'The authorization information you provided is invalid. Please try again.'] # XXX ?
      BadDigest                    = [400, 'The Content-MD5 you specified did not match what we received.']
      BucketAlreadyExists          = [409, 'The named bucket you tried to create already exists.']
      BucketNotEmpty               = [409, 'The bucket you tried to delete is not empty.']
      CredentialsNotSupported      = [400, 'This request does not support credentials.']
      EntityTooLarge               = [400, 'Your proposed upload exceeds the maximum allowed object size.']
      ExpiredToken                 = [400, 'The provided token has expired.']
      IncompleteBody               = [400, 'You did not provide the number of bytes specified by the Content-Length HTTP header.']
      IncorrectNumberOfFilesInPostRequest = [400, 'POST requires exactly one file upload per request.']
      InlineDataTooLarge           = [400, 'Inline data exceeds the maximum allowed size.']
      InternalError                = [500, 'We encountered an internal error. Please try again.']
      InvalidAccessKeyId           = [403, 'The AWS Access Key Id you provided does not exist in our records.']
      InvalidArgument              = [400, 'Invalid Argument']
      InvalidBucketName            = [400, 'The specified bucket is not valid.']
      InvalidDigest                = [400, 'The Content-MD5 you specified was an invalid.']
      InvalidLocationConstraint    = [400, 'The specified location constraint is not valid.']
      InvalidPart                  = [400, 'One or more of the specified parts could not be found.']
      InvalidPartOrder             = [400, 'The list of parts was not in ascending order.Parts list must specified in order by part number.']
      InvalidPayer                 = [403, 'All access to this object has been disabled.']
      InvalidPolicyDocument        = [400, 'The content of the form does not meet the conditions specified in the policy document.']
      InvalidRange                 = [416, 'The requested range is not satisfiable.']
      InvalidSecurity              = [403, 'The provided security credentials are not valid.']
      InvalidSOAPRequest           = [400, 'The SOAP request body is invalid.']
      InvalidStorageClass          = [400, 'The storage class you specified is not valid.']
      InvalidTargetBucketForLogging = [400, 'The target bucket for logging does not exist, is not owned by you, or does not have the appropriate grants for the log-delivery group.']
      InvalidToken                 = [400, 'The provided token is malformed or otherwise invalid.']
      InvalidURI                   = [400, "Couldn't parse the specified URI."]
      KeyTooLong                   = [400, 'Your key is too long.']
      MalformedACLError            = [400, 'The XML you provided was not well-formed or did not validate against our published schema.']
      MalformedPOSTRequest         = [400, 'The body of your POST request is not well-formed multipart/form-data.']
      MalformedXML                 = [400, 'The XML you provided was not well-formed or did not validate against our published schema.']
      MaxMessageLengthExceeded     = [400, 'Your request was too big.']
      MaxPostPreDataLengthExceededError = [400, 'Your POST request fields preceding the upload file were too large.']
      MetadataTooLarge             = [400, 'Your metadata headers exceed the maximum allowed metadata size.']
      MethodNotAllowed             = [405, 'The specified method is not allowed against this resource.']
      MissingAttachment            = [400, 'An attachment was expected, but none were found.']
      MissingContentLength         = [411, 'You must provide the Content-Length HTTP header.']
      MissingRequestBodyError      = [400, 'Request body is empty.']
      MissingSecurityElement       = [400, 'The SOAP 1.1 request is missing a security element.']
      MissingSecurityHeader        = [400, 'Your request was missing a required header.']
      NoLoggingStatusForKey        = [400, 'There is no such thing as a logging status sub-resource for a key.']
      NoSuchBucket                 = [404, 'The specified bucket does not exist.']
      NoSuchKey                    = [404, 'The specified key does not exist.']
      NoSuchUpload                 = [404, 'The specified multipart upload does not exist']
      NoSuchVersion                = [404, 'Indicates that the version ID specified in the request does not match an existing version.']
      NotImplemented               = [501, 'A header you provided implies functionality that is not implemented.']
      NotSignedUp                  = [403, 'Your account is not signed up for the service.']
      NotModified                  = [304, 'The request resource has not been modified.']
      OperationAborted             = [409, 'A conflicting conditional operation is currently in progress against this resource. Please try again.']
      PermanentRedirect            = [301, 'The bucket you are attempting to access must be addressed using the specified endpoint. Please send all future requests to this endpoint.']
      PreconditionFailed           = [412, 'At least one of the pre-conditions you specified did not hold.']
      Redirect                     = [307, 'Temporary redirect.']
      RequestIsNotMultiPartContent = [400, 'Bucket POST must be of the enclosure-type multipart/form-data.']
      RequestTimeout               = [400, 'Your socket connection to the server was not read from or written to within the timeout period.']
      RequestTimeTooSkewed         = [400, "The difference between the request time and the server's time is too large."]
      RequestTorrentOfBucketError  = [400, 'Requesting the torrent file of a bucket is not permitted.']
      SignatureDoesNotMatch        = [403, 'The request signature we calculated does not match the signature you provided.']
      SlotAlreadyExists            = [409, 'The slot you tried to create already exists.'] # XXX ?
      SlowDown                     = [503, 'Please reduce your request rate.']
      TemporaryRedirect            = [307, 'You are being redirected to the bucket while DNS updates.']
      TokenRefreshRequired         = [400, 'The provided token must be refreshed.']
      TooManyBuckets               = [400, 'You have attempted to create more buckets than allowed.']
      UnexpectedContent            = [400, 'This request does not support content.']
      UnresolvableGrantByEmailAddress = [400, 'The e-mail address you provided does not match any account on record.']
      UserKeyMustBeSpecified       = [400, 'The bucket POST must contain the specified field name. If it is specified, please check the order of the fields.']

    end

    class Error < StandardError

      attr_reader :transport_code, :obj

      def initialize(message = '', obj = {} )
        @obj = obj
        @transport_code,  message = constantize "AWS::S3::ErrorCodes::#{code}"
        super(message)
      end

      def code
        self.class.name.split(':').last
      end
    end

    module Errors
      class AccessDenied < Error; end
      class AccountProblem < Error; end
      class AllAccessDisabled < Error; end
      class AmbiguousGrantByEmailAddress < Error; end
      class BadAuthentication < Error; end
      class BadDigest < Error; end
      class BucketAlreadyExists < Error; end
      class BucketNotEmpty < Error; end
      class CredentialsNotSupported < Error; end
      class EntityTooLarge < Error; end
      class ExpiredToken < Error; end
      class IncompleteBody < Error; end
      class IncorrectNumberOfFilesInPostRequest < Error; end
      class InlineDataTooLarge < Error; end
      class InternalError < Error; end
      class InvalidAccessKeyId < Error; end
      class InvalidArgument < Error; end
      class InvalidBucketName < Error; end
      class InvalidDigest < Error; end
      class InvalidLocationConstraint < Error; end
      class InvalidPart < Error; end
      class InvalidPartOrder < Error; end
      class InvalidPayer < Error; end
      class InvalidPolicyDocument < Error; end
      class InvalidRange < Error; end
      class InvalidSecurity < Error; end
      class InvalidSOAPRequest < Error; end
      class InvalidStorageClass < Error; end
      class InvalidTargetBucketForLogging < Error; end
      class InvalidToken < Error; end
      class InvalidURI < Error; end
      class KeyTooLong < Error; end
      class MalformedACLError < Error; end
      class MalformedPOSTRequest < Error; end
      class MalformedXML < Error; end
      class MaxMessageLengthExceeded < Error; end
      class MaxPostPreDataLengthExceededError < Error; end
      class MetadataTooLarge < Error; end
      class MethodNotAllowed < Error; end
      class MissingAttachment < Error; end
      class MissingContentLength < Error; end
      class MissingRequestBodyError < Error; end
      class MissingSecurityElement < Error; end
      class MissingSecurityHeader < Error; end
      class NoLoggingStatusForKey < Error; end
      class NoSuchBucket < Error; end
      class NoSuchKey < Error; end
      class NoSuchUpload < Error; end
      class NoSuchVersion < Error; end
      class NotImplemented < Error; end
      class NotSignedUp < Error; end
      class NotModified < Error; end
      class OperationAborted < Error; end
      class PermanentRedirect < Error; end
      class PreconditionFailed < Error; end
      class Redirect < Error; end
      class RequestIsNotMultiPartContent < Error; end
      class RequestTimeout < Error; end
      class RequestTimeTooSkewed < Error; end
      class RequestTorrentOfBucketError < Error; end
      class SignatureDoesNotMatch < Error; end
      class SlotAlreadyExists < Error; end
      class SlowDown < Error; end
      class TemporaryRedirect < Error; end
      class TokenRefreshRequired < Error; end
      class TooManyBuckets < Error; end
      class UnexpectedContent < Error; end
      class UnresolvableGrantByEmailAddress < Error; end
      class UserKeyMustBeSpecified < Error; end
    end
  end
end
