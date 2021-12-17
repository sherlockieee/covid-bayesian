:- dynamic node/1.
:- dynamic edge/2.
:- dynamic parent/2.
:- dynamic p/3.

show_prob([]).										% Itemize and write the list of path and probability
show_prob([[Path,Prob]|Tail]):-
	write('Path: '), write(Path), nl,
	write('Probability: '), write(Prob), nl,
	show_prob(Tail).

show_path([]).										% Itemize and write the list of path
show_path([H|Tail]):-
	write(H),nl,show_path(Tail).

show_descendant([]).
show_descendant([[Node, Descendant, Length]|Tail]) :-
	write('Person: '), write(Node), nl,
	write('Potentially gives COVID to: '), write(Descendant),nl,
	write('Total: '), write(Length), nl,
	show_descendant(Tail).

show_ancestor([]).
show_ancestor([[Node, Ancestor, Length]|Tail]) :-
	write('Person: '), write(Node), nl,
	write('Potentially gets COVID from: '), write(Ancestor),nl,
	write('Total: '), write(Length), nl,
	show_descendant(Tail).

probability:-
    findall(X, node(X), List),
    check_person((write('Susceptible person: '), write(List)), List, Ans),
    findall(X, (node(X), X\=Ans), List2), 
	check_person_or_zero((write('Person who got COVID (Write "0" if you just want to see the suspected person data): '), write(List2)), List2, Ans2),
	(	% If no conditional
		(Ans2 = 0, write('Probability they get COVID: '), ((prob(Ans,[],P), write(P)); write(0)), nl,
		numberOfParent(Ans,N1, L1), write('No of people who might give COVID to '), write(Ans), write(': '), write(N1), nl, write(L1),nl,
		numberOfChildren(Ans,N2, L2), write('No of people who '), write(Ans), write(' might give COVID to: '), write(N2), nl, write(L2));
		% If there exists a conditional
		(Ans2 \= 0, findall([P1,P2],path_probability(Ans2,Ans,P1,P2),L),
		(L = [] -> (write('Path: []'), nl, write('Probability: '), findall(Prob, prob(Ans, [Ans2], Prob), P), write(P), nl); show_prob(L)))
	).

trace:-
    findall(X, node(X), L1),
	check_person((write('Susceptible Person: '), write(L1)), L1, A1),
    findall(X, (node(X), X\=A1), L2),
	check_person((write('Initial person who got COVID: '), write(L2)), L2, A2),
    findall(X, (node(X), X\=A1, X\=A2), L3),
	check_person_or_zero((write('Person who also got COVID (write 0 if none): '), write(L3)), L3, A3),
    findall(X, (node(X), X\=A1, X\=A2, X\=A3), L4),
	check_person_or_zero((write('Person who definitely do not have COVID (write 0 if none): '), write(L4)), L4, A4),
    (	% If no conditional
		(A3 = 0, write('All paths from '), write(A2), write(' to '), write(A1), nl,
		findall([P1,P2],path_probability(A2,A1,P1,P2),L),
		(L = [] -> (write('Path: []'), nl, write('Probability: '), findall(Prob, prob(A1, [A2], Prob), P), write(P), nl); show_prob(L))
        );
		% If there exists a conditional
		(A3 \= 0, write('Path containing '), write(A3), write(': '), nl,
		findall(Path,causing(A2,A1,Path, A3),L), sort(L, Sorted), write(Sorted), nl)
	),(   
      (A4 \= 0, write('Path not containing '),write(A4), write(': '), nl,
          findall(Path,notCausing(A2,A1,Path,A4),L1), 
      (   L1 = [] ->   write('None'); (sort(L1, Sorted1), write(Sorted1), nl)));
      (A4 = 0, nl)
    ).
    
check_person(Query, List, Name) :-
    Query, read(TmpName),
    (  \+member(TmpName, List) -> write('Name is not valid. Try again.'), nl, check_person(Query, List, Name); 
    					Name = TmpName).

check_person_or_zero(Query, List, Name) :-
    Query, read(TmpName),
     (  (   \+member(TmpName, List), TmpName\=0) -> write('Name is not valid. Try again.'), nl, check_person_or_zero(Query, List, Name); 
    					Name = TmpName).

add_people :-
    create_person(Name),
    assertz(node(Name)), nl,
    write('All Minervans: '), findall(X,node(X),L), write(L),nl,
    give_covid(Name), numberOfParent(Name, _, ParentsList), 
    write("All people who might give COVID to "), write(Name), write(": "), 
    write(ParentsList),nl,
    % get_covid(Name), numberOfChildren(Name, _, ChildrenList), 
    % write("All people who might get COVID from "), write(Name), write(": "), 
    % write(ChildrenList),
    get_probability(Name, ParentsList, [], 0),
	write("Data is encoded. To find the related probabliy, check out 2 or 3."),
    nl.

create_person(Name) :-
    write('Name of person you want to add (write in lowercase): '), read(TmpName),
    (   node(TmpName) -> write('Name already exists. Try again.'), nl, create_person(Name); Name = TmpName).

give_covid(Name) :-
    write('Write 1 person name who might give COVID to '), write(Name), write(' (Or 0 if None): '),
    findall(X, (node(X), X\=Name, \+parent(X, Name), \+parent(Name, X)), L), write(L), read(NewPerson),
    (node(NewPerson) -> (assertz(edge(NewPerson, Name)), assertz(parent(NewPerson, Name)),
                            write(NewPerson), write(" might gives COVID to "), write(Name), nl,
                            give_covid(Name));
    NewPerson = 0 -> write('Everyone added.'), nl; 
    (write('Person does not exist in databases'), nl, give_covid(Name))
    ).


get_probability(Name, [], List, Val) :- 
    X is Val * 4,
    tab(X), write("Write probability that "), write(Name), write(" gets COVID (between 0 and 1)"), 
    check_probability(P),
    (   (length(List, N), N > 0) ->   assertz(p(Name, List, P)); assertz(p(Name, P))).

get_probability(Name, [Head | Rest], List, Val) :-
    X is Val * 4,
    tab(X), write("Given "), write(Head), write(" gets COVID"), nl,
    get_probability(Name, Rest, [Head | List], Val + 1),
    tab(X), write("Given "), write(Head), write(" does not get COVID"), nl,
    get_probability(Name, Rest, [\+Head | List], Val + 1).

check_probability(P) :-
    read(Ans),((float(Ans), 0 =< Ans, Ans =< 1) ->   P = Ans ; 
    			write('Invalid value, try again.'), nl, check_probability(P)
    ).
    

menu:-
	write('Main Menu'),nl,
	write('1. All Minervans'),nl,
	write('2. Probability of getting COVID'),nl,
	write('3. Trace COVID cases'),nl,
    write('4. Add people to network'), nl,
	write('5. Exit'), nl,
	write('Choice: '),read(Ans),
	(
		(Ans = 1, findall(X,node(X),L), write('All people in network: '),write(L),nl,nl,menu);
		(Ans = 2, probability ,nl, menu);
		(Ans = 3, trace, nl, menu);
    	(Ans = 4, add_people, nl, menu);
		(Ans = 5, write('Closing'));
		((not(integer(Ans)); Ans > 5; Ans < 1), write('Invalid choice.'),nl,nl,menu)
	).