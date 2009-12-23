module Iceberg
  module Helpers
    module Visuals
      
      def breadcrumbs(forum_or_topic, options={})
        separator = options.delete(:separator) || ' > '
        wrap_with_tag = options.delete(:wrap_with_tag)

        links = []
        current = if forum_or_topic.is_a?(::Iceberg::Topic)
          links << link_to(forum_or_topic.title, topic_path(forum_or_topic))
          forum_or_topic.forum
        else
          forum_or_topic
        end
        while current
          links.unshift(link_to(current.title, forum_path(current)))
          current = current.parent
        end
        links.unshift(link_to("Index", forums_path))
        links.map! {|l| content_tag(wrap_with_tag, l)} if wrap_with_tag
        links.join(h(separator))
      end
      
    end
  end
end
