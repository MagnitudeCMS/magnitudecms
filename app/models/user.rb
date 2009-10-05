# This code is pretty britle
# you can't save the doc, fail and try again. You need to start again with a new object.
#   unique_id appears to run only once
#   salt isn't saved if u save without a password the first time round.

class User < Mcms::BaseModel
  # Explicit SaltedUser mixin specificaiton
  require 'merb-auth-more/mixins/salted_user'
  include Merb::Authentication::Mixins::SaltedUser
  
  use_database CouchRest.database(Merb::Config[:couchdb_url] + "/" + Merb::Config[:database])
  
  # Official Schema
  property :email
  property :crypted_password
  property :salt
  
  timestamps!
  unique_id :set_id
  
  before_save :encrypt_password
  
  # Validation
  validates_present :email
  
  # Need to specify own authenticate method as merb-auth doesn't know about couchrest
  def self.authenticate(email, password)
    @u = User.get("user:#{email}")
    @u && @u.authenticated?(password) ? @u : nil
  end
  
  private
  # now there can only be one user with a given email address
  # however now that user is not able to change their email address...
  # well they could ifI write code to handle email change I suppose
  def set_id
    "user:#{self['email']}"
  end
end
