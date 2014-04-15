require 'singleton'
require 'sqlite3'


class QuestionsDatabase < SQLite3::Database
  include Singleton


  def initialize
    super("AAquestions.db")

    self.results_as_hash = true
    self.type_translation = true
  end
end

#class

class User
  attr_accessor :id, :fname, :lname

  def self.all
    results = QuestionsDatabase.instance.execute("SELECT * FROM users")
    results.map { |result| User.new(result) }
  end

  def initialize(options = {})
    p options
    @id = options["id"]
    @fname = options["fname"]
    @lname = options["lname"]
  end

  def self.find_by_id(find_id)
    #id = id.to_i
    result = QuestionsDatabase.instance.execute(<<-SQL,find_id)
      SELECT
        *
      FROM
        users
      WHERE
        users.id = ?
    SQL

    User.new(result.first)
  end

  def self.find_by_name(fname, lname)
    result = QuestionsDatabase.instance.execute(<<-SQL,fname, lname)
      SELECT
        *
      FROM
        users
      WHERE
        users.fname = ? AND
        users.lname = ?
    SQL

    User.new(result.first)
  end
end

class Question
  attr_accessor :id, :title, :body, :author_id

  def self.all
    results = QuestionsDatabase.instance.execute("SELECT * FROM questions")
    results.map { |result| User.new(result) }
  end

  def initialize(options = {})
    @id = options["id"]
    @title = options["title"]
    @body = options["body"]
    @author_id = options["author_id"]
  end

  def self.find_by_id(find_id)
    #id = id.to_i
    result = QuestionsDatabase.instance.execute(<<-SQL,find_id)
      SELECT
        *
      FROM
        questions
      WHERE
        questions.id = ?
    SQL

    Question.new(result.first)
  end


end

class QuestionFollower
  attr_accessor :id, :question_id, :user_id

  def self.all
    results = QuestionsDatabase.instance.execute("SELECT * FROM question_followers")
    results.map { |result| QuestionFollower.new(result) }
  end

  def initialize(options = {})
    @id = options["id"]
    @question_id = options["question_id"]
    @user_id = options["user_id"]
  end


  def self.find_by_id(find_id)
    result = QuestionsDatabase.instance.execute(<<-SQL,find_id)
      SELECT
        *
      FROM
        question_followers
      WHERE
        question_followers.id = ?
    SQL

    QuestionFollower.new(result.first)
  end
end

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
end

class QuestionLike
  attr_accessor :id, :question_id, :user_id

  def self.all
    results = QuestionsDatabase.instance.execute("SELECT * FROM question_likes")
    results.map { |result| QuestionLike.new(result) }
  end

  def initialize(options = {})
    @id = options["id"]
    @question_id = options["question_id"]
    @user_id = options["user_id"]
  end

  def self.find_by_id(find_id)
    result = QuestionsDatabase.instance.execute(<<-SQL,find_id)
      SELECT
        *
      FROM
        question_likes
      WHERE
        question_likes.id = ?
    SQL

    QuestionLike.new(result.first)
  end
end


#
# puts "QuestionLikes:"
# p QuestionLike.all
# puts "Replies:"
# p Reply.all


































