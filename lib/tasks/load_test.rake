# require 'capybara/poltergeist'

desc "Simulate load against Keevah application"
task :load_test => :environment do
  4.times.map { Thread.new { browse } }.map(&:join)
end

def browse
  session = Capybara::Session.new(:selenium)

  loop do
    session.visit('https://immense-beach-5339.herokuapp.com/')
    session.click_link('Browse')
  end

end