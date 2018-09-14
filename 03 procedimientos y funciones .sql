
--------------------------------- procedimientos y funciones --------------------------------

--a. Crear un procedimiento almacenado 'torneosGanadosPorTipoYAnio' que reciba como
--parámetros un año y un id de jugador, y devuelva por parámetro: la cantidad de
--torneos de Grand Slam ganados por este jugador en el año, la cantidad de M1000,
--M500 y M250 ganados respectivamente por este jugador en el año pasado como
--parámetro. Si el jugador no hubiera ganado algún tipo de estos torneos, se devolverá 0
--en el parámetro correspondiente.
go
create procedure torneosGanadosPorTipoYAnio
@anio int,
@idJugador int,
@GS int output,
@M1000 int output,
@M500 int output,
@M250 int output
as begin
	select @GS = count(*)
	from TorneoEdicion TE, Torneos T
	where TE.torneoId = T.torneoId
	and anio = @anio
	and jugadorGanador = @idJugador
	and torneoTipo = 'GS'

	select @M1000 = count(*)
	from TorneoEdicion TE, Torneos T
	where TE.torneoId = T.torneoId
	and anio = @anio
	and jugadorGanador = @idJugador
	and torneoTipo = '1000'

	select @M500 = count(*)
	from TorneoEdicion TE, Torneos T
	where TE.torneoId = T.torneoId
	and anio = @anio
	and jugadorGanador = @idJugador
	and torneoTipo = '500'

	select @M250 = count(*)
	from TorneoEdicion TE, Torneos T
	where TE.torneoId = T.torneoId
	and anio = @anio
	and jugadorGanador = @idJugador
	and torneoTipo = '250'
end

declare @GS int declare @M1000 int declare @M500 int declare @M250 int
exec torneosGanadosPorTipoYAnio 2011, 12, 
@GS output, @M1000 output, @M500 output, @M250 output
select @GS GS, @M1000 M1000, @M500 M500, @M250 M250


--b. Crear un procedimiento almacenado 'mejorPosicionJugador', que dado el código de un
--jugador, devuelva por parámetro, la mejor posición en el ranking en la historia de este
--jugador, y la fecha en que obtuvo por primera vez esta posición.
go
create procedure mejorPosicionJugador
@idJugador int,
@mejorPosición int output,
@fecha date output
as begin
	select @mejorPosición = posicion 
	from Ranking
	where jugadorId = @idJugador
	and posicion <= all (
						select posicion
						from Ranking
						where jugadorId = @idJugador )

	select @fecha = min(fecha)
	from Ranking R, FechaRanking FR
	where R.fechaRanking = FR.fechaRankingId
	and jugadorId = @idJugador
	and posicion = @mejorPosición
end

declare @mejorPosición int declare @fecha date
exec mejorPosicionJugador 11, 
@mejorPosición output, @fecha output
select @mejorPosición mejorPosición, @fecha fecha


--c. Implementar una función 'torneosPorJugadorPorAnio', que reciba como parámetros el
--id de un jugador y un año, devolviendo la cantidad de torneos jugados por el jugador
--en el año.
go
create function torneosPorJugadorPorAnio
( @jugadorId int, @anio int )
returns int
as begin
declare @ret int
	select @ret = count(distinct torneoId)
	from Partidos
	where ( jugadorGanador = @jugadorId	or jugadorPerdedor = @jugadorId )
	and anio = @anio
return @ret
end

print dbo.torneosPorJugadorPorAnio(2, 2017)


--d. Implementar un procedimiento almacenado 'resumenJugadorPorAnio', que dados el
--código de un jugador y un año, devuelva por parámetro la cantidad de partidos
--ganados en el año, la cantidad de partidos perdidos en el año, la cantidad de torneos
--en los que alcanzó la final en el año (haya ganado o no), la cantidad de torneos que
--ganó en el año, el importe en premios obtenido por los títulos ganados en el año.
go
create procedure resumenJugadorPorAnio
@idJugador int,
@anio int,
@partGanados int output,
@partPerdidos int output,
@torFinal int output, --(haya ganado o no)
@torGanador int output,
@impPremios int output
as begin
	select @partGanados = count(*)
	from Partidos
	where jugadorGanador = @idJugador
	and anio = @anio

	select @partPerdidos = count(*)
	from Partidos
	where jugadorPerdedor = @idJugador
	and anio = @anio

	select @torFinal = count(*)
	from TorneoEdicion
	where anio = @anio
	and jugadorGanador = @idJugador
	or finalista = @idJugador

	select @torGanador = count(*), @impPremios = sum(premioGanador)
	from TorneoEdicion
	where anio = @anio
	and jugadorGanador = @idJugador
end

declare @partGanados int declare @partPerdidos int declare @torFinal int 
declare @torGanador int declare @impPremios int
exec resumenJugadorPorAnio 12,2017, @partGanados output, @partPerdidos output,
@torFinal output, @torGanador output, @impPremios output
select @partGanados partGanados, @partPerdidos partPerdidos,
@torFinal torFinal, @torGanador torGanador, @impPremios impPremios


--e. Crear un procedimiento almacenado 'enfrentamientosJugadores', que reciba como
--parámetros dos jugadores (sus ids) y devuelva por parámetro: la cantidad total de
--enfrentamientos entre estos jugadores, la cantidad de partidos que el jugador 1 le ganó
--al jugador 2, la cantidad de partidos que el jugador 2 le ganó al jugador 1.
go
create procedure enfrentamientosJugadores
@jugador1 int,
@jugador2 int,
@enfrentamientos int output,
@jugador1gana int output,
@jugador2gana int output
as begin
	select @enfrentamientos = count(*)
	from Partidos
	where (jugadorGanador = @jugador1 and jugadorPerdedor = @jugador2)
	or (jugadorGanador = @jugador2 and jugadorPerdedor = @jugador1)

	select @jugador1gana = count(*)
	from Partidos
	where (jugadorGanador = @jugador1 and jugadorPerdedor = @jugador2)

	select @jugador2gana = count(*)
	from Partidos
	where (jugadorGanador = @jugador2 and jugadorPerdedor = @jugador1)
end

declare @enfrentamientos int declare @jugador1gana int declare @jugador2gana int
exec enfrentamientosJugadores 4, 13, @enfrentamientos output,
@jugador1gana output, @jugador2gana output
select @enfrentamientos enfrentamientos, @jugador1gana jugador1gana, 
@jugador2gana jugador2gana


--f. Implementar un procedimiento almacenado 'masGanadoresPorSuperficiePorAnio', que
--reciba como parámetro un año, y devuelva también por parámetro, el id del jugador
--que ganó más partidos en cemento en el año, el id del jugador que ganó más partidos
--en arcilla en el año y el id del jugador que ganó más partidos en pasto en el año.
go
create procedure masGanadoresPorSuperficiePorAnio
@anio int,
@jugadorCemento int output,
@jugadorArcilla int output,
@jugadorPasto int output
as begin
	select @jugadorCemento = jugadorGanador
	from Partidos P, Torneos T
	where P.torneoId = T.torneoId
	and anio = @anio and T.torneoSuperficie = 'C'
	group by jugadorGanador
	having count(*) >= all (
						select count(*)
						from Partidos P, Torneos T
						where P.torneoId = T.torneoId
						and anio = @anio and T.torneoSuperficie = 'C'
						group by jugadorGanador )

	select @jugadorArcilla = jugadorGanador
	from Partidos P, Torneos T
	where P.torneoId = T.torneoId
	and anio = @anio and T.torneoSuperficie = 'A'
	group by jugadorGanador
	having count(*) >= all (
						select count(*)
						from Partidos P, Torneos T
						where P.torneoId = T.torneoId
						and anio = @anio and T.torneoSuperficie = 'A'
						group by jugadorGanador )

	select @jugadorPasto = jugadorGanador
	from Partidos P, Torneos T
	where P.torneoId = T.torneoId
	and anio = @anio and T.torneoSuperficie = 'P'
	group by jugadorGanador
	having count(*) >= all (
						select count(*)
						from Partidos P, Torneos T
						where P.torneoId = T.torneoId
						and anio = @anio and T.torneoSuperficie = 'P'
						group by jugadorGanador )
end

declare @anio int declare @jugadorCemento int declare @jugadorArcilla int declare @jugadorPasto int
exec masGanadoresPorSuperficiePorAnio 2017, @jugadorCemento output,
@jugadorArcilla output, @jugadorPasto output
select @jugadorCemento cemento, @jugadorArcilla arcilla, @jugadorPasto pasto


--g. Crear una función 'jugadoresPorPais' que reciba como parámetro un id de país y
--devuelva la cantidad de jugadores de dicho país que disputaron algún torneo este año.

go
create function jugadoresPorPais ( @paisId int )
returns int
as begin
declare @ret int
	select @ret = count(*)
	from Jugadores
	where paisNacimiento = @paisId
	and ( jugadorId in ( select jugadorGanador from Partidos where anio = year(getdate()) )
		or jugadorId in ( select jugadorPerdedor from Partidos where anio = year(getdate()) ) )
	group by paisNacimiento
return @ret
end

print dbo.jugadoresPorPais(3) -- hay 4 del mismo país pero uno no jugó
print dbo.jugadoresPorPais(241) -- hay uno solo



















--