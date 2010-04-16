TestApp::Board.fixture {{
  :title => /\w+/.gen,
  :description => /\w+/.gen
}}

TestApp::Topic.fixture {{
  :title => /\w+/.gen,
  :message => /\w+/.gen
}}
