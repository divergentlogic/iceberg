Factory.define :forum, :class => Iceberg::Forum do |f|
  f.title "This is a General Forum"
  f.description "Talk about general topics in this forum"
end

Factory.define :topic, :class => Iceberg::Topic do |f|
  f.title "Let's talk about something"
  f.message "What do you guys want to talk about?"
end
