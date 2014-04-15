require_relative 'aadatabase.rb'
require_relative 'question.rb'
require_relative 'question_follower.rb'
require_relative 'user.rb'
require_relative 'reply.rb'


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