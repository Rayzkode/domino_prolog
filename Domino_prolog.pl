:- dynamic jugador/2.
:- dynamic reserva/1.
:- dynamic tablero/1.

fichas([
    ficha(0, 0), ficha(0, 1), ficha(0, 2), ficha(0, 3), ficha(0, 4),
    ficha(0, 5), ficha(0, 6), ficha(1, 1), ficha(1, 2), ficha(1, 3),
    ficha(1, 4), ficha(1, 5), ficha(1, 6), ficha(2, 2), ficha(2, 3),
    ficha(2, 4), ficha(2, 5), ficha(2, 6), ficha(3, 3), ficha(3, 4),
    ficha(3, 5), ficha(3, 6), ficha(4, 4), ficha(4, 5), ficha(4, 6),
    ficha(5, 5), ficha(5, 6), ficha(6, 6)
]).

iniciar :-
    write("Bienvenidos jugadores"), nl,
    write("Jugaremos domino :D"), nl,
    write("Empecemos por repartir fichas, ¿de acuerdo?"), nl,
    fichas(Fichas),
    random_permutation(Fichas, FichasAleatorias),
    repartirFichas(FichasAleatorias, 0),
    assertz(tablero([])), % Inicializamos el tablero como una lista vacía
    (
        (jugador(jugador1, ficha(5, )) ; jugador(jugador1, ficha(, 5))),
        \+ (jugador(jugador2, ficha(5, )) ; jugador(jugador2, ficha(, 5)))
    ->  Quien = jugador1
    ;   (
            (jugador(jugador2, ficha(5, )) ; jugador(jugador2, ficha(, 5))),
            \+ (jugador(jugador1, ficha(5,_ )) ; jugador(jugador1, ficha(_, 5)))
        ->  Quien = jugador2
        ;   (
                % Si ninguno de los jugadores tiene una ficha con un 5, tomar una de la reserva
                \+ (jugador(jugador1, ficha(5, )) ; jugador(jugador1, ficha(, 5))),
                \+ (jugador(jugador2, ficha(5, )) ; jugador(jugador2, ficha(, 5)))
            ->  tomarFichaReserva(jugador1), Quien = jugador1
            ;   random_member(Quien, [jugador1, jugador2])
            )
        )
    ),
    mostrarEstadoJuego,
    format("¡Empieza el jugador ~w!~n", [Quien]),
    jugar(Quien).

tomarFichaReserva(Jugador) :-
    findall(Ficha, reserva(Ficha), Reserva),
    length(Reserva, Len),
    random(0, Len, Index),
    nth0(Index, Reserva, Ficha),
    retract(reserva(Ficha)),
    assertz(jugador(Jugador, Ficha)).

validarInicio :-
    (   jugador(jugador1, Ficha), (Ficha = ficha(5, ) ; Ficha = ficha(, 5)) 
    ;   jugador(jugador2, Ficha), (Ficha = ficha(5, ) ; Ficha = ficha(, 5))
    ),
    !.
validarInicio :-
    write("El juego debe comenzar con la mula de 5 o alguna ficha que tenga 5 en alguno de sus lados."), nl,
    reiniciarJuego.

reiniciarJuego :-
    retract(jugador(_, _)),
    retract(reserva(_)),
    retract(tablero(_)),
    iniciar.

mostrarEstadoJuego :-
    mostrarFichas(jugador1), 
    mostrarFichas(jugador2), 
    findall(Ficha, reserva(Ficha), Reserva),
    (
        Reserva = []
        -> write("Fichas en la reserva: []"), nl % Si la reserva está vacía, se imprime [] directamente
        ;  (
               write("Fichas en la reserva: "), nl,
               mostrarFichasAux(Reserva)
           )
    ).

jugar(Jugador) :-
    mostrarFichas(Jugador),
    format("¿Qué ficha usarás, jugador ~w? ", [Jugador]),
    read(Ficha),
    jugarFicha(Jugador, Ficha).

jugarFicha(Jugador, Ficha) :-
    tablero(Tablero),
    append(Tablero, [Ficha], NuevoTablero), % Agregar la ficha al tablero
    retract(tablero(_)),
    assertz(tablero(NuevoTablero)),
    retract(jugador(Jugador, Ficha)), % Quitar la ficha de las fichas del jugador
    mostrarTablero,
    cambiarTurno(Jugador, SiguienteJugador),
    jugar(SiguienteJugador).

repartirFichas([], _).
repartirFichas([Ficha|Resto], N) :-
    N < 5,
    assertz(jugador(jugador1, Ficha)),
    N1 is N + 1,
    repartirFichas(Resto, N1).
repartirFichas([Ficha|Resto], N) :-
    N >= 5,
    N < 10,  % Se agrega esta condición para detener el ciclo cuando N alcanza 5 o más pero es menor que 10
    assertz(jugador(jugador2, Ficha)),
    N1 is N + 1,
    repartirFichas(Resto, N1).
repartirFichas([Ficha|Resto], N) :-
    N >= 10,
    assertz(reserva(Ficha)),
    N1 is N + 1,
    repartirFichas(Resto, N1).

mostrarFichas(Jugador) :-
    write("Fichas del jugador "), write(Jugador), nl,
    findall(Ficha, jugador(Jugador, Ficha), Fichas),
    mostrarFichasAux(Fichas).

mostrarFichasAux([]).
mostrarFichasAux([Ficha|Resto]) :-
    write(Ficha), nl,
    mostrarFichasAux(Resto).

mostrarTablero :-
    write("Tablero: "), nl,
    tablero(Tablero),
    mostrarFichasAux(Tablero).

cambiarTurno(jugador1, jugador2).
cambiarTurno(jugador2, jugador1).

%sexo