--
-- Table: clients
--
DROP TABLE "clients" CASCADE;
CREATE TABLE "clients" (
  "id" integer NOT NULL,
  "user" integer NOT NULL,
  "name" text NOT NULL,
  "domain" integer NOT NULL,
  "create_time" integer,
  "update_time" integer,
  "close_time" integer,
  PRIMARY KEY ("id")
);
CREATE INDEX "clients_idx_domain" on "clients" ("domain");
CREATE INDEX "clients_idx_user" on "clients" ("user");

--
-- Table: domains
--
DROP TABLE "domains" CASCADE;
CREATE TABLE "domains" (
  "id" integer NOT NULL,
  "name" text NOT NULL,
  "create_time" integer,
  "update_time" integer,
  "close_time" integer,
  PRIMARY KEY ("id")
);

--
-- Table: groups
--
DROP TABLE "groups" CASCADE;
CREATE TABLE "groups" (
  "id" integer NOT NULL,
  "user" integer NOT NULL,
  "name" text NOT NULL,
  "domain" integer NOT NULL,
  "create_time" integer,
  "update_time" integer,
  "close_time" integer,
  PRIMARY KEY ("id")
);
CREATE INDEX "groups_idx_domain" on "groups" ("domain");
CREATE INDEX "groups_idx_user" on "groups" ("user");

--
-- Table: projects
--
DROP TABLE "projects" CASCADE;
CREATE TABLE "projects" (
  "id" integer NOT NULL,
  "user" integer NOT NULL,
  "name" text NOT NULL,
  "client" integer NOT NULL,
  "description" text NOT NULL,
  "create_time" integer,
  "update_time" integer,
  "close_time" integer,
  PRIMARY KEY ("id")
);
CREATE INDEX "projects_idx_client" on "projects" ("client");
CREATE INDEX "projects_idx_user" on "projects" ("user");

--
-- Table: rights
--
DROP TABLE "rights" CASCADE;
CREATE TABLE "rights" (
  "id" integer NOT NULL,
  "owner_type" text NOT NULL,
  "owner_id" integer NOT NULL,
  "app_name" txt NOT NULL,
  "app_id" integer NOT NULL,
  "right" text NOT NULL,
  "delegated_by" integer NOT NULL,
  "create_time" integer,
  "update_time" integer,
  "close_time" integer,
  PRIMARY KEY ("id")
);

--
-- Table: tasks
--
DROP TABLE "tasks" CASCADE;
CREATE TABLE "tasks" (
  "id" integer NOT NULL,
  "user" integer NOT NULL,
  "name" text NOT NULL,
  "project" interger NOT NULL,
  "description" text NOT NULL,
  "create_time" integer,
  "update_time" integer,
  "close_time" integer,
  PRIMARY KEY ("id")
);
CREATE INDEX "tasks_idx_project" on "tasks" ("project");
CREATE INDEX "tasks_idx_user" on "tasks" ("user");

--
-- Table: times
--
DROP TABLE "times" CASCADE;
CREATE TABLE "times" (
  "id" integer NOT NULL,
  "name" text NOT NULL,
  "user" integer NOT NULL,
  "task" integer NOT NULL,
  "description" text NOT NULL,
  "start_datetime" integer,
  "end_datetime" integer,
  "create_time" integer,
  "update_time" integer,
  PRIMARY KEY ("id")
);
CREATE INDEX "times_idx_task" on "times" ("task");
CREATE INDEX "times_idx_user" on "times" ("user");

--
-- Table: user_group
--
DROP TABLE "user_group" CASCADE;
CREATE TABLE "user_group" (
  "user" integer NOT NULL,
  "gid" integer NOT NULL,
  PRIMARY KEY ("user", "gid")
);
CREATE INDEX "user_group_idx_gid" on "user_group" ("gid");
CREATE INDEX "user_group_idx_user" on "user_group" ("user");

--
-- Table: users
--
DROP TABLE "users" CASCADE;
CREATE TABLE "users" (
  "id" integer NOT NULL,
  "username" text NOT NULL,
  "password" text NOT NULL,
  "domain" integer NOT NULL,
  "name" text NOT NULL,
  "superuser" integer DEFAULT '0' NOT NULL,
  "create_time" integer,
  "update_time" integer,
  "close_time" integer,
  PRIMARY KEY ("id")
);
CREATE INDEX "users_idx_domain" on "users" ("domain");

--
-- Foreign Key Definitions
--

ALTER TABLE "clients" ADD FOREIGN KEY ("domain")
  REFERENCES "domains" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "clients" ADD FOREIGN KEY ("user")
  REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "groups" ADD FOREIGN KEY ("domain")
  REFERENCES "domains" ("id") DEFERRABLE;

ALTER TABLE "groups" ADD FOREIGN KEY ("user")
  REFERENCES "users" ("id") DEFERRABLE;

ALTER TABLE "projects" ADD FOREIGN KEY ("client")
  REFERENCES "clients" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "projects" ADD FOREIGN KEY ("user")
  REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "tasks" ADD FOREIGN KEY ("project")
  REFERENCES "projects" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "tasks" ADD FOREIGN KEY ("user")
  REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "times" ADD FOREIGN KEY ("task")
  REFERENCES "tasks" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "times" ADD FOREIGN KEY ("user")
  REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "user_group" ADD FOREIGN KEY ("gid")
  REFERENCES "groups" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "user_group" ADD FOREIGN KEY ("user")
  REFERENCES "users" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;

ALTER TABLE "users" ADD FOREIGN KEY ("domain")
  REFERENCES "domains" ("id") ON DELETE CASCADE ON UPDATE CASCADE DEFERRABLE;
