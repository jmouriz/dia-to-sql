# dia-to-sql

dia-to-sql es un pequeño código escrito en Perl que convierte un diagrama de dabe de datos (ER) de DIA a SQL. Está basado en el módulo de Perl [Parse::DIA::SQL](http://annocpan.org/dist/Parse-Dia-SQL) pero no lo usa. A diferencia de éste, dia-to-sql agrega la característica de reconocer las líneas de relaciones entre tablas calculando por aproximaxión a qué columnas se refieren. No encontré hasta hoy alguna herramienta que lo haga ya que las relaciones de los diagramas de base de datos de día no incluyen datos acerca de qué columnas relacionan sino que conectan las tablas por puntos de conexión preestablecidos en el borde la de caja que contiene la tabla. dia-to-sql intenta calcular por aproximación a qué columna relaciona según qué punto de unión se use.

dia-to-sql intenta convertir esto:

![screenshot](https://jmouriz.github.io/resources/images/screenshots/dia-to-sql-1.png) 

en esto:

![screenshot](https://jmouriz.github.io/resources/images/screenshots/dia-to-sql-1.png) 

Espero te sea de utilidad
