require 'rails_helper'

describe Feedback::States, type: :model do
  before(:each) do
    FactoryGirl.create(:blog)
    @comment = FactoryGirl.create(:article).comments.build(author: 'Piers', body: 'Body')
  end

  it 'test_ham_all_the_way' do
    class << @comment
      def classify
        :ham
      end
    end
    assert @comment.unclassified?
    @comment.classify_content
    assert @comment.published?
    @comment.save
    @comment = Comment.find(@comment.id)
    @comment.confirm_classification
    assert @comment.published?
  end

  it 'test_spam_all_the_way' do
    class << @comment
      def classify
        :spam
      end
    end
    assert @comment.unclassified?
    @comment.classify_content
    assert !@comment.published?
    assert @comment.save
    assert !@comment.published?
    @comment = Comment.find(@comment.id)
    @comment.confirm_classification
    assert !@comment.published?
  end

  it 'test_presumed_spam_marked_as_ham' do
    @comment[:state] = 'presumed_spam'
    @comment.mark_as_ham
    assert @comment.published?
  end

  it 'test_presumed_ham_marked_as_spam' do
    @comment[:state] = 'presumed_ham'
    @comment.mark_as_spam
    assert !@comment.published?
  end
end
