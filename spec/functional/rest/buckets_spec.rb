require File.expand_path("../../rest_spec_helper", __FILE__)

describe 'REST service, the bucket API' do

  TEST_FILE = 'README.markdown'

  before do
    @service = connect_as :admin

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

describe 'REST service, the bucket ' do

  before do
    @service = connect_as :admin
    @bucket = @service.bucket('boardwalk_test_new', true, 'public-read')

  end

  after do

    @bucket.delete
  end

  it 'lets a user clear the bucket' do
    @bucket.put(TEST_FILE, open(TEST_FILE))
    @bucket.keys.count.should == 1
    @bucket.clear
    @bucket.keys.count.should == 0
  end

  it 'lets a user delete a folder' do
    #bucket.delete_folder
  end

  it 'lets a user enable and disable logging' do
    #bucket.emable_logging
    #bucket.disable_logging
    #bucket.logging_info
  end

  it 'lets a user get the list of grantees' do
    # at least the owner
    @bucket.grantees.count.should > 0
  end

  it 'lets a user get a list of keys' do

    @bucket.put("/foo/#{TEST_FILE}", open(TEST_FILE))
    @bucket.keys.count.should == 1
    @bucket.keys(:prefix => 'foo').count.should == 1
    @bucket.keys(:prefix => 'bar').count.should == 0
    @bucket.clear
  end

  it 'lets a user get a list of keys' do
    @bucket.put("/foo/#{TEST_FILE}", open(TEST_FILE))
    pp @bucket.keys_and_service
    @bucket.clear
  end

  it 'lets a user get the location of the bucket ' do
    @bucket.location
  end

  it 'lets a user move a key' do
   #bucket.move_key
  end

  it 'lets a user rename a key' do
    #bucket.rename_key
   end

  it 'lets a user move get a public link ' do
    #bucket.public_link
  end


end
