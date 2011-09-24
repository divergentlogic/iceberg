module Iceberg::Models::Move
  extend ActiveSupport::Concern

  included do
    include DataMapper::Resource

    property :id,         DataMapper::Property::Serial
    property :board_path, DataMapper::Property::String, :length => (1..250), :unique_index => :board_and_topic
    property :topic_slug, DataMapper::Property::String, :length => (1..250), :unique_index => :board_and_topic

    belongs_to :topic

    validates_presence_of   :board_path, :topic_slug, :topic
    validates_uniqueness_of :board_path, :scope => :topic_slug
    validates_uniqueness_of :topic_slug, :scope => :board_path
  end
end
