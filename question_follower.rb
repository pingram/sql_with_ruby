require_relative 'aadatabase.rb'
require_relative 'question.rb'
require_relative 'user.rb'
require_relative 'reply.rb'
require_relative 'question_like.rb'

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