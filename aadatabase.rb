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

class SaveObjects

  def initialize
    @fname = 'aa2'
    @lname = 'adfa2'
  end

  def save

    inst_var_keys = self.instance_variables
    inst_var_values = inst_var_keys.map do |iv|
      self.instance_variable_get(iv)
    end
    inst_var_keys.map!(&:to_s)
    inst_var_keys.map! do |str|
      str.delete('@')
    end
    # p inst_var_keys
    # p inst_var_values

    str_cols = '('
    inst_var_keys.each do |key|
      str_cols += key + ', '
    end
    str_cols = str_cols[0..-3]
    str_cols += ')'
    p str_cols

    str_vals = '('
    inst_var_values.each do |value|
      if value.is_a? String
        str_vals += "'" + value + "', "
      else
        str_vals += value.to_s + ", "
      end
    end
    str_vals = str_vals[0..-3]
    str_vals += ')'
    p str_vals


    sql_str = " INSERT INTO users #{str_cols} VALUES #{str_vals}"

    # str = " INSERT INTO users (fname, lname) VALUES ('ABC', 'DEF') "
    #
    QuestionsDatabase.instance.execute(sql_str)


    # if self.id.nil?
    #   QuestionsDatabase.instance.execute(<<-SQL, options)
    #     INSERT INTO
    #       users (fname, lname)
    #     VALUES
    #       (:fname, :lname)
    #   SQL
    #   @id = QuestionsDatabase.instance.last_insert_row_id
    # else
    #   QuestionsDatabase.instance.execute(<<-SQL, :id => id, :fname => fname, :lname => lname)
    #     UPDATE
    #       users
    #     SET
    #       fname = :fname,
    #       lname = :lname
    #     WHERE
    #       id = :id
    #   SQL
    # end
  end

end











#
# puts "QuestionLikes:"
# p QuestionLike.all
# puts "Replies:"
# p Reply.all


































