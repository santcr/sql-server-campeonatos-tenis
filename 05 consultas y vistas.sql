
------------------------------------- consultas y vistas ------------------------------------

--a. Mostrar los jugadores que han jugado todos los torneos de Grand Slam de este año.

select J.jugadorId
from Jugadores J, Partidos P, Torneos T
where ( J.jugadorId = P.jugadorGanador or J.jugadorId = P.jugadorPerdedor )
and P.torneoId = T.torneoId
and T.torneoTipo = 'GS'
and P.anio = year(getdate())
group by J.jugadorId
having count(distinct P.torneoId) = (
									select count(*)
									from Torneos T, TorneoEdicion TE
									where T.torneoId = TE.torneoId
									and torneoTipo = 'GS'
									and TE.anio = year(getdate()) )


--b. Mostrar los jugadores que no han jugado torneos de Grand Slam este año, pero que
--han ganado algún torneo de este tipo en la última década.

select *
from Jugadores J
where J.jugadorId in ( 
				select TE.jugadorGanador
				from TorneoEdicion TE, Torneos T
				where  TE.torneoId = T.torneoId
				and TE.anio >= year(getdate()) - 10
				and T.torneoTipo = 'GS' )
and J.jugadorId not in ( 
					select P.jugadorGanador
					from Partidos P, TorneoEdicion TE, Torneos T
					where P.torneoId = TE.torneoId
					and P.anio = TE. anio
					and TE.torneoId = T.torneoId
					and TE.anio = year(getdate())
					and T.torneoTipo = 'GS' )
and J.jugadorId not in ( 
					select P.jugadorPerdedor
					from Partidos P, TorneoEdicion TE, Torneos T
					where P.torneoId = TE.torneoId
					and P.anio = TE. anio
					and TE.torneoId = T.torneoId
					and TE.anio = year(getdate())
					and T.torneoTipo = 'GS' )


--c. Realizar una consulta que muestre el nombre de cada jugador, conjuntamente con el
--nombre del jugador que le ganó más veces y el nombre del jugador al que le ganó más
--veces.

select
J.nombre as jugador, 
( select top(1) J2.nombre 
	from Jugadores J2, Partidos P2 
	where J2.jugadorId = P2.jugadorGanador
	and P2.jugadorPerdedor = J.jugadorId
	group by J2.nombre
	order by count(*) desc ) as [perdió mucho contra],
( select top(1) J3.nombre 
	from Jugadores J3, Partidos P3 
	where J3.jugadorId = P3.jugadorPerdedor
	and P3.jugadorGanador = J.jugadorId
	group by J3.nombre
	order by count(*) desc ) as [le ganó mucho a]
from Jugadores J


--d. Devolver el id de los jugadores conjuntamente con la cantidad de torneos ganados,
--para los jugadores que ganaron más de 5 Grand Slams, más de 10 M1000, más de 5
--M500 pero que nunca ganaron una Master Cup.

select jugadorGanador jugadorId, count(*) cantTorneosGanados
from TorneoEdicion TE
where 5 < ( 
		select count(*) 
		from TorneoEdicion TEGS, Torneos TGS
		where TEGS.torneoId = TGS.torneoId
		and TEGS.jugadorGanador = TE.jugadorGanador
		and TGS.torneoTipo = 'GS' )
and 10 < (
		select count(*) 
		from TorneoEdicion TEGS, Torneos TGS
		where TEGS.torneoId = TGS.torneoId
		and TEGS.jugadorGanador = TE.jugadorGanador
		and TGS.torneoTipo = '1000' )
and 5 < (
		select count(*) 
		from TorneoEdicion TEGS, Torneos TGS
		where TEGS.torneoId = TGS.torneoId
		and TEGS.jugadorGanador = TE.jugadorGanador
		and TGS.torneoTipo = '500' )
and jugadorGanador not in (
		select jugadorGanador
		from TorneoEdicion TEGS, Torneos TGS
		where TEGS.torneoId = TGS.torneoId
		and TGS.torneoTipo = 'MC' )
group by jugadorGanador


--e. Devolver el nombre del jugador que ganó más Grand Slams. Considerar solamente los
--jugadores que hayan participado en algún torneo este año.

select nombre
from Jugadores J, TorneoEdicion TE, Torneos T
where jugadorId in ( 
				select jugadorGanador 
				from Partidos
				where anio = year(getdate()) )
and TE.torneoId = T.torneoId
and J.jugadorId = TE.jugadorGanador
and T.torneoTipo = 'GS'

or jugadorId in (
				select jugadorPerdedor 
				from Partidos
				where anio = year(getdate()) )
and TE.torneoId = T.torneoId
and J.jugadorId = TE.jugadorGanador
and T.torneoTipo = 'GS'

group by nombre
having count(*) >= all (
					select count(*)
					from TorneoEdicion TE, Torneos T
					where TE.torneoId = T.torneoId
					and T.torneoTipo = 'GS'
					group by jugadorGanador )


--f. Devolver el nombre de los jugadores que hayan ganado torneos en todas las
--superficies.

select nombre
from Jugadores J, TorneoEdicion TE, Torneos T
where TE.torneoId = T.torneoId
and J.jugadorId = TE.jugadorGanador
group by nombre
having count(distinct torneoSuperficie) = (	
										select count(distinct torneoSuperficie)
										from Torneos )


--g. Mostrar el nombre del torneo que a lo largo de su historia ha repartido más premios.
--Devolver en la misma consulta, el mínimo monto entregado por este torneo a un
--ganador y el máximo monto percibido por el ganador de este torneo.

select torneoNombre, min(premioGanador) montoMin, max(premioGanador) montoMax
from TorneoEdicion TE, Torneos T
where TE.torneoId = T.torneoId
group by torneoNombre
having sum(premiosTotales) >= all ( 
								select sum(premiosTotales) 
								from TorneoEdicion
								group by torneoId )


--Vistas: crear una vista 'rankingActualPorPais' que muestre por país la cantidad de jugadores
--en el top ten del ranking actual (mostrar solo los países con jugadores en el resultado).

go
create view rankingActualPorPais
as (
	select paisId, paisNombre, count(*) cantJugadores
	from FechaRanking FR, Ranking R, Jugadores J, Paises P
	where FR.fecha = ( select max(fecha) from FechaRanking )
	and FR.fechaRankingId = R.fechaRanking
	and R.jugadorId = J.jugadorId
	and J.paisNacimiento = P.paisId
	and posicion <= 10
	group by paisId, paisNombre
)

select * from rankingActualPorPais


--Informe de consideraciones de la solución





--
