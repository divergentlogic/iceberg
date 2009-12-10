class Iceberg::Forum
  include DataMapper::Resource
  
  property :id,               Serial
  property :title,            String,   :length => (1..2000)
  property :slug,             Slug
  property :description,      String,   :length => (1..2000)
  property :last_post_id,     Integer
  property :created_at,       DateTime
  property :updated_at,       DateTime
  property :last_updated_at,  DateTime
  
  belongs_to :category
  has n, :topics
  has n, :posts, :through => :topics
  
  validates_present   :category
  validates_is_unique :title, :scope => :category_id, :message => "There's already a forum with that title in this category"
  
  is :list, :scope => [:category_id]
  
  before :valid?, :set_slug
  
protected
  def set_slug
    attribute_set(:slug, :title)
  end
end
