class Account
  include MongoMapper::Document
  attr_accessor :password, :password_confirmation

  # Keys
  key :name,             String
  key :surname,          String
  key :identity,         String, :required => true
  key :crypted_password, String
  key :role,             String, :required => true, :default => :user

  key :key,              String,   :limit => 64,       :required => true
  key :secret,           String,   :limit => 64,       :required => true

  timestamps!
  key :activated_at,  Time

  key :deleted,       Boolean,  :default => false

  ensure_index :identity
  ensure_index :key

  # Validations
  validates_presence_of     :email, :role
  validates_presence_of     :password,                   :if => :password_required
  validates_presence_of     :password_confirmation,      :if => :password_required
  validates_length_of       :password, :within => 4..40, :if => :password_required
  validates_confirmation_of :password,                   :if => :password_required
  validates_length_of       :identity, :within => 3..100
  validates_uniqueness_of   :identity, :case_sensitive => false
  validates_format_of       :identity, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates_format_of       :role,     :with => /[A-Za-z]/

  validates_uniqueness_of   :key

  many :buckets,            :dependent => :destroy

  scope :admins,            where(:role => :admin)
  scope :users,             where(:role => :user)

  scope :active,            where(:deleted => false)

  #attr_accessible           :identity, :name, :surname, :role, :key

  # Callbacks
  before_validation :ensure_key_secret, :if => :missing_key_secret?
  before_save :encrypt_password,        :if => :password_required

  # our identity will be the email
  alias_method :email,  :identity
  alias_method :email=, :identity=

  ##
  # This method is for authentication purpose
  #
  def self.authenticate(identity, password)
    account = first(:identity => identity) if identity.present?
    account && account.has_password?(password) ? account : nil
  end

  def has_password?(password)
    ::BCrypt::Password.new(crypted_password) == password
  end

  def administrator?
    self.role.to_sym == :admin
  end

  def writable_by? passed_account
    passed_account.administrator? || self == passed_account
  end

  def update_these_attributes(attrs, *filter)
    update_attributes attrs.select { |k,v| filter.include? k }
  end

  def regenerate_key
    self.key = self.class.generate_key
    # a new key needs a new secret
    regenerate_secret
    self
  end

  def regenerate_secret
    self.secret = self.class.generate_secret
    self
  end

  private

  def encrypt_password
    self.crypted_password = ::BCrypt::Password.create(password)
  end

  def password_required
    crypted_password.blank? || password.present?
  end

  def missing_key_secret?
    key.blank? || secret.blank?
  end

  def ensure_key_secret
    self.key ||= self.class.generate_key
    self.secret ||= self.class.generate_secret
  end

  class << self

    def generate_key
      abc = %{ABCDEF0123456789}
      (1..20).map { abc[rand(abc.size),1] }.join
    end

    def generate_secret
      abc = %{ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz}
      (1..40).map { abc[rand(abc.size),1] }.join
    end

  end
end

if Account.all.size == 0
  Mainboard.logger.warn "= No users found! Creating bootstrap user user #{Mainboard.settings._bootstrap_admin_identity}..."

  user = Account.create({
    :identity => Mainboard.settings._bootstrap_admin_identity,
    :password => Mainboard.settings._bootstrap_admin_password,
    :password_confirmation => Mainboard.settings._bootstrap_admin_password,
    :key => Mainboard.settings._bootstrap_admin_key,
    :created_at => Time.now,
    :activated_at => Time.now,
    :role => :admin
  })

  if user.save
    Mainboard.logger.warn "= User 'admin' created! Please log in at http://replaceme/control/login using the following credentials:"
    Mainboard.logger.warn "\tLogin: #{Mainboard.settings._bootstrap_admin_identity}"
    Mainboard.logger.warn "\tPassword: #{Mainboard.settings._bootstrap_admin_password}"
    Mainboard.logger.warn "= It is STRONGLY advised that you change this password once logged in!"
  else
    Mainboard.logger.error "= There was an error creating admin user! Make sure your MongoDB connection information is correct and try running boardwalk again."
    Mainboard.logger.debug "Error(s): \n\t" + user.errors.map {|k,v| "#{k}: #{v}"}.join("\n\t")
  end
end
