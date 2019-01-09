(* (c) Frédéric Bour *)

module type FUNCTOR = sig type 'a t end

module Make (K : FUNCTOR) = struct
  type t = ..

  module type Extension = sig
    type x
    type t += T of x
  end

  type 'a extension = (module Extension with type x = 'a)
  type instance = V : 'a * 'a K.t -> instance

  let handlers = Hashtbl.create 16

  module Injection (X : sig
    type t

    val instance : t K.t
  end) : Extension with type x = X.t = struct
    type x = X.t
    type t += T of x

    let () =
      let instance = X.instance in
      Hashtbl.add handlers
        (Obj.extension_id [%extension_constructor T])
        (function T x -> V (x, instance) | _ -> raise Not_found)
  end

  let inj (type a) (f : a K.t) : a extension =
    ( module Injection (struct
      type t = a

      let instance = f
    end) )

  let prj (t : t) =
    let rec go = function
      | [] -> assert false (* totality *)
      | x :: r -> ( try x t with Not_found -> go r )
    in
    go
      (Hashtbl.find_all handlers
         (Obj.extension_id (Obj.extension_constructor t)))
end
