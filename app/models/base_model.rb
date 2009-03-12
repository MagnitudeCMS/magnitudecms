class BaseModel < CouchRest::ExtendedDocument
  # Include the validation module to get access to the validation methods
  include CouchRest::Validation 
  
  def self.get(id)
    begin
      super
    rescue RestClient::ResourceNotFound
      nil
    end
  end
end