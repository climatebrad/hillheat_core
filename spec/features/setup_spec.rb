# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Blog setup", type: :feature do
  let(:strong_password) { "fhnehnhfiiuh" }

  before do
    stub_request(:get,
                 "http://www.google.com/search?output=rss&q=link:www.example.com&tbm=blg")
      .to_return(status: 200, body: "", headers: {})
    load Rails.root.join("db/seeds.rb")
  end

  scenario "User accesses blog for the first time" do
    # Go to the blog setup
    visit "/"
    expect(page).to have_text I18n.t!("setup.index.welcome_to_your_blog_setup")

    # Set up the blog
    fill_in :blog_blog_name, with: "Awesome blog"
    fill_in :user_email, with: "foo@bar.com"
    fill_in :user_password, with: strong_password
    click_button I18n.t!("generic.save")

    # Confirm set up success
    expect(page).to have_text I18n.t!("accounts.confirm.success")
    expect(page).to have_text I18n.t!("accounts.confirm.login", login: "admin")

    # Visit the autogenerated article
    click_link I18n.t!("accounts.confirm.admin")
    click_link I18n.t!("admin.shared.menu.all_articles")
    find("tbody#articleList td a.published").click

    expect(page).to have_text I18n.t!("setup.article.title")

    # Confirm ability to log in
    visit admin_dashboard_path
    find("a[href=\"#{destroy_user_session_path}\"]").click

    visit admin_dashboard_path
    fill_in :user_login, with: "admin"
    fill_in :user_password, with: strong_password
    find("input[type=submit]").click
    expect(page).to have_text I18n.t!("admin.dashboard.index.welcome_back",
                                      user_name: "admin")

    # Confirm proper setting fo user properties
    expect(User.first.email).to eq "foo@bar.com"
  end

  scenario "setup fails at first due to password weakness" do
    visit "/setup"
    fill_in :blog_blog_name, with: "Awesome blog"
    fill_in :user_email, with: "foo@bar.com"
    fill_in :user_password, with: "not-strong"
    click_button I18n.t!("generic.save")

    expect(page)
      .to have_text "Password not strong enough. It scored 2. It must score at least 4."

    fill_in :user_password, with: strong_password
    click_button I18n.t!("generic.save")

    expect(page).to have_text I18n.t!("accounts.confirm.success")
  end

  scenario "setup fails due to missing blog name" do
    visit "/setup"
    click_button I18n.t!("generic.save")

    expect(page).to have_text "Blog name can't be blank"
  end
end
