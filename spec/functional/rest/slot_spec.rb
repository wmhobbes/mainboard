require File.expand_path("../../rest_spec_helper", __FILE__)

describe 'REST service, the slot API' do

  before do

    account = Account.where(:role => :admin).first
    @s3_settings = {
      :key => account.key,
      :secret => account.secret,
      :bucket_name => 'test_bucket',
      :settings => {
        :server => '127.0.0.1',
        :port => 3000,
        :protocol => 'http'
      }
    }
    @service = RightAws::S3.new @s3_settings[:key], @s3_settings[:secret], @s3_settings[:settings]

    begin
      @bucket = @service.bucket('test_bucket', true, 'public-read')
    rescue RightAws::AwsError
      # alright, prolly a test failed and we left over the bucket
      @bucket = @service.bucket('test_bucket')
    end

  end

  after do
    @bucket.delete
  end

  it 'lets a user add an item, retrieve it, and delete it' do

    file = 'README.markdown'

    @bucket.put(file, open(file))

    @bucket.keys.find_all { |k| k.to_s == file }.length.should > 0

    key = RightAws::S3::Key.new(@bucket, file)
    key.exists?.should == true

    key.delete
    key.exists?.should == false

  end

end
