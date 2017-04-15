(*
			      CS51 Lab 8
				Events
			     Spring 2017
 *)

(*
Objective:

This lab introduces events and listeners, a paradigm that is
particularly useful in the programming of front-end applications.
Event programming in the back-end has also grown in popularity
with the rise of Node.js.
 *)


(*====================================================================
Events and Listeners

Imagine that you were writing an operating system and wanted to provide
an application programming interface (API) for programmers to write a
user interface. Given what you've learned, how would you design this
API? You might create an abstraction for drawing, so that
an application could call a method in your API to draw a button.
This has the benefit of allowing you to control the button style
throughout the whole OS, and the application's developer need
only call a single method to draw a button in an application.

Once you've added buttons to your API, how would you allow
client applications to react to, say, a mouse click?
One way might be to add a function parameter to the button creation
method. The function that is passed on creation of the button
could be then be executed each time the user
presses the button. This type of parameter is called a *callback*:
a function that is passed to another function, which the latter
then executes at the appropriate time. (Higher-order
functional programming makes this approach very natural.)

Now imagine a more complex situation: you would like to allow the user
to interact with buttons in a myriad of ways. Perhaps the user
could long-click, double-click, right-click, or maybe even use the
keyboard to activate the button. An application might require
different behavior in each case; that would mean many individual
callbacks. Adding parameters for each type of interaction quickly
becomes untenable.

One solution to this problem is to leverage *events*. Programmers
using your API write functions that are designed to handle
various events, like a keyboard press or a right-click, and notify
the API which functions react to these events by "registering" the
functions for those events.

JavaScript makes frequent use of this paradigm. For example, you might
have written code in the past that executes a function when
the "onclick" event is fired. This event is named appropriately:
it is the one that is fired on clicking an on-screen object.

In the end, there are several requirements for events to work: we must
define an event itself (like "onclick"), have listeners for those
events (like a function that is executed in response to the "onclick"
event), and provide a mechanism that "fires" the event.

This lab walks through each of these steps to build a simple event
system. First, we'll define an event interface.  *)

(* An interface for an event module. *)
module type WEVENT =
sig
  (* The event listener identifier type. *)
  type id

  (* The event type. *)
  type 'a event

  (* Create a new event. *)
  val new_event : unit -> 'a event

  (* Add a listener to an event which is called every time the event
     is fired. Return an identifier for the listener. *)
  val add_listener : 'a event -> ('a -> unit) -> id

  (* Remove a listener from being called when an event is fired. Has no effect
     if the listener is not waiting for the event. *)
  val remove_listener : 'a event -> id -> unit

  (* Signal that an event has occurred.  The 'a value is passed to each
     function waiting for the event. *)
  val fire_event : 'a event -> 'a -> unit
end

(* Below are the beginnings of an implementation of the interface.
Look at the interface, above, for descriptions of each function. *)
module WEvent : WEVENT =
struct
  type id = int

  (* In this implementation, an event will be made up of a list of
  "waiters" which includes a unique ID for the listener (which will
  allow us to manage it later), and the listener itself. The listener
  is an event handler, or a function that will execute when the event
  is "fired". *)
  type 'a waiter = {id : id ; action : 'a -> unit}
  type 'a event = 'a waiter list ref

  (* New IDs should be unique ints; we'll increment from 0. *)
  let id_counter = ref 0

  let new_id () : id =
    let i = !id_counter in
    incr id_counter ; i

  let new_event : unit -> 'a event = fun () -> ref []

(*......................................................................
Exercise 1: Write add_listener, which adds a listener to an
event. Consider the explanations of waiters and events, above, to
decide how to implement this.
......................................................................*)

  let add_listener (e:'a event) (f:'a -> unit) : id =
    let id = new_id () in
    let listener = {id = id; action = f} in
    e := !e @ [listener]; id

(*......................................................................
Exercise 2: Write remove_listener, which, given an id and an event,
unregisters the listener with that id from the event if there is
one. If there is no listener with that id, do nothing.
......................................................................*)

  let remove_listener (e:'a event) (i:id) : unit =
    let _, y = List.partition (fun eve -> eve.id = i) !e in
    e := y

(*......................................................................
Exercise 3: Write fire_event, which will execute all event handlers
listening for the event.
......................................................................*)

  let fire_event (e:'a event) (v:'a) : unit =
    List.iter (fun waitr -> waitr.action v) !e
end
(* Let's now put this to use by creating a newswire. In this
example, reporters on the ground can fire events that correspond to
headlines they've discovered in the field. News outlets subscribe
to these events and publish stories based on them. *)

(*......................................................................
Exercise 4: Given your implementation of Event, create a new event
called "newswire" that should pass strings to the event handlers.
......................................................................*)

let newswire = WEvent.new_event ()

(* News organizations might want to register event listeners to the
newswire so that they might report on stories. Below are functions
from two organizations that accept headlines and "publish" stories (to
stdout) in different ways. *)

let fakeNewsNetwork (s : string) : unit =
  Printf.printf "BREAKING NEWS %s\n" s ;;

let buzzFake (s : string) : unit =
  Printf.printf "YOU'LL NEVER BELIEVE %s\n" s ;;

(*......................................................................
Exercise 5: Register both news organizations to the newswire event.
......................................................................*)
let listen1 = WEvent.add_listener newswire fakeNewsNetwork;;
let listen2 = WEvent.add_listener newswire buzzFake;;
(* .. *)

(* Here are some headlines to play with. *)

let h1 = "the national animal of Eritrea is officially the camel!" ;;
let h2 = "camels can run in short bursts up to 40mph!" ;;
let h3 = "bactrian camels can weigh up to 2200lbs!" ;;

(*......................................................................
Exercise 6: Finally, fire the newswire events with the above
headlines, and observe what happens!
......................................................................*)
WEvent.fire_event newswire h1;
WEvent.fire_event newswire h2;
WEvent.fire_event newswire h3;
(* .. *)

(* Imagine now that you work at Facebook, and you're growing concerned
with the proliferation of fake news. To combat the problem, you decide
that headlines shouldn't be published right when the wires flash them;
instead, they should be reviewed and approved first, and not
printed until approved. The first step is to make sure that
the publications don't publish right away. *)

(*......................................................................
Exercise 7: Remove the newswire listeners that were previously registered.
......................................................................*)
WEvent.remove_listener newswire listen1;
WEvent.remove_listener newswire listen2
(* .. *)

(*......................................................................
Exercise 8: Create a new event to signal that all stories should be
published. The event should be a unit WEvent.event.
......................................................................*)

let publish = WEvent.new_event ();;

(*......................................................................
Exercise 9: Write a function to handle new news stories.
Instead of publishing them immediately, the function should
delay publication until after the publish event is fired.
......................................................................*)

let receive_report (s : string) : unit =
  ignore (WEvent.add_listener publish
    (fun () -> Printf.printf "After careful consideration: %s\n" s));;


(*......................................................................
Exercise 10: Register your new event to listen for the newswire event.
......................................................................*)
WEvent.add_listener newswire receive_report;;
(* .. *)

(* Here are some new headlines to use for testing this part. *)

let h4 = "today's top story: memes." ;;
let h5 = "cs50 is fake news." ;;
let h6 = "cs51 is not fake news.";;

(*......................................................................
Exercise 11: Using the new headlines above, make sure that firing
the newswire event doesn't immediately print the news.
......................................................................*)
WEvent.fire_event newswire h4;
WEvent.fire_event newswire h5;
WEvent.fire_event newswire h6;
(* .. *)
print_string "Moved to publication.\n" ;;
(*......................................................................
Exercise 12: Finally, make sure that firing the publish event prints
out the headlines. You should see the headlines printed after
the line above.
......................................................................*)
WEvent.fire_event publish ()
(* .. *)

