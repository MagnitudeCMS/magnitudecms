class BaseModel < CouchRest::ExtendedDocument
  def self.get(id)
    begin
      super
    rescue RestClient::ResourceNotFound
      nil
    end
  end
end