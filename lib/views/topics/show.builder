xml.instruct! :xml, :version => '1.0', :encoding => 'utf-8'
xml.feed(:xmlns => "http://www.w3.org/2005/Atom") do
  xml.title @topic.title
  xml.link(:href => url_for(:topic, @topic), :rel => "alternate", :type => "text/html")
  xml.link(:href => url_for(:topic_atom, @topic), :rel => "self", :type => "application/atom+xml")
  xml.updated @topic.last_updated_at.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
  xml.id url_for(:topic_atom, @topic)
  @topic.posts.each do |post|
    xml.entry do
      xml.title @topic.title
      xml.link(:href => url_for(:post, post), :rel => "alternate", :type => "text/html")
      xml.id url_for(:post, post)
      xml.updated post.updated_at.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
      xml.author do
        # TODO add author
        xml.name "Name"
      end
      xml.content(post.message, :type => "html")
    end
  end
end
