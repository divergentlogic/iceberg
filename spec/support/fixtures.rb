TestApp::Board.fixture {{
  :title => /\w+/.gen,
  :description => /\w+/.gen
}}

TestApp::Topic.fixture {{
  :title => /\w+/.gen,
  :message => /\w+/.gen,
  :board => TestApp::Board.generate
}}

TestApp::Move.fixture {{
  :board_path => /\w+/.gen,
  :topic_slug => /\w+/.gen,
  :topic => TestApp::Topic.make
}}
