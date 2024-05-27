module BibleAccess = Bible_access
module AudioAccess = Audio_access
module Address = Address
module InterlinearBibleAccess = Interlinear_bible_access
module TranslationsManager = Translations_manager

module type MembershipManager = sig
  type login_req

  type login_res

  val login : login_req -> login_res

  val logout : unit -> unit

  type register_req

  type register_res

  val register : register_req -> register_res

  type confirm_email_req

  type confirm_email_res

  val confirm_email : confirm_email_req -> confirm_email_res

  val forgot_password : string -> unit

  type change_password_req =
    { email: string
    ; token: string
    ; password: string }

  type change_password_error

  val change_password :
    change_password_req -> (unit, change_password_error) Result.t

  val forget_user : unit -> unit
end

module type TranslationsManager = sig
  type read_req =
    { address: Address.t
    ; include_comments: bool }

  type passage

  val read : read_req -> passage

  type upload_req

  type upload_res

  val upload : upload_req -> upload_res

  type search_res

  val search : string -> search_res
end

module type InteractionManager = sig
  type comment_status =
    | Private
    | ToReview
    | InReview
    | Accepted
    | Rejected

  type query =
    | ByAddress of Address.t
    | ByStatus of comment_status

  type show_comments_res

  val show_comments : query -> show_comments_res

  type comment

  val comment : comment -> unit

  type moderate_req

  type moderate_res

  val moderate : moderate_req -> moderate_res

  val bookmark : Address.t -> unit

  val download_my_data : unit -> unit

  type comment_id = string

  val remove_comment : comment_id -> unit

  (* there should be a running process in background
     for unblocking the comments InReview *)
end

module type SearchEngine = sig
  type search_res

  val search : string -> search_res
end

module type GamificationEngine = sig
  type role =
    | User
    | Moderator
    | Admin

  type query = ByRole of role

  type find_user_res

  val find_user : query -> find_user_res

  type ctx

  val is_allowed : ctx -> string -> bool
end

module type UserAccess = sig
  type t =
    { id: string
    ; email: string }

  type query_by =
    | EmailPassword of string * string
    | EmailToken of string * string
    | Email of string
    | Id of string

  type query_return = Bookmarks

  type query =
    { by: query_by
    ; return: query_return list }

  type find_res

  val find : query -> find_res

  type store_req

  type store_res =
    { id: string
    ; email_confirmation_token: string option }

  val store : store_req -> store_res

  type user_id = string

  val anonymize : user_id -> unit

  val store_bookmark : Address.t -> unit
end

module type SessionAccess = sig
  type t =
    { session_id: string
    ; user_id: string
    ; created_at: string }

  val create_session : string -> unit

  val destroy_session : string -> unit

  type session_id

  val find : session_id -> t option
end

(* module type BibleAccess = sig *)
(*   type verse = *)
(*     { address: Address.t *)
(*     ; text: string } *)

(*   type passage = verse list *)

(*   type find_req = *)
(*     | Address of Address.t *)
(*     | Text of string *)

(*   type find_res = {passages: passage list} *)
(*   val find : Ctx.t -> find_req -> find_res *)
(* end *)

module type AudioAccess = sig
  type store_req

  type store_res

  val store : store_req -> store_res

  type query

  type find_urls_res

  val find : query -> find_urls_res
end

module type InterlinearBibleAccess = sig
  val find_url : Address.t -> string
end

module type CommentsAccess = sig
  type query = {addresses: Address.t list}

  type find_res

  val find : query -> find_res

  type comment

  type store_res

  val store : comment -> store_res

  type comment_id = string

  val toggle_visibility : comment_id -> unit
end

module type Notification = sig
  type t =
    { recipient: string
    ; title: string
    ; body: string }

  val send : t -> unit
end
