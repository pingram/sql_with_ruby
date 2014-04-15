require_relative 'aadatabase.rb'
require_relative 'user.rb'
require_relative 'question_follower.rb'
require_relative 'reply.rb'
require_relative 'question_like.rb'



class Question
  attr_accessor :id, :title, :body, :author_id

  def self.all
    results = QuestionsDatabase.instance.execute("SELECT * FROM questions")
    results.map { |result| Question.new(result) }
  end

  def initialize(options = {})
    @id = options["id"]
    @title = options["title"]
    @body = options["body"]
    @author_id = options["author_id"]
  end

  def save

    if self.id.nil?
      QuestionsDatabase.instance.execute(<<-SQL, :title => title, :body => body, :author_id => author_id)
        INSERT INTO
          questions (title, body, author_id)
        VALUES
          (:title, :body, :author_id)
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
    else
      QuestionsDatabase.instance.execute(<<-SQL, :title => title, :body => body, :author_id => author_id, :id => id)
        UPDATE
          questions
        SET
          title = :title,
          body = :body,
          author_id = :author_id
        WHERE
          id = :id
      SQL
    end
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
