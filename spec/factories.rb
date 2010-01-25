Factory.define :board, :class => Iceberg::Board do |f|
  f.title "This is a General Board"
  f.description "Talk about general topics in this board"
end

Factory.define :topic, :class => Iceberg::Topic do |f|
  f.title "Let's talk about something"
  f.message "What do you guys want to talk about?"
end
