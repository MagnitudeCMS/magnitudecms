module Mcms
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
    
    
    def etag
      Digest::SHA1.hexdigest(self.id.to_s)
    end
    
    def last_modified
      # last_modified needs to get Time, not DateTime
      if self.respond_to?(:updated_at)
        self.updated_at.to_time
      end
    end
    
  end
end # Mcms