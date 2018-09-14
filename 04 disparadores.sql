
--------------------------------------- disparadores ----------------------------------------

--a. Cada vez que se ingrese un partido, se actualicen los partidos ganados y perdidos
--según corresponda en los datos del jugador.
go
create trigger PartidosJugadores
on Partidos
after insert
as begin
	update Jugadores
	set partidosGanados = partidosGanados + ( 
										select count(*) 
										from inserted I 
										where I.jugadorGanador = J.jugadorId )
	from Jugadores J, inserted I
	where J.jugadorId = I.jugadorGanador

	update Jugadores
	set partidosPerdidos = partidosPerdidos + ( 
										select count(*) 
										from inserted I 
										where I.jugadorPerdedor = J.jugadorId )
	from Jugadores J, inserted I
	where J.jugadorId = I.jugadorPerdedor
end

select jugadorId, partidosGanados, partidosPerdidos from Jugadores
where jugadorId = 1 or jugadorId = 2 or jugadorId = 3
insert into Partidos values
(1, 2, 3, 2018, 'R16', '3 3 6 6'),
(1, 2, 3, 2018, 'R32', '3 3 6 6'),
(2, 3, 3, 2018, 'R16', '3 3 6 6')
select jugadorId, partidosGanados, partidosPerdidos from Jugadores
where jugadorId = 1 or jugadorId = 2 or jugadorId = 3


--b. Cuando se ingrese el ganador de un torneo, se sume a los premios del jugador el
--premio obtenido en el torneo.
go
create trigger GanadorTorneo
on TorneoEdicion
after insert, update
as begin
	update Jugadores
	set premiosGanados = premiosGanados + ( select sum(premioGanador) 
											from inserted 
											where J.jugadorId = jugadorGanador )
	from Jugadores J, inserted I
	where J.jugadorId = I.jugadorGanador
end

select jugadorId, nombre, premiosGanados 
from Jugadores where jugadorId = 2 or jugadorId = 3
insert into TorneoEdicion values 
(7, 2015, 2, 11, 10000, 20000, '20150201', '20150420'),
(7, 2014, 2, 18, 20000, 30000, '20140201', '20140420'),
(7, 2013, 3, 15, 20000, 30000, '20130201', '20130420')
select jugadorId, nombre, premiosGanados 
from Jugadores where jugadorId = 2 or jugadorId = 3


--c. Cuando se cree un nuevo ranking, se debe generar un log en el que se deberá
--registrar para cada jugador del top ten: si mantiene la posición, si modifica la posición,
--o si deja de estar en el top 10. Implementar la estructura necesaria para poder soportar
--este disparador.

create table LogRanking (
jugadorId int,
pos varchar(9) check (pos in ('mantiene', 'modifica', 'dejaTop10')),
fecha date
)
go
create trigger RankingLog
on Ranking
after insert
as begin
	insert LogRanking
	select jugadorId, 'mantiene', (select fecha from FechaRanking 
									where fechaRankingId = fechaRanking )
	from inserted I
	where exists ( select * from Ranking R
					where fechaRanking = ( select max(fechaRankingId) -1
											from FechaRanking )
					and R.jugadorId = I.jugadorId
					and R.posicion = I.posicion )

	insert LogRanking
	select jugadorId, 'modifica', (select fecha from FechaRanking 
									where fechaRankingId = fechaRanking )
	from inserted I
	where exists ( select * from Ranking R
					where fechaRanking = ( select max(fechaRankingId) -1
											from FechaRanking )
					and R.jugadorId = I.jugadorId
					and R.posicion <> I.posicion 
					and not (R.posicion <= 10 and I.posicion > 10 ))

	insert LogRanking
	select jugadorId, 'dejaTop10', (select fecha from FechaRanking 
									where fechaRankingId = fechaRanking )
	from inserted I
	where exists ( select * from Ranking R
					where fechaRanking = ( select max(fechaRankingId) -1
											from FechaRanking )
					and R.jugadorId = I.jugadorId
					and R.posicion <= 10
					and I.posicion > 10 )
end

insert into FechaRanking values ('20180611')
insert into Ranking values (11, 8, 12, 775), --jugador 8 pasa de 10 a 12 - dejaTop10
(11, 2, 4, 429), --jugador 2 mantiene la pos 4 - mantiene
(11, 11, 6, 233) --jugador 11 pasa de 8 a 6 - modifica
select * from LogRanking


--d. No permitir ingresar una nueva edición de torneo, si el total de premios estipulado para
--esta edición es menor al total de premios de la edición anterior del torneo.
go
create trigger TorneoPremios
on TorneoEdicion
instead of insert
as begin
	insert TorneoEdicion
	select torneoId, anio, jugadorGanador, finalista, premioGanador,
		premiosTotales,	fechaComienzo, fechaFin
	from inserted I
	where I.premiosTotales >= (
							select premiosTotales
							from TorneoEdicion TE
							where TE.torneoId = I.torneoId
							and TE.anio = (
										select max(anio)
										from TorneoEdicion TEA
										where TEA.torneoId = TE.torneoId ) )
end

insert into TorneoEdicion values
(1, 2019, null, null, 9000, 19000, '20190201', '20190420'),
(2, 2019, null, null, 1000, 20000, '20190201', '20190420')
select * from TorneoEdicion where anio = 2019


--e. Controlar que no se ingrese más de un ranking por semana (controlar el ingreso y
--modificación de la fecha en FechaRanking).
go
create trigger ControlSemana
on FechaRanking
instead of insert, update
as begin
	if exists ( select * from deleted )
	begin
		update FechaRanking set fecha = I.fecha
		from inserted I
		where not exists ( select FR.fecha
							from FechaRanking FR
							where FR.fecha > dateadd(day, -7, I.fecha) )
	end
	else
	begin
		insert FechaRanking	select fecha
		from inserted I
		where not exists ( select FR.fecha
							from FechaRanking FR
							where FR.fecha > dateadd(day, -7, I.fecha) )
	end
end

alter table FechaRanking drop es_lunes -- borro eso para que no revise si es lunes
insert into FechaRanking values ('20180618')
insert into FechaRanking values('20180625')
insert into FechaRanking values('20180627') -- este no lo agrega
update FechaRanking set fecha = '20180623' where fecha = '20180625' -- no deja hacerlo
select * from FechaRanking


--f. Crear un trigger que registre en un log el historial de entrenadores de un jugador.
--(Cada vez que un jugador cambia de entrenador se debe guardar el registro del
--entrenador anterior y la fecha en que se registra el cambio). Implementar la estructura
--necesaria para soportar este trigger.
go
create table LogEntrenadores(
jugadorId int,
entrenadorAnterior varchar(30),
fechaCambio date
)
go
create trigger EntrenadoresLog
on Jugadores
after update
as begin
	if update(entrenador)
	begin
		insert into LogEntrenadores (jugadorId, entrenadorAnterior, fechaCambio)
		select jugadorId, entrenador, getdate()
		from deleted
	end
end

update Jugadores set entrenador = 'Otro entrenador' where jugadorId = 2
select * from Jugadores where jugadorId = 2
select * from LogEntrenadores


--g. Implementar un disparador que al eliminar un torneo elimine todo lo relacionado al
--mismo (edición, partidos).
go
create trigger EliminarTorneoTotalmente
on Torneos
instead of delete
as begin
	delete Partidos
	from Partidos P, deleted D
	where P.torneoId = D.torneoId

	delete TorneoEdicion
	from TorneoEdicion TE, deleted D
	where TE.torneoId = D.torneoId

	delete Torneos
	from Torneos T, deleted D
	where T.torneoId = D.torneoId
end

delete from Torneos where torneoId = 1
select * from Torneos where torneoId = 1
select * from TorneoEdicion where torneoId = 1
select * from Partidos where torneoId = 1

