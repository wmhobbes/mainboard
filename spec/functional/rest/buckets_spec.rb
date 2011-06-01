require File.expand_path("../../rest_spec_helper", __FILE__)

describe 'REST service, the bucket API' do

  before do

    account = Account.where(:role => :admin).first
    @s3_settings = {
      :key => account.key,
      :secret => account.secret,
      :bucket_name => 'none',
      :settings => {
        :server => '127.0.0.1',
        :port => 3000,
        :protocol => 'http'
      }
    }
    @service = RightAws::S3.new @s3_settings[:key], @s3_settings[:secret], @s3_settings[:settings]
  end

  it 'lets a user retrieve a list of buckets' do
    @service.buckets.class.should == Array
  end

  it 'lets a user add and delete a new bucket' do
    bucket = @service.bucket('boardwalk_test_new', true, 'public-read')

    @service.buckets.find_all { |b| b.to_s == 'boardwalk_test_new' }.length.should > 0

    bucket.delete
    @service.buckets.find_all { |b| b.to_s == 'boardwalk_test_new' }.length.should == 0
  end



end
