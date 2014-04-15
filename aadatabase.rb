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

  def authored_questions
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        questions.author_id = ?
    SQL

    results.map { |result| Question.new(result) }
  end

  def authored_replies
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.user_id = ?
    SQL

    results.map { |result| Reply.new(result) }
  end

  def followed_questions
    QuestionFollower.followed_questions_for_user_id(id)
  end

  def liked_questions
    QuestionLike.liked_questions_for_user_id(id)
  end

  def average_karma
    results = QuestionsDatabase.instance.execute(<<-SQL, id, id)
      SELECT
        (COUNT(ql.question_id) * 1.0 /
         (SELECT COUNT(*)
          FROM users u
          JOIN questions q
          ON u.id = q.author_id
          WHERE u.id = ?
        )) avg_likes
      FROM
        questions q
      JOIN
        question_likes ql
      ON
        q.id = ql.question_id
      WHERE
        q.author_id = ?
    SQL

    results.first["avg_likes"]
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

  def self.find_by_author_id(id)
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        questions
      WHERE
        questions.author_id = ?
    SQL

    results.map { |result| Question.new(result) }
  end

  def author
    result = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        users
      WHERE
        users.id = ?
    SQL

    User.new(result.first)
  end

  def replies
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        replies.question_id = ?
    SQL

    results.map { |result| Reply.new(result) }
  end

  def followers
    QuestionFollower.followers_for_question_id(id)
  end

  def self.most_followed(n)
    QuestionFollower.most_followed_questions(n)
  end

  def likers
    QuestionLike.likers_for_question_id(id)
  end

  def num_likes
    QuestionLike.num_likes_for_question_id(id)
  end

  def self.most_liked(n)
    QuestionLike.most_liked_questions(n)
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

  def self.followers_for_question_id(find_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, find_id)
      SELECT
        u.id, u.fname, u.lname
      FROM
        question_followers qf
      JOIN
        users u
      ON
        qf.user_id = u.id
      WHERE
        qf.question_id = ?
    SQL

    results.map { |result| User.new(result) }
  end

  def self.followed_questions_for_user_id(find_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, find_id)
      SELECT
         q.id, q.title, q.body, q.author_id
      FROM
        question_followers qf
      JOIN
        questions q
      ON
        qf.question_id = q.id
      WHERE
        qf.user_id = ?
    SQL

    results.map { |result| Question.new(result) }
  end

  def self.most_followed_questions(n)
    results = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
         q.id, q.title, q.body, q.author_id
      FROM
        question_followers qf
      JOIN
        questions q
      ON
        qf.question_id = q.id
      GROUP BY
        q.id
      ORDER BY
        COUNT(qf.user_id) DESC
    SQL

    results.map { |result| Question.new(result) }.take(n)
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

  def self.likers_for_question_id(find_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, find_id)
      SELECT
        u.id, u.fname, u.lname
      FROM
        question_likes ql
      JOIN
        users u
      ON
        ql.user_id = u.id
      WHERE
        ql.question_id = ?
    SQL

    results.map { |result| User.new(result) }
  end

  def self.num_likes_for_question_id(find_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, find_id)
      SELECT
        COUNT(user_id) like_count
      FROM
        question_likes
      WHERE
        question_id = ?
      GROUP BY
        question_id
    SQL

    results.first["like_count"]
  end

  def self.liked_questions_for_user_id(find_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, find_id)
      SELECT
      q.id, q.title, q.body, q.author_id
      FROM
        question_likes ql
      JOIN
        questions q
      ON
        ql.question_id = q.id
      WHERE
        ql.user_id = ?
      GROUP BY
        ql.question_id
    SQL

    results.map { |result| Question.new(result) }
  end

  def self.most_liked_questions(n)
    results = QuestionsDatabase.instance.execute(<<-SQL)
      SELECT
         q.id, q.title, q.body, q.author_id
      FROM
        question_likes ql
      JOIN
        questions q
      ON
        ql.question_id = q.id
      GROUP BY
        q.id
      ORDER BY
        COUNT(ql.user_id) DESC
    SQL

    results.map { |result| Question.new(result) }.take(n)
  end
end


#
# puts "QuestionLikes:"
# p QuestionLike.all
# puts "Replies:"
# p Reply.all


































