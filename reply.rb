require_relative 'aadatabase.rb'
require_relative 'question.rb'
require_relative 'question_follower.rb'
require_relative 'user.rb'
require_relative 'question_like.rb'

class Reply
  attr_accessor :id, :question_id, :parent_reply_id, :user_id, :body

  def self.all
    results = QuestionsDatabase.instance.execute("SELECT * FROM replies")
    results.map { |result| Reply.new(result) }
  end

  def initialize(options = {})
    @id = options["id"]
    @question_id = options["question_id"]
    @parent_reply_id = options["parent_reply_id"]
    @user_id = options["user_id"]
    @body = options["body"]
  end

  def self.find_by_id(find_id)
    result = QuestionsDatabase.instance.execute(<<-SQL,find_id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.id = ?
    SQL

    Reply.new(result.first)
  end

  def self.find_by_user_id(find_id)
    results = QuestionsDatabase.instance.execute(<<-SQL,find_id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.user_id = ?
    SQL

    results.map { |result| Reply.new(result) }
  end

  def author
    result = QuestionsDatabase.instance.execute(<<-SQL,user_id)
      SELECT
        *
      FROM
        users
      WHERE
        users.id = ?
    SQL

    User.new(result.first)
  end

  def question
    result = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        questions
      WHERE
        questions.id = ?
    SQL

    Question.new(result.first)
  end

  def parent_reply
    result = QuestionsDatabase.instance.execute(<<-SQL, parent_reply_id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.id = ?
    SQL

    Reply.new(result.first)
  end

  def child_replies
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.parent_reply_id = ?
    SQL

    results.map { |result| Reply.new(result) }
  end

end