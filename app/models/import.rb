class Import
  def initialize(attributes={})
    attributes.each do |k,v|
      respond_to?(:"#{k}=") ? send(:"#{k}=", v) : raise(NoMethodError, "Unknown method #{k}, add it to the record attributes")
    end
  end

  include Validatable

  attr_accessor :uploaded_file, :collection, :format

  validates_presence_of :uploaded_file
  validates_presence_of :collection
  validates_presence_of :format

end
