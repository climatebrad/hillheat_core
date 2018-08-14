# Factory definitions
FactoryBot.define do
  sequence(:name) { |n| "name_#{n}" }
  sequence(:body) { |n| "body #{n}" * (n + 3 % 5) }
  sequence(:user) { |n| "user#{n}" }
  sequence(:email) { |n| "user#{n}@example.com" }
  sequence(:guid) { |n| "deadbeef#{n}" }
  sequence(:label) { |n| "lab_#{n}" }
  sequence(:file_name) { |f| "file_name_#{f}" }
  sequence(:time) { |n| Time.new(2012, 3, 26, 19, 56).in_time_zone - n }

  factory :user do
    login { FactoryBot.generate(:user) }
    email { generate(:email) }
    name 'Bond'
    nickname 'James Bond'
    notify_via_email false
    notify_on_new_articles false
    notify_on_comments false
    password 'top-secret'
    state 'active'
    profile User::CONTRIBUTOR
    association :text_filter, factory: :textile

    trait :without_twitter do
      twitter nil
      association :resource, nil
    end

    trait :with_a_full_profile do
      description 'I am a poor lonesone factory generated user'
      url 'http://myblog.net'
      msn 'random@mail.com'
      aim 'randomaccount'
      yahoo 'anotherrandomaccount'
      twitter '@random'
      jabber 'random@account.com'
    end

    trait :as_admin do
      profile User::ADMIN
    end

    trait :as_publisher do
      profile User::PUBLISHER
    end

    trait :as_contributor do
      profile User::CONTRIBUTOR
    end
  end

  factory :article do
    title 'A big article'
    body 'A content with several data'
    extended 'extended content for fun'
    guid
    permalink 'a-big-article'
    published_at { Time.zone.now }
    user
    allow_comments true
    state :published
    allow_pings true
    association :text_filter, factory: :textile

    after :build do |article|
      article.blog ||= Blog.first || create(:blog)
    end

    after :stub do |article|
      article.blog ||= Blog.first || create(:blog)
    end

    trait :with_tags do
      keywords 'a tag'
    end
  end

  factory :unpublished_article, parent: :article do
    published_at nil
    state :draft
  end

  factory :content do
    blog { Blog.first || create(:blog) }
  end

  factory :post_type do |p|
    p.name 'foobar'
    p.description 'Some description'
  end

  factory :markdown, class: :text_filter do
    name 'markdown'
    description 'Markdown'
    markup 'markdown'
    filters []
    params {}
  end

  factory :smartypants, parent: :markdown do |m|
    m.name 'smartypants'
    m.description 'SmartyPants'
    m.markup 'none'
    m.filters [:smartypants]
  end

  factory 'markdown smartypants', parent: :smartypants do |m|
    m.name 'markdown smartypants'
    m.description 'Markdown with SmartyPants'
    m.markup 'markdown'
    m.filters [:smartypants]
  end

  factory :textile, parent: :markdown do |m|
    m.name 'textile'
    m.description 'Textile'
    m.markup 'textile'
  end

  factory :none, parent: :markdown do |_m|
    name 'none'
    description 'None'
    markup 'none'
  end

  factory :utf8article, parent: :article do |u|
    u.title 'ルビー'
    u.permalink 'ルビー'
  end

  factory :second_article, parent: :article do |a|
    a.title 'Another big article'
  end

  factory :article_with_accent_in_html, parent: :article do |a|
    a.title 'article with accent'
    a.body '&eacute;coute The future is cool!'
    a.permalink 'article-with-accent'
  end

  factory :blog do
    base_url 'http://test.host/blog'
    hide_extended_on_rss true
    blog_name 'test blog'
    limit_article_display 2
    sp_url_limit 3
    plugin_avatar ''
    blog_subtitle 'test subtitle'
    limit_rss_display 10
    geourl_location ''
    default_allow_pings false
    send_outbound_pings false
    sp_global true
    default_allow_comments true
    email_from 'scott@sigkill.org'
    text_filter 'textile'
    sp_article_auto_close 0
    comment_text_filter 'markdown'
    permalink_format '/%year%/%month%/%day%/%title%'
    use_canonical_url true
    rss_description_text 'rss description text'
    lang 'en_US'

    after :stub do |blog|
      [blog.text_filter, blog.comment_text_filter].uniq.each do |filter|
        build_stubbed filter
      end
    end
  end

  factory :tag do |tag|
    tag.name { FactoryBot.generate(:name) }
    tag.display_name { |a| a.name } # rubocop:disable Style/SymbolProc
    blog { Blog.first || create(:blog) }
  end

  factory :resource do |r|
    r.upload { file_upload }
    r.mime 'image/jpeg'
    r.size 110
    blog { Blog.first || create(:blog) }
  end

  factory :avatar, parent: :resource do |a|
    a.upload 'avatar.jpg'
    a.mime 'image.jpeg'
    a.size 600
  end

  factory :redirect do
    from_path 'foo/bar'
    to_path '/someplace/else'
    blog { Blog.first || create(:blog) }
  end

  factory :comment do
    article
    association :text_filter, factory: :textile
    author 'Bob Foo'
    url 'http://fakeurl.com'
    body 'Comment body'
    guid
    state 'ham'

    factory :unconfirmed_comment do |c|
      c.state 'presumed_ham'
    end

    factory :published_comment do |c|
      c.state 'ham'
    end

    factory :not_published_comment do |c|
      c.state 'spam'
    end

    factory :ham_comment do |c|
      c.state 'ham'
    end

    factory :presumed_ham_comment do |c|
      c.state 'presumed_ham'
    end

    factory :presumed_spam_comment do |c|
      c.state 'presumed_spam'
    end

    factory :spam_comment do |c|
      c.state 'spam'
    end
  end

  factory :page do
    name { FactoryBot.generate(:name) }
    title 'Page One Title'
    body { FactoryBot.generate(:body) }
    published_at { Time.zone.now }
    user
    blog { Blog.first || create(:blog) }
    state 'published'
  end

  factory :note do
    body 'this is a note'
    published_at { Time.zone.now }
    user
    state 'published'
    association :text_filter, factory: :markdown
    guid
    blog { Blog.first || create(:blog) }
  end

  factory :unpublished_note, parent: :note do |n|
    n.state 'draft'
  end

  factory :trackback do |_t|
    state 'ham'
    article
    blog_name 'Trackback Blog'
    title 'Trackback Entry'
    url 'http://www.example.com'
    excerpt 'This is an excerpt'
    guid 'dsafsadffsdsf'
  end

  factory :sidebar do
    active_position 1
    config('title' => 'Links', 'body' => 'some links')
    type 'StaticSidebar'
    blog { Blog.first || create(:blog) }
  end
end
