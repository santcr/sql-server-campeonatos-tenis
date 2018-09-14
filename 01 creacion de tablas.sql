use master
create database ObligBD2
go
use ObligBD2

CREATE TABLE Paises(
	paisId int identity,
	paisNombre varchar(30),
	paisCodigo char(3)
)
CREATE TABLE Jugadores(
	jugadorId int identity,
	nombre varchar(50),
	fechaNacimiento date,
	paisNacimiento int,
	paisResidencia int,
	estatura int,
	peso int,
	juego char(1),
	entrenador varchar(30),
	profesionalDesde int,
	partidosGanados int,
	partidosPerdidos int,
	titulosGanados int,
	premiosGanados int
)
CREATE TABLE Torneos(
	torneoId int identity,
	torneoNombre varchar(30),
	torneoTipo char(4),
	torneoSuperficie char(1),
	torneoPrimeraEdicion int,
	torneoPais int
)
CREATE TABLE TorneoEdicion(
	torneoId int,
	anio int,
	jugadorGanador int,
	finalista int,
	premioGanador int,
	premiosTotales int,
	fechaComienzo date,
	fechaFin date
)
CREATE TABLE Partidos(
	jugadorGanador int,
	jugadorPerdedor int,
	torneoId int,
	anio int,
	torneoInstancia char(4),
	marcador varchar(30),
)
CREATE TABLE FechaRanking(
	fechaRankingId int identity,
	fecha date
)
CREATE TABLE Ranking(
	fechaRanking int,
	jugadorId int,
	posicion int,
	puntos int,
)