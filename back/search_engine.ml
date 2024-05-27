open! Base

type query = {phrase: string}

let search ~(ctx : Ctx.t) query = Bible_access.find ~ctx (Text query.phrase)
