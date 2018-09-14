
--------------------------------- procedimientos y funciones --------------------------------

--a. Crear un procedimiento almacenado 'torneosGanadosPorTipoYAnio' que reciba como
--par�metros un a�o y un id de jugador, y devuelva por par�metro: la cantidad de
--torneos de Grand Slam ganados por este jugador en el a�o, la cantidad de M1000,
--M500 y M250 ganados respectivamente por este jugador en el a�o pasado como
--par�metro. Si el jugador no hubiera ganado alg�n tipo de estos torneos, se devolver� 0
--en el par�metro correspondiente.
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


--b. Crear un procedimiento almacenado 'mejorPosicionJugador', que dado el c�digo de un
--jugador, devuelva por par�metro, la mejor posici�n en el ranking en la historia de este
--jugador, y la fecha en que obtuvo por primera vez esta posici�n.
go
create procedure mejorPosicionJugador
@idJugador int,
@mejorPosici�n int output,
@fecha date output
as begin
	select @mejorPosici�n = posicion 
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
	and posicion = @mejorPosici�n
end

declare @mejorPosici�n int declare @fecha date
exec mejorPosicionJugador 11, 
@mejorPosici�n output, @fecha output
select @mejorPosici�n mejorPosici�n, @fecha fecha


--c. Implementar una funci�n 'torneosPorJugadorPorAnio', que reciba como par�metros el
--id de un jugador y un a�o, devolviendo la cantidad de torneos jugados por el jugador
--en el a�o.
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
--c�digo de un jugador y un a�o, devuelva por par�metro la cantidad de partidos
--ganados en el a�o, la cantidad de partidos perdidos en el a�o, la cantidad de torneos
--en los que alcanz� la final en el a�o (haya ganado o no), la cantidad de torneos que
--gan� en el a�o, el importe en premios obtenido por los t�tulos ganados en el a�o.
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
--par�metros dos jugadores (sus ids) y devuelva por par�metro: la cantidad total de
--enfrentamientos entre estos jugadores, la cantidad de partidos que el jugador 1 le gan�
--al jugador 2, la cantidad de partidos que el jugador 2 le gan� al jugador 1.
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
--reciba como par�metro un a�o, y devuelva tambi�n por par�metro, el id del jugador
--que gan� m�s partidos en cemento en el a�o, el id del jugador que gan� m�s partidos
--en arcilla en el a�o y el id del jugador que gan� m�s partidos en pasto en el a�o.
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


--g. Crear una funci�n 'jugadoresPorPais' que reciba como par�metro un id de pa�s y
--devuelva la cantidad de jugadores de dicho pa�s que disputaron alg�n torneo este a�o.

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

print dbo.jugadoresPorPais(3) -- hay 4 del mismo pa�s pero uno no jug�
print dbo.jugadoresPorPais(241) -- hay uno solo



















--