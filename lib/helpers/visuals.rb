module Iceberg
  module Helpers
    module Visuals
      
      include Rack::Utils
      alias_method :h, :escape_html
      
      def breadcrumbs(board_or_topic, options={})
        separator = options.delete(:separator) || ' > '
        wrap_with_tag = options.delete(:wrap_with_tag)

        links = []
        current = if board_or_topic.is_a?(::Iceberg::Topic)
          links << link_to(board_or_topic.title, topic_path(board_or_topic))
          board_or_topic.board
        else
          board_or_topic
        end
        while current
          links.unshift(link_to(current.title, board_path(current)))
          current = current.parent
        end
        links.unshift(link_to("Index", boards_path))
        links.map! {|l| content_tag(wrap_with_tag, l)} if wrap_with_tag
        links.join(h(separator))
      end
      
      def quote_post(post)
        post.message
      end
      
    end
  end
end
