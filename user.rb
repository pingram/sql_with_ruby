require_relative 'aadatabase.rb'
require_relative 'question.rb'
require_relative 'question_follower.rb'
require_relative 'reply.rb'
require_relative 'question_like.rb'


class User <SaveObjects
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

  def save

    if self.id.nil?
      QuestionsDatabase.instance.execute(<<-SQL, :fname => fname, :lname => lname)
        INSERT INTO
          users (fname, lname)
        VALUES
          (:fname, :lname)
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
    else
      QuestionsDatabase.instance.execute(<<-SQL, :id => id, :fname => fname, :lname => lname)
        UPDATE
          users
        SET
          fname = :fname,
          lname = :lname
        WHERE
          id = :id
      SQL
    end
  end

end