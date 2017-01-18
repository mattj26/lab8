(*********************************************************************

            CS51 Lab 8
              Events

Objective:

This lab introduces events and listeners, a paradigm that 
is particularly useful in the programming of front-end applications.

*********************************************************************)

   
(*====================================================================
Events and Listeners

Imagine that you were writing an operating system and want to provide
an interface for programmers to write programs for a UI. Given what you
know now, how might you design this UI? You might create an abstraction
for drawing, so that an application can call a method in your API to
draw a button. Since you expose a single draw method for a button, you
get to dictate the style of the button, and the programmer must only
call a single method to draw a button on the interface.

Now imagine interaction; how would you design the UI to react to, say,
mouse clicks? One way might be to pass a function as a parameter to
the button draw API call that would be executed when the user presses
the button. This is typically called a callback: a function that is
passed as parameter to another function, which then executes it at
appropriate time.

But imagine a more complex situation: your interface allows the user
to interact with the button in a myriad of ways. Perhaps the user
could long-click, double-click, right-click, or maybe even use the
keyboard to activate the button. In this case, we want to provide the
programmer with the opportunity to have different behavior for every
case, which might mean individual callbacks for each case. This
quickly becomes untenable.

A solution to this problem would be to leverage events. Programmers
using your API would write functions that are designed to handle
various events, like a keyboard press or a right-click, and notify
the API which functions react to events by "registering" them for
those events.

Javascript does this, for example; you might have written code in
the past that executes a function when the "onclick" event is fired.
This event is named appropriately: it is the one that is fired when
an object onscreen is clicked.

In the end, there are several requirements for events to work: we
must define an event itself (like "onclick"), listeners for those
events (like a function that is executed in response to the "onclick"
event), and have a mechanism that "fires" the event.

You will use events in problem set 7. Below, we'll look at a simplified
version of the event module used in the problem set. First, we'll define
an event interface.
 *)

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

(*
......................................................................
Exercise 5A: Write add_listener, below, that adds a listener to an
event. Consider the explanations of waiters and events, above, to
decide how to implement this.
......................................................................
 *)
						   
  let add_listener (e:'a event) (f:'a -> unit) : id =
    failwith "WEvent.add_listener not implemented"

(*
......................................................................
Exercise 5B: Given an id and an event, unregister the listener from
the event.
......................................................................
 *)
	    
  let remove_listener (e:'a event) (i:id) : unit =
    failwith "WEvent.remove_listener not implemented"

(*
......................................................................
Exercise 5C: Complete fire_event which will execute all event handlers
stored in the event.
......................................................................
 *)
	    
  let fire_event (e:'a event) (v:'a) : unit =
    failwith "WEvent.fire_event not implemented"

end

(* Let's now put this to use, by creating a newswire event. In this
example, reporters on the ground can fire events that correspond to
headlines they've discovered in the field. News outlets subscribe
to these events and publish stories based on them.

......................................................................
Exercise 5D: Given your implementation of Event, create a new event
called "newswire" that should pass strings to the event handlers.
......................................................................
 *)
  
let newswire = fun _ -> failwith "newswire not implemented" ;;

(*
News organizations might want to register event listeners to the
newswire so that they might report on stories. Below are functions
from two organizations that accept headlines and "publish" stories
(to stdout) in different ways.
 *)
	    
let fakeNewsNetwork (s : string) : unit =
  Printf.printf "BREAKING NEWS %s\n" s ;;

let buzzFake (s : string) : unit =
  Printf.printf "YOU'LL NEVER BELIEVE %s\n" s ;;

(*
......................................................................
Exercise 5E: Register both news organizations to the newswire event.
......................................................................
 *)
  
(* .. *)

(*
Below are some headlines.
 *)

let h1 = "the national animal of Eritrea is officially the camel!" ;;
let h2 = "camels can run in short bursts up to 40mph!" ;;
let h3 = "bactrian camels can weigh up to 2200lbs!" ;;

(*
......................................................................
Exercise 5F: Finally, fire the newswire events with the above
headlines, and observe what happens!
......................................................................
 *)
  
(* .. *)
