# dia-to-sql

dia-to-sql es un pequeño código escrito en Perl que convierte un diagrama de dabe de datos (ER) de DIA a SQL. Está basado en el módulo de Perl [Parse::DIA::SQL](http://annocpan.org/dist/Parse-Dia-SQL) pero no lo usa. A diferencia de éste, dia-to-sql agrega la característica de reconocer las líneas de relación entre tablas calculando por aproximaxión a que columnas se refieren. No encontré hasta hoy alguna herramienta que lo haga ya que las relaciones de los diagramas de base de datos de DIA no incluyen datos acerca de las columnas que relacionan sino que conectan las tablas por puntos de conexión preestablecidos en el borde la de caja que contiene la tabla. dia-to-sql intenta calcular geométricamente por aproximación a que columna se refiere la relación según el punto de unión al que se conecta.

dia-to-sql intenta convertir esto:

![screenshot](https://jmouriz.github.io/resources/images/screenshots/dia-to-sql-1.png) 

en esto:

![screenshot](https://jmouriz.github.io/resources/images/screenshots/dia-to-sql-2.png) 

Bienvenidos a probarlo, espero les sea de utilidad
