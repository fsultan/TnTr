-- 
-- Created by SQL::Translator::Producer::SQLite
-- Created on Tue Jul  7 13:18:24 2009
-- 


BEGIN TRANSACTION;

--
-- Table: clients
--
DROP TABLE clients;

CREATE TABLE clients (
  id INTEGER PRIMARY KEY NOT NULL,
  user INTEGER NOT NULL,
  name TEXT NOT NULL,
  domain INTEGER NOT NULL,
  create_time INTEGER,
  update_time INTEGER,
  close_time INTEGER
);

CREATE INDEX clients_idx_domain_clients ON clients (domain);

CREATE INDEX clients_idx_user_clients ON clients (user);

--
-- Table: domains
--
DROP TABLE domains;

CREATE TABLE domains (
  id INTEGER PRIMARY KEY NOT NULL,
  name TEXT NOT NULL,
  create_time INTEGER,
  update_time INTEGER,
  close_time INTEGER
);

--
-- Table: groups
--
DROP TABLE groups;

CREATE TABLE groups (
  id INTEGER PRIMARY KEY NOT NULL,
  user INTEGER NOT NULL,
  name TEXT NOT NULL,
  domain INTEGER NOT NULL,
  create_time INTEGER,
  update_time INTEGER,
  close_time INTEGER
);

CREATE INDEX groups_idx_domain_groups ON groups (domain);

CREATE INDEX groups_idx_user_groups ON groups (user);

--
-- Table: projects
--
DROP TABLE projects;

CREATE TABLE projects (
  id INTEGER PRIMARY KEY NOT NULL,
  user INTEGER NOT NULL,
  name TEXT NOT NULL,
  client INTEGER NOT NULL,
  description TEXT NOT NULL,
  create_time INTEGER,
  update_time INTEGER,
  close_time INTEGER
);

CREATE INDEX projects_idx_client_projects ON projects (client);

CREATE INDEX projects_idx_user_projects ON projects (user);

--
-- Table: rights
--
DROP TABLE rights;

CREATE TABLE rights (
  id INTEGER PRIMARY KEY NOT NULL,
  owner_type TEXT NOT NULL,
  owner_id INTEGER NOT NULL,
  app_name TXT NOT NULL,
  app_id INTEGER NOT NULL,
  right TEXT NOT NULL,
  delegated_by INTEGER NOT NULL,
  create_time INTEGER,
  update_time INTEGER,
  close_time INTEGER
);

--
-- Table: tasks
--
DROP TABLE tasks;

CREATE TABLE tasks (
  id INTEGER PRIMARY KEY NOT NULL,
  user INTEGER NOT NULL,
  name TEXT NOT NULL,
  project INTERGER NOT NULL,
  description TEXT NOT NULL,
  create_time INTEGER,
  update_time INTEGER,
  close_time INTEGER
);

CREATE INDEX tasks_idx_project_tasks ON tasks (project);

CREATE INDEX tasks_idx_user_tasks ON tasks (user);

--
-- Table: times
--
DROP TABLE times;

CREATE TABLE times (
  id INTEGER PRIMARY KEY NOT NULL,
  name TEXT NOT NULL,
  user INTEGER NOT NULL,
  task INTEGER NOT NULL,
  description TEXT NOT NULL,
  start_datetime INTEGER,
  end_datetime INTEGER,
  create_time INTEGER,
  update_time INTEGER
);

CREATE INDEX times_idx_task_times ON times (task);

CREATE INDEX times_idx_user_times ON times (user);

--
-- Table: user_group
--
DROP TABLE user_group;

CREATE TABLE user_group (
  user INTEGER NOT NULL,
  gid INTEGER NOT NULL,
  PRIMARY KEY (user, gid)
);

CREATE INDEX user_group_idx_gid_user_group ON user_group (gid);

CREATE INDEX user_group_idx_user_user_group ON user_group (user);

--
-- Table: users
--
DROP TABLE users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY NOT NULL,
  username TEXT NOT NULL,
  password TEXT NOT NULL,
  domain INTEGER NOT NULL,
  name TEXT NOT NULL,
  superuser INTEGER NOT NULL DEFAULT '0',
  create_time INTEGER,
  update_time INTEGER,
  close_time INTEGER
);

CREATE INDEX users_idx_domain_users ON users (domain);

COMMIT;
