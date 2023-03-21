-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Tue Jul  7 13:18:24 2009
-- 
SET foreign_key_checks=0;

DROP TABLE IF EXISTS `clients`;

--
-- Table: `clients`
--
CREATE TABLE `clients` (
  `id` INTEGER NOT NULL,
  `user` INTEGER NOT NULL,
  `name` text NOT NULL,
  `domain` INTEGER NOT NULL,
  `create_time` INTEGER,
  `update_time` INTEGER,
  `close_time` INTEGER,
  INDEX clients_idx_domain (`domain`),
  INDEX clients_idx_user (`user`),
  PRIMARY KEY (`id`),
  CONSTRAINT `clients_fk_domain` FOREIGN KEY (`domain`) REFERENCES `domains` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `clients_fk_user` FOREIGN KEY (`user`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `domains`;

--
-- Table: `domains`
--
CREATE TABLE `domains` (
  `id` INTEGER NOT NULL,
  `name` text NOT NULL,
  `create_time` INTEGER,
  `update_time` INTEGER,
  `close_time` INTEGER,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `groups`;

--
-- Table: `groups`
--
CREATE TABLE `groups` (
  `id` INTEGER NOT NULL,
  `user` INTEGER NOT NULL,
  `name` text NOT NULL,
  `domain` INTEGER NOT NULL,
  `create_time` INTEGER,
  `update_time` INTEGER,
  `close_time` INTEGER,
  INDEX groups_idx_domain (`domain`),
  INDEX groups_idx_user (`user`),
  PRIMARY KEY (`id`),
  CONSTRAINT `groups_fk_domain` FOREIGN KEY (`domain`) REFERENCES `domains` (`id`),
  CONSTRAINT `groups_fk_user` FOREIGN KEY (`user`) REFERENCES `users` (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `projects`;

--
-- Table: `projects`
--
CREATE TABLE `projects` (
  `id` INTEGER NOT NULL,
  `user` INTEGER NOT NULL,
  `name` text NOT NULL,
  `client` INTEGER NOT NULL,
  `description` text NOT NULL,
  `create_time` INTEGER,
  `update_time` INTEGER,
  `close_time` INTEGER,
  INDEX projects_idx_client (`client`),
  INDEX projects_idx_user (`user`),
  PRIMARY KEY (`id`),
  CONSTRAINT `projects_fk_client` FOREIGN KEY (`client`) REFERENCES `clients` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `projects_fk_user` FOREIGN KEY (`user`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `rights`;

--
-- Table: `rights`
--
CREATE TABLE `rights` (
  `id` INTEGER NOT NULL,
  `owner_type` text NOT NULL,
  `owner_id` INTEGER NOT NULL,
  `app_name` text NOT NULL,
  `app_id` INTEGER NOT NULL,
  `right` text NOT NULL,
  `delegated_by` INTEGER NOT NULL,
  `create_time` INTEGER,
  `update_time` INTEGER,
  `close_time` INTEGER,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `tasks`;

--
-- Table: `tasks`
--
CREATE TABLE `tasks` (
  `id` INTEGER NOT NULL,
  `user` INTEGER NOT NULL,
  `name` text NOT NULL,
  `project` INTEGER NOT NULL,
  `description` text NOT NULL,
  `create_time` INTEGER,
  `update_time` INTEGER,
  `close_time` INTEGER,
  INDEX tasks_idx_project (`project`),
  INDEX tasks_idx_user (`user`),
  PRIMARY KEY (`id`),
  CONSTRAINT `tasks_fk_project` FOREIGN KEY (`project`) REFERENCES `projects` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `tasks_fk_user` FOREIGN KEY (`user`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `times`;

--
-- Table: `times`
--
CREATE TABLE `times` (
  `id` INTEGER NOT NULL,
  `name` text NOT NULL,
  `user` INTEGER NOT NULL,
  `task` INTEGER NOT NULL,
  `description` text NOT NULL,
  `start_datetime` INTEGER,
  `end_datetime` INTEGER,
  `create_time` INTEGER,
  `update_time` INTEGER,
  INDEX times_idx_task (`task`),
  INDEX times_idx_user (`user`),
  PRIMARY KEY (`id`),
  CONSTRAINT `times_fk_task` FOREIGN KEY (`task`) REFERENCES `tasks` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `times_fk_user` FOREIGN KEY (`user`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `user_group`;

--
-- Table: `user_group`
--
CREATE TABLE `user_group` (
  `user` INTEGER NOT NULL,
  `gid` INTEGER NOT NULL,
  INDEX user_group_idx_gid (`gid`),
  INDEX user_group_idx_user (`user`),
  PRIMARY KEY (`user`, `gid`),
  CONSTRAINT `user_group_fk_gid` FOREIGN KEY (`gid`) REFERENCES `groups` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `user_group_fk_user` FOREIGN KEY (`user`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP TABLE IF EXISTS `users`;

--
-- Table: `users`
--
CREATE TABLE `users` (
  `id` INTEGER NOT NULL,
  `username` text NOT NULL,
  `password` text NOT NULL,
  `domain` INTEGER NOT NULL,
  `name` text NOT NULL,
  `superuser` INTEGER NOT NULL DEFAULT '0',
  `create_time` INTEGER,
  `update_time` INTEGER,
  `close_time` INTEGER,
  INDEX users_idx_domain (`domain`),
  PRIMARY KEY (`id`),
  CONSTRAINT `users_fk_domain` FOREIGN KEY (`domain`) REFERENCES `domains` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

SET foreign_key_checks=1;

