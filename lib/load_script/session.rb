require "logger"
require "capybara"
require 'capybara/poltergeist'
require "faker"
require "active_support"
require "active_support/core_ext"

module LoadScript
  class Session
    include Capybara::DSL
    attr_reader :host
    def initialize(host = nil)
      Capybara.default_driver = :poltergeist
      @host = host || "http://localhost:3000"
    end

    def logger
      @logger ||= Logger.new("./log/requests.log")
    end

    def session
      @session ||= Capybara::Session.new(:poltergeist)
    end

    def run
      while true
        run_action(actions.sample)
      end
    end

    def run_action(name)
      benchmarked(name) do
        send(name)
      end
    rescue Capybara::Poltergeist::TimeoutError
      logger.error("Timed out executing Action: #{name}. Will continue.")
    end

    def benchmarked(name)
      logger.info "Running action #{name}"
      start = Time.now
      val = yield
      logger.info "Completed #{name} in #{Time.now - start} seconds"
      val
    end

    def actions
      [:browse_loan_requests,   :sign_up_as_lender, :browse_categories,
       :make_a_loan, :sign_up_as_borrower, :borrower_creates_loan_request]
    end

    def log_in(email="demo+horace@jumpstartlab.com", pw="password")
      log_out
      session.visit host
      session.click_link("Login")
      session.fill_in("Email", with: email)
      session.fill_in("Password", with: pw)
      session.click_link_or_button("Log In")
    end

    def browse_loan_requests
      session.visit "#{host}/browse"
      session.all(".lr-about").sample.click
    end

    def log_out
      session.visit host
      if session.has_content?("Log out")
        session.find("#logout").click
      end
    end

    def new_user_name
      "#{Faker::Name.name} #{Time.now.to_i}"
    end

    def new_user_email(name)
      "TuringPivotBots+#{name.split.join}@gmail.com"
    end

    def sign_up_as_lender(name = new_user_name)
      log_out
      session.find("#sign-up-dropdown").click
      session.find("#sign-up-as-lender").click
      session.within("#lenderSignUpModal") do
        session.fill_in("user_name", with: name)
        session.fill_in("user_email", with: new_user_email(name))
        session.fill_in("user_password", with: "password")
        session.fill_in("user_password_confirmation", with: "password")
        session.click_link_or_button "Create Account"
      end
    end

    def sign_up_as_borrower(name = new_user_name)
      log_out
      session.find("#sign-up-dropdown").click
      session.find("#sign-up-as-borrower").click
      session.within("#borrowerSignUpModal") do
        session.fill_in("user_name", with: name)
        session.fill_in("user_email", with: new_user_email(name))
        session.fill_in("user_password", with: "password")
        session.fill_in("user_password_confirmation", with: "password")
        session.click_link_or_button "Create Account"
      end
    end

    def categories
      ["Agriculture", "Education", "Community"]
    end

    def browse_categories
      session.visit("#{host}/categories")
      session.all(".cat-lr").sample.click
    end

    def make_a_loan
      log_in
      session.visit "#{host}/browse"
      session.all(".lr-about").sample.click
      session.find(".contribute").click
      session.click_link("Basket")
      session.click_link_or_button("Transfer Funds")
    end

    def borrower_creates_loan_request
      sign_up_as_borrower
      session.click_link_or_button "Create Loan Request"
      session.within("#loanRequestModal") do
        session.fill_in("Title", with: "Basketball Court")
        session.fill_in("Description", with: "Court for the kids")
        session.fill_in("Image url", with: "")
        session.fill_in("Requested by date", with: "10/10/2015")
        session.fill_in("Repayment begin date", with: "12/10/2015")
        session.select("Monthly", from: "Repayment rate")
        session.select("Education", from: "Category")
        session.fill_in("Amount", with: "100")

        session.click_link_or_button "Submit"
      end

    end

  end
end
