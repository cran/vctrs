#' Cast a vector to a specified type
#'
#' @description
#'
#' `vec_cast()` provides directional conversions from one type of
#' vector to another. Along with [vec_ptype2()], this generic forms
#' the foundation of type coercions in vctrs.
#'
#' @includeRmd man/faq/developer/links-coercion.Rmd
#'
#' @inheritParams rlang::args_error_context
#' @param x Vectors to cast.
#' @param ... For `vec_cast_common()`, vectors to cast. For
#'   `vec_cast()`, `vec_cast_default()`, and `vec_restore()`, these
#'   dots are only for future extensions and should be empty.
#' @param to,.to Type to cast to. If `NULL`, `x` will be returned as is.
#' @param x_arg Argument name for `x`, used in error messages to
#'   inform the user about the locations of incompatible types
#'   (see [stop_incompatible_type()]).
#' @param to_arg Argument name `to` used in error messages to
#'   inform the user about the locations of incompatible types
#'   (see [stop_incompatible_type()]).
#' @return A vector the same length as `x` with the same type as `to`,
#'   or an error if the cast is not possible. An error is generated if
#'   information is lost when casting between compatible types (i.e. when
#'   there is no 1-to-1 mapping for a specific value).
#'
#' @section Dependencies of `vec_cast_common()`:
#'
#' ## vctrs dependencies
#'
#' - [vec_ptype2()]
#' - [vec_cast()]
#'
#'
#' ## base dependencies
#'
#' Some functions enable a base-class fallback for
#' `vec_cast_common()`. In that case the inputs are deemed compatible
#' when they have the same [base type][base::typeof] and inherit from
#' the same base class.
#'
#' @seealso Call [stop_incompatible_cast()] when you determine from the
#' attributes that an input can't be cast to the target type.
#' @export
#' @examples
#' # x is a double, but no information is lost
#' vec_cast(1, integer())
#'
#' # When information is lost the cast fails
#' try(vec_cast(c(1, 1.5), integer()))
#' try(vec_cast(c(1, 2), logical()))
#'
#' # You can suppress this error and get the partial results
#' allow_lossy_cast(vec_cast(c(1, 1.5), integer()))
#' allow_lossy_cast(vec_cast(c(1, 2), logical()))
#'
#' # By default this suppress all lossy cast errors without
#' # distinction, but you can be specific about what cast is allowed
#' # by supplying prototypes
#' allow_lossy_cast(vec_cast(c(1, 1.5), integer()), to_ptype = integer())
#' try(allow_lossy_cast(vec_cast(c(1, 2), logical()), to_ptype = integer()))
#'
#' # No sensible coercion is possible so an error is generated
#' try(vec_cast(1.5, factor("a")))
#'
#' # Cast to common type
#' vec_cast_common(factor("a"), factor(c("a", "b")))
vec_cast <- function(x,
                     to,
                     ...,
                     x_arg = caller_arg(x),
                     to_arg = "",
                     call = caller_env()) {
  if (!missing(...)) {
    check_ptype2_dots_empty(...)
  }
  return(.Call(ffi_cast, x, to, environment()))
  UseMethod("vec_cast", to)
}
vec_cast_dispatch <- function(x, to, ..., x_arg = "", to_arg = "") {
  UseMethod("vec_cast", to)
}

vec_cast_dispatch_native <- function(x,
                                     to,
                                     ...,
                                     x_arg = "",
                                     to_arg = "",
                                     call = caller_env()) {
  .Call(
    ffi_cast_dispatch_native,
    x,
    to,
    match_fallback_opts(...),
    x_arg,
    to_arg,
    environment()
  )
}

#' @export
#' @rdname vec_cast
vec_cast_common <- function(...,
                            .to = NULL,
                            .arg = "",
                            .call = caller_env()) {
  .External2(ffi_cast_common, .to)
}
vec_cast_common_opts <- function(...,
                                 .to = NULL,
                                 .opts = fallback_opts(),
                                 .arg = "",
                                 .call = caller_env()) {
  .External2(ffi_cast_common_opts, .to, .opts)
}
vec_cast_common_params <- function(...,
                                   .to = NULL,
                                   .s3_fallback = NULL,
                                   .arg = "",
                                   .call = caller_env()) {
  opts <- fallback_opts(
    s3_fallback = .s3_fallback
  )
  vec_cast_common_opts(
    ...,
    .to = .to,
    .opts = opts,
    .arg = .arg,
    .call = .call
  )
}
vec_cast_common_fallback <- function(...,
                                     .to = NULL,
                                     .arg = "",
                                     .call = caller_env()) {
  vec_cast_common_opts(
    ...,
    .to = .to,
    .opts = full_fallback_opts(),
    .arg = .arg,
    .call = .call
  )
}

#' @rdname vec_default_ptype2
#' @inheritParams vec_cast
#' @export
vec_default_cast <- function(x,
                             to,
                             ...,
                             x_arg = "",
                             to_arg = "",
                             call = caller_env()) {
  if (is_asis(x)) {
    return(vec_cast_from_asis(
      x,
      to,
      x_arg = x_arg,
      to_arg = to_arg,
      call = call
    ))
  }
  if (is_asis(to)) {
    return(vec_cast_to_asis(
      x,
      to,
      x_arg = x_arg,
      to_arg = to_arg,
      call = call
    ))
  }

  if (inherits(to, "vctrs_vctr") && !inherits(to, c("vctrs_rcrd", "vctrs_list_of"))) {
    return(vctr_cast(
      x,
      to,
      x_arg = x_arg,
      to_arg = to_arg,
      call = call
    ))
  }

  opts <- match_fallback_opts(...)

  if (is_common_class_fallback(to) && length(common_class_suffix(x, to))) {
    return(x)
  }

  # Data frames have special bare class and same type fallbacks
  if (is.data.frame(x) && is.data.frame(to)) {
    out <- df_cast_opts(
      x,
      to,
      ...,
      opts = opts,
      x_arg = x_arg,
      to_arg = to_arg,
      call = call
    )

    # Same-type fallback for data frames. If attributes of the empty
    # data frames are congruent, just reproduce these attributes. This
    # eschews any constraints on rows and cols that `[` and `[<-`
    # methods might have. If that is a problem, the class needs to
    # implement vctrs methods.
    if (identical(non_df_attrib(x), non_df_attrib(to))) {
      attributes(out) <- c(df_attrib(out), non_df_attrib(to))
      return(out)
    }

    # Bare-class fallback for data frames.
    # FIXME: Should we only allow it when target is a bare df?
    if (inherits(to, "tbl_df")) {
      out <- df_as_tibble(out)
    }
    return(out)
  }

  if (is_same_type(x, to)) {
    return(x)
  }

  withRestarts(
    stop_incompatible_cast(
      x,
      to,
      x_arg = x_arg,
      to_arg = to_arg,
      `vctrs:::from_dispatch` = match_from_dispatch(...),
      call = call
    ),
    vctrs_restart_cast = function(out) {
      out
    }
  )
}

is_bare_df <- function(x) {
  inherits_only(x, "data.frame") || inherits_only(x, c("tbl_df", "tbl", "data.frame"))
}

is_informative_error_vctrs_error_cast_lossy <- function(x, ...) {
  FALSE
}
