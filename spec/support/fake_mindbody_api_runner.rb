FakeMindBodyApiRunner = Capybara::Discoball::Runner.new(FakeMindBodyApi::Application) do |server|
  MindBodyApi.base_url = "http://#{server.host}:#{server.port}"
end
