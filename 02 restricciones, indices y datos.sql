
-------------------------------- restricciones de integridad --------------------------------

use master
go
use ObligBD2


alter table Paises add 
	constraint pk_Paises primary key (paisId),
	constraint paisNombre_unico unique(paisNombre),
	constraint paisCodigo_unico unique(paisCodigo)

alter table Jugadores add 
	constraint pk_Jugadores primary key (jugadorId),
	constraint derecho_zurdo check(juego in ('D','Z')),
	constraint fk_paisNacimiento foreign key (paisNacimiento) references Paises,
	constraint fk_paisResidencia foreign key (paisResidencia) references Paises,
	constraint anio_coherente check (profesionalDesde between 1900 and year(getdate()))

alter table Torneos add 
	constraint pk_Torneos primary key (torneoId),
	constraint tipos_de_torneo check (torneoTipo in ('GS', 'MC', '1000', '500', '250')),
	constraint superficie check (torneoSuperficie in ('C', 'P', 'A')),
	constraint fk_torneoPais foreign key (torneoPais) references Paises

alter table TorneoEdicion alter column anio int not null
alter table TorneoEdicion alter column torneoId int not null
go
alter table TorneoEdicion add
	constraint pk_TorneoEdicion primary key (torneoId, anio),
	constraint fk_torneoId foreign key (torneoId) references Torneos,
	constraint fk_ganador foreign key (jugadorGanador) references Jugadores,
	constraint fk_finalista foreign key (finalista) references Jugadores,
	constraint ganador_no_finalista check (jugadorGanador <> finalista),
	constraint fecha_fechaFin check (fechaFin > fechaComienzo),
	constraint anio_fechaComienzo check (year(fechaComienzo) = anio),
	constraint anio_fechaFin check (year(fechaFin) = anio),
	constraint premio_coherente check (premioGanador <= premiosTotales)

alter table Partidos alter column jugadorGanador int not null
alter table Partidos alter column jugadorPerdedor int not null
alter table Partidos alter column torneoId int not null
alter table Partidos alter column anio int not null
alter table Partidos alter column torneoInstancia char(4) not null
go
alter table Partidos add 
	constraint fk_jugadorGanador foreign key (jugadorGanador) references Jugadores,
	constraint fk_jugadorPerdedor foreign key (jugadorPerdedor) references Jugadores,
	constraint fk_torneoId_anio foreign key (torneoId, anio) references TorneoEdicion(torneoId, anio),
	constraint tipos_de_instancias check (torneoInstancia in ('RR', 'R128', 'R64', 'R32', 'R16', 'CF', 'SF', 'F')),
	constraint ganador_distinto_perdedor check (jugadorGanador <> jugadorPerdedor),
	constraint pk_Partidos primary key (jugadorGanador, jugadorPerdedor, torneoId, anio, torneoInstancia)


alter table FechaRanking add 
	constraint pk_FechaRanking primary key (fechaRankingId),
	constraint es_lunes check (datename(weekday, fecha) = 'Monday' )


alter table Ranking alter column fechaRanking int not null
alter table Ranking alter column jugadorId int not null
go
alter table Ranking add 
	constraint fk_fechaRanking foreign key (fechaRanking) references FechaRanking,
	constraint fk_jugadorId foreign key (jugadorId) references Jugadores,
	constraint pos_unica_en_fecha unique(fechaRanking, posicion),
	constraint pk_Ranking primary key (fechaRanking, jugadorId)




----------------------- restricciones de integridad no implementadas ------------------------

-- en txt separado

------------------------------------------ índices ------------------------------------------

create index i1 on Jugadores(paisNacimiento)
create index i2 on Jugadores(paisResidencia)
create index i3 on Torneos(torneoPais)
create index i4 on TorneoEdicion(jugadorGanador)
create index i5 on TorneoEdicion(finalista)
create index i6 on Partidos(jugadorPerdedor)
create index i7 on Partidos(torneoId, anio)
create index i8 on Ranking(jugadorId)

---------------------------------- datos de prueba válidos ----------------------------------

alter table Paises alter column paisNombre varchar(50) --lo cambié porque hay alguno más largo
alter table Paises add codNo char(2) --agrego esa columna porque el script que conseguí la tiene
go
insert into Paises (paisCodigo, paisNombre, codNo) values
('AFG','Afghanistan','AF'),('ALA','Åland','AX'),('ALB','Albania','AL'),('DZA','Algeria','DZ'),
('ASM','American Samoa','AS'),('AND','Andorra','AD'),('AGO','Angola','AO'),('AIA','Anguilla','AI'),
('ATA','Antarctica','AQ'),('ATG','Antigua and Barbuda','AG'),('ARG','Argentina','AR'),
('ARM','Armenia','AM'),('ABW','Aruba','AW'),('AUS','Australia','AU'),('AUT','Austria','AT'),
('AZE','Azerbaijan','AZ'),('BHS','Bahamas','BS'),('BHR','Bahrain','BH'),('BGD','Bangladesh','BD'),
('BRB','Barbados','BB'),('BLR','Belarus','BY'),('BEL','Belgium','BE'),('BLZ','Belize','BZ'),
('BEN','Benin','BJ'),('BMU','Bermuda','BM'),('BTN','Bhutan','BT'),('BOL','Bolivia','BO'),
('BES','Bonaire','BQ'),('BIH','Bosnia and Herzegovina','BA'),('BWA','Botswana','BW'),
('BVT','Bouvet Island','BV'),('BRA','Brazil','BR'),('IOT','British Indian Ocean Territory','IO'),
('VGB','British Virgin Islands','VG'),('BRN','Brunei','BN'),('BGR','Bulgaria','BG'),
('BFA','Burkina Faso','BF'),('BDI','Burundi','BI'),('KHM','Cambodia','KH'),('CMR','Cameroon','CM'),
('CAN','Canada','CA'),('CPV','Cape Verde','CV'),('CYM','Cayman Islands','KY'),
('CAF','Central African Republic','CF'),('TCD','Chad','TD'),('CHL','Chile','CL'),('CHN','China','CN'),
('CXR','Christmas Island','CX'),('CCK','Cocos [Keeling] Islands','CC'),('COL','Colombia','CO'),
('COM','Comoros','KM'),('COK','Cook Islands','CK'),('CRI','Costa Rica','CR'),('HRV','Croatia','HR'),
('CUB','Cuba','CU'),('CUW','Curacao','CW'),('CYP','Cyprus','CY'),('CZE','Czech Republic','CZ'),
('COD','Democratic Republic of the Congo','CD'),('DNK','Denmark','DK'),('DJI','Djibouti','DJ'),
('DMA','Dominica','DM'),('DOM','Dominican Republic','DO'),('TLS','East Timor','TL'),
('ECU','Ecuador','EC'),('EGY','Egypt','EG'),('SLV','El Salvador','SV'),('GNQ','Equatorial Guinea','GQ'),
('ERI','Eritrea','ER'),('EST','Estonia','EE'),('ETH','Ethiopia','ET'),('FLK','Falkland Islands','FK'),
('FRO','Faroe Islands','FO'),('FJI','Fiji','FJ'),('FIN','Finland','FI'),('FRA','France','FR'),
('GUF','French Guiana','GF'),('PYF','French Polynesia','PF'),('ATF','French Southern Territories','TF'),
('GAB','Gabon','GA'),('GMB','Gambia','GM'),('GEO','Georgia','GE'),('DEU','Germany','DE'),
('GHA','Ghana','GH'),('GIB','Gibraltar','GI'),('GRC','Greece','GR'),('GRL','Greenland','GL'),
('GRD','Grenada','GD'),('GLP','Guadeloupe','GP'),('GUM','Guam','GU'),('GTM','Guatemala','GT'),
('GGY','Guernsey','GG'),('GIN','Guinea','GN'),('GNB','Guinea-Bissau','GW'),('GUY','Guyana','GY'),
('HTI','Haiti','HT'),('HMD','Heard Island and McDonald Islands','HM'),('HND','Honduras','HN'),
('HKG','Hong Kong','HK'),('HUN','Hungary','HU'),('ISL','Iceland','IS'),('IND','India','IN'),
('IDN','Indonesia','ID'),('IRN','Iran','IR'),('IRQ','Iraq','IQ'),('IRL','Ireland','IE'),
('IMN','Isle of Man','IM'),('ISR','Israel','IL'),('ITA','Italy','IT'),('CIV','Ivory Coast','CI'),
('JAM','Jamaica','JM'),('JPN','Japan','JP'),('JEY','Jersey','JE'),('JOR','Jordan','JO'),
('KAZ','Kazakhstan','KZ'),('KEN','Kenya','KE'),('KIR','Kiribati','KI'),('XKX','Kosovo','XK'),
('KWT','Kuwait','KW'),('KGZ','Kyrgyzstan','KG'),('LAO','Laos','LA'),('LVA','Latvia','LV'),
('LBN','Lebanon','LB'),('LSO','Lesotho','LS'),('LBR','Liberia','LR'),('LBY','Libya','LY'),
('LIE','Liechtenstein','LI'),('LTU','Lithuania','LT'),('LUX','Luxembourg','LU'),('MAC','Macao','MO'),
('MKD','Macedonia','MK'),('MDG','Madagascar','MG'),('MWI','Malawi','MW'),('MYS','Malaysia','MY'),
('MDV','Maldives','MV'),('MLI','Mali','ML'),('MLT','Malta','MT'),('MHL','Marshall Islands','MH'),
('MTQ','Martinique','MQ'),('MRT','Mauritania','MR'),('MUS','Mauritius','MU'),('MYT','Mayotte','YT'),
('MEX','Mexico','MX'),('FSM','Micronesia','FM'),('MDA','Moldova','MD'),('MCO','Monaco','MC'),
('MNG','Mongolia','MN'),('MNE','Montenegro','ME'),('MSR','Montserrat','MS'),('MAR','Morocco','MA'),
('MOZ','Mozambique','MZ'),('MMR','Myanmar [Burma]','MM'),('NAM','Namibia','NA'),('NRU','Nauru','NR'),
('NPL','Nepal','NP'),('NLD','Netherlands','NL'),('NCL','New Caledonia','NC'),('NZL','New Zealand','NZ'),
('NIC','Nicaragua','NI'),('NER','Niger','NE'),('NGA','Nigeria','NG'),('NIU','Niue','NU'),
('NFK','Norfolk Island','NF'),('PRK','North Korea','KP'),('MNP','Northern Mariana Islands','MP'),
('NOR','Norway','NO'),('OMN','Oman','OM'),('PAK','Pakistan','PK'),('PLW','Palau','PW'),
('PSE','Palestine','PS'),('PAN','Panama','PA'),('PNG','Papua New Guinea','PG'),('PRY','Paraguay','PY'),
('PER','Peru','PE'),('PHL','Philippines','PH'),('PCN','Pitcairn Islands','PN'),('POL','Poland','PL'),
('PRT','Portugal','PT'),('PRI','Puerto Rico','PR'),('QAT','Qatar','QA'),('COG','Republic of the Congo','CG'),
('REU','Réunion','RE'),('ROU','Romania','RO'),('RUS','Russia','RU'),('RWA','Rwanda','RW'),
('BLM','Saint Barthélemy','BL'),('SHN','Saint Helena','SH'),('KNA','Saint Kitts and Nevis','KN'),
('LCA','Saint Lucia','LC'),('MAF','Saint Martin','MF'),('SPM','Saint Pierre and Miquelon','PM'),
('VCT','Saint Vincent and the Grenadines','VC'),('WSM','Samoa','WS'),('SMR','San Marino','SM'),
('STP','São Tomé and Príncipe','ST'),('SAU','Saudi Arabia','SA'),('SEN','Senegal','SN'),
('SRB','Serbia','RS'),('SYC','Seychelles','SC'),('SLE','Sierra Leone','SL'),('SGP','Singapore','SG'),
('SXM','Sint Maarten','SX'),('SVK','Slovakia','SK'),('SVN','Slovenia','SI'),('SLB','Solomon Islands','SB'),
('SOM','Somalia','SO'),('ZAF','South Africa','ZA'),
('SGS','South Georgia and the South Sandwich Islands','GS'),
('KOR','South Korea','KR'),('SSD','South Sudan','SS'),('ESP','Spain','ES'),('LKA','Sri Lanka','LK'),
('SDN','Sudan','SD'),('SUR','Suriname','SR'),('SJM','Svalbard and Jan Mayen','SJ'),
('SWZ','Swaziland','SZ'),('SWE','Sweden','SE'),('CHE','Switzerland','CH'),('SYR','Syria','SY'),
('TWN','Taiwan','TW'),('TJK','Tajikistan','TJ'),('TZA','Tanzania','TZ'),('THA','Thailand','TH'),
('TGO','Togo','TG'),('TKL','Tokelau','TK'),('TON','Tonga','TO'),('TTO','Trinidad and Tobago','TT'),
('TUN','Tunisia','TN'),('TUR','Turkey','TR'),('TKM','Turkmenistan','TM'),('TCA','Turks and Caicos Islands','TC'),
('TUV','Tuvalu','TV'),('UMI','U.S. Minor Outlying Islands','UM'),('VIR','U.S. Virgin Islands','VI'),
('UGA','Uganda','UG'),('UKR','Ukraine','UA'),('ARE','United Arab Emirates','AE'),
('GBR','United Kingdom','GB'),('USA','United States','US'),('URY','Uruguay','UY'),('UZB','Uzbekistan','UZ'),
('VUT','Vanuatu','VU'),('VAT','Vatican City','VA'),('VEN','Venezuela','VE'),('VNM','Vietnam','VN'),
('WLF','Wallis and Futuna','WF'),('ESH','Western Sahara','EH'),('YEM','Yemen','YE'),
('ZMB','Zambia','ZM'),('ZWE','Zimbabwe','ZW');
alter table Paises drop column codNo -- borro la columna agredada que no va

insert into Jugadores values
('Rafael Nadal Parera', --nombre
'19860603', --fechaNacimiento
(select paisId from Paises where paisNombre='Spain'), --paisNacimiento
(select paisId from Paises where paisNombre='Spain'), --paisResidencia
185, --estatura
85, --peso
'Z', --juego
'Carlos Moya and Toni Nadal',--entrenador
2001, --profesionalDesde
100, --partidosGanados
50, --partidosPerdidos
20, --titulosGanados
15 --premiosGanados
)

insert into Jugadores values
('Melesa Ivankov', '1978/08/13', 3, 96, 167, 76, 'D', 'Mose Lamyman', 2013, 3, 53, 20, 50),
('Skipton Pinchen', '1980/02/22', 3, 125, 128, 84, 'D', 'Gunter Peniello', 1989, 95, 84, 45, 17),
('Candida Riediger', '1993/08/19', 3, 226, 121, 55, 'D', 'Maurine Gillbey', 1983, 8, 29, 46, 17),
('Karie Andrag', '1979/04/27', 134, 8, 140, 63, 'D', 'Madison Bissiker', 2009, 48, 75, 46, 17),
('Charo MacChaell', '1991/10/14', 48, 42, 144, 53, 'D', 'Hughie Blaydes', 2015, 29, 36, 31, 22),
('Thibaud Cockburn', '1996/08/23', 57, 53, 220, 60, 'D', 'Bernadina Labrone', 1980, 21, 39, 25, 45),
('Culver Stebbings', '1988/04/28', 106, 216, 186, 65, 'D', 'Ingrim Glassman', 2013, 6, 38, 12, 38),
('Shel Trayton', '1998/01/10', 126, 63, 181, 79, 'D', 'Claudian Friedlos', 1988, 74, 91, 1, 47),
('Willette Theobold', '1985/06/12', 50, 223, 216, 56, 'D', 'Dorette McLarens', 1997, 14, 87, 6, 5),
('Brendon Calow', '1983/12/28', 7, 115, 204, 77, 'D', 'Fanya Kirsz', 1980, 83, 34, 12, 50),
('Lizzie Tuttle', '1993/09/23', 246, 110, 194, 56, 'D', 'Ervin Caro', 1998, 68, 41, 32, 40),
('Stephenie Chieco', '1988/01/10', 25, 87, 134, 86, 'D', 'Cary Keywood', 1992, 61, 2, 39, 19),
('Laurie Manes', '1981/09/25', 4, 17, 182, 53, 'D', 'Vasili McLernon', 1991, 78, 94, 36, 43),
('Remy Binnes', '1986/02/07', 187, 38, 194, 61, 'D', 'Gal Grog', 1984, 67, 72, 16, 18),
('Hermia O''Curneen', '1995/04/03', 241, 213, 167, 71, 'D', 'Alec Kuzma', 1985, 7, 19, 11, 45),
('Elfrieda Eshmade', '1974/04/15', 21, 202, 187, 62, 'D', 'Siward Imison', 2005, 40, 15, 38, 39),
('Dalenna McCole', '1970/02/15', 6, 43, 137, 87, 'D', 'Brandy Buckett', 2013, 43, 89, 8, 12),
('Micky Peverell', '1998/01/18', 73, 10, 137, 91, 'D', 'Ferdinand Danzelman', 2013, 30, 87, 39, 44),
('Bernarr O''Sheilds', '1983/10/05', 103, 131, 130, 62, 'D', 'Ernst Haggith', 1990, 16, 85, 13, 4),
('Orson Village', '1981/12/05', 146, 215, 149, 77, 'D', 'Jarib Autrie', 1986, 42, 0, 9, 50)


insert into Torneos values
('Wimbledon', 'GS', 'P', 1877, (select paisId from Paises where paisNombre = 'United Kingdom')),
('US Open', 'GS', 'C', 1881, (select paisId from Paises where paisNombre = 'United States')),
('French Open', 'GS', 'A', 1891, (select paisId from Paises where paisNombre = 'France')),
('Madrid Open', 'MC', 'A', 2002, (select paisId from Paises where paisNombre = 'Spain')),
('Shanghai Masters', '1000', 'C', 2009, (select paisId from Paises where paisNombre = 'China')),
('Rio Open', '500', 'A', 2014, (select paisId from Paises where paisNombre = 'Brazil')),
('Open 13', '250', 'C', 1993, (select paisId from Paises where paisNombre = 'France'))


insert into TorneoEdicion values 
(1, 2018, 13, 18, 10000, 20000, '20180201', '20180420'),
(1, 2017, 18, 21, 30000, 60000, '20170203', '20170409'),
(1, 2016, 2, 12, 20000, 90000, '20160202', '20160411'),

(2, 2018, null, null, 50000, 80000, '20180925', '20181011'), -- todavía no se disputó
(2, 2017, 12, 6, 10000, 20000, '20170920', '20171015'),
(2, 2016, 15, 16, 20000, 70000, '20160909', '20161010'),

(3, 2018, null, null, 30000, 80000, '20181111', '20181211'), -- todavía no se disputó
(3, 2017, 18, 11, 40000, 60000, '20171110', '20171209'),
(3, 2016, 11, 5, 30000, 50000, '20161108', '20161212'),

(4, 2018, 19, 1, 20000, 40000, '20180115', '20180212'),
(4, 2004, 2, 18, 30000, 80000, '20040724', '20041214'),

(5, 2018, 19, 8, 50000, 90000, '20180129', '20180214'), -- se repite ganador para ver distinct en cosulta d
(5, 2016, 9, 12, 10000, 20000, '20160324', '20161015'),

(6, 2016, 4, 1, 60000, 90000, '20160915', '20161009'),
(6, 2017, 18, 7, 30000, 50000, '20170704', '20171202'),

(7, 1995, 18, 10, 20000, 70000, '19950913', '19951104'),
(7, 2003, 17, 9, 10000, 20000, '20031003', '20031211')


insert into Partidos values
(5, 3, 1, 2018, 'RR', '3 3 6 6'),
(16, 10, 1, 2018, 'RR', '6 6 4 2'),
(19, 9, 1, 2018, 'R128', '7 6 6 6 7 4'),
(17, 7, 1, 2018, 'R128', '6 6 3 1'),
(20, 6, 1, 2018, 'R64', '6 3 6 3 6 7'), --
(14, 20, 2, 2017, 'R64', '6 6 6 4 7 3'),
(13, 10, 2, 2017, 'R32', '6 1 7 6'),
(4, 16, 2, 2017, 'R32', '6 6 1 4'),
(14, 5, 2, 2017, 'R16', '2 6 3 6 3 6'),
(5, 6, 2, 2017, 'R16', '6 3 6 2 6 3'),
(12, 3, 2, 2017, 'R16', '6 6 3 2'), --
(13, 8, 3, 2017, 'R16', '3 2 6 6'),
(19, 2, 3, 2017, 'CF', '1 3 6 6'),
(4, 12, 3, 2017, 'CF', '6 3 7 6'),
(11, 7, 3, 2017, 'CF', '5 4 7 6'),
(14, 21, 3, 2017, 'CF', '6 2 7 1 6 6'),
(10, 1, 3, 2017, 'SF', '4 2 6 6'),
(2, 20, 3, 2017, 'SF', '2 3 6 6'),
(2, 13, 3, 2017, 'SF', '6 6 3 3'),--
(12, 9, 1, 2017, 'F', '4 0 6 6'),
(10, 19, 1, 2017, 'F', '7 7 6 6'),
(9, 11, 1, 2017, 'F', '4 4 6 6'),
(16, 1, 1, 2017, 'F', '7 2 5 5 6 7'),
(5, 12, 1, 2017, 'F', '6 6 4 3'),
(19, 10, 1, 2017, 'RR', '6 6 4 7 4 6'), --
(14, 8, 4, 2018, 'RR', '6 6 6 7 4 4'),
(7, 2, 4, 2018, 'RR', '7 3 6 5 6 3'),
(8, 17, 4, 2018, 'RR', '4 6 6 7'),
(15, 7, 4, 2018, 'R128', '7 6 5 4'),
(21, 10, 4, 2018, 'R128', '4 2 6 6'),
(6, 7, 4, 2018, 'R128', '6 6 6 7 4 0'),
(13, 7, 4, 2018, 'R64', '5 6 7 7 4 6'),
(7, 14, 4, 2018, 'R64', '3 4 6 6'), --
(16, 21, 5, 2018, 'R64', '6 6 2 0'),
(21, 11, 5, 2018, 'R64', '2 5 6 7'),
(14, 6, 5, 2018, 'R32', '6 6 0 2'),
(16, 7, 5, 2018, 'R32', '7 7 6 6'),
(17, 12, 5, 2018, 'R32', '6 6 3 1'),
(5, 9, 5, 2018, 'R32', '1 7 2 6 6 6'),
(19, 1, 5, 2018, 'R16', '3 6 5 6 4 7'),
(20, 5, 5, 2018, 'R16', '6 3 5 4 6 7'),
(13, 7, 5, 2018, 'R16', '6 6 2 1'),
(15, 18, 5, 2018, 'CF', '5 6 2 7 2 6'),
(10, 9, 5, 2018, 'CF', '6 2 6 3 6 3'), --
(14, 9, 6, 2017, 'CF', '7 6 5 3'),
(16, 6, 6, 2017, 'R128', '7 6 2 5 7 6'),
(9, 11, 6, 2017, 'R128', '6 6 3 4'),
(13, 4, 6, 2017, 'R128', '4 2 6 6'),
(8, 5, 6, 2017, 'R128', '6 4 6 3 6 7'),
(2, 11, 6, 2017, 'R128', '6 6 4 4')





----------------------------- más datos para testear la parte 2 -----------------------------

insert into Partidos values
(1, 3, 1, 2018, 'RR', '3 3 6 6'),
(1, 4, 2, 2018, 'RR', '3 3 6 6'),
(1, 5, 3, 2018, 'RR', '3 3 6 6'),
(2, 3, 1, 2018, 'RR', '3 3 6 6'),
(2, 4, 2, 2018, 'RR', '3 3 6 6'),
(2, 5, 3, 2018, 'RR', '3 3 6 6')

insert into Partidos values
(12, 3, 1, 2018, 'RR', '3 3 6 6'),
(13, 4, 2, 2018, 'RR', '3 3 6 6')

insert into TorneoEdicion values
(3, 2015, 12, 18, 10000, 20000, '20150201', '20150420'),
(3, 2014, 12, 11, 10000, 20000, '20140201', '20140420'),
(3, 2013, 12, 5, 10000, 20000, '20130201', '20130420'),
(3, 2012, 12, 4, 10000, 20000, '20120201', '20120420'),
(3, 2011, 12, 9, 10000, 20000, '20110201', '20110420'),
(3, 1998, 12, 9, 10000, 20000, '19980201', '19980420'),
(3, 2010, 15, 18, 10000, 20000, '20100201', '20100420'),
(3, 2009, 15, 11, 10000, 20000, '20090201', '20090420'),
(3, 2008, 15, 5, 10000, 20000, '20080201', '20080420'),
(3, 2007, 15, 4, 10000, 20000, '20070201', '20070420'),
(3, 2006, 15, 9, 10000, 20000, '20060201', '20060420'),
(3, 1999, 15, 9, 10000, 20000, '19990201', '19990420'),
(3, 2005, 2, 18, 10000, 20000, '20050201', '20050420'),
(3, 2000, 2, 11, 10000, 20000, '20000201', '20000420'),
(3, 2003, 2, 5, 10000, 20000, '20030201', '20030420'),
(3, 2002, 2, 4, 10000, 20000, '20020201', '20020420'),
(3, 2001, 2, 9, 10000, 20000, '20010201', '20010420')

insert into TorneoEdicion values
(5, 2015, 12, 18, 10000, 20000, '20150201', '20150420'),
(5, 2014, 12, 11, 10000, 20000, '20140201', '20140420'),
(5, 2013, 12, 5, 10000, 20000, '20130201', '20130420'),
(5, 2012, 12, 4, 10000, 20000, '20120201', '20120420'),
(5, 2011, 12, 4, 10000, 20000, '20110201', '20110420'),
(5, 2010, 12, 4, 10000, 20000, '20100201', '20100420'),
(5, 2009, 12, 4, 10000, 20000, '20090201', '20090420'),
(5, 2008, 12, 4, 10000, 20000, '20080201', '20080420'),
(5, 2007, 12, 4, 10000, 20000, '20070201', '20070420'),
(5, 2006, 12, 4, 10000, 20000, '20060201', '20060420'),
(5, 2005, 12, 4, 10000, 20000, '20050201', '20050420'),
(5, 2004, 15, 18, 10000, 20000, '20040201', '20040420'),
(5, 2003, 15, 11, 10000, 20000, '20030201', '20030420'),
(5, 2002, 15, 5, 10000, 20000, '20020201', '20020420'),
(5, 2001, 15, 4, 10000, 20000, '20010201', '20010420'),
(5, 2000, 15, 4, 10000, 20000, '20000201', '20000420'),
(5, 1999, 15, 4, 10000, 20000, '19990201', '19990420'),
(5, 1998, 15, 4, 10000, 20000, '19980201', '19980420'),
(5, 1997, 15, 4, 10000, 20000, '19970201', '19970420'),
(5, 1996, 15, 4, 10000, 20000, '19960201', '19960420'),
(5, 1995, 15, 4, 10000, 20000, '19950201', '19950420'),
(5, 1994, 15, 4, 10000, 20000, '19940201', '19940420')

insert into TorneoEdicion values
(6, 2015, 12, 18, 10000, 20000, '20150201', '20150420'),
(6, 2014, 12, 11, 10000, 20000, '20140201', '20140420'),
(6, 2013, 12, 5, 10000, 20000, '20130201', '20130420'),
(6, 2012, 12, 4, 10000, 20000, '20120201', '20120420'),
(6, 2011, 12, 4, 10000, 20000, '20110201', '20110420'),
(6, 2010, 12, 4, 10000, 20000, '20100201', '20100420'),
(6, 2009, 12, 4, 10000, 20000, '20090201', '20090420'),
(6, 2008, 12, 4, 10000, 20000, '20080201', '20080420'),
(6, 2007, 12, 4, 10000, 20000, '20070201', '20070420'),
(6, 2006, 12, 4, 10000, 20000, '20060201', '20060420'),
(6, 2005, 12, 4, 10000, 20000, '20050201', '20050420'),
(6, 2004, 15, 18, 10000, 20000, '20040201', '20040420'),
(6, 2003, 15, 11, 10000, 20000, '20030201', '20030420'),
(6, 2002, 15, 5, 10000, 20000, '20020201', '20020420'),
(6, 2001, 15, 4, 10000, 20000, '20010201', '20010420'),
(6, 2000, 15, 4, 10000, 20000, '20000201', '20000420'),
(6, 1999, 15, 4, 10000, 20000, '19990201', '19990420'),
(6, 1998, 15, 4, 10000, 20000, '19980201', '19980420'),
(6, 1997, 15, 4, 10000, 20000, '19970201', '19970420'),
(6, 1996, 15, 4, 10000, 20000, '19960201', '19960420'),
(6, 1995, 15, 4, 10000, 20000, '19950201', '19950420'),
(6, 1994, 15, 4, 10000, 20000, '19940201', '19940420'),
(6, 1993, 15, 4, 10000, 20000, '19930201', '19930420'),
(6, 1992, 15, 4, 10000, 20000, '19920201', '19920420')

insert into TorneoEdicion values
(2, 2015, 2, 11, 10000, 20000, '20150201', '20150420')

insert into Jugadores values
('Alguien que no jugó', '1973/09/11', 3, 94, 160, 73, 'Z', 'Mose Lamyman', 2015, 0, 53, 0, 0)

insert into FechaRanking values 
('20180305'), ('20180312'), ('20180319'),('20180326'), ('20180402'), 
('20180409'),('20180416'), ('20180423'), ('20180430'), ('20180507')

insert into Ranking values
(10, 9, 1, 772),
(10, 4, 2, 429),
(10, 12, 3, 219),
(10, 2, 4, 495),
(10, 10, 5, 866),
(10, 13, 6, 139),
(10, 14, 7, 569),
(10, 11, 8, 756),
(10, 5, 9, 114),
(10, 8, 10, 325),
(10, 16, 11, 419),
(10, 3, 12, 500),
(10, 7, 13, 145),
(10, 6, 14, 957),
(10, 1, 15, 370), --

(9, 18, 1, 803),
(9, 6, 2, 767),
(9, 5, 3, 934),
(9, 19, 4, 283),
(9, 4, 5, 264),
(9, 1, 6, 353),
(9, 13, 7, 725),
(9, 14, 8, 903),
(9, 3, 9, 278),
(9, 9, 10, 432),
(9, 10, 11, 760),
(9, 16, 12, 849),
(9, 11, 13, 623),
(9, 7, 14, 645),
(9, 2, 15, 426),
(9, 17, 16, 250),
(9, 8, 17, 378),
(9, 12, 18, 262),
(9, 15, 19, 557) --












--