----------drop----------
drop table utilizator_abonament;
drop table vizioneaza;
drop table media_gen;
drop table dispozitiv;
drop table episod;
drop table sezon;
drop table media;
drop table distribuitor;
drop table gen;
drop table tip_abonament;
drop table utilizator;
drop trigger validare_abonament;
drop trigger update_aboament;
drop trigger validare_sezon;
drop trigger update_sezon;
drop trigger validare_episod;
drop trigger update_episod;
drop trigger validare_vizionare;
--------------------

------------UTILIZATOR--------------
create table UTILIZATOR(
id_utilizator number(4),
nume_utilizator varchar2(20) constraint nume_user_nn not null,
prenume_utilizator varchar2(20) constraint prenume_user_nn not null,
email varchar2(40) constraint email_nn not null,
data_nasterii date constraint data_nastere_nn not null,
data_inregistrare date constraint data_inregistrare_nn not null,
limba varchar2(15) default 'engleza',
banca_card varchar2(30) constraint banca_nn not null,
numar_card varchar2(16) constraint numar_card_nn not null,
data_expirare_card date constraint data_expirare_card_nn not null,
cod_securitate_card varchar2(3) constraint cod_securitate_card_nn not null
);

alter table utilizator
add(
constraint id_utilizator_pk primary key(id_utilizator),
constraint email_u unique(email),
constraint numar_card_u unique(numar_card,cod_securitate_card),
constraint data_nastere_valida check ( ( extract(year from data_nasterii) ) <= 2007), --peste 18 ani 
constraint data_inregistrare_valida check (data_inregistrare > data_nasterii), -- data de inregistrare sa nu fie inainte de data nasterii
constraint data_expirare_valida check (data_expirare_card >= add_months(data_inregistrare,1)), --la momentul inserarii, cardul sa nu fie expirat
constraint numar_card_lungime_valida check (length(numar_card) = 16), --numarul cardului trebuie sa aiba fix 16 caractere 
constraint numar_card_caractere_valide check (regexp_like(numar_card,'^[0-9]+$')), --numarul cardului trebuie sa aiba doar cifre 0-9
constraint cod_securitate_valid check (length(cod_securitate_card) = 3) --codul de securitate trebuie sa aiba 3 sau 4 cifre
);

-----------DISPOZITIV--------------
create table DISPOZITIV
(
id_dispozitiv number(3),
id_utilizator number(4) constraint id_utlizator_fk not null,
tip varchar2(10) constraint tip_nn not null,
model varchar2(20)
);

alter table dispozitiv
add(
constraint id_dispozitiv_pk primary key(id_dispozitiv),
constraint id_dispozitiv_utilizator_fk foreign key (id_utilizator) references utilizator(id_utilizator) on delete cascade,
constraint tip_dispozitiv_valid check(tip in ('telefon', 'laptop', 'tableta', 'desktop', 'smart_tv', 'consola'))
);

------------TIP_ABONAMENT--------------
create table TIP_ABONAMENT
(
id_abonament number(3),
nume_abonament varchar2(15) constraint nume_abonament_nn not null,
cost_lunar number(5,2) constraint cost_lunar_nn not null,
cost_anual number(5,2),
reclame number(1) constraint reclame_bool_nn not null,
descarcari_offline number(1) constraint descarcari_offline_nn not null,
numar_de_ecrane number(1) constraint nr_ecrane_nn not null
);

alter table tip_abonament
add(
constraint id_abonament_pk primary key(id_abonament),
constraint nume_abonament_u unique(nume_abonament),
constraint cost_lunar_pozitiv check(cost_lunar>0),
constraint cost_anual_pozitiv check(cost_anual>0),
constraint reclame_bool_valid check (reclame =1 or reclame =0),
constraint descarcari_offline_bool_valid check (descarcari_offline =1 or descarcari_offline=0),
constraint nr_ecrane_valid check (numar_de_ecrane in (1,2,3,4,5))
);

-----UTILIZATOR_ABONAMENT(ASOCIATIV)-----
create table utilizator_abonament
(
id_utilizator number(4),
id_abonament number(3),
data_start date constraint data_start_nn not null,
data_end date constraint data_end_nn not null
);

alter table utilizator_abonament
add(
constraint id_utilizator_abonament_pk primary key(id_utilizator,id_abonament,data_start,data_end), 
constraint id_utilizator_fk foreign key(id_utilizator) references utilizator(id_utilizator) on delete cascade,
constraint id_abonament_fk foreign key(id_abonament) references tip_abonament(id_abonament) on delete cascade, 
constraint data_end_valida check(data_end>data_start and ( (add_months(data_start,1) = data_end) or (add_months(data_start,12) = data_end) ) )  --data de final dupa cea de start
);

------TRIGGER VALIDARE ABONAMENT------
create or replace trigger validare_abonament
before insert on utilizator_abonament
for each row
declare
    nr_suprapunere number;
begin
    select count(*)
    into nr_suprapunere
    from utilizator_abonament
    where 
        id_utilizator = :new.id_utilizator
        and(
            (:new.data_start > data_start and :new.data_start < data_end) or (:new.data_end > data_start and :new.data_end < data_end)
        );

    if nr_suprapunere > 0 then
        raise_application_error(-20001, 'Intervalul de date pentru acest utilizator se suprapune cu un alt abonament existent.');
    end if;
end;
/

----TRIGGER OPRIRE UPDATE ABONAMENT----
create or replace trigger update_abonament
before update on utilizator_abonament
for each row
begin
    if :old.id_abonament <> :new.id_abonament then
        raise_application_error(-20013, 'Abonamentul poate fi schimbat doar cand se termina.');
    end if;
    
    if :old.id_utilizator <> :new.id_utilizator then
        raise_application_error(-20014, 'Abonamntul nu poate fi mutat de la un utilizator la altul.');
    end if;
    
    if :old.data_start <> :new.data_start then
        raise_application_error(-20015, 'Data de inceput a abonamentului nu poate fi actualizata.');
    end if;
end;
/
    
---------DISTRIBUITOR-----------
create table DISTRIBUITOR
(
id_distribuitor number(3),
nume_distribuitor varchar2(50) constraint nume_dist_nn not null,
tara varchar2(30) constraint tara_nn not null,

constraint id_dist_pk primary key(id_distribuitor),
constraint nume_dist_u unique(nume_distribuitor)
);

------------GEN---------------
create table GEN
(
id_gen number(2) constraint id_gen_pk primary key,
nume_gen varchar2(16) constraint nume_gen_nn not null,
constraint nume_gen_u unique (nume_gen)
);

----------MEDIA--------------
create table MEDIA
(
id_media number(4),
id_distribuitor number(3) constraint id_distribuitor_nn not null,
titlu_media varchar2(50) constraint titlu_nn not null,
tip_media varchar2(15) constraint tip_media_nn not null,
durata_media number(3), --daca e media cu sezoane nu are durata - este suma duratelor episoadelor
data_lansare_media date constraint data_lansare_media_nn not null,
varsta_minima number(2) constraint varsta_minima_nn not null,
buget number(12,2) constraint buget_nn not null
);

alter table media
add(
constraint id_media_pk primary key(id_media),
constraint id_media_distribuitor_fk foreign key (id_distribuitor) references distribuitor(id_distribuitor) on delete cascade,
constraint tip_media_valid check (tip_media in ('film' , 'documentar', 'serial', 'scurtmetraj', 'emisiune_tv')),
constraint durata_media_valida check (durata_media>0),
constraint varsta_minima_valida check (varsta_minima>=0),
constraint buget_valid check (buget>0)
);

------------SEZON--------------
create table SEZON
(
id_sezon number(4),
id_media number(4) constraint id_media__fk_nn not null, -- orice sezon trebuie sa apartina de media
numar_sezon number(2) constraint numar_sezon_nn not null,
data_lansare_sezon date constraint data_lansare_sezon_nn not null
);

alter table sezon
add(
constraint id_sezon_pk primary key(id_sezon),
constraint id_sezon_media_fk foreign key(id_media) references media(id_media) on delete cascade,
constraint numar_sezon_valid check(numar_sezon > 0)
);

---------TRIGGER OPRIRE UPDATE SEZON------------
create or replace trigger update_sezon
before update on sezon
for each row
begin
    if :old.numar_sezon <> :new.numar_sezon then
        raise_application_error(-20006,'Numarul sezonului nu se poate actualiza.');
    end if;
    
    if :old.id_media <> :new.id_media then
        raise_application_error(-20007,'Media asociata sezonului nu se poate actualiza.');
    end if;

    if :old.data_lansare_sezon <> :new.data_lansare_sezon then
        raise_application_error(-20008,'Data de lansare a sezonului nu poate fi actualizata.');
    end if;
end;
/

------TRIGGER VALIDARE SEZON-------
create or replace trigger validare_sezon 
before insert on sezon
for each row
declare 
    sezon_anterior number;
    data_media date;
    tip varchar2(15);
begin
    select max(numar_sezon)
    into sezon_anterior
    from sezon
    where id_media = :new.id_media;
    
    if sezon_anterior is not null and :new.numar_sezon <>sezon_anterior+1 then
        raise_application_error(-20002, 'Numarul sezonului trebuie sa fie egal cu utlimul sezon+1.');
    end if;
    
    select data_lansare_media
    into data_media
    from media
    where id_media = :new.id_media;
    
    if data_media is not null and :new.data_lansare_sezon < data_media then
        raise_application_error(-20003, 'Data de lansare a sezonului trebuie sa fie dupa data de lansare media.');
    end if;
    
    select tip_media
    into tip
    from media
    where id_media = :new.id_media;
    
    if tip is not null and tip in ('film','scurtmetraj') then
        raise_application_error(-20004, 'Filmele si scurtmetrajele nu pot avea sezoane.');
    end if;
    
end;
/

------EPISOD-------
create table episod
(
id_episod number(4),
id_sezon number(4) constraint id_sezon_fk_nn not null,
numar_episod number(2) constraint numar_episod_nn not null,
durata_episod number(3) constraint durata_episod_nn not null,
titlu_episod varchar2(40),
data_lansare_episod date constraint data_lansare_episod_nn not null
);

alter table episod
add(
constraint id_episod_pk primary key(id_episod),
constraint id_episod_sezon_fk foreign key(id_sezon) references sezon(id_sezon) on delete cascade,
constraint numar_episod_valid check(numar_episod>0),
constraint durata_episod_valida check(durata_episod>0)
);



-----TRIGGER VALIDARE EPISOD-----
create or replace trigger validare_episod
before insert on episod
for each row
declare
    data_sezon date;
    episod_anterior number;
begin
    select max(numar_episod)
    into episod_anterior
    from episod
    where id_sezon = :new.id_sezon;
    
    if episod_anterior is not null and :new.numar_episod <> episod_anterior+1 then
        raise_application_error(-20009,'Numarul episodului trebuie sa il preceada imediat pe ultimul episod adaugat.');
    end if;

    select data_lansare_sezon
    into data_sezon
    from sezon
    where id_sezon = :new.id_sezon;
    
    if data_sezon is not null and data_sezon > :new.data_lansare_episod then
        raise_application_error(-20005,'Data de lansare a episodului nu poate fi inainte de lansarea sezonului.');
    end if;
end;
/


----TRIGGER OPRIRE UPDATE EPISOD------
create or replace trigger update_episod
before update on episod
for each row
begin
    if :old.id_sezon <> :new.id_sezon then
        raise_application_error(-20010,'Sezonul asociat episodului nu se poate actualiza.');
    end if;
    
    if :old.numar_episod <> :new.numar_episod then
        raise_application_error(-20011,'Numarul episodului nu se poate actualiza.');
    end if;
    
    if :old.durata_episod <> :new.durata_episod then
        raise_application_error(-20012,'Durata episodului nu se poate actualiza.');
    end if;
    
    if :old.data_lansare_episod <> :new.data_lansare_episod then
        raise_application_error(-20013,'Data de lansare a episodului nu se poate actualiza.');
    end if;
end;
/


---------------MEDIA-GEN (asociativ)----------------
create table MEDIA_GEN
(
id_media number(4),
id_gen number(2),

constraint media_gen_pk primary key(id_media,id_gen),
constraint id_media_fk foreign key(id_media) references media(id_media) on delete cascade,
constraint id_gen_fk foreign key(id_gen) references gen(id_gen) on delete cascade
);


---------------VIZIONEAZA (asociaativ) -------------
create table VIZIONEAZA
(
id_utilizator number(4),
id_media number(4),
data_vizionare date constraint data_vizionare_nn not null,
durata_vizionare number(3) constraint durata_vizionare_nn not null
);

alter table vizioneaza
add(
constraint id_vizioneaza_pk primary key(id_utilizator,id_media,data_vizionare,durata_vizionare),
constraint id_utilizator_viz_fk foreign key(id_utilizator) references utilizator(id_utilizator) on delete cascade,
constraint id_media_viz_fk foreign key(id_media) references media(id_media) on delete cascade,
constraint durata_viz_valida check(durata_vizionare>0)
);

-----TRIGGER VALIDARE VIZIONARE----------
create or replace trigger validare_vizionare
before insert or update on vizioneaza
for each row
declare 
    abonament number;
begin
    select id_abonament
    into abonament
    from utilizator_abonament
    where id_utilizator = :new.id_utilizator and :new.data_vizionare >= data_start and :new.data_vizionare <= data_end;
    
    if abonament is null then
        raise_application_error(-20017,'Utilizatorul nu are un abonament activ la aceasta data.');
    end if;
end;
/

insert into distribuitor values(1,'Warner Bros. Pictures', 'SUA');
insert into distribuitor values(2,'Universal Pictures','SUA');
insert into distribuitor values(3,'20th Century Studios','SUA');
insert into distribuitor values(4,'Columbia Pictures','SUA');
insert into distribuitor values(5,'Paramount Pictures','SUA');
insert into distribuitor values(6,'Walt Disney Studios Motion Pictures','SUA');
insert into distribuitor values(7,'Lionsgate Films','SUA');
insert into distribuitor values(8,'Focus Features','SUA');
insert into distribuitor values(9,'BBC Studios','United Kingdom');
insert into distribuitor values(10,'Netflix','SUA');
insert into distribuitor values(11,'Sony Pictures','SUA');
commit;

-------------1 = warner bros-------------------
insert into media
values(1,1,'Harry Potter and the Sorcerer''s Stone','film',152,to_date('16-nov-2001','dd-mon-yyyy'),10,125000000);
insert into media
values(2,1,'Harry Potter and the Chamber of Secrets','film',161,to_date('15-nov-2002','dd-mon-yyyy'),10,100000000);
insert into media
values(3,1,'Harry Potter and the Prisoner of Azkaban','film',142,to_date('4-jun-2004','dd-mon-yyyy'),10,130000000);
insert into media
values(4,1,'Harry Potter and the Goblet of Fire','film',157,to_date('18-nov-2005','dd-mon-yyyy'),12,150000000);
insert into media
values(5,1,'Harry Potter and the Order of Phoenix','film',138,to_date('11-jul-2007','dd-mon-yyyy'),12,150000000);
insert into media
values(6,1,'Harry Potter and the Half-Blood Prince','film',153,to_date('15-jul-2009','dd-mon-yyyy'),12,250000000);
insert into media
values(7,1,'Harry Potter and the Deathly Hollow''s: Part 1','film',146,to_date('19-nov-2010','dd-mon-yyyy'),12,250000000);
insert into media
values(8,1,'Harry Potter and the Deathly Hollow''s: Part 2','film',130,to_date('15-jul-2011','dd-mon-yyyy'),12,250000000);
----------------------------------------------------
insert into media
values(9,1,'Batman Begins','film',140,to_date('15-jun-2005','dd-mon-yyyy'),13,150000000);
insert into media
values(10,1,'The Dark Knight','film',152,to_date('18-jul-2008','dd-mon-yyyy'),13,185000000);
insert into media
values(11,1,'The Dark Knight Arises','film',165,to_date('20-jul-2012','dd-mon-yyyy'),13,230000000);
---------------------------------------------------
insert into media
values(12,1,'Inception','film',148,to_date('16-jul-2010','dd-mon-yyyy'),13,160000000);
--------------------------------------------------
insert into media
values(13,1,'Friends','serial',null,to_date('22-sep-1994','dd-mon-yyyy'),12,200000000);
--------------------------------------------------
insert into media
values(14,1,'Game of Thrones','serial',null,to_date('17-apr-2011','dd-mon-yyyy'),18,1500000000);
-------------------------------------------------
insert into media
values(15,1,'The Matrix','film',136,to_date('31-mar-1999','dd-mon-yyyy'),14,63000000);
insert into media
values(16,1,'The Matrix Reloaded','film',138,to_date('15-may-2003','dd-mon-yyyy'),14,150000000);
insert into media
values(17,1,'The Matrix Revolutions','film',129,to_date('5-nov-2003','dd-mon-yyyy'),14,150000000);
insert into media
values(18,1,'The Matrix Resurrections','film',148,to_date('22-dec-2021','dd-mon-yyyy'),14,190000000);
------------------------------------------------
insert into media
values(19,1,'Fantastic Beasts and Where to Find Them','film',133,to_date('18-nov-2016','dd-mon-yyyy'),12,180000000);
insert into media
values(20,1,'Fantastic Beasts: The Crimes Of Grindelwald','film',134,to_date('16-nov-2018','dd-mon-yyyy'),12,200000000);
insert into media
values(21,1,'Fantastic Beasts: The Secrets of Dumbledore','film',142,to_date('15-apr-2022','dd-mon-yyyy'),12,200000000);
-----------------
-------------------2 = Universal pictures---------------
insert into media
values(22,2,'Jurassic Park','film',127,to_date('11-jun-1993','dd-mon-yyyy'),12,63000000);
insert into media
values(23,2,'The Lost World: Jurassic Park','film',129,to_date('23-jun-1997','dd-mon-yyyy'),12,73000000);
insert into media
values(24,2,'Jurassic Park III','film',92,to_date('18-jul-2001','dd-mon-yyyy'),12,93000000);
insert into media
values(25,2,'Jurassic World','film',124,to_date('12-jun-2015','dd-mon-yyyy'),12,150000000);
insert into media
values(26,2,'Jurassic World: Fallen Kingdom','film',128,to_date('22-jun-2018','dd-mon-yyyy'),12,170000000);
insert into media
values(27,2,'Jurassic World: Dominion','film',146,to_date('10-jun-2022','dd-mon-yyyy'),12,185000000);
--------------------------------------------------
insert into media
values(28,2,'The Fast and the Furious','film',106,to_date('22-jun-2001','dd-mon-yyyy'),12,38000000);
insert into media
values(29,2,'2 Fast 2 Furious','film',108,to_date('6-jun-2003','dd-mon-yyyy'),12,76000000);
insert into media
values(30,2,'The Fast and the Furious: Tokyo Drift','film',104,to_date('16-jun-2006','dd-mon-yyyy'),12,85000000);
insert into media
values(31,2,'Fast and Furious','film',107,to_date('3-apr-2009','dd-mon-yyyy'),12,85000000);
insert into media
values(32,2,'Fast Five','film',130,to_date('29-apr-2011','dd-mon-yyyy'),12,125000000);
insert into media
values(33,2,'Fast and Furious 6','film',130,to_date('24-may-2013','dd-mon-yyyy'),12,160000000);
insert into media
values(34,2,'Furious 7','film',137,to_date('3-apr-2015','dd-mon-yyyy'),12,190000000);
insert into media
values(35,2,'The Fate of the Furious','film',136,to_date('14-apr-2017','dd-mon-yyyy'),12,250000000);
------------------------------------------------
insert into media
values(36,2,'Despicable Me','film',95,to_date('9-jul-2010','dd-mon-yyyy'),6,69000000);
insert into media
values(37,2,'Despicable Me 2','film',98,to_date('3-jul-2013','dd-mon-yyyy'),6,76000000);
insert into media
values(38,2,'Minions','film',91,to_date('10-jul-2015','dd-mon-yyyy'),6,74000000);
insert into media
values(39,2,'Despicable Me 3','film',90,to_date('30-jun-2017','dd-mon-yyyy'),6,80000000);
insert into media
values(40,2,'Minions: The Rise of Gru','film',87,to_date('1-jul-2022','dd-mon-yyyy'),6,80000000);
-----------------------------
insert into media
values(41,2,'Back to the Future','film',136,to_date('3-jul-1985','dd-mon-yyyy'),6,19000000);
----------------------
insert into media
values(42,2,'The Mummy','film',124,to_date('7-may-1999','dd-mon-yyyy'),12,80000000);
-------------------
--------------3 = 20th century stidos-----------
insert into media
values(43,3,'The Martian','film',144,to_date('2-oct-2015','dd-mon-yyyy'),12,108000000);
-------------------------------------
insert into media
values(44,3,'Kingsman: The Secret Service','film',129,to_date('13-feb-2015','dd-mon-yyyy'),12,81000000);
----------------
insert into media
values(45,3,'Titanic','film',195,to_date('19-dec-1997','dd-mon-yyyy'),12,200000000);
----------------
insert into media
values(46,3,'Night at the Museum','film',108,to_date('22-dec-2006','dd-mon-yyyy'),6,110000000);
insert into media
values(47,3,'Night at the Museum: Battle of Smithsonian','film',105,to_date('22-may-2009','dd-mon-yyyy'),6,150000000);
insert into media
values(48,3,'Night at the Museum: Secret of the Tomb','film',98,to_date('19-dec-2014','dd-mon-yyyy'),6,127000000);
-------------------
insert into media
values(49,3,'X-Men','film',104,to_date('14-jul-2000','dd-mon-yyyy'),12,75000000);
insert into media
values(50,3,'X2: X-Men United','film',133,to_date('2-may-2003','dd-mon-yyyy'),12,110000000);
insert into media
values(51,3,'X-Men: The Last Stand','film',104,to_date('26-may-2006','dd-mon-yyyy'),12,210000000);
insert into media
values(52,3,'X-Men: First Class','film',132,to_date('3-jun-2011','dd-mon-yyyy'),12,160000000);
insert into media
values(53,3,'X-Men: Days of Future Past','film',131,to_date('23-may-2014','dd-mon-yyyy'),12,200000000);
insert into media
values(54,3,'X-Men: Apocalypse','film',144,to_date('27-may-2016','dd-mon-yyyy'),12,178000000);
insert into media
values(55,3,'Logan','film',137,to_date('3-mar-2017','dd-mon-yyyy'),15,97000000);
insert into media
values(56,3,'X-Men: Dark Phoenix','film',113,to_date('7-jun-2019','dd-mon-yyyy'),12,200000000);
---------------
insert into media
values(57,3,'Deadpool','film',108,to_date('12-feb-2016','dd-mon-yyyy'),15,58000000);
insert into media
values(58,3,'Deadpool 2','film',119,to_date('18-may-2018','dd-mon-yyyy'),15,110000000);
---------------------------------------
insert into media
values(59,3,'Avatar','film',162,to_date('18-dec-2009','dd-mon-yyyy'),12,237000000);
insert into media
values(60,3,'Avatar: The Way of Water','film',192,to_date('16-dec-2022','dd-mon-yyyy'),12,350000000);
---------------------------
insert into media
values(61,3,'Prison Break','serial',null,to_date('29-oct-2005','dd-mon-yyyy'),12,180000000);
----------------
--------------4 = columbia pictures-----------
insert into media
values(62,4,'The Karate Kid','film',126,to_date('22-jun-1984','dd-mon-yyyy'),12,8500000);
insert into media
values(63,4,'The Karate Kid Part II','film',113,to_date('20-jun-1986','dd-mon-yyyy'),12,13000000);
insert into media
values(64,4,'The Karate Kid Part III','film',112,to_date('30-jun-1989','dd-mon-yyyy'),12,12000000);
insert into media
values(65,4,'The Next Karate Kid','film',107,to_date('3-sep-1994','dd-mon-yyyy'),12,12000000);
insert into media
values(66,4,'The Karate Kid','film',140,to_date('11-jun-2010','dd-mon-yyyy'),12,40000000);
---------------
insert into media
values(67,4,'Men in Black', 'film',98,to_date('2-jul-1997','dd-mon-yyyy'),12,90000000);
insert into media
values(68,4,'Men in Black II','film',88,to_date('3-jul-2002','dd-mon-yyyy'),12,140000000);
insert into media
values(69,4,'Men in Black 3','film',106,to_date('25-may-2012','dd-mon-yyyy'),12,225000000);
insert into media
values(70,4,'Men in Black: International','film',114,to_date('14-jun-2019','dd-mon-yyyy'),12,110000000);
-------------
-----------6 = disney ------------------
insert into media
values(71,6,'Paperman','scurtmetraj',7,to_date('1-jun-2005','dd-mon-yyyy'),12,5000000);
-------------
insert into media
values(72,6,'The Imagineering Story','documentar',null,to_date('12-nov-2019','dd-mon-yyyy'),12,5000000);
------------
insert into media
values(73,6,'Toy Story','film',81,to_date('22-nov-1995','dd-mon-yyyy'),12,30000000);
insert into media
values(74,6,'Toy Story 2','film',92,to_date('24-nov-1999','dd-mon-yyyy'),12,90000000);
insert into media
values(75,6,'Toy Story 3','film',103,to_date('18-jun-2010','dd-mon-yyyy'),12,200000000);
insert into media
values(76,6,'Toy Story 4','film',100,to_date('21-jun-2019','dd-mon-yyyy'),12,200000000);
------------
insert into media
values(77,6,'The Lion King','film',88,to_date('24-jun-1994','dd-mon-yyyy'),12,45000000);
insert into media
values(78,6,'The Lion King 2: Simba?s Pride','film',81,to_date('27-oct-1998','dd-mon-yyyy'),12,25000000);
--------------
insert into media
values(79,6,'Frozen','film',102,to_date('27-nov-2013','dd-mon-yyyy'),12,150000000);
insert into media
values(80,6,'Frozen II','film',103,to_date('22-nov-2019','dd-mon-yyyy'),12,150000000);
----------------
insert into media
values(81,6,'Pirates of the Caribbean: TheCurseoftheBlackPearl','film',143,to_date('9-jul-2003','dd-mon-yyyy'),12,140000000);
insert into media
values(82,6,'Pirates of the Caribbean: Dead Man?s Chest','film',151,to_date('7-jul-2006','dd-mon-yyyy'),12,225000000);
insert into media
values(83,6,'Pirates of the Caribbean: At World?s End','film',169,to_date('25-may-2007','dd-mon-yyyy'),12,300000000);
insert into media
values(84,6,'Pirates of the Caribbean: On Stranger Tides','film',137,to_date('20-may-2011','dd-mon-yyyy'),12,379000000);
insert into media
values(85,6,'Pirates of the Caribbean: Dead Men Tell No Tales','film',129,to_date('26-may-2017','dd-mon-yyyy'),12,230000000);
----------------
insert into media
values(86,6,'The Mandalorian','serial',null,to_date('12-nov-2019','dd-mon-yyyy'),12,220000000);
---------------
-------------7 = Lionsgate Films-----
insert into media
values(87,7,'The Hunger Games','film',142,to_date('23-mar-2012','dd-mon-yyyy'),12,78000000);
insert into media
values(88,7,'The Hunger Games: Catching Fire','film',146,to_date('22-nov-2013','dd-mon-yyyy'),12,130000000);
insert into media
values(89,7,'The Hunger Games: Mockingjay ? Part 1','film',123,to_date('21-nov-2014','dd-mon-yyyy'),12,125000000);
insert into media
values(90,7,'The Hunger Games: Mockingjay ? Part 2','film',137,to_date('20-nov-2015','dd-mon-yyyy'),12,160000000);
--------------
insert into media
values(91,7,'John Wick','film',101,to_date('24-oct-2014','dd-mon-yyyy'),12,20000000);
insert into media
values(92,7,'John Wick: Chapter 2','film',122,to_date('10-feb-2017','dd-mon-yyyy'),12,40000000);
insert into media
values(93,7,'John Wick: Chapter 3 ? Parabellum','film',131,to_date('17-may-2019','dd-mon-yyyy'),12,75000000);
insert into media
values(94,7,'John Wick: Chapter 4','film',169,to_date('24-mar-2023','dd-mon-yyyy'),12,100000000);
--------------
-------8 = focus features-----
insert into media
values(95,8,'Darkest Hour','film',125,to_date('22-nov-2017','dd-mon-yyyy'),12,30000000);
-------10 = netflix ------
insert into media
values(96,10,'La Casa de Papel','serial',null,to_date('2-may-2017','dd-mon-yyyy'),18,15000000);
-----------
insert into media
values(97,10,'Narcos','serial',null,to_date('28-aug-2015','dd-mon-yyyy'),18,45000000);
-----------
insert into media
values(98,10,'Squid Game','serial',null,to_date('17-sep-2021','dd-mon-yyyy'),18,21000000);
----------
insert into media
values(99,10,'Stranger Things','serial',null,to_date('15-jul-2016','dd-mon-yyyy'),16,30000000);
------
insert into media
values(100,10,'Inside the Mind of a Cat','documentar',80,to_date('18-may-2022','dd-mon-yyyy'),0,5000000);
-------11 = sony pictures-----
insert into media
values(101,11,'Spider-Man','film',121,to_date('3-may-2002','dd-mon-yyyy'),12,139000000);
insert into media
values(102,11,'Spider-Man 2','film',127,to_date('30-jun-2004','dd-mon-yyyy'),12,200000000);
insert into media
values(103,11,'Spider-Man 3','film',139,to_date('4-may-2007','dd-mon-yyyy'),12,258000000);
insert into media
values(104,11,'The Amazing Spider-Man','film',136,to_date('3-jul-2012','dd-mon-yyyy'),12,230000000);
insert into media
values(105,11,'The Amazing Spider-Man 2','film',142,to_date('2-may-2014','dd-mon-yyyy'),12,200000000);
commit;

------13 = Friends
insert into sezon
values(1,13,1,to_date('22-sep-1994','dd-mon-yyyy'));
insert into sezon
values(2,13,2,to_date('21-sep-1995','dd-mon-yyyy'));
insert into sezon
values(3,13,3,to_date('19-sep-1996','dd-mon-yyyy'));
---------------
---------14 = game of thrones
insert into sezon
values(4,14,1,to_date('17-apr-2011','dd-mon-yyyy'));
insert into sezon
values(5,14,2,to_date('1-apr-2012','dd-mon-yyyy'));
insert into sezon
values(6,14,3,to_date('31-mar-2013','dd-mon-yyyy'));
insert into sezon
values(7,14,4,to_date('6-apr-2014','dd-mon-yyyy'));
--------------
-------72 = imagineering story
insert into sezon
values(8,72,1,to_date('12-nov-2019','dd-mon-yyyy'));
---------------
---------86 = the mandalorian
insert into sezon
values(9,86,1,to_date('12-nov-2019','dd-mon-yyyy'));
insert into sezon
values(10,86,2,to_date('30-oct-2020','dd-mon-yyyy'));
insert into sezon
values(11,86,3,to_date('1-mar-2023','dd-mon-yyyy'));
----------------
--------96 = casa de papel
insert into sezon
values(12,96,1,to_date('2-may-2017','dd-mon-yyyy'));
insert into sezon
values(13,96,2,to_date('16-oct-2017','dd-mon-yyyy'));
insert into sezon
values(14,96,3,to_date('19-jul-2019','dd-mon-yyyy'));
insert into sezon
values(15,96,4,to_date('3-apr-2020','dd-mon-yyyy'));
insert into sezon
values(16,96,5,to_date('3-sep-2021','dd-mon-yyyy'));
-------------------
-----------97 = narcos
insert into sezon
values(17,97,1,to_date('28-aug-2015','dd-mon-yyyy'));
insert into sezon
values(18,97,2,to_date('2-sep-2016','dd-mon-yyyy'));
insert into sezon
values(19,97,3,to_date('1-sep-2017','dd-mon-yyyy'));
-------------------
---------98 = squid game
insert into sezon
values(20,98,1,to_date('17-sep-2021','dd-mon-yyyy'));
insert into sezon
values(21,98,2,to_date('26-dec-2024','dd-mon-yyyy'));
--------------------
--------99 = stranger things
insert into sezon
values(22,99,1,to_date('15-jul-2016','dd-mon-yyyy'));
insert into sezon
values(23,99,2,to_date('27-oct-2017','dd-mon-yyyy'));
insert into sezon
values(24,99,3,to_date('4-jul-2019','dd-mon-yyyy'));
insert into sezon
values(25,99,4,to_date('27-may-2022','dd-mon-yyyy'));

------friends sezon 1
insert into episod
values(1,1,1,22,null,to_date('22-sep-1994','dd-mon-yyyy'));
insert into episod
values(2,1,2,22,null,to_date('22-sep-1994','dd-mon-yyyy'));
insert into episod
values(3,1,3,22,null,to_date('22-sep-1994','dd-mon-yyyy'));
insert into episod
values(4,1,4,22,null,to_date('22-sep-1994','dd-mon-yyyy'));
insert into episod
values(5,1,5,22,null,to_date('22-sep-1994','dd-mon-yyyy'));
insert into episod
values(6,1,6,22,null,to_date('22-sep-1994','dd-mon-yyyy'));
insert into episod
values(7,1,7,22,null,to_date('22-sep-1994','dd-mon-yyyy'));
insert into episod
values(8,1,8,22,null,to_date('22-sep-1994','dd-mon-yyyy'));
insert into episod
values(9,1,9,22,null,to_date('22-sep-1994','dd-mon-yyyy'));
insert into episod
values(10,1,10,22,null,to_date('22-sep-1994','dd-mon-yyyy'));
insert into episod
values(11,1,11,22,null,to_date('22-sep-1994','dd-mon-yyyy'));
insert into episod
values(12,1,12,22,null,to_date('22-sep-1994','dd-mon-yyyy'));
insert into episod
values(13,1,13,22,null,to_date('22-sep-1994','dd-mon-yyyy'));
insert into episod
values(14,1,14,22,null,to_date('22-sep-1994','dd-mon-yyyy'));
insert into episod
values(15,1,15,22,null,to_date('22-sep-1994','dd-mon-yyyy'));
insert into episod
values(16,1,16,22,null,to_date('22-sep-1994','dd-mon-yyyy'));
insert into episod
values(17,1,17,22,null,to_date('22-sep-1994','dd-mon-yyyy'));
insert into episod
values(18,1,18,22,null,to_date('22-sep-1994','dd-mon-yyyy'));
insert into episod
values(19,1,19,22,null,to_date('22-sep-1994','dd-mon-yyyy'));
insert into episod
values(20,1,20,22,null,to_date('22-sep-1994','dd-mon-yyyy'));
insert into episod
values(21,1,21,22,null,to_date('22-sep-1994','dd-mon-yyyy'));
insert into episod
values(22,1,22,22,null,to_date('22-sep-1994','dd-mon-yyyy'));
-----------
------game of thrones sezoane 4,5,6,7
------sezon 1 -> id 4
insert into episod
values(23,4,1,62,'Winter Is Coming',to_date('17-apr-2011','dd-mon-yyyy'));
insert into episod
values(24,4,2,56,'The Kingsroad',to_date('17-apr-2011','dd-mon-yyyy'));
insert into episod
values(25,4,3,58,'Lord Snow',to_date('17-apr-2011','dd-mon-yyyy'));
insert into episod
values(26,4,4,59,'Cripples, Bastards, and Broken Things',to_date('17-apr-2011','dd-mon-yyyy'));
insert into episod
values(27,4,5,56,'The Wolf and the Lion',to_date('17-apr-2011','dd-mon-yyyy'));
insert into episod
values(28,4,6,53,'A Golden Crown',to_date('17-apr-2011','dd-mon-yyyy'));
insert into episod
values(29,4,7,60,'You Win or You Die',to_date('17-apr-2011','dd-mon-yyyy'));
insert into episod
values(30,4,8,53,'The Pointy End',to_date('17-apr-2011','dd-mon-yyyy'));
insert into episod
values(31,4,9,58,'Baelor',to_date('17-apr-2011','dd-mon-yyyy'));
insert into episod
values(32,4,10,60,'Fire and Blood',to_date('17-apr-2011','dd-mon-yyyy'));
-----------sezon 2-> id 5
insert into episod
values(33,5,1,55,'The North Remembers',to_date('1-apr-2012','dd-mon-yyyy'));
insert into episod
values(34,5,2,56,'The Night Lands',to_date('8-apr-2012','dd-mon-yyyy'));
insert into episod
values(35,5,3,56,'What Is Dead May Never Die',to_date('15-apr-2012','dd-mon-yyyy'));
insert into episod
values(36,5,4,56,'Garden of Bones',to_date('22-apr-2012','dd-mon-yyyy'));
insert into episod
values(37,5,5,55,'The Ghost of Harrenhal',to_date('29-apr-2012','dd-mon-yyyy'));
insert into episod
values(38,5,6,54,'The Prince of Winterfell',to_date('6-may-2012','dd-mon-yyyy'));
insert into episod
values(39,5,7,56,'A Man Without Honor',to_date('13-may-2012','dd-mon-yyyy'));
insert into episod
values(40,5,8,55,'The Prince of Winterfell',to_date('20-may-2012','dd-mon-yyyy'));
insert into episod
values(41,5,9,60,'Blackwater',to_date('27-may-2012','dd-mon-yyyy'));
insert into episod
values(42,5,10,63,'Valar Morghulis',to_date('3-jun-2012','dd-mon-yyyy'));
-----------sezon 3 -> id 6
insert into episod
values(43,6,1,60,'Valar Dohaeris',to_date('31-mar-2013','dd-mon-yyyy'));
insert into episod
values(44,6,2,58,'Dark Wings, Dark Words',to_date('7-apr-2013','dd-mon-yyyy'));
insert into episod
values(45,6,3,60,'Walk of Punishment',to_date('14-apr-2013','dd-mon-yyyy'));
insert into episod
values(46,6,4,58,'And Now His Watch Is Ended',to_date('21-apr-2013','dd-mon-yyyy'));
insert into episod
values(47,6,5,57,'Kissed by Fire',to_date('28-apr-2013','dd-mon-yyyy'));
insert into episod
values(48,6,6,58,'The Climb',to_date('5-may-2013','dd-mon-yyyy'));
insert into episod
values(49,6,7,59,'The Bear and the Maiden Fair',to_date('12-may-2013','dd-mon-yyyy'));
insert into episod
values(50,6,8,58,'Second Sons',to_date('19-may-2013','dd-mon-yyyy'));
insert into episod
values(51,6,9,60,'The Rains of Castamere',to_date('26-may-2013','dd-mon-yyyy'));
insert into episod
values(52,6,10,63,'Mhysa',to_date('2-jun-2013','dd-mon-yyyy'));
--------sezon 4 -> id 7
insert into episod
values(53,7,1,60,'Two Swords',to_date('6-apr-2014','dd-mon-yyyy'));
insert into episod
values(54,7,2,60,'The Lion and the Rose',to_date('13-apr-2014','dd-mon-yyyy'));
insert into episod
values(55,7,3,60,'Breaker of Chains',to_date('20-apr-2014','dd-mon-yyyy'));
insert into episod
values(56,7,4,59,'Oathkeeper',to_date('27-apr-2014','dd-mon-yyyy'));
insert into episod
values(57,7,5,60,'First of His Name',to_date('4-may-2014','dd-mon-yyyy'));
insert into episod
values(58,7,6,59,'The Laws of Gods and Men',to_date('11-may-2014','dd-mon-yyyy'));
insert into episod
values(59,7,7,60,'Mockingbird',to_date('18-may-2014','dd-mon-yyyy'));
insert into episod
values(60,7,8,60,'The Mountain and the Viper',to_date('25-may-2014','dd-mon-yyyy'));
insert into episod
values(61,7,9,60,'The Watchers on the Wall',to_date('1-jun-2014','dd-mon-yyyy'));
insert into episod
values(62,7,10,66,'The Children',to_date('8-jun-2014','dd-mon-yyyy'));
---------
---------imagineering story id sezon 8
insert into episod
values(63,8,1,60,'The Happiest Place on Earth',to_date('12-nov-2019','dd-mon-yyyy'));
insert into episod
values(64,8,2,60,'What Would Walt Do?',to_date('12-nov-2019','dd-mon-yyyy'));
insert into episod
values(65,8,3,60,'The Architecture of Reassurance',to_date('12-nov-2019','dd-mon-yyyy'));
insert into episod
values(66,8,4,60,'The Desert to the Sea',to_date('12-nov-2019','dd-mon-yyyy'));
insert into episod
values(67,8,5,60,'A Carousel of Progress',to_date('12-nov-2019','dd-mon-yyyy'));
insert into episod
values(68,8,6,60,'What''s Next?',to_date('12-nov-2019','dd-mon-yyyy'));
---------------------
-------mandalorian sezoane 9,10,11
insert into episod
values(69,9,1,39,'Chapter 1: The Mandalorian',to_date('12-nov-2019','dd-mon-yyyy'));
insert into episod
values(70,9,2,31,'Chapter 2: The Child',to_date('15-nov-2019','dd-mon-yyyy'));
insert into episod
values(71,9,3,33,'Chapter 3: The Sin',to_date('22-nov-2019','dd-mon-yyyy'));
insert into episod
values(72,9,4,38,'Chapter 4: Sanctuary',to_date('29-nov-2019','dd-mon-yyyy'));
insert into episod
values(73,9,5,40,'Chapter 5: The Gunslinger',to_date('6-dec-2019','dd-mon-yyyy'));
insert into episod
values(74,9,6,41,'Chapter 6: The Prisoner',to_date('13-dec-2019','dd-mon-yyyy'));
insert into episod
values(75,9,7,47,'Chapter 7: The Reckoning',to_date('18-dec-2019','dd-mon-yyyy'));
insert into episod
values(76,9,8,52,'Chapter 8: Redemption',to_date('27-dec-2019','dd-mon-yyyy'));
----sezon 2->id 10
insert into episod
values(77,10,1,54,'Chapter 9: The Marshal',to_date('30-oct-2020','dd-mon-yyyy'));
insert into episod
values(78,10,2,52,'Chapter 10: The Passenger',to_date('6-nov-2020','dd-mon-yyyy'));
insert into episod
values(79,10,3,47,'Chapter 11: The Heiress',to_date('13-nov-2020','dd-mon-yyyy'));
insert into episod
values(80,10,4,48,'Chapter 12: The Siege',to_date('20-nov-2020','dd-mon-yyyy'));
insert into episod
values(81,10,5,48,'Chapter 13: The Jedi',to_date('27-nov-2020','dd-mon-yyyy'));
insert into episod
values(82,10,6,47,'Chapter 14: The Tragedy',to_date('4-dec-2020','dd-mon-yyyy'));
insert into episod
values(83,10,7,49,'Chapter 15: The Believer',to_date('11-dec-2020','dd-mon-yyyy'));
insert into episod
values(84,10,8,53,'Chapter 16: The Rescue',to_date('18-dec-2020','dd-mon-yyyy'));
-----sezon 3->id 11
insert into episod
values(85,11,1,45,'Chapter 17: The Apostate',to_date('1-mar-2023','dd-mon-yyyy'));
insert into episod
values(86,11,2,43,'Chapter 18: The Mines of Mandalore',to_date('8-mar-2023','dd-mon-yyyy'));
insert into episod
values(87,11,3,41,'Chapter 19: The Convert',to_date('15-mar-2023','dd-mon-yyyy'));
insert into episod
values(88,11,4,44,'Chapter 20: The Foundling',to_date('22-mar-2023','dd-mon-yyyy'));
insert into episod
values(89,11,5,45,'Chapter 21: The Pirate',to_date('29-mar-2023','dd-mon-yyyy'));
insert into episod
values(90,11,6,44,'Chapter 22: Guns for Hire',to_date('5-apr-2023','dd-mon-yyyy'));
insert into episod
values(91,11,7,46,'Chapter 23: The Spies',to_date('12-apr-2023','dd-mon-yyyy'));
insert into episod
values(92,11,8,51,'Chapter 24: The Return',to_date('19-apr-2023','dd-mon-yyyy'));
----------------
------casa de papel id sezoane 12,13,14,15,16
insert into episod
values(93,12,1,48,null,to_date('2-may-2017','dd-mon-yyyy'));
insert into episod
values(94,12,2,42,null,to_date('2-may-2017','dd-mon-yyyy'));
insert into episod
values(95,12,3,51,null,to_date('2-may-2017','dd-mon-yyyy'));
insert into episod
values(96,12,4,52,null,to_date('2-may-2017','dd-mon-yyyy'));
insert into episod
values(97,12,5,43,null,to_date('2-may-2017','dd-mon-yyyy'));
insert into episod
values(98,12,6,44,null,to_date('2-may-2017','dd-mon-yyyy'));
insert into episod
values(99,12,7,49,null,to_date('2-may-2017','dd-mon-yyyy'));
insert into episod
values(100,12,8,44,null,to_date('2-may-2017','dd-mon-yyyy'));
insert into episod
values(101,12,9,43,null,to_date('2-may-2017','dd-mon-yyyy'));
insert into episod
values(102,12,10,55,null,to_date('2-may-2017','dd-mon-yyyy'));
insert into episod
values(103,12,11,43,null,to_date('2-may-2017','dd-mon-yyyy'));
insert into episod
values(104,12,12,44,null,to_date('2-may-2017','dd-mon-yyyy'));
insert into episod
values(105,12,13,56,null,to_date('2-may-2017','dd-mon-yyyy'));
-----sezonul 2 id->13
insert into episod
values(106,13,1,44,null,to_date('16-oct-2017','dd-mon-yyyy'));
insert into episod
values(107,13,2,42,null,to_date('16-oct-2017','dd-mon-yyyy'));
insert into episod
values(108,13,3,45,null,to_date('16-oct-2017','dd-mon-yyyy'));
insert into episod
values(109,13,4,51,null,to_date('16-oct-2017','dd-mon-yyyy'));
insert into episod
values(110,13,5,44,null,to_date('16-oct-2017','dd-mon-yyyy'));
insert into episod
values(111,13,6,46,null,to_date('16-oct-2017','dd-mon-yyyy'));
insert into episod
values(112,13,7,45,null,to_date('16-oct-2017','dd-mon-yyyy'));
insert into episod
values(113,13,8,50,null,to_date('16-oct-2017','dd-mon-yyyy'));
insert into episod
values(114,13,9,45,null,to_date('16-oct-2017','dd-mon-yyyy'));
-----sezonul 3 id->14
insert into episod
values(115,14,1,51,'Ne-am intors',to_date('19-jul-2019','dd-mon-yyyy'));
insert into episod
values(116,14,2,42,'Aikido',to_date('19-jul-2019','dd-mon-yyyy'));
insert into episod
values(117,14,3,49,'48 de metri in subteran',to_date('19-jul-2019','dd-mon-yyyy'));
insert into episod
values(118,14,4,44,'Bum, Bum, Ciao',to_date('19-jul-2019','dd-mon-yyyy'));
insert into episod
values(119,14,5,50,'Cutiile rosii',to_date('19-jul-2019','dd-mon-yyyy'));
insert into episod
values(120,14,6,47,'Nu a mai contat',to_date('19-jul-2019','dd-mon-yyyy'));
insert into episod
values(121,14,7,45,'O mica vacanta',to_date('19-jul-2019','dd-mon-yyyy'));
insert into episod
values(122,14,8,59,'Razna',to_date('19-jul-2019','dd-mon-yyyy'));
------sezonul 4->id 15
insert into episod
values(123,15,1,53,'Jocul s-a terminat',to_date('3-apr-2020','dd-mon-yyyy'));
insert into episod
values(124,15,2,45,'Nunta lui Berlin',to_date('3-apr-2020','dd-mon-yyyy'));
insert into episod
values(125,15,3,43,'Lectie de anatomie',to_date('3-apr-2020','dd-mon-yyyy'));
insert into episod
values(126,15,4,54,'Pasodoble',to_date('3-apr-2020','dd-mon-yyyy'));
insert into episod
values(127,15,5,43,'Cu 5 minute mai devreme',to_date('3-apr-2020','dd-mon-yyyy'));
insert into episod
values(128,15,6,46,'KO tehnic',to_date('3-apr-2020','dd-mon-yyyy'));
insert into episod
values(129,15,7,53,'Tinteste cortul',to_date('3-apr-2020','dd-mon-yyyy'));
insert into episod
values(130,15,8,61,'Planul lui Paris',to_date('3-apr-2020','dd-mon-yyyy'));
-----sezonul  5->id 16
insert into episod
values(131,16,1,49,'Capatul Drumului',to_date('3-sep-2021','dd-mon-yyyy'));
insert into episod
values(132,16,2,52,'Crezi in reincarnare?',to_date('3-sep-2021','dd-mon-yyyy'));
insert into episod
values(133,16,3,49,'Bun venit la spectacolul vietii!',to_date('3-sep-2021','dd-mon-yyyy'));
insert into episod
values(134,16,4,51,'Un loc in rai',to_date('3-sep-2021','dd-mon-yyyy'));
insert into episod
values(135,16,5,55,'Poti trai mai multe vieti',to_date('3-sep-2021','dd-mon-yyyy'));
insert into episod
values(136,16,6,54,'Supapa',to_date('3-sep-2021','dd-mon-yyyy'));
insert into episod
values(137,16,7,54,'Iluzii',to_date('3-sep-2021','dd-mon-yyyy'));
insert into episod
values(138,16,8,49,'Teoria elegantei',to_date('3-sep-2021','dd-mon-yyyy'));
insert into episod
values(139,16,9,52,'Converstatii de dormitor',to_date('3-sep-2021','dd-mon-yyyy'));
insert into episod
values(140,16,10,76,'O traditie in familie',to_date('3-sep-2021','dd-mon-yyyy'));
---------------------
------squid game id sezoane 20, 21
insert into episod
values(141,20,1,60,'Rosu,Verde',to_date('17-sep-2021','dd-mon-yyyy'));
insert into episod
values(142,20,2,63,'Iad',to_date('17-sep-2021','dd-mon-yyyy'));
insert into episod
values(143,20,3,55,'Barbatul cu umbrela',to_date('17-sep-2021','dd-mon-yyyy'));
insert into episod
values(144,20,4,55,'Ramai cu echipa',to_date('17-sep-2021','dd-mon-yyyy'));
insert into episod
values(145,20,5,52,'O lume dreapta',to_date('17-sep-2021','dd-mon-yyyy'));
insert into episod
values(146,20,6,62,'Gganbu',to_date('17-sep-2021','dd-mon-yyyy'));
insert into episod
values(147,20,7,58,'VIP-uri',to_date('17-sep-2021','dd-mon-yyyy'));
insert into episod
values(148,20,8,33,'Omul din fata',to_date('17-sep-2021','dd-mon-yyyy'));
insert into episod
values(149,20,9,56,'O zi norocoasa',to_date('17-sep-2021','dd-mon-yyyy'));
-----sezon 2 -> id=21
insert into episod
values(150,21,1,65,'Paine si Loterie',to_date('26-dec-2024','dd-mon-yyyy'));
insert into episod
values(151,21,2,51,'Petrecere de Halloween',to_date('26-dec-2024','dd-mon-yyyy'));
insert into episod
values(152,21,3,61,'001',to_date('26-dec-2024','dd-mon-yyyy'));
insert into episod
values(153,21,4,62,'6 Picioare',to_date('26-dec-2024','dd-mon-yyyy'));
insert into episod
values(154,21,5,76,'Inca un joc',to_date('26-dec-2024','dd-mon-yyyy'));
insert into episod
values(155,21,6,52,'O X',to_date('26-dec-2024','dd-mon-yyyy'));
insert into episod
values(156,21,7,60,'Prieten sau Dusman',to_date('26-dec-2024','dd-mon-yyyy'));
commit;

insert into gen values(1,'Fantezie');
insert into gen values(2,'Aventura');
insert into gen values(3,'Drama');
insert into gen values(4,'Familie');
insert into gen values(5,'Mister');
insert into gen values(6,'Actiune');
insert into gen values(7,'Crima');
insert into gen values(8,'Thriller');
insert into gen values(9,'Supererou');
insert into gen values(10,'SF');
insert into gen values(11,'Suspans');
insert into gen values(12,'Comedie');
insert into gen values(13,'Romantism');
insert into gen values(14,'Razboi');
insert into gen values(15,'Politica');
insert into gen values(16,'Animatie');
insert into gen values(17,'Groaza');
insert into gen values(18,'Spionaj');
insert into gen values(19,'Istoric');
insert into gen values(20,'Western');
insert into gen values(21,'Arte martiale');
insert into gen values(22,'Sport');
insert into gen values(23,'Musical');
insert into gen values(24,'Distopie');
insert into gen values(25,'Biografic');
insert into gen values(26,'Supravietuire');
insert into gen values(27,'Documentar');
insert into gen values(28,'Natura');
insert into gen values(29,'Animal');
insert into gen values(30,'Psihologic');
insert into gen values(31,'Steampunk');
insert into gen values(32,'Post-apocaliptic');
commit;

-----------hp
insert into media_gen (id_media, id_gen)
with media_ids as (
  select 1 as id_media from dual
  union all
  select 2 from dual
  union all
  select 3 from dual
  union all
  select 4 from dual
  union all
  select 5 from dual
  union all
  select 6 from dual
  union all
  select 7 from dual
  union all
  select 8 from dual
),
gen_ids as (
  select 1 as id_gen from dual
  union all
  select 2 from dual
  union all
  select 3 from dual
  union all
  select 4 from dual
  union all
  select 5 from dual
  union all
  select 6 from dual
)
select m.id_media, g.id_gen
from media_ids m
cross join gen_ids g;

--------------------- batman---------- 9,10,11 genuri 6,2,3,8,7
---casa de papel 96, squid game 98
insert into media_gen(id_media,id_gen)
with media_ids as (
    select 9 as id_media from dual
    union all
    select 10 from dual
    union all
    select 11 from dual
    union all
    select 96 from dual
    union all
    select 98 from dual
),
gen_ids as (
    select 6 as id_gen from dual
    union all
    select 2 from dual
    union all
    select 3 from dual
    union all
    select 8 from dual
    union all
    select 7 from dual
)
select m.id_media,g.id_gen
from media_ids m cross join gen_ids g;
------------inception
insert into media_gen
values(12,6);
insert into media_gen
values(12,2);
insert into media_gen
values(12,10);
insert into media_gen
values(12,8);
insert into media_gen
values(12,5);
insert into media_gen
values(12,11);
-------------
------friends
insert into media_gen values(13,3);
insert into media_gen values(13,12);
insert into media_gen values(13,13);
-----game ef thrones
insert into media_gen values(14,1);
insert into media_gen values(14,2);
insert into media_gen values(14,3);
insert into media_gen values(14,6);
insert into media_gen values(14,15);

-------fantstic beasts 19,20,21 genuri 1,2,4,5
insert into media_gen (id_media, id_gen)
with media_ids as (
  select 19 as id_media from dual
  union all
  select 20 from dual
  union all
  select 21 from dual
),
gen_ids as (
  select 1 as id_gen from dual
  union all
  select 2 from dual
  union all
  select 4 from dual
  union all
  select 5 from dual
)
select m.id_media, g.id_gen
from media_ids m
cross join gen_ids g;

-------jurassic park 22-27 genuri 2,6,10,8
insert into media_gen (id_media, id_gen)
with media_ids as (
  select 22 as id_media from dual
  union all
  select 23 from dual
  union all
  select 24 from dual
  union all
  select 25 from dual
  union all
  select 26 from dual
  union all
  select 27 from dual
),
gen_ids as (
  select 2 as id_gen from dual
  union all
  select 6 from dual
  union all
  select 10 from dual
  union all
  select 8 from dual
)
select m.id_media, g.id_gen
from media_ids m
cross join gen_ids g;


-----fast and furious 28-35 genuri 2,6,7,8
insert into media_gen (id_media, id_gen)
with media_ids as (
  select 28 as id_media from dual
  union all
  select 29 from dual
  union all
  select 30 from dual
  union all
  select 31 from dual
  union all
  select 32 from dual
  union all
  select 33 from dual
  union all
  select 34 from dual
  union all
  select 35 from dual
),
gen_ids as (
  select 2 as id_gen from dual
  union all
  select 6 from dual
  union all
  select 7 from dual
  union all
  select 8 from dual
)
select m.id_media, g.id_gen
from media_ids m
cross join gen_ids g;


--------minionii 36-40 genuri 4,2,16,12
insert into media_gen (id_media, id_gen)
with media_ids as (
  select 36 as id_media from dual
  union all
  select 37 from dual
  union all
  select 38 from dual
  union all
  select 39 from dual
  union all
  select 40 from dual
),
gen_ids as (
  select 2 as id_gen from dual
  union all
  select 16 from dual
  union all
  select 4 from dual
  union all
  select 12 from dual
)
select m.id_media, g.id_gen
from media_ids m
cross join gen_ids g;

-----back to the future 41 genuri 1,2,12
insert into media_gen values(41,1);
insert into media_gen values(41,2);
insert into media_gen values(41,12);

-----muumy 42 genuri 2,1,6,17
insert into media_gen values(42,1);
insert into media_gen values(42,2);
insert into media_gen values(42,6);
insert into media_gen values(42,17);

-------the martian 43 genuri 2,3,10
insert into media_gen values(43,2);
insert into media_gen values(43,3);
insert into media_gen values(43,10);

-----kingsman 44 genuri 2,6,12,18
insert into media_gen values(44,2);
insert into media_gen values(44,6);
insert into media_gen values(44,12);
insert into media_gen values(44,18);

----titanic 45 genuri 3,13,2,19
insert into media_gen values(45,3);
insert into media_gen values(45,13);
insert into media_gen values(45,2);
insert into media_gen values(45,19);

---nigh at museum 46-48, 2,12,1,4
insert into media_gen (id_media, id_gen)
with media_ids as (
  select 46 as id_media from dual
  union all
  select 47 from dual
  union all
  select 48 from dual
),
gen_ids as (
  select 1 as id_gen from dual
  union all
  select 2 from dual
  union all
  select 4 from dual
  union all
  select 12 from dual
)
select m.id_media, g.id_gen
from media_ids m
cross join gen_ids g;

---------x-men 49-56 deadpool 57,58 genuri 6,1,10,3,9
insert into media_gen (id_media, id_gen)
with media_ids as (
  select 49 as id_media from dual
  union all
  select 50 from dual
  union all
  select 51 from dual
  union all
  select 52 from dual
  union all
  select 53 from dual
  union all
  select 54 from dual
  union all
  select 55 from dual
  union all
  select 56 from dual
  union all
  select 57 from dual
  union all
  select 58 from dual
),
gen_ids as (
  select 1 as id_gen from dual
  union all
  select 3 from dual
  union all
  select 6 from dual
  union all
  select 9 from dual
  union all
  select 10 from dual
)
select m.id_media, g.id_gen
from media_ids m
cross join gen_ids g;

-------avatar 59,60 genuri 1,2,3,6,10
insert into media_gen (id_media, id_gen)
with media_ids as (
  select 59 as id_media from dual
  union all
  select 60 from dual
),
gen_ids as (
  select 1 as id_gen from dual
  union all
  select 2 from dual
  union all
  select 3 from dual
  union all
  select 6 from dual
  union all
  select 10 from dual
)
select m.id_media, g.id_gen
from media_ids m
cross join gen_ids g;

---prison break 61, genuri 3,5,6,7,8
insert into media_gen values(61,3);
insert into media_gen values(61,5);
insert into media_gen values(61,7);
insert into media_gen values(61,8);
insert into media_gen values(61,6);

-----karate kid 62-66 genuri 3,6,21,22
insert into media_gen (id_media, id_gen)
with media_ids as (
  select 62 as id_media from dual
  union all
  select 63 from dual
  union all
  select 64 from dual
  union all
  select 65 from dual
  union all
  select 66 from dual
),
gen_ids as (
  select 6 as id_gen from dual
  union all
  select 3 from dual
  union all
  select 21 from dual
  union all
  select 22 from dual
)
select m.id_media, g.id_gen
from media_ids m
cross join gen_ids g;


-----men in black 67-70 genuri 10,12,6,1,2
insert into media_gen (id_media, id_gen)
with media_ids as (
  select 67 as id_media from dual
  union all
  select 68 from dual
  union all
  select 69 from dual
  union all
  select 70 from dual
),
gen_ids as (
  select 1 as id_gen from dual
  union all
  select 2 from dual
  union all
  select 6 from dual
  union all
  select 12 from dual
  union all
  select 10 from dual
)
select m.id_media, g.id_gen
from media_ids m
cross join gen_ids g;


---paperman 71 genrui 12,13,16
insert into media_gen values(71,12);
insert into media_gen values(71,13);
insert into media_gen values(71,16);

----imagine story 72 genuri 19,27
insert into media_gen values(72,19);
insert into media_gen values(72,27);

-----toy story 73-76 genuri 12,4,1,2,16
insert into media_gen (id_media, id_gen)
with media_ids as (
  select 73 as id_media from dual
  union all
  select 74 from dual
  union all
  select 75 from dual
  union all
  select 76 from dual
),
gen_ids as (
  select 1 as id_gen from dual
  union all
  select 2 from dual
  union all
  select 4 from dual
  union all
  select 12 from dual
  union all
  select 16 from dual
)
select m.id_media, g.id_gen
from media_ids m
cross join gen_ids g;

----frozen lion king 77-80 genuri 16,2,3,4,23
insert into media_gen (id_media, id_gen)
with media_ids as (
  select 77 as id_media from dual
  union all
  select 78 from dual
  union all
  select 79 from dual
  union all
  select 80 from dual
),
gen_ids as (
  select 3 as id_gen from dual
  union all
  select 2 from dual
  union all
  select 4 from dual
  union all
  select 23 from dual
  union all
  select 16 from dual
)
select m.id_media, g.id_gen
from media_ids m
cross join gen_ids g;


--piratii din caraibe 81-85 genuri 1,2,4,6,12
insert into media_gen (id_media, id_gen)
with media_ids as (
  select 81 as id_media from dual
  union all
  select 82 from dual
  union all
  select 83 from dual
  union all
  select 84 from dual
  union all
  select 85 from dual
),
gen_ids as (
  select 1 as id_gen from dual
  union all
  select 2 from dual
  union all
  select 4 from dual
  union all
  select 6 from dual
  union all
  select 12 from dual
)
select m.id_media, g.id_gen
from media_ids m
cross join gen_ids g;

----the mandalorian 86 genuri 1,2,6,10
insert into media_gen (id_media, id_gen)
with media_ids as (
  select 86 as id_media from dual
),
gen_ids as (
  select 1 as id_gen from dual
  union all
  select 2 from dual
  union all
  select 10 from dual
  union all
  select 6 from dual
)
select m.id_media, g.id_gen
from media_ids m
cross join gen_ids g;

----john wick 91,92,93,94 genuri 6,7,8,1,3
insert into media_gen (id_media, id_gen)
with media_ids as (
  select 91 as id_media from dual
  union all
  select 92 from dual
  union all
  select 93 from dual
  union all
  select 94 from dual
),
gen_ids as (
  select 1 as id_gen from dual
  union all
  select 3 from dual
  union all
  select 7 from dual
  union all
  select 6 from dual
  union all
  select 8 from dual
)
select m.id_media, g.id_gen
from media_ids m
cross join gen_ids g;
commit;

insert into tip_abonament
values(1,'solo',19.99,209.99,1,0,1);
insert into tip_abonament
values(2,'solo ad_free',24.99,249.99,0,0,1);
insert into tip_abonament
values(3,'solo offline',29.99,279.99,0,1,1);

insert into tip_abonament
values(4,'dup',34.99,359.99,1,0,2);
insert into tip_abonament
values(5,'duo ad_free',39.99,419.99,0,0,2);
insert into tip_abonament
values(6,'duo offline',44.99,469.99,0,1,2);

insert into tip_abonament
values(7,'trio',49.99,null,1,0,3);
insert into tip_abonament
values(8,'trio ad_free',54.99,null,0,0,3);
insert into tip_abonament
values(9,'trio offline',59.99,null,0,1,3);

insert into tip_abonament
values(10,'squad',64.99,null,1,0,4);
insert into tip_abonament
values(11,'squad ad_free',69.99,null,0,0,4);
insert into tip_abonament
values(12,'squad offline',74.99,null,0,1,4);
commit;

insert into utilizator values (1, 'Ion', 'Popescu', 'ion.popescu@gmail.com', to_date('15-mar-1995','dd-mon-yyyy'), to_date('12-may-2021','dd-mon-yyyy'), 'romana', 'Banca Transilvania', '1234567812345678', to_date('10-mar-2024','dd-mon-yyyy'), '823');
insert into utilizator values (2, 'Maria', 'Ionescu', 'maria.ionescu@gmail.com', to_date('23-jul-1990','dd-mon-yyyy'), to_date('5-aug-2020','dd-mon-yyyy'), 'romana', 'Raiffeisen Bank', '2345678923456789', to_date('22-sep-2023','dd-mon-yyyy'), '123');
insert into utilizator values (3, 'Mihai', 'Popescu', 'mihai.popescu@yahoo.com', to_date('25-jan-1998','dd-mon-yyyy'), to_date('21-mar-2020','dd-mon-yyyy'), 'romana', 'Raiffeisen Bank', '3456789034567890', to_date('15-apr-2024','dd-mon-yyyy'), '456');
insert into utilizator values (4, 'Alice', 'Johnson', 'alice.johnson@yahoo.com', to_date('18-jul-1992','dd-mon-yyyy'), to_date('5-aug-2019','dd-mon-yyyy'), 'engleza', 'UniCredit Bank', '4567890145678901', to_date('22-aug-2023','dd-mon-yyyy'), '738');
insert into utilizator values (5, 'James', 'Smith', 'james.smith@gmail.com', to_date('2-sep-1990','dd-mon-yyyy'), to_date('15-mar-2021','dd-mon-yyyy'), 'engleza', 'Bank of America', '5678901256789012', to_date('10-mar-2024','dd-mon-yyyy'), '234');
insert into utilizator values (6, 'Luca', 'Muller', 'luca.muller@yahoo.com', to_date('5-mar-1992','dd-mon-yyyy'), to_date('1-jun-2020','dd-mon-yyyy'), 'germana', 'Deutsche Bank', '6789012367890123', to_date('22-jul-2023','dd-mon-yyyy'), '876');
insert into utilizator values (7, 'Franco', 'Bianchi', 'franco.bianchi@yahoo.com', to_date('10-jan-1995','dd-mon-yyyy'), to_date('15-apr-2021','dd-mon-yyyy'), 'italiana', 'UniCredit Bank', '7890123478901234', to_date('10-may-2024','dd-mon-yyyy'), '567');
insert into utilizator values (8, 'Sophie', 'Durand', 'sophie.durand@yahoo.com', to_date('8-mar-1994','dd-mon-yyyy'), to_date('19-may-2021','dd-mon-yyyy'), 'franceza', 'Credit Agricole', '8901234589012345', to_date('15-jul-2023','dd-mon-yyyy'), '912');
insert into utilizator values (9, 'Juan', 'Martinez', 'juan.martinez@yahoo.com', to_date('12-apr-1993','dd-mon-yyyy'), to_date('28-aug-2020','dd-mon-yyyy'), 'spaniola', 'Banco Santander', '9012345690123456', to_date('30-sep-2023','dd-mon-yyyy'), '345');
insert into utilizator values (10, 'Carlos', 'Gomez', 'carlos.gomez@gmail.com', to_date('20-oct-1992','dd-mon-yyyy'), to_date('1-dec-2020','dd-mon-yyyy'), 'spaniola', 'BBVA', '0123456701234567', to_date('2-mar-2024','dd-mon-yyyy'), '234');
insert into utilizator values (11, 'Paulo', 'Silva', 'paulo.silva@gmail.com', to_date('14-jan-1994','dd-mon-yyyy'), to_date('18-apr-2021','dd-mon-yyyy'), 'portugheza', 'Caixa Geral de Depositos', '1234567812345678', to_date('30-may-2023','dd-mon-yyyy'), '765');
insert into utilizator values (12, 'Pedro', 'Costa', 'pedro.costa@yahoo.com', to_date('6-jul-1992','dd-mon-yyyy'), to_date('3-sep-2019','dd-mon-yyyy'), 'portugheza', 'Millennium BCP', '2345678923456789', to_date('12-aug-2023','dd-mon-yyyy'), '678');
insert into utilizator values (13, 'Michael', 'Williams', 'michael.williams@yahoo.com', to_date('28-apr-1990','dd-mon-yyyy'), to_date('20-sep-2019','dd-mon-yyyy'), 'engleza', 'Citibank', '3456789034567890', to_date('15-oct-2023','dd-mon-yyyy'), '145');
insert into utilizator values (14, 'Oliver', 'Brown', 'oliver.brown@gmail.com', to_date('18-jul-1991','dd-mon-yyyy'), to_date('2-oct-2020','dd-mon-yyyy'), 'engleza', 'HSBC', '4567890145678901', to_date('1-nov-2023','dd-mon-yyyy'), '876');
insert into utilizator values (15, 'Luca', 'Schmidt', 'luca.schmidt@yahoo.com', to_date('23-dec-1993','dd-mon-yyyy'), to_date('12-mar-2021','dd-mon-yyyy'), 'germana', 'Commerzbank', '5678901256789012', to_date('10-aug-2024','dd-mon-yyyy'), '123');
insert into utilizator values (16, 'Emma', 'Jones', 'emma.jones@yahoo.com', to_date('25-apr-1995','dd-mon-yyyy'), to_date('15-jan-2020','dd-mon-yyyy'), 'engleza', 'Lloyds Bank', '6789012367890123', to_date('5-jun-2023','dd-mon-yyyy'), '912');
insert into utilizator values (17, 'Marie', 'Dubois', 'marie.dubois@yahoo.com', to_date('8-jul-1991','dd-mon-yyyy'), to_date('22-aug-2020','dd-mon-yyyy'), 'franceza', 'Societe Generale', '7890123478901234', to_date('15-mar-2023','dd-mon-yyyy'), '456');
insert into utilizator values (18, 'Clara', 'Lopez', 'clara.lopez@yahoo.com', to_date('3-aug-1994','dd-mon-yyyy'), to_date('17-jul-2021','dd-mon-yyyy'), 'spaniola', 'CaixaBank', '8901234589012345', to_date('20-sep-2023','dd-mon-yyyy'), '315');
insert into utilizator values (19, 'Giovanni', 'Rossi', 'giovanni.rossi@yahoo.com', to_date('11-feb-1993','dd-mon-yyyy'), to_date('3-sep-2020','dd-mon-yyyy'), 'italiana', 'Intesa Sanpaolo', '9012345690123456', to_date('11-jul-2023','dd-mon-yyyy'), '235');
insert into utilizator values (20, 'John', 'Williams', 'john.williams@gmail.com', to_date('20-jun-1992','dd-mon-yyyy'), to_date('30-mar-2021','dd-mon-yyyy'), 'engleza', 'Barclays', '0123456701234567', to_date('7-apr-2024','dd-mon-yyyy'), '123');
insert into utilizator values (21, 'Isabella', 'Taylor', 'isabella.taylor@gmail.com', to_date('12-apr-1992','dd-mon-yyyy'), to_date('25-oct-2020','dd-mon-yyyy'), 'engleza', 'Chase Bank', '1234567812345678', to_date('5-jan-2024','dd-mon-yyyy'), '234');
insert into utilizator values (22, 'David', 'Wilson', 'david.wilson@yahoo.com', to_date('2-sep-1994','dd-mon-yyyy'), to_date('30-nov-2020','dd-mon-yyyy'), 'engleza', 'Wells Fargo', '2345678923456789', to_date('10-mar-2023','dd-mon-yyyy'), '456');
insert into utilizator values (23, 'Amelie', 'Lemoine', 'amelie.lemoine@gmail.com', to_date('15-feb-1991','dd-mon-yyyy'), to_date('12-apr-2021','dd-mon-yyyy'), 'franceza', 'BNP Paribas', '3456789034567890', to_date('2-jul-2024','dd-mon-yyyy'), '567');
insert into utilizator values (24, 'Pablo', 'Gonzalez', 'pablo.gonzalez@gmail.com', to_date('27-mar-1993','dd-mon-yyyy'), to_date('16-dec-2020','dd-mon-yyyy'), 'spaniola', 'Banco Sabadell', '4567890145678901', to_date('10-sep-2023','dd-mon-yyyy'), '678');
insert into utilizator values (25, 'Lucas', 'Martins', 'lucas.martins@yahoo.com', to_date('3-oct-1992','dd-mon-yyyy'), to_date('5-mar-2021','dd-mon-yyyy'), 'portugheza', 'Novo Banco', '5678901256789012', to_date('25-apr-2024','dd-mon-yyyy'), '709');
insert into utilizator values (26, 'Nina', 'Klein', 'nina.klein@gmail.com', to_date('4-nov-1991','dd-mon-yyyy'), to_date('15-aug-2020','dd-mon-yyyy'), 'germana', 'DZ Bank', '6789012367890123', to_date('7-sep-2023','dd-mon-yyyy'), '890');
insert into utilizator values (27, 'Charlie', 'Clark', 'charlie.clark@gmail.com', to_date('19-jun-1994','dd-mon-yyyy'), to_date('12-mar-2021','dd-mon-yyyy'), 'engleza', 'American Express', '7890123478901234', to_date('14-oct-2023','dd-mon-yyyy'), '234');
insert into utilizator values (28, 'Lena', 'Weber', 'lena.weber@yahoo.com', to_date('13-aug-1990','dd-mon-yyyy'), to_date('17-sep-2021','dd-mon-yyyy'), 'germana', 'Volksbank', '8901234589012345', to_date('19-jun-2023','dd-mon-yyyy'), '349');
insert into utilizator values (29, 'Esteban', 'Diaz', 'esteban.diaz@yahoo.com', to_date('9-jul-1992','dd-mon-yyyy'), to_date('30-jul-2020','dd-mon-yyyy'), 'spaniola', 'Banco de Espana', '9012345690123456', to_date('23-may-2023','dd-mon-yyyy'), '568');
insert into utilizator values (30, 'Leandro', 'Costa', 'leandro.costa@gmail.com', to_date('2-apr-1995','dd-mon-yyyy'), to_date('20-apr-2021','dd-mon-yyyy'), 'portugheza', 'Santander Totta', '0123456701234567', to_date('15-jul-2023','dd-mon-yyyy'), '678');
insert into utilizator values (31, 'Frederic', 'Hoffmann', 'frederic.hoffmann@yahoo.com', to_date('25-dec-1993','dd-mon-yyyy'), to_date('5-mar-2020','dd-mon-yyyy'), 'germana', 'HypoVereinsbank', '1234567812345678', to_date('12-mar-2023','dd-mon-yyyy'), '193');
insert into utilizator values (32, 'Claire', 'Martin', 'claire.martin@gmail.com', to_date('11-apr-1994','dd-mon-yyyy'), to_date('9-jul-2021','dd-mon-yyyy'), 'franceza', 'Credit Lyonnais', '2345678923456789', to_date('23-oct-2023','dd-mon-yyyy'), '233');
insert into utilizator values (33, 'Maya', 'Brown', 'maya.brown@yahoo.com', to_date('15-jul-1990','dd-mon-yyyy'), to_date('22-oct-2021','dd-mon-yyyy'), 'engleza', 'Bank of Ireland', '3456789034567890', to_date('1-sep-2023','dd-mon-yyyy'), '486');
insert into utilizator values (34, 'Marta', 'Sanchez', 'marta.sanchez@gmail.com', to_date('3-mar-1992','dd-mon-yyyy'), to_date('7-aug-2021','dd-mon-yyyy'), 'spaniola', 'Bankinter', '4567890145678901', to_date('20-dec-2023','dd-mon-yyyy'), '178');
insert into utilizator values (35, 'Irene', 'Gonzalez', 'irene.gonzalez@gmail.com', to_date('9-sep-1995','dd-mon-yyyy'), to_date('19-mar-2022','dd-mon-yyyy'), 'spaniola', 'CaixaBank', '5677901256789012', to_date('5-aug-2023','dd-mon-yyyy'), '719');
insert into utilizator values (36, 'Alex', 'Taylor', 'alex.taylor@yahoo.com', to_date('12-aug-1991','dd-mon-yyyy'), to_date('21-oct-2020','dd-mon-yyyy'), 'engleza', 'Barclays', '6789012367890123', to_date('2-jul-2023','dd-mon-yyyy'), '800');
insert into utilizator values (37, 'Nicolas', 'Lemoine', 'nicolas.lemoine@gmail.com', to_date('5-oct-1990','dd-mon-yyyy'), to_date('10-mar-2020','dd-mon-yyyy'), 'franceza', 'Credit Mutuel', '7890123478901234', to_date('25-aug-2024','dd-mon-yyyy'), '123');
insert into utilizator values (38, 'Hugo', 'Garcia', 'hugo.garcia@gmail.com', to_date('12-jan-1992','dd-mon-yyyy'), to_date('16-apr-2021','dd-mon-yyyy'), 'spaniola', 'Banco Santander', '8901234589012345', to_date('19-dec-2023','dd-mon-yyyy'), '234');
insert into utilizator values (39, 'Pedro', 'Santos', 'pedro.santos@yahoo.com', to_date('21-sep-1991','dd-mon-yyyy'), to_date('5-may-2020','dd-mon-yyyy'), 'portugheza', 'Banco BPI', '9012345690123456', to_date('12-jun-2023','dd-mon-yyyy'), '567');
insert into utilizator values (40, 'Alice', 'Anderson', 'alice.anderson@gmail.com', to_date('18-feb-1994','dd-mon-yyyy'), to_date('15-may-2021','dd-mon-yyyy'), 'engleza', 'HSBC', '0123456701234567', to_date('25-jul-2023','dd-mon-yyyy'), '789');
insert into utilizator values (41, 'Maria', 'Silva', 'maria.silva@gmail.com', to_date('6-apr-1992','dd-mon-yyyy'), to_date('5-jul-2021','dd-mon-yyyy'), 'portugheza', 'Caixa Geral de Depositos', '1234567812345678', to_date('14-oct-2023','dd-mon-yyyy'), '456');
insert into utilizator values (42, 'Oliver', 'Martinez', 'oliver.martinez@yahoo.com', to_date('13-nov-1995','dd-mon-yyyy'), to_date('25-feb-2021','dd-mon-yyyy'), 'spaniola', 'Banco Bilbao Argentaria', '2345678923456789', to_date('23-mar-2023','dd-mon-yyyy'), '134');
insert into utilizator values (43, 'Laura', 'Schneider', 'laura.schneider@gmail.com', to_date('17-aug-1991','dd-mon-yyyy'), to_date('30-mar-2020','dd-mon-yyyy'), 'germana', 'Deutsche Bank', '3456789034567890', to_date('14-dec-2023','dd-mon-yyyy'), '305');
insert into utilizator values (44, 'Chloe', 'Morris', 'chloe.morris@gmail.com', to_date('19-dec-1993','dd-mon-yyyy'), to_date('13-nov-2020','dd-mon-yyyy'), 'engleza', 'Lloyds Bank', '4567890145678901', to_date('2-mar-2024','dd-mon-yyyy'), '567');
insert into utilizator values (45, 'Luis', 'Fernandez', 'luis.fernandez@gmail.com', to_date('1-may-1990','dd-mon-yyyy'), to_date('5-sep-2021','dd-mon-yyyy'), 'spaniola', 'Banco Popular', '5678001256789012', to_date('19-nov-2023','dd-mon-yyyy'), '789');
insert into utilizator values (46, 'Emilia', 'Perez', 'emilia.perez@yahoo.com', to_date('8-oct-1994','dd-mon-yyyy'), to_date('14-dec-2020','dd-mon-yyyy'), 'spaniola', 'La Caixa', '6789012367890123', to_date('23-mar-2023','dd-mon-yyyy'), '820');
insert into utilizator values (47, 'Victor', 'Muller', 'victor.muller@gmail.com', to_date('30-jun-1992','dd-mon-yyyy'), to_date('2-mar-2020','dd-mon-yyyy'), 'germana', 'Commerzbank', '7890123478901234', to_date('19-nov-2023','dd-mon-yyyy'), '224');
insert into utilizator values (48, 'Liam', 'Williams', 'liam.williams@yahoo.com', to_date('20-nov-1994','dd-mon-yyyy'), to_date('12-sep-2021','dd-mon-yyyy'), 'engleza', 'Royal Bank of Scotland', '8901224589012345', to_date('8-mar-2023','dd-mon-yyyy'), '345');
insert into utilizator values (49, 'Sophie', 'Olsen', 'sophie.olsen@gmail.com', to_date('11-feb-1990','dd-mon-yyyy'), to_date('28-may-2020','dd-mon-yyyy'), 'engleza', 'Barclays', '9012345690123456', to_date('15-oct-2023','dd-mon-yyyy'), '678');
insert into utilizator values (50, 'Mark', 'Evans', 'mark.evans@yahoo.com', to_date('3-jun-1993','dd-mon-yyyy'), to_date('15-jul-2021','dd-mon-yyyy'), 'engleza', 'Citibank', '0123356701234567', to_date('7-dec-2023','dd-mon-yyyy'), '799');
insert into utilizator values (51, 'Ella', 'King', 'ella.king@gmail.com', to_date('10-mar-1995','dd-mon-yyyy'), to_date('12-aug-2021','dd-mon-yyyy'), 'engleza', 'Capital One', '1234567812345678', to_date('22-dec-2023','dd-mon-yyyy'), '123');
insert into utilizator values (52, 'Oliver', 'Scott', 'oliver.scott@yahoo.com', to_date('21-apr-1990','dd-mon-yyyy'), to_date('30-sep-2021','dd-mon-yyyy'), 'engleza', 'Chase Bank', '2345678923456789', to_date('5-jul-2024','dd-mon-yyyy'), '236');
insert into utilizator values (53, 'Sophia', 'Jenkins', 'sophia.jenkins@gmail.com', to_date('12-jul-1993','dd-mon-yyyy'), to_date('16-may-2020','dd-mon-yyyy'), 'engleza', 'Bank of America', '3456789034567890', to_date('14-sep-2023','dd-mon-yyyy'), '395');
insert into utilizator values (54, 'James', 'Miller', 'james.miller@yahoo.com', to_date('2-feb-1992','dd-mon-yyyy'), to_date('3-oct-2021','dd-mon-yyyy'), 'engleza', 'Wells Fargo', '4567890145678901', to_date('30-aug-2023','dd-mon-yyyy'), '456');
insert into utilizator values (55, 'Chloe', 'Adams', 'chloe.adams@gmail.com', to_date('19-nov-1994','dd-mon-yyyy'), to_date('1-may-2020','dd-mon-yyyy'), 'engleza', 'American Express', '5678901256789012', to_date('10-apr-2023','dd-mon-yyyy'), '567');
insert into utilizator values (56, 'Liam', 'Nelson', 'liam.nelson@yahoo.com', to_date('14-mar-1991','dd-mon-yyyy'), to_date('20-jun-2021','dd-mon-yyyy'), 'engleza', 'Bank of Ireland', '6789012367890123', to_date('22-jul-2023','dd-mon-yyyy'), '678');
insert into utilizator values (57, 'Madison', 'Carter', 'madison.carter@gmail.com', to_date('5-jul-1993','dd-mon-yyyy'), to_date('12-apr-2021','dd-mon-yyyy'), 'engleza', 'Barclays', '7890123478901234', to_date('3-sep-2023','dd-mon-yyyy'), '789');
insert into utilizator values (58, 'Ethan', 'Moore', 'ethan.moore@yahoo.com', to_date('26-apr-1992','dd-mon-yyyy'), to_date('8-mar-2020','dd-mon-yyyy'), 'engleza', 'HSBC', '8901234589012345', to_date('5-jul-2023','dd-mon-yyyy'), '890');
insert into utilizator values (59, 'Abigail', 'Turner', 'abigail.turner@gmail.com', to_date('22-sep-1994','dd-mon-yyyy'), to_date('2-dec-2020','dd-mon-yyyy'), 'engleza', 'Citibank', '9012345690123456', to_date('16-oct-2023','dd-mon-yyyy'), '237');
insert into utilizator values (60, 'Benjamin', 'Young', 'benjamin.young@yahoo.com', to_date('16-oct-1995','dd-mon-yyyy'), to_date('24-apr-2021','dd-mon-yyyy'), 'engleza', 'Lloyds Bank', '0123456701234567', to_date('7-dec-2023','dd-mon-yyyy'), '568');
insert into utilizator values (61, 'Mihai', 'Popescu', 'mihai.popescu@gmail.com', to_date('10-aug-1992','dd-mon-yyyy'), to_date('1-mar-2020','dd-mon-yyyy'), 'romana', 'Banca Transilvania', '1234567812345678', to_date('15-sep-2023','dd-mon-yyyy'), '120');
insert into utilizator values (62, 'Ioana', 'Ionescu', 'ioana.ionescu@yahoo.com', to_date('21-apr-1991','dd-mon-yyyy'), to_date('12-apr-2021','dd-mon-yyyy'), 'romana', 'Raiffeisen Bank', '2345678923456789', to_date('30-aug-2023','dd-mon-yyyy'), '234');
insert into utilizator values (63, 'Andrei', 'Vasile', 'andrei.vasile@gmail.com', to_date('4-sep-1993','dd-mon-yyyy'), to_date('19-may-2020','dd-mon-yyyy'), 'romana', 'BCR', '3456789034567890', to_date('18-sep-2023','dd-mon-yyyy'), '345');
insert into utilizator values (64, 'Elena', 'Radu', 'elena.radu@yahoo.com', to_date('14-mar-1990','dd-mon-yyyy'), to_date('3-oct-2021','dd-mon-yyyy'), 'romana', 'UniCredit Bank', '4567890145678901', to_date('23-jul-2023','dd-mon-yyyy'), '454');
insert into utilizator values (65, 'Alexandra', 'Marin', 'alexandra.marin@gmail.com', to_date('1-aug-1994','dd-mon-yyyy'), to_date('22-oct-2021','dd-mon-yyyy'), 'romana', 'OTP Bank', '5678901256789011', to_date('12-aug-2023','dd-mon-yyyy'), '557');
insert into utilizator values (66, 'Stefan', 'Nistor', 'stefan.nistor@yahoo.com', to_date('17-nov-1995','dd-mon-yyyy'), to_date('5-dec-2021','dd-mon-yyyy'), 'romana', 'ING Bank', '6789012367890123', to_date('8-apr-2023','dd-mon-yyyy'), '628');
insert into utilizator values (67, 'Larisa', 'Dumitru', 'larisa.dumitru@gmail.com', to_date('22-apr-1992','dd-mon-yyyy'), to_date('15may2020','dd-mon-yyyy'), 'romana', 'BRD', '7890123478901234', to_date('21-jul-2023','dd-mon-yyyy'), '189');
insert into utilizator values (68, 'Florin', 'Petrescu', 'florin.petrescu@yahoo.com', to_date('9-aug-1990','dd-mon-yyyy'), to_date('27-jul-2021','dd-mon-yyyy'), 'romana', 'Alpha Bank', '8901234589012345', to_date('2-sep-2023','dd-mon-yyyy'), '899');
insert into utilizator values (69, 'Adrian', 'Munteanu', 'adrian.munteanu@gmail.com', to_date('4-mar-1993','dd-mon-yyyy'), to_date('20-jul-2021','dd-mon-yyyy'), 'romana', 'CEC Bank', '9012345690123456', to_date('15-oct-2023','dd-mon-yyyy'), '234');
insert into utilizator values (70, 'Gabriela', 'Stoica', 'gabriela.stoica@yahoo.com', to_date('19-dec-1994','dd-mon-yyyy'), to_date('2-mar-2020','dd-mon-yyyy'), 'romana', 'Piraeus Bank', '0123456701234567', to_date('6-aug-2023','dd-mon-yyyy'), '567');
commit;

insert into dispozitiv values (1, 1, 'telefon', 'Samsung Galaxy S21');
insert into dispozitiv values (2, 2, 'laptop', 'Dell XPS 13');
insert into dispozitiv values (3, 2, 'telefon', 'iPhone 12');
insert into dispozitiv values (4, 3, 'smart_tv', 'Samsung QLED 55"');
insert into dispozitiv values (5, 4, 'laptop', 'Apple MacBook Pro');
insert into dispozitiv values (6, 4, 'tableta', 'Apple iPad Pro');
insert into dispozitiv values (7, 5, 'laptop', 'Asus TUF F15');
insert into dispozitiv values (8, 6, 'telefon', 'Google Pixel 5');
insert into dispozitiv values (9, 7, 'smart_tv', 'LG OLED 65"');
insert into dispozitiv values (10, 8, 'laptop', 'HP Spectre x360');
insert into dispozitiv values (11, 9, 'desktop', 'HP Pavilion 24"');
insert into dispozitiv values (12, 9, 'consola', 'PlayStation 5');
insert into dispozitiv values (13, 10, 'laptop', 'Lenovo Legion 5');
insert into dispozitiv values (14, 10, 'telefon', 'OnePlus 8');
insert into dispozitiv values (15, 11, 'smart_tv', 'Sony Bravia 55"');
insert into dispozitiv values (16, 12, 'tableta', null);
insert into dispozitiv values (17, 13, 'telefon', 'Xiaomi Mi 11');
insert into dispozitiv values (18, 14, 'laptop', null);
insert into dispozitiv values (19, 14, 'smart_tv', null);
insert into dispozitiv values (20, 15, 'consola', 'Xbox Series X');
insert into dispozitiv values (21, 16, 'laptop', 'MSI GE76 Raider');
insert into dispozitiv values (22, 17, 'telefon', 'Motorola Edge Plus');
insert into dispozitiv values (23, 17, 'tableta', 'Huawei MatePad Pro');
insert into dispozitiv values (24, 18, 'smart_tv', 'Panasonic Viera 55"');
insert into dispozitiv values (25, 19, 'telefon', 'Nokia 8.3 5G');
insert into dispozitiv values (26, 20, 'desktop', null);
insert into dispozitiv values (27, 21, 'tableta', null);
insert into dispozitiv values (28, 22, 'laptop', 'Razer Blade 15');
insert into dispozitiv values (29, 22, 'consola', 'Nintendo Switch');
insert into dispozitiv values (30, 23, 'telefon', 'Samsung Galaxy A72');
insert into dispozitiv values (31, 24, 'smart_tv', 'TCL 55" 4K HDR');
insert into dispozitiv values (32, 25, 'desktop', 'Lenovo ThinkCentre');
insert into dispozitiv values (33, 26, 'telefon', 'Realme X50 Pro');
insert into dispozitiv values (34, 27, 'laptop', 'Gigabyte AERO 15');
insert into dispozitiv values (35, 28, 'tableta', 'Amazon Fire HD 10');
insert into dispozitiv values (36, 29, 'telefon', 'Sony Xperia 1 II');
insert into dispozitiv values (37, 30, 'desktop', null);
insert into dispozitiv values (38, 31, 'laptop', 'MSI GS66 Stealth');
insert into dispozitiv values (39, 32, 'smart_tv', 'Vizio 65" 4K');
insert into dispozitiv values (40, 33, 'laptop', 'HP Omen 15');
commit;

insert into utilizator_abonament values(1, 1, to_date('01-feb-2020', 'dd-mon-yyyy'), to_date('01-mar-2020', 'dd-mon-yyyy'));
insert into utilizator_abonament values(1, 2, to_date('02-mar-2020', 'dd-mon-yyyy'), to_date('02-apr-2020', 'dd-mon-yyyy'));
insert into utilizator_abonament values(1, 3, to_date('02-apr-2020', 'dd-mon-yyyy'), to_date('02-may-2020', 'dd-mon-yyyy'));
insert into utilizator_abonament values(1, 4, to_date('02-may-2020', 'dd-mon-yyyy'), to_date('02-jun-2020', 'dd-mon-yyyy'));
insert into utilizator_abonament values(1, 5, to_date('02-jul-2020', 'dd-mon-yyyy'), to_date('02-aug-2020', 'dd-mon-yyyy'));
insert into utilizator_abonament values(2, 3, to_date('15-feb-2021', 'dd-mon-yyyy'), to_date('15-mar-2021', 'dd-mon-yyyy'));
insert into utilizator_abonament values(2, 5, to_date('20-may-2021', 'dd-mon-yyyy'), to_date('20-jun-2021', 'dd-mon-yyyy'));
insert into utilizator_abonament values(2, 5, to_date('20-jun-2021', 'dd-mon-yyyy'), to_date('20-jul-2021', 'dd-mon-yyyy'));
insert into utilizator_abonament values(2, 5, to_date('20-jul-2021', 'dd-mon-yyyy'), to_date('20-aug-2021', 'dd-mon-yyyy'));
insert into utilizator_abonament values(3, 2, to_date('10-jun-2020', 'dd-mon-yyyy'), to_date('10-jul-2020', 'dd-mon-yyyy'));
insert into utilizator_abonament values(3, 4, to_date('10-jul-2020', 'dd-mon-yyyy'), to_date('10-aug-2020', 'dd-mon-yyyy'));
insert into utilizator_abonament values(3, 6, to_date('10-sep-2020', 'dd-mon-yyyy'), to_date('10-oct-2020', 'dd-mon-yyyy'));
insert into utilizator_abonament values(3, 6, to_date('10-oct-2020', 'dd-mon-yyyy'), to_date('10-oct-2021', 'dd-mon-yyyy'));
insert into utilizator_abonament values(4, 6, to_date('07-sep-2019', 'dd-mon-yyyy'), to_date('07-oct-2019', 'dd-mon-yyyy'));
insert into utilizator_abonament values(4, 9, to_date('07-oct-2019', 'dd-mon-yyyy'), to_date('07-nov-2019', 'dd-mon-yyyy'));
insert into utilizator_abonament values(4, 9, to_date('19-nov-2019', 'dd-mon-yyyy'), to_date('19-dec-2019', 'dd-mon-yyyy'));
insert into utilizator_abonament values(4, 9, to_date('23-dec-2019', 'dd-mon-yyyy'), to_date('23-dec-2020', 'dd-mon-yyyy'));
insert into utilizator_abonament values(4, 3, to_date('30-aug-2021', 'dd-mon-yyyy'), to_date('30-aug-2022', 'dd-mon-yyyy'));
insert into utilizator_abonament values(5, 11, to_date('01-dec-2020', 'dd-mon-yyyy'), to_date('01-jan-2021', 'dd-mon-yyyy'));
insert into utilizator_abonament values(5, 12, to_date('12-jan-2020', 'dd-mon-yyyy'), to_date('12-feb-2020', 'dd-mon-yyyy'));
insert into utilizator_abonament values(5, 12, to_date('12-feb-2020', 'dd-mon-yyyy'), to_date('12-feb-2021', 'dd-mon-yyyy'));
insert into utilizator_abonament values(6, 2, to_date('15-mar-2022', 'dd-mon-yyyy'), to_date('15-apr-2022', 'dd-mon-yyyy'));
insert into utilizator_abonament values(6, 8, to_date('22-apr-2022', 'dd-mon-yyyy'), to_date('22-may-2022', 'dd-mon-yyyy'));
insert into utilizator_abonament values(6, 9, to_date('22-may-2022', 'dd-mon-yyyy'), to_date('22-jun-2022', 'dd-mon-yyyy'));
insert into utilizator_abonament values(6, 9, to_date('22-jun-2022', 'dd-mon-yyyy'), to_date('22-jul-2022', 'dd-mon-yyyy'));
insert into utilizator_abonament values(6, 9, to_date('22-jul-2022', 'dd-mon-yyyy'), to_date('22-aug-2022', 'dd-mon-yyyy'));
insert into utilizator_abonament values(7, 1, to_date('09-nov-2018', 'dd-mon-yyyy'), to_date('09-dec-2018', 'dd-mon-yyyy'));
insert into utilizator_abonament values(7, 4, to_date('12-jan-2019', 'dd-mon-yyyy'), to_date('12-feb-2019', 'dd-mon-yyyy'));
insert into utilizator_abonament values(8, 5, to_date('15-aug-2021', 'dd-mon-yyyy'), to_date('15-sep-2021', 'dd-mon-yyyy'));
insert into utilizator_abonament values(8, 6, to_date('15-sep-2021', 'dd-mon-yyyy'), to_date('15-oct-2021', 'dd-mon-yyyy'));
insert into utilizator_abonament values(8, 6, to_date('15-oct-2021', 'dd-mon-yyyy'), to_date('15-nov-2021', 'dd-mon-yyyy'));
insert into utilizator_abonament values(8, 9, to_date('15-nov-2021', 'dd-mon-yyyy'), to_date('15-dec-2021', 'dd-mon-yyyy'));
insert into utilizator_abonament values(8, 6, to_date('15-jan-2022', 'dd-mon-yyyy'), to_date('15-feb-2022', 'dd-mon-yyyy'));
insert into utilizator_abonament values(9, 7, to_date('18-jun-2019', 'dd-mon-yyyy'), to_date('18-jul-2019', 'dd-mon-yyyy'));
insert into utilizator_abonament values(9, 3, to_date('23-aug-2019', 'dd-mon-yyyy'), to_date('23-sep-2019', 'dd-mon-yyyy'));
insert into utilizator_abonament values(10, 1, to_date('25-dec-2020', 'dd-mon-yyyy'), to_date('25-jan-2021', 'dd-mon-yyyy'));
insert into utilizator_abonament values(10, 6, to_date('25-jan-2021', 'dd-mon-yyyy'), to_date('25-feb-2021', 'dd-mon-yyyy'));
insert into utilizator_abonament values(10, 6, to_date('25-feb-2021', 'dd-mon-yyyy'), to_date('25-feb-2022', 'dd-mon-yyyy'));
insert into utilizator_abonament values(11, 2, to_date('07-oct-2021', 'dd-mon-yyyy'), to_date('07-nov-2021', 'dd-mon-yyyy'));
insert into utilizator_abonament values(11, 8, to_date('07-nov-2021', 'dd-mon-yyyy'), to_date('07-dec-2021', 'dd-mon-yyyy'));
insert into utilizator_abonament values(11, 8, to_date('07-dec-2021', 'dd-mon-yyyy'), to_date('07-dec-2022', 'dd-mon-yyyy'));
insert into utilizator_abonament values(12, 3, to_date('03-may-2022', 'dd-mon-yyyy'), to_date('03-jun-2022', 'dd-mon-yyyy'));
insert into utilizator_abonament values(12, 4, to_date('13-jun-2022', 'dd-mon-yyyy'), to_date('13-jul-2022', 'dd-mon-yyyy'));
insert into utilizator_abonament values(12, 5, to_date('13-jul-2022', 'dd-mon-yyyy'), to_date('13-aug-2022', 'dd-mon-yyyy'));
insert into utilizator_abonament values(12, 6, to_date('24-aug-2022', 'dd-mon-yyyy'), to_date('24-sep-2022', 'dd-mon-yyyy'));
insert into utilizator_abonament values(12, 6, to_date('24-sep-2022', 'dd-mon-yyyy'), to_date('24-oct-2022', 'dd-mon-yyyy'));
insert into utilizator_abonament values(12, 6, to_date('24-oct-2022', 'dd-mon-yyyy'), to_date('24-oct-2023', 'dd-mon-yyyy'));
insert into utilizator_abonament values(12, 6, to_date('24-oct-2023', 'dd-mon-yyyy'), to_date('24-oct-2024', 'dd-mon-yyyy'));
insert into utilizator_abonament values(12, 6, to_date('24-oct-2024', 'dd-mon-yyyy'), to_date('24-oct-2025', 'dd-mon-yyyy'));
insert into utilizator_abonament values(13, 6, to_date('01-jul-2020', 'dd-mon-yyyy'), to_date('01-aug-2020', 'dd-mon-yyyy'));
insert into utilizator_abonament values(13, 9, to_date('19-aug-2020', 'dd-mon-yyyy'), to_date('19-sep-2020', 'dd-mon-yyyy'));
insert into utilizator_abonament values(14, 7, to_date('02-feb-2021', 'dd-mon-yyyy'), to_date('02-mar-2021', 'dd-mon-yyyy'));
insert into utilizator_abonament values(14, 5, to_date('02-mar-2021', 'dd-mon-yyyy'), to_date('02-apr-2021', 'dd-mon-yyyy'));
insert into utilizator_abonament values(14, 6, to_date('02-apr-2021', 'dd-mon-yyyy'), to_date('02-apr-2022', 'dd-mon-yyyy'));
insert into utilizator_abonament values(15, 3, to_date('10-apr-2020', 'dd-mon-yyyy'), to_date('10-may-2020', 'dd-mon-yyyy'));
insert into utilizator_abonament values(15, 2, to_date('21-may-2020', 'dd-mon-yyyy'), to_date('21-jun-2020', 'dd-mon-yyyy'));
insert into utilizator_abonament values(16, 8, to_date('13-jan-2022', 'dd-mon-yyyy'), to_date('13-feb-2022', 'dd-mon-yyyy'));
insert into utilizator_abonament values(16, 6, to_date('13-feb-2022', 'dd-mon-yyyy'), to_date('13-mar-2022', 'dd-mon-yyyy'));
insert into utilizator_abonament values(17, 5, to_date('23-jul-2022', 'dd-mon-yyyy'), to_date('23-aug-2022', 'dd-mon-yyyy'));
insert into utilizator_abonament values(17, 9, to_date('30-sep-2022', 'dd-mon-yyyy'), to_date('30-sep-2023', 'dd-mon-yyyy'));
insert into utilizator_abonament values(17, 12, to_date('30-sep-2023', 'dd-mon-yyyy'), to_date('30-sep-2024', 'dd-mon-yyyy'));
insert into utilizator_abonament values(18, 7, to_date('19-dec-2019', 'dd-mon-yyyy'), to_date('19-jan-2020', 'dd-mon-yyyy'));
insert into utilizator_abonament values(18, 4, to_date('01-feb-2020', 'dd-mon-yyyy'), to_date('01-mar-2020', 'dd-mon-yyyy'));
insert into utilizator_abonament values(18, 3, to_date('01-mar-2020', 'dd-mon-yyyy'), to_date('01-apr-2020', 'dd-mon-yyyy'));
insert into utilizator_abonament values(18, 2, to_date('01-apr-2020', 'dd-mon-yyyy'), to_date('01-may-2020', 'dd-mon-yyyy'));
insert into utilizator_abonament values(19, 3, to_date('04-may-2022', 'dd-mon-yyyy'), to_date('04-jun-2022', 'dd-mon-yyyy'));
insert into utilizator_abonament values(19, 1, to_date('09-jun-2022', 'dd-mon-yyyy'), to_date('09-jul-2022', 'dd-mon-yyyy'));
insert into utilizator_abonament values(20, 9, to_date('01-mar-2023', 'dd-mon-yyyy'), to_date('01-apr-2023', 'dd-mon-yyyy'));
insert into utilizator_abonament values(20, 4, to_date('23-apr-2023', 'dd-mon-yyyy'), to_date('23-may-2023', 'dd-mon-yyyy'));
insert into utilizator_abonament values(21, 5, to_date('12-jul-2021', 'dd-mon-yyyy'), to_date('12-aug-2021', 'dd-mon-yyyy'));
insert into utilizator_abonament values(22, 3, to_date('11-oct-2020', 'dd-mon-yyyy'), to_date('11-oct-2021', 'dd-mon-yyyy'));
insert into utilizator_abonament values(22, 2, to_date('20-nov-2021', 'dd-mon-yyyy'), to_date('20-dec-2021', 'dd-mon-yyyy'));
insert into utilizator_abonament values(23, 7, to_date('07-apr-2020', 'dd-mon-yyyy'), to_date('07-may-2020', 'dd-mon-yyyy'));
commit;

insert into vizioneaza values(1,1,to_date('01-feb-2020', 'dd-mon-yyyy'),110);
insert into vizioneaza values(1,2,to_date('02-feb-2020', 'dd-mon-yyyy'),56);
insert into vizioneaza values(1,2,to_date('01-feb-2020', 'dd-mon-yyyy'),70);
insert into vizioneaza values(1,3,to_date('01-feb-2020', 'dd-mon-yyyy'),150);
insert into vizioneaza values(2,1,to_date('17-feb-2021', 'dd-mon-yyyy'),110);
insert into vizioneaza values(2,9,to_date('01-jun-2021', 'dd-mon-yyyy'),89);
insert into vizioneaza values(2,10,to_date('01-jun-2021', 'dd-mon-yyyy'),113);
insert into vizioneaza values(2,11,to_date('29-may-2021', 'dd-mon-yyyy'),123);
insert into vizioneaza values(2,9,to_date('13-feb-2021', 'dd-mon-yyyy'),66); 
insert into vizioneaza values(2,9,to_date('01-jun-2021', 'dd-mon-yyyy'),100);
insert into vizioneaza values(3,36,to_date('14-jun-2020', 'dd-mon-yyyy'),113); 
insert into vizioneaza values(3,37,to_date('31-jul-2020', 'dd-mon-yyyy'),92);
insert into vizioneaza values(3,12,to_date('15-sep-2020', 'dd-mon-yyyy'),156);
insert into vizioneaza values(3,90,to_date('18-sep-2020', 'dd-mon-yyyy'),100);
insert into vizioneaza values(4,8,to_date('01-dec-2019','dd-mon-yyyy'),110);
insert into vizioneaza values(4,14,to_date('05-oct-2019','dd-mon-yyyy'),115);
insert into vizioneaza values(5,19,to_date('23-jul-2020','dd-mon-yyyy'),125);
insert into vizioneaza values(5,35,to_date('27-aug-2020','dd-mon-yyyy'),140);
insert into vizioneaza values(6,25,to_date('26-apr-2022','dd-mon-yyyy'),101);
insert into vizioneaza values(6,47,to_date('17-aug-2022','dd-mon-yyyy'),120);
insert into vizioneaza values(7,2,to_date('21-nov-2018','dd-mon-yyyy'),135);
insert into vizioneaza values(7,10,to_date('25-jan-2019','dd-mon-yyyy'),97);
insert into vizioneaza values(8,9,to_date('14-oct-2021','dd-mon-yyyy'),150);
insert into vizioneaza values(8,55,to_date('22-oct-2021','dd-mon-yyyy'),130);
insert into vizioneaza values(9,30,to_date('22-jun-2019','dd-mon-yyyy'),140);
insert into vizioneaza values(9,18,to_date('22-jun-2019','dd-mon-yyyy'),64);
insert into vizioneaza values(9,13,to_date('23-jun-2019','dd-mon-yyyy'),46);
insert into vizioneaza values(9,19,to_date('24-jun-2019','dd-mon-yyyy'),54);
insert into vizioneaza values(9,75,to_date('25-jun-2019','dd-mon-yyyy'),59);
insert into vizioneaza values(10,6,to_date('25-apr-2021','dd-mon-yyyy'),125);
insert into vizioneaza values(10,3,to_date('13-may-2021','dd-mon-yyyy'),130);
insert into vizioneaza values(11,1,to_date('06-dec-2021','dd-mon-yyyy'),93);
insert into vizioneaza values(11,40,to_date('20-oct-2021','dd-mon-yyyy'),140);
insert into vizioneaza values(11,33,to_date('21-oct-2021','dd-mon-yyyy'),77);
insert into vizioneaza values(11,93,to_date('23-oct-2021','dd-mon-yyyy'),78);
insert into vizioneaza values(11,88,to_date('20-nov-2021','dd-mon-yyyy'),90);
insert into vizioneaza values(12,1,to_date('08-jan-2023','dd-mon-yyyy'),135);
insert into vizioneaza values(12,70,to_date('22-feb-2023','dd-mon-yyyy'),32);
insert into vizioneaza values(12,96,to_date('26-dec-2024','dd-mon-yyyy'),278);
insert into vizioneaza values(12,96,to_date('27-dec-2024','dd-mon-yyyy'),300);
insert into vizioneaza values(13,63,to_date('18-jul-2020','dd-mon-yyyy'),150);
insert into vizioneaza values(13,22,to_date('19-aug-2020','dd-mon-yyyy'),43);
insert into vizioneaza values(14,9,to_date('17-jul-2021','dd-mon-yyyy'),120);
insert into vizioneaza values(14,45,to_date('22-aug-2021','dd-mon-yyyy'),63);
insert into vizioneaza values(14,85,to_date('22-aug-2021','dd-mon-yyyy'),132);
insert into vizioneaza values(14,23,to_date('22-aug-2021','dd-mon-yyyy'),160);
insert into vizioneaza values(14,67,to_date('22-aug-2021','dd-mon-yyyy'),110);
insert into vizioneaza values(14,90,to_date('22-aug-2021','dd-mon-yyyy'),34);
insert into vizioneaza values(15,41,to_date('28-apr-2020','dd-mon-yyyy'),125);
insert into vizioneaza values(15,5,to_date('9-may-2020','dd-mon-yyyy'),87);
insert into vizioneaza values(15,5,to_date('22-may-2020','dd-mon-yyyy'),100);
insert into vizioneaza values(15,5,to_date('23-may-2020','dd-mon-yyyy'),78);
insert into vizioneaza values(16,6,to_date('15-jan-2022','dd-mon-yyyy'),140);
insert into vizioneaza values(16,43,to_date('16-jan-2022','dd-mon-yyyy'),130);
insert into vizioneaza values(17,27,to_date('23-aug-2022','dd-mon-yyyy'),120);
insert into vizioneaza values(17,49,to_date('20-sep-2023','dd-mon-yyyy'),77);
insert into vizioneaza values(18,8,to_date('20-dec-2019','dd-mon-yyyy'),125);
insert into vizioneaza values(18,16,to_date('25-dec-2019','dd-mon-yyyy'),145);
insert into vizioneaza values(18,8,to_date('03-jan-2020','dd-mon-yyyy'),99);
insert into vizioneaza values(18,71,to_date('07-jan-2020','dd-mon-yyyy'),92);
insert into vizioneaza values(19,6,to_date('2-jul-2022','dd-mon-yyyy'),56);
insert into vizioneaza values(19,33,to_date('5-jul-2022','dd-mon-yyyy'),140);
insert into vizioneaza values(19,67,to_date('5-jul-2022','dd-mon-yyyy'),91);
insert into vizioneaza values(19,68,to_date('5-jul-2022','dd-mon-yyyy'),65);
insert into vizioneaza values(20,101,to_date('14-mar-2023','dd-mon-yyyy'),125);
insert into vizioneaza values(20,103,to_date('14-mar-2023','dd-mon-yyyy'),125);
insert into vizioneaza values(20,102,to_date('15-mar-2023','dd-mon-yyyy'),111);
insert into vizioneaza values(20,104,to_date('15-mar-2023','dd-mon-yyyy'),130);
insert into vizioneaza values(20,99,to_date('25-apr-2023','dd-mon-yyyy'),25);
commit;