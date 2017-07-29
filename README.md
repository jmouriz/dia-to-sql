# dia-to-sql

dia-to-sql es un pequeño código escrito en Perl que convierte un diagrama de base de datos (ER) de [Dia](https://live.gnome.org/Dia) a SQL. Está basado en el módulo de Perl [Parse::DIA::SQL](http://annocpan.org/dist/Parse-Dia-SQL) pero no lo usa. A diferencia de éste, **dia-to-sql agrega la característica de reconocer relaciones entre tablas** calculando por aproximaxión a que columnas se refieren las líneas que las conectan. No encontré hasta hoy alguna herramienta que lo haga ya que las relaciones de los diagramas de base de datos de Dia no incluyen datos acerca de las columnas que relacionan sino que conectan las tablas por puntos de conexión preestablecidos en el borde la de caja que contiene la tabla. dia-to-sql intenta calcular geométricamente por aproximación a que columna se refiere la relación según el punto de unión al que se conecta.

dia-to-sql convierte esto:

![screenshot](https://jmouriz.github.io/resources/images/screenshots/dia-to-sql-1.png) 

en esto:

```sql
drop table if exists roles;

create table roles (
   id integer primary key,
   role varchar
);

drop table if exists providers;

create table providers (
   id integer primary key,
   provider varchar not null unique
);

drop table if exists history;

create table history (
   id integer primary key,
   date timestamp not null,
   description varchar not null
);

drop table if exists cities;

create table cities (
   id integer primary key,
   city varchar not null unique
);

drop table if exists users_roles;

create table users_roles (
   id integer primary key,
   user integer not null references users (id),
   role integer not null references roles (id)
);

drop table if exists promotions;

create table promotions (
   id integer primary key,
   city integer references cities (id)
);

drop table if exists users;

create table users (
   id integer primary key,
   email varchar not null unique,
   firstname varchar,
   lastname varchar,
   type varchar,
   document varchar,
   phone varchar,
   address varchar,
   city integer references cities (id),
   state varchar,
   zip varchar,
   country varchar,
   latitude numeric,
   longitude numeric,
   password varchar,
   alternative varchar,
   signature varchar,
   token varchar,
   code varchar,
   balance numeric,
   date timestamp,
   provider varchar references providers (id)
);

drop table if exists tickets;

create table tickets (
   id integer primary key,
   date timestamp not null,
   amount numeric not null,
   channel varchar,
   vehicle integer references vehicles (id)
);

drop table if exists vehicles;

create table vehicles (
   id integer primary key,
   user integer not null references users (id),
   domain varchar not null unique,
   parked timestamp
);

drop table if exists infringements;

create table infringements (
   id integer primary key,
   vehicle integer not null references vehicles (id),
   street varchar,
   number integer,
   paid boolean
);

drop table if exists advertising;

create table advertising (
   id integer primary key,
   title varchar not null,
   subtitle varchar,
   image varchar,
   content varchar,
   link varchar
);

drop table if exists help;

create table help (
   id integer primary key,
   reference varchar not null unique,
   topic varchar not null,
   summary varchar not null,
   content text
);
```

Escribiendo código por tí. Bienvenido a probarlo y espero te sea de utilidad
