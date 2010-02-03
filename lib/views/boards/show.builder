xml.instruct! :xml, :version => '1.0', :encoding => 'utf-8'
xml.feed(:xmlns => "http://www.w3.org/2005/Atom") do
  xml.title @board.title
  xml.link(:href => url_for(:board, @board), :rel => "alternate", :type => "text/html")
  xml.link(:href => url_for(:board_atom, @board), :rel => "self", :type => "application/atom+xml")
  xml.updated @board.last_updated_at.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
  xml.id url_for(:board_atom, @board)
  @board.topics.each do |topic|
    xml.entry do
      xml.title topic.title
      xml.link(:href => url_for(:topic, topic), :rel => "alternate", :type => "text/html")
      xml.id url_for(:topic, topic)
      xml.updated topic.last_updated_at.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
      xml.author do
        # TODO add author
        xml.name "Name"
      end
      xml.content(topic.last_post.message, :type => "html")
    end
  end
end
