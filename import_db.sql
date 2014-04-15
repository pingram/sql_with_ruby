CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

CREATE TABLE questions(
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body VARCHAR(255) NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (author_id) REFERENCES users(id)
);

CREATE TABLE question_followers(
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES user(id)
);

CREATE TABLE replies(
  id INTEGER PRIMARY KEY,
  body VARCHAR(255) NOT NULL,
  question_id INTEGER NOT NULL,
  parent_reply_id INTEGER,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (parent_reply_id) REFERENCES replies(id)

);

CREATE TABLE question_likes(
  id INTEGER PRIMARY KEY,
  question_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,

  FOREIGN KEY (question_id) REFERENCES questions(id),
  FOREIGN KEY (user_id) REFERENCES user(id)
);

INSERT INTO
  users (fname, lname)
VALUES
  ('Tejas', 'Mehta'), ('Phil', 'Ingram'), ('Follows', 'All');

INSERT INTO
  questions(title, body, author_id)
VALUES
  ('Angels and demons', 'What are they?', 1),
  ('Ruby and SQL', 'How does it work?', 2),
  ('Sky color', 'Why is the sky blue?', 2);

INSERT INTO
  question_followers(question_id, user_id)
VALUES
  (1, 3), (2, 3), (3, 3), (1, 1), (1, 2);


INSERT INTO
  replies(body, question_id, parent_reply_id, user_id)
VALUES
  ('Reply 1 from Follows all', 1, null, 3),
  ('Reply 2 from Phil', 1, 1, 2);

INSERT INTO
  question_likes(question_id, user_id)
VALUES
  (2, 1), (2, 2), (2, 3);