#!/usr/bin/perl
use strict;
use warnings;
use utf8;
use POSIX 'ceil';
use XML::Parser;
use Data::Dumper;

binmode STDOUT, ':encoding(UTF-8)';

my (%schema, %references, %context);
&parse(shift or die "Por favor, especifica el archivo a procesar\n");
undef %context;
my (%tables, %relations);
&classify;
undef %references;
&sql;
undef %tables;
undef %relations;

exit 0;

sub sql {
   for my $table (keys %tables) {
      print "drop table if exists $table;\n\n";
      print "create table $table (\n";
      my @columns = @{$tables{$table}};
      my $index = 0;
      for my $column (@columns) {
         my $name = $column->{name};
         print "   $name $column->{type}";
         if ($column->{primary} eq 'true') {
            print " primary key" if $column->{primary} eq 'true';
         } else {
            print " not null" if $column->{null} eq 'false';
            print " unique" if $column->{unique} eq 'true';
            my $reference = $relations{$table}{$name};
            print " references $reference->{table} ($reference->{column})" if $reference;
         }
         print ',' if ++$index < scalar @columns; 
         print "\n";
      }
      print ');';
      print "\n\n"; # unless last;
   }
}

sub classify {
   my %boxes;

   for my $id (keys %schema) {
      my %node = %{$schema{$id}};
      my $table = $node{name};
      $tables{$table} = $node{columns};
      $boxes{$table} = $node{box};
   }
   
   undef %schema;
   
   for my $id (keys %references) {
      my %node = %{$references{$id}};
      my @points = @{$node{points}};
      my $start = $points[0];
      my $end = $points[-1];
      my $from = $node{1};
      my $to = $node{0};
      my ($source, $target);
   
      $source = $tables{$from}[$_ - 1]{name} if $_ = &inner($start, $boxes{$from}, scalar @{$tables{$from}});
      $source = $tables{$from}[$_ - 1]{name} if $_ = &inner($end, $boxes{$from}, scalar @{$tables{$from}});
      $target = $tables{$to}[$_ - 1]{name} if $_ = &inner($start, $boxes{$to}, scalar @{$tables{$to}});
      $target = $tables{$to}[$_ - 1]{name} if $_ = &inner($end, $boxes{$to}, scalar @{$tables{$to}});
   
      $relations{$from}{$source}{table} = $to;
      $relations{$from}{$source}{column} = $target;
   }
   
   undef %boxes;
   
   sub inner {
      my (%point, %box, $start, $end, $count);
      ($point{x}, $point{y}) = split /,/, shift;
      ($start, $end) = split /;/, shift;
      ($box{start}{x}, $box{start}{y}) = split /,/, $start;
      ($box{end}{x}, $box{end}{y}) = split /,/, $end;
      $count = shift;
   
      return 0 if $point{y} eq $box{start}{y} or $point{y} eq $box{end}{y};

      if ($point{x} eq $box{start}{x} or $point{x} eq $box{end}{x}) {
         my $height = ($box{end}{y} - $box{start}{y}) / ($count + 1);
         $_ = ceil(($point{y} - ($box{start}{y} + $height)) / $height);
         return ceil(($point{y} - ($box{start}{y} + $height)) / $height);
      }
   
      return 0;
   }
}

sub start {
   my ($parser, $element, %attributes) = @_;
   if ($element eq 'dia:object') {
      my $type = $attributes{type};
      my $id = $attributes{id};
      if ($type eq 'Database - Table') {
         $context{object} = 'table';
      } elsif ($type eq 'Database - Reference') {
         $context{object} = 'reference';
      }
      $context{id} = $id;
   } elsif ($element eq 'dia:attribute') {
      if ($attributes{name} eq 'name') {
         $context{attribute} = 'name';
      } elsif ($attributes{name} eq 'attributes') {
         $context{object} = 'column';
      } elsif ($attributes{name} eq 'comment') {
         $context{attribute} = 'comment';
      } elsif ($attributes{name} eq 'type') {
         $context{attribute} = 'type';
      } elsif ($attributes{name} eq 'primary_key') {
         $context{attribute} = 'primary-key';
      } elsif ($attributes{name} eq 'nullable') {
         $context{attribute} = 'null';
      } elsif ($attributes{name} eq 'unique') {
         $context{attribute} = 'unique';
      } elsif ($attributes{name} eq 'obj_bb') {
         $context{attribute} = 'bounding-box';
      } elsif ($attributes{name} eq 'orth_points') {
         $context{attribute} = 'points';
      } else {
         undef $context{attribute};
      }
   } elsif ($element eq 'dia:connection') {
      $context{attribute} = 'connection';
      &content($parser, "$attributes{handle}:$schema{$attributes{to}}{name}");
   } elsif ($element eq 'dia:rectangle' or $element eq 'dia:point' or $element eq 'dia:boolean') {
      &content($parser, $attributes{val});
   }
}

sub content {
   my ($parser, $string) = @_;
   return unless $string !~ /^\s+$/ and $context{object};
   my $id = $context{id};
   $string =~ s/#//g;
   if ($context{object} eq 'column') {
      if ($context{attribute}) {
         if ($context{attribute} eq 'name') {
            $context{column} = $string;
            push @{$schema{$id}{columns}}, { name => $string };
         } elsif ($context{attribute} eq 'type') {
            $schema{$id}{columns}[-1]{type} = $string;
         } elsif ($context{attribute} eq 'primary-key') {
            $schema{$id}{columns}[-1]{primary} = $string;
         } elsif ($context{attribute} eq 'null') {
            $schema{$id}{columns}[-1]{null} = $string;
         } elsif ($context{attribute} eq 'unique') {
            $schema{$id}{columns}[-1]{unique} = $string;
         } elsif ($context{attribute} eq 'comment') {
            $schema{$id}{columns}[-1]{comment} = $string;
         }
      }
   } elsif ($context{object} eq 'table') {
      if ($context{attribute}) {
         if ($context{attribute} eq 'name') {
            $context{table} = $string;
            $schema{$id}{name} = $string;
            $schema{$id}{columns} = [];
         } elsif ($context{attribute} eq 'bounding-box') {
            $schema{$id}{box} = $string;
         } elsif ($context{attribute} eq 'comment') {
            $schema{$id}{comment} = $string;
         }
      }
   } elsif ($context{object} eq 'reference') {
      if ($context{attribute}) {
         if ($context{attribute} eq 'points') {
            $references{$id}{points} = [] unless $references{$id}{points};
            push @{$references{$id}{points}}, $string;
         } elsif ($context{attribute} eq 'connection') {
            my ($type, $table) = split /:/, $string;
            $references{$id}{$type} = $table;
         }
      }
   }
}

sub parse {
   my $file = shift;

   if (not -f $file) {
      die "No existe el archivo $file\n";
   }

   my $parser = new XML::Parser(Handlers => {
      Start => \&start,
      Char  => \&content
   });

   open INPUT, "gzip -dc $file |";
   $parser->parse(*INPUT, ProtocolEncoding => 'UTF-8');
   close INPUT;
}
