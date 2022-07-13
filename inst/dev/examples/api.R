#* @apiTitle Matching API
#* @apiDescription API for string matching

#* Match string
#* @param req The request object
#* @serializer unboxedJSON
#* @post /match
function(req) {
  names(req$body) |>
    mcn::get_matched_names() |>
    dplyr::bind_rows(
      data.frame(
        "id" = 27,
        "original_name" = "engenharia ambiental e sanitaria",
        "discr_id" = 333,
        "source" = "ftk",
        "priority" = 2
      )
    ) |>
    dplyr::arrange(id, priority) |>
    dplyr::select("original_name", "discr_id") |>
    dplyr::group_by(original_name) |>
    dplyr::summarise("discr_id" = I(list(discr_id))) |>
    with(setNames(discr_id, original_name)) |>
    jsonlite::toJSON(pretty = TRUE, na = "null", auto_unbox = TRUE) |>
    jsonlite::write_json("//match.json")
}
