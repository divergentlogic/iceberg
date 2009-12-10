class Iceberg::Category
  include DataMapper::Resource
  
  property :id,         Serial
  property :title,      String
  property :created_at, DateTime
  property :updated_at, DateTime
  
  has n, :forums, :order => [:position]
  
  validates_present   :title
  validates_is_unique :title
  
  is :list
  
  def self.ordered
    all(:order => [:position])
  end
end
