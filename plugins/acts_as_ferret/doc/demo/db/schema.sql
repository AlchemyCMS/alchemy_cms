drop table if exists contents;
create table contents (
  id int not null auto_increment,
  type varchar(255) not null,
  title varchar(100) not null,
  description text not null,
  special varchar(255) not null,
  primary key (id)
) TYPE=InnoDB DEFAULT CHARSET=utf8;

drop table if exists comments;
create table comments (
  id int not null auto_increment,
  author varchar(100) not null,
  content text not null,
  content_id int,
  primary key (id)
) TYPE=InnoDB DEFAULT CHARSET=utf8;
