class Iceberg::Forum
  include DataMapper::Resource
  
  property :id,               Serial
  property :title,            String,   :length => (1..250)
  property :slug,             Slug,     :length => (1..250)
  property :description,      String,   :length => (1..500)
  property :parent_id,        Integer
  property :position,         Integer,  :default => 0
  property :topics_count,     Integer,  :default => 0
  property :posts_count,      Integer,  :default => 0
  property :created_at,       DateTime
  property :updated_at,       DateTime
  property :last_updated_at,  DateTime
  property :last_topic_id,    Integer
  property :last_post_id,     Integer
  property :allow_topics,     Boolean,  :default => true
  
  has n, :topics
  has n, :posts, :through => :topics
  belongs_to :last_topic, 'Iceberg::Topic'
  belongs_to :last_post,  'Iceberg::Post'
  
  validates_present   :title, :description
  validates_is_unique :title, :scope => :parent_id, :message => "There's already a forum with that title"
  
  is :list, :scope => [:parent_id]
  is :tree, :order => :position
  alias_method :forums, :children
  
  before :valid?, :set_slug
  
  class << self
    def ordered(options={})
      all(options.merge!({:order => [:position]}))
    end
    
    def by_ancestory(slugs)
      while !slugs.empty?
        slug = slugs.shift
        child = if child
          child.children(:slug => slug).first
        else
          first(:slug => slug, :parent_id => nil)
        end
        return nil unless child
      end
      child
    end
  end
  
  def post_topic(author, attributes={})
    topic = Iceberg::Topic.new(attributes)
    topic.forum = self
    # topic.author = author
    # topic.last_author = author
    topic.save
    topic
  end
  
  def ancestory
    unless @ancestory
      @ancestory = [slug]
      current = self
      while current.parent
        @ancestory.unshift(current.parent.slug)
        current = current.parent
      end
    end
    @ancestory
  end
  
  def ancestory_path
    ancestory.join('/')
  end

protected

  def set_slug
    if title && slug.nil?
      attribute_set(:slug, title.to_url)
    end
  end

end
