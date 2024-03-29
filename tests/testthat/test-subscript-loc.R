
test_that("vec_as_location2() returns a position", {
  expect_identical(vec_as_location2(2, 2L), 2L)
  expect_identical(vec_as_location2("foo", 2L, c("bar", "foo")), 2L)
  expect_identical(vec_as_location2("0", 4L, as.character(-1:2)), 2L)
})

test_that("vec_as_location2() requires integer or character inputs", {
  expect_snapshot({
    (expect_error(vec_as_location2(TRUE, 10L), class = "vctrs_error_subscript_type"))
    (expect_error(vec_as_location2(mtcars, 10L), class = "vctrs_error_subscript_type"))
    (expect_error(vec_as_location2(env(), 10L), class = "vctrs_error_subscript_type"))
    (expect_error(vec_as_location2(foobar(), 10L), class = "vctrs_error_subscript_type"))
    (expect_error(vec_as_location2(2.5, 10L), class = "vctrs_error_subscript_type"))
    (expect_error(vec_as_location2(Inf, 10L), class = "vctrs_error_subscript_type"))
    (expect_error(vec_as_location2(-Inf, 10L), class = "vctrs_error_subscript_type"))

    "Idem with custom `arg`"
    (expect_error(vec_as_location2(foobar(), 10L, arg = "foo", call = call("my_function")), class = "vctrs_error_subscript_type"))
    (expect_error(vec_as_location2(2.5, 3L, arg = "foo", call = call("my_function")), class = "vctrs_error_subscript_type"))
    (expect_error(with_tibble_rows(vec_as_location2(TRUE)), class = "vctrs_error_subscript_type"))
  })
})

test_that("vec_as_location() requires integer, character, or logical inputs", {
  expect_snapshot({
    (expect_error(vec_as_location(mtcars, 10L), class = "vctrs_error_subscript_type"))
    (expect_error(vec_as_location(env(), 10L), class = "vctrs_error_subscript_type"))
    (expect_error(vec_as_location(foobar(), 10L), class = "vctrs_error_subscript_type"))
    (expect_error(vec_as_location(2.5, 10L), class = "vctrs_error_subscript_type"))
    (expect_error(vec_as_location(list(), 10L), class = "vctrs_error_subscript_type"))
    (expect_error(vec_as_location(function() NULL, 10L), class = "vctrs_error_subscript_type"))
    (expect_error(vec_as_location(Sys.Date(), 3L), class = "vctrs_error_subscript_type"))

    "Idem with custom `arg`"
    (expect_error(vec_as_location(env(), 10L, arg = "foo", call = call("my_function")), class = "vctrs_error_subscript_type"))
    (expect_error(vec_as_location(foobar(), 10L, arg = "foo", call = call("my_function")), class = "vctrs_error_subscript_type"))
    (expect_error(vec_as_location(2.5, 3L, arg = "foo", call = call("my_function")), class = "vctrs_error_subscript_type"))
  })
})

test_that("vec_as_location2() and vec_as_location() require integer- or character-like OO inputs", {
  expect_identical(vec_as_location2(factor("foo"), 2L, c("bar", "foo")), 2L)
  expect_identical(vec_as_location(factor("foo"), 2L, c("bar", "foo")), 2L)
  expect_error(vec_as_location2(foobar(1L), 10L), class = "vctrs_error_subscript_type")
  expect_error(vec_as_location(foobar(1L), 10L), class = "vctrs_error_subscript_type")

  # Define subtype of logical and integer
  local_methods(
    vec_ptype2.vctrs_foobar = function(x, y, ...) UseMethod("vec_ptype2.vctrs_foobar"),
    vec_ptype2.vctrs_foobar.logical = function(x, y, ...) logical(),
    vec_ptype2.vctrs_foobar.integer = function(x, y, ...) integer(),
    vec_ptype2.logical.vctrs_foobar = function(x, y, ...) logical(),
    vec_ptype2.integer.vctrs_foobar = function(x, y, ...) integer(),
    vec_cast.vctrs_foobar = function(x, to, ...) UseMethod("vec_cast.vctrs_foobar"),
    vec_cast.vctrs_foobar.integer = function(x, to, ...) foobar(x),
    vec_cast.integer.vctrs_foobar = function(x, to, ...) vec_cast(unclass(x), int()),
    vec_cast.logical.vctrs_foobar = function(x, to, ...) vec_cast(unclass(x), lgl())
  )
  expect_error(vec_as_location2(foobar(TRUE), 10L), class = "vctrs_error_subscript_type")
  expect_identical(vec_as_location(foobar(TRUE), 10L), 1:10)
  expect_identical(vec_as_location(foobar(FALSE), 10L), int())
})

test_that("vec_as_location() and variants check for OOB elements (#1605)", {
  expect_snapshot({
    "Numeric indexing"
    (expect_error(vec_as_location(10L, 2L), class = "vctrs_error_subscript_oob"))
    (expect_error(vec_as_location(-10L, 2L), class = "vctrs_error_subscript_oob"))
    (expect_error(vec_as_location2(10L, 2L), class = "vctrs_error_subscript_oob"))

    "Character indexing"
    (expect_error(vec_as_location("foo", 1L, names = "bar"), class = "vctrs_error_subscript_oob"))
    (expect_error(vec_as_location2("foo", 1L, names = "bar"), class = "vctrs_error_subscript_oob"))
    (expect_error(vec_as_location2("foo", 1L, names = "bar", call = call("baz")), class = "vctrs_error_subscript_oob"))
  })

  expect_error(num_as_location(10L, 2L), class = "vctrs_error_subscript_oob")
  expect_error(num_as_location2(10L, 2L), class = "vctrs_error_subscript_oob")
})

test_that("vec_as_location() doesn't require `n` for character indexing", {
  expect_identical(vec_as_location("b", NULL, names = letters), 2L)
})

test_that("vec_as_location2() requires length 1 inputs", {
  expect_snapshot({
    (expect_error(vec_as_location2(1:2, 2L), class = "vctrs_error_subscript_type"))
    (expect_error(vec_as_location2(c("foo", "bar"), 2L, c("foo", "bar")), class = "vctrs_error_subscript_type"))

    "Idem with custom `arg`"
    (expect_error(vec_as_location2(1:2, 2L, arg = "foo", call = call("my_function")), class = "vctrs_error_subscript_type"))
    (expect_error(vec_as_location2(mtcars, 10L, arg = "foo", call = call("my_function")), class = "vctrs_error_subscript_type"))
    (expect_error(vec_as_location2(1:2, 2L, arg = "foo", call = call("my_function")), class = "vctrs_error_subscript_type"))
  })
})

test_that("vec_as_location2() requires positive integers", {
  expect_snapshot({
    (expect_error(vec_as_location2(0, 2L), class = "vctrs_error_subscript_type"))
    (expect_error(vec_as_location2(-1, 2L), class = "vctrs_error_subscript_type"))

    "Idem with custom `arg`"
    (expect_error(vec_as_location2(0, 2L, arg = "foo", call = call("my_function")), class = "vctrs_error_subscript_type"))
  })
})

test_that("vec_as_location2() fails with NA", {
  expect_snapshot({
    (expect_error(vec_as_location2(na_int, 2L), class = "vctrs_error_subscript_type"))
    (expect_error(vec_as_location2(na_chr, 1L, names = "foo"), class = "vctrs_error_subscript_type"))

    "Idem with custom `arg`"
    (expect_error(vec_as_location2(na_int, 2L, arg = "foo", call = call("my_function")), class = "vctrs_error_subscript_type"))
  })
})

test_that("vec_as_location2() doesn't allow lossy casts", {
  expect_error(vec_as_location2(2^31, 3L), class = "vctrs_error_subscript_type")

  # Lossy casts generate missing values, which are disallowed
  expect_error(allow_lossy_cast(vec_as_location2(2^31, 3L)), class = "vctrs_error_subscript_type")
})

test_that("all subscript errors inherit from `vctrs_error_subscript`", {
  expect_error(vec_as_location(100, 2L), class = "vctrs_error_subscript")
  expect_error(vec_as_location("foo", 2L, names = c("bar", "baz")), class = "vctrs_error_subscript")
  expect_error(vec_as_location(foobar(1L), 2L), class = "vctrs_error_subscript")
  expect_error(vec_as_location(1.5, 2L), class = "vctrs_error_subscript")
  expect_error(vec_as_location2(TRUE, 2L), class = "vctrs_error_subscript")
  expect_error(vec_as_location2(1.5, 2L), class = "vctrs_error_subscript")
})

test_that("all OOB errors inherit from `vctrs_error_subscript_oob`", {
  expect_error(vec_as_location(100, 2L), class = "vctrs_error_subscript_oob")
  expect_error(vec_as_location("foo", 2L, names = c("bar", "baz")), class = "vctrs_error_subscript_oob")
})

test_that("vec_as_location() preserves names if possible", {
  expect_identical(vec_as_location(c(a = 1L, b = 3L), 3L), c(a = 1L, b = 3L))
  expect_identical(vec_as_location(c(a = 1, b = 3), 3L), c(a = 1L, b = 3L))
  expect_identical(vec_as_location(c(a = "z", b = "y"), 26L, letters), c(a = 26L, b = 25L))

  expect_identical(vec_as_location(c(foo = TRUE, bar = FALSE, baz = TRUE), 3L), c(foo = 1L, baz = 3L))
  expect_identical(vec_as_location(c(foo = TRUE), 3L), c(foo = 1L, foo = 2L, foo = 3L))
  expect_identical(vec_as_location(c(foo = NA), 3L), c(foo = na_int, foo = na_int, foo = na_int))

  # Names of negative selections are dropped
  expect_identical(vec_as_location(c(a = -1L, b = -3L), 3L), 2L)
})

test_that("vec_as_location2() optionally allows missing values", {
  expect_identical(vec_as_location2(NA, 2L, missing = "propagate"), na_int)
  expect_error(vec_as_location2(NA, 2L, missing = "error"), class = "vctrs_error_subscript_type")
})

test_that("num_as_location2() optionally allows missing and negative locations", {
  expect_identical(num_as_location2(na_dbl, 2L, missing = "propagate"), na_int)
  expect_identical(num_as_location2(-1, 2L, negative = "ignore"), -1L)
  expect_error(num_as_location2(-3, 2L, negative = "ignore"), class = "vctrs_error_subscript_oob")
  expect_error(num_as_location2(0, 2L, negative = "ignore"), class = "vctrs_error_subscript_type")
})

test_that("num_as_location() optionally allows negative indices", {
  expect_identical(num_as_location(dbl(1, -1), 2L, negative = "ignore"), int(1L, -1L))
  expect_error(num_as_location(c(1, -10), 2L, negative = "ignore"), class = "vctrs_error_subscript_oob")
})

test_that("num_as_location() optionally forbids negative indices", {
  expect_snapshot({
    (expect_error(num_as_location(dbl(1, -1), 2L, negative = "error"), class = "vctrs_error_subscript_type"))
  })
  expect_error(num_as_location(c(1, -10), 2L, negative = "error"), class = "vctrs_error_subscript_type")
})

test_that("num_as_location() optionally ignores zero indices", {
  expect_identical(num_as_location(c(1, 0), 2L, zero = "ignore"), c(1L, 0L))
})

test_that("num_as_location() optionally forbids zero indices", {
  expect_snapshot({
    (expect_error(
      num_as_location(0L, 1L, zero = "error"),
      class = "vctrs_error_subscript_type"
    ))
    (expect_error(
      num_as_location(c(0, 0, 0, 0, 0, 0), 1, zero = "error"),
      class = "vctrs_error_subscript_type"
    ))
  })
})

test_that("vec_as_location() handles NULL", {
  expect_identical(
    vec_as_location(NULL, 10),
    vec_as_location(int(), 10),
  )
})

test_that("vec_as_location() checks for mix of negative and missing locations", {
  expect_snapshot({
    (expect_error(
      vec_as_location(-c(1L, NA), 30),
      class = "vctrs_error_subscript_type"
    ))
    (expect_error(
      vec_as_location(-c(1L, rep(NA, 10)), 30),
      class = "vctrs_error_subscript_type"
    ))
  })
})

test_that("vec_as_location() checks for mix of negative and positive locations", {
  expect_snapshot({
    (expect_error(
      vec_as_location(c(-1L, 1L), 30),
      class = "vctrs_error_subscript_type"
    ))
    (expect_error(
      vec_as_location(c(-1L, rep(1L, 10)), 30),
      class = "vctrs_error_subscript_type"
    ))
  })
})

test_that("logical subscripts must match size of indexed vector", {
  expect_snapshot({
    (expect_error(
      vec_as_location(c(TRUE, FALSE), 3),
      class = "vctrs_error_subscript_size"
    ))
  })
})

test_that("character subscripts require named vectors", {
  expect_snapshot({
    (expect_error(vec_as_location(letters[1], 3), "unnamed vector"))
  })
})

test_that("arg is evaluated lazily (#1150)", {
  expect_silent(vec_as_location(1, 1, arg = { writeLines("oof"); "boo" }))
})

test_that("arg works for complex expressions (#1150)", {
  expect_error(vec_as_location(mean, 1, arg = paste0("foo", "bar")), "foobar")
})

test_that("can optionally extend beyond the end", {
  expect_error(num_as_location(1:5, 3), class = "vctrs_error_subscript_oob")

  expect_identical(num_as_location(1:5, 3, oob = "extend"), 1:5)
  expect_identical(num_as_location(4:5, 3, oob = "extend"), 4:5)

  expect_snapshot({
    (expect_error(
      num_as_location(3, 1, oob = "extend"),
      class = "vctrs_error_subscript_oob"
    ))
    (expect_error(
      num_as_location(c(1, 3), 1, oob = "extend"),
      class = "vctrs_error_subscript_oob"
    ))
    (expect_error(
      num_as_location(c(1:5, 7), 3, oob = "extend"),
      class = "vctrs_error_subscript_oob"
    ))
    (expect_error(
      num_as_location(c(1:5, 7, 1), 3, oob = "extend"),
      class = "vctrs_error_subscript_oob"
    ))
    (expect_error(
      class = "vctrs_error_subscript_oob",
      num_as_location(c(1:5, 7, 1, 10), 3, oob = "extend")
    ))
  })
})

test_that("can extend beyond the end consecutively but non-monotonically (#1166)", {
  expect_identical(num_as_location(6:4, 3, oob = "extend"), 6:4)
  expect_identical(num_as_location(c(1:5, 7, 6), 3, oob = "extend"), c(1:5, 7L, 6L))
  expect_identical(num_as_location(c(1, NA, 4, 3), 2, oob = "extend"), c(1L, NA, 4L, 3L))
})

test_that("num_as_location() can optionally remove oob values (#1595)", {
  expect_identical(num_as_location(c(5, 3, 2, 4), 3, oob = "remove"), c(3L, 2L))
  expect_identical(num_as_location(c(-4, 5, 2, -1), 3, oob = "remove", negative = "ignore"), c(2L, -1L))
})

test_that("num_as_location() errors when inverting oob negatives unless `oob = 'remove'` (#1630)", {
  expect_snapshot(error = TRUE, {
    num_as_location(-4, 3, oob = "error", negative = "invert")
  })
  expect_snapshot(error = TRUE, {
    num_as_location(c(-4, 4, 5), 3, oob = "extend", negative = "invert")
  })
  expect_identical(num_as_location(-4, 3, oob = "remove", negative = "invert"), c(1L, 2L, 3L))
  expect_identical(num_as_location(c(-4, -2), 3, oob = "remove", negative = "invert"), c(1L, 3L))
})

test_that("num_as_location() generally drops zeros when inverting negatives (#1612)", {
  expect_identical(
    num_as_location(c(-3, 0, -1), n = 5L, negative = "invert", zero = "remove"),
    c(2L, 4L, 5L)
  )

  # Trying to "ignore" and retain the zeroes in the output doesn't make sense,
  # where would they be placed? Instead, think of the ignored zeros as being
  # inverted as well, they just don't correspond to any location after the
  # inversion so they aren't in the output.
  expect_identical(
    num_as_location(c(-3, 0, -1, 0), n = 5L, negative = "invert", zero = "ignore"),
    c(2L, 4L, 5L)
  )
})

test_that("num_as_location() errors on disallowed zeros when inverting negatives (#1612)", {
  expect_snapshot(error = TRUE, {
    num_as_location(c(0, -1), n = 2L, negative = "invert", zero = "error")
  })
  expect_snapshot(error = TRUE, {
    num_as_location(c(-1, 0), n = 2L, negative = "invert", zero = "error")
  })
})

test_that("num_as_location() with `oob = 'remove'` doesn't remove missings if they are being propagated", {
  expect_identical(num_as_location(NA_integer_, 1, oob = "remove"), NA_integer_)
})

test_that("num_as_location() with `oob = 'remove'` doesn't remove zeros if they are being ignored", {
  expect_identical(num_as_location(0, 1, oob = "remove", zero = "ignore"), 0L)
  expect_identical(num_as_location(0, 0, oob = "remove", zero = "ignore"), 0L)
})

test_that("num_as_location() with `oob = 'extend'` doesn't allow ignored oob negative values (#1614)", {
  # This is fine (ignored negative that is in bounds)
  expect_identical(num_as_location(c(-5L, 6L), 5L, oob = "extend", negative = "ignore"), c(-5L, 6L))

  expect_snapshot(error = TRUE, {
    # Ignored negatives aren't allowed to extend the vector
    num_as_location(-6L, 5L, oob = "extend", negative = "ignore")
  })
  expect_snapshot(error = TRUE, {
    # Ensure error only reports negative indices
    num_as_location(c(-7L, 6L), 5L, oob = "extend", negative = "ignore")
  })
  expect_snapshot(error = TRUE, {
    num_as_location(c(-7L, NA), 5L, oob = "extend", negative = "ignore")
  })
})

test_that("num_as_location() with `oob = 'error'` reports negative and positive oob values", {
  expect_snapshot(error = TRUE, {
    num_as_location(c(-6L, 7L), n = 5L, oob = "error", negative = "ignore")
  })
})

test_that("num_as_location() with `missing = 'remove'` retains names (#1633)", {
  x <- c(a = 1, b = NA, c = 2, d = NA)
  expect_named(num_as_location(x, n = 2, missing = "remove"), c("a", "c"))
})

test_that("num_as_location() with `zero = 'remove'` retains names (#1633)", {
  x <- c(a = 1, b = 0, c = 2, d = 0)
  expect_named(num_as_location(x, n = 2, zero = "remove"), c("a", "c"))
})

test_that("num_as_location() with `oob = 'remove'` retains names (#1633)", {
  x <- c(a = 1, b = 3, c = 2, d = 4)
  expect_named(num_as_location(x, n = 2, oob = "remove"), c("a", "c"))
})

test_that("num_as_location() with `negative = 'invert'` drops names (#1633)", {
  # The inputs don't map 1:1 to outputs
  x <- c(a = -1, b = -3)
  expect_named(num_as_location(x, n = 5), NULL)
})

test_that("missing values are supported in error formatters", {
  expect_snapshot({
    (expect_error(
      num_as_location(c(1, NA, 2, 3), 1),
      class = "vctrs_error_subscript_oob"
    ))
    (expect_error(
      num_as_location(c(1, NA, 3), 1, oob = "extend"),
      class = "vctrs_error_subscript_oob"
    ))
  })
})

test_that("can disallow missing values", {
  expect_snapshot({
    (expect_error(
      vec_as_location(c(1, NA), 2, missing = "error"),
      class = "vctrs_error_subscript_type"
    ))
    (expect_error(
      vec_as_location(c(1, NA, 2, NA), 2, missing = "error", arg = "foo", call = call("my_function")),
      class = "vctrs_error_subscript_type"
    ))
    (expect_error(
      with_tibble_cols(vec_as_location(c(1, NA, 2, NA), 2, missing = "error")),
      class = "vctrs_error_subscript_type"
    ))
    (expect_error(
      with_tibble_cols(vec_as_location(NA, 1, missing = "error")),
      class = "vctrs_error_subscript_type"
    ))
    (expect_error(
      with_tibble_cols(vec_as_location(NA, 3, missing = "error")),
      class = "vctrs_error_subscript_type"
    ))
    (expect_error(
      with_tibble_cols(vec_as_location(c(TRUE, NA, FALSE), 3, missing = "error")),
      class = "vctrs_error_subscript_type"
    ))
    (expect_error(
      with_tibble_cols(vec_as_location(NA_character_, 2, missing = "error", names = c("x", "y"))),
      class = "vctrs_error_subscript_type"
    ))
  })
})

test_that("can alter logical missing value handling (#1595)", {
  x <- c(a = TRUE, b = NA, c = FALSE, d = NA)

  expect_identical(
    vec_as_location(x, n = 4L, missing = "propagate"),
    c(a = 1L, b = NA, d = NA)
  )
  expect_identical(
    vec_as_location(x, n = 4L, missing = "remove"),
    c(a = 1L)
  )
  expect_snapshot(error = TRUE, {
    vec_as_location(x, n = 4L, missing = "error")
  })

  # Specifically test size 1 case, which has its own special path
  x <- c(a = NA)

  expect_identical(
    vec_as_location(x, n = 2L, missing = "propagate"),
    c(a = NA_integer_, a = NA_integer_)
  )
  expect_identical(
    vec_as_location(x, n = 2L, missing = "remove"),
    named(integer())
  )
  expect_snapshot(error = TRUE, {
    vec_as_location(x, n = 2L, missing = "error")
  })
})

test_that("can alter character missing value handling (#1595)", {
  x <- c(NA, "z", NA)
  names(x) <- c("a", "b", "c")
  names <- c("x", "z")

  expect_identical(
    vec_as_location(x, n = 2L, names = names, missing = "propagate"),
    set_names(c(NA, 2L, NA), names(x))
  )
  expect_identical(
    vec_as_location(x, n = 2L, names = names, missing = "remove"),
    set_names(2L, "b")
  )
  expect_snapshot(error = TRUE, {
    vec_as_location(x, n = 2L, names = names, missing = "error")
  })
})

test_that("can alter integer missing value handling (#1595)", {
  x <- c(NA, 1L, NA, 3L)
  names(x) <- c("a", "b", "c", "d")

  expect_identical(
    vec_as_location(x, n = 4L, missing = "propagate"),
    x
  )
  expect_identical(
    vec_as_location(x, n = 4L, missing = "remove"),
    c(b = 1L, d = 3L)
  )
  expect_snapshot(error = TRUE, {
    vec_as_location(x, n = 4L, missing = "error")
  })
})

test_that("can alter negative integer missing value handling (#1595)", {
  x <- c(-1L, NA, NA, -3L)

  expect_snapshot(error = TRUE, {
    num_as_location(x, n = 4L, missing = "propagate", negative = "invert")
  })
  expect_identical(
    num_as_location(x, n = 4L, missing = "remove", negative = "invert"),
    c(2L, 4L)
  )
  expect_snapshot(error = TRUE, {
    num_as_location(x, n = 4L, missing = "error", negative = "invert")
  })
})

test_that("missing value character indices never match missing value names (#1489)", {
  x <- NA_character_
  names <- NA_character_

  expect_identical(vec_as_location(x, n = 1L, names = names, missing = "propagate"), NA_integer_)
  expect_identical(vec_as_location(x, n = 1L, names = names, missing = "remove"), integer())
})

test_that("empty string character indices never match empty string names (#1489)", {
  names <- c("", "y")

  expect_snapshot(error = TRUE, {
    vec_as_location("", n = 2L, names = names)
  })
  expect_snapshot(error = TRUE, {
    vec_as_location(c("", "y", ""), n = 2L, names = names)
  })
})

test_that("scalar logical `FALSE` and `NA` cases don't modify a shared object (#1633)", {
  x <- vec_as_location(FALSE, n = 2)
  expect_identical(x, integer())

  y <- vec_as_location(c(a = FALSE), n = 2)
  expect_identical(y, named(integer()))
  # Still unnamed
  expect_identical(x, integer())


  x <- vec_as_location(NA, n = 2, missing = "remove")
  expect_identical(x, integer())

  y <- vec_as_location(c(a = FALSE), n = 2, missing = "remove")
  expect_identical(y, named(integer()))
  # Still unnamed
  expect_identical(x, integer())
})

test_that("can customise subscript type errors", {
  expect_snapshot({
    "With custom `arg`"
    (expect_error(
      num_as_location(-1, 2, negative = "error", arg = "foo", call = call("my_function")),
      class = "vctrs_error_subscript_type"
    ))
    (expect_error(
      num_as_location2(-1, 2, negative = "error", arg = "foo", call = call("my_function")),
      class = "vctrs_error_subscript_type"
    ))
    (expect_error(
      vec_as_location2(0, 2, arg = "foo", call = call("my_function")),
      class = "vctrs_error_subscript_type"
    ))
    (expect_error(
      vec_as_location2(na_dbl, 2, arg = "foo", call = call("my_function")),
      class = "vctrs_error_subscript_type"
    ))
    (expect_error(
      vec_as_location2(c(1, 2), 2, arg = "foo", call = call("my_function")),
      class = "vctrs_error_subscript_type"
    ))
    (expect_error(
      vec_as_location(c(TRUE, FALSE), 3, arg = "foo", call = call("my_function")),
      class = "vctrs_error_subscript_size"
    ))
    (expect_error(
      vec_as_location(c(-1, NA), 3, arg = "foo", call = call("my_function")),
      class = "vctrs_error_subscript_type"
    ))
    (expect_error(
      vec_as_location(c(-1, 1), 3, arg = "foo", call = call("my_function")),
      class = "vctrs_error_subscript_type"
    ))
    (expect_error(
      num_as_location(c(1, 4), 2, oob = "extend", arg = "foo", call = call("my_function")),
      class = "vctrs_error_subscript_oob"
    ))
    (expect_error(
      num_as_location(0, 1, zero = "error", arg = "foo", call = call("my_function")),
      class = "vctrs_error_subscript_type"
    ))

    "With tibble columns"
    (expect_error(
      with_tibble_cols(num_as_location(-1, 2, negative = "error")),
      class = "vctrs_error_subscript_type"
    ))
    (expect_error(
      with_tibble_cols(num_as_location2(-1, 2, negative = "error")),
      class = "vctrs_error_subscript_type"
    ))
    (expect_error(
      with_tibble_cols(vec_as_location2(0, 2)),
      class = "vctrs_error_subscript_type"
    ))
    (expect_error(
      with_tibble_cols(vec_as_location2(na_dbl, 2)),
      class = "vctrs_error_subscript_type"
    ))
    (expect_error(
      with_tibble_cols(vec_as_location2(c(1, 2), 2)),
      class = "vctrs_error_subscript_type"
    ))
    (expect_error(
      with_tibble_cols(vec_as_location(c(TRUE, FALSE), 3)),
      class = "vctrs_error_subscript_size"
    ))
    (expect_error(
      with_tibble_cols(vec_as_location(c(-1, NA), 3)),
      class = "vctrs_error_subscript_type"
    ))
    (expect_error(
      with_tibble_cols(vec_as_location(c(-1, 1), 3)),
      class = "vctrs_error_subscript_type"
    ))
    (expect_error(
      with_tibble_cols(num_as_location(c(1, 4), 2, oob = "extend")),
      class = "vctrs_error_subscript_oob"
    ))
    (expect_error(
      with_tibble_cols(num_as_location(0, 1, zero = "error")),
      class = "vctrs_error_subscript_type"
    ))
  })
})

test_that("can customise OOB errors", {
  expect_snapshot({
    (expect_error(
      vec_slice(set_names(letters), "foo"),
      class = "vctrs_error_subscript_oob"
    ))

    "With custom `arg`"
    (expect_error(
      vec_as_location(30, length(letters), arg = "foo", call = call("my_function")),
      class = "vctrs_error_subscript_oob"
    ))
    (expect_error(
      vec_as_location("foo", NULL, letters, arg = "foo", call = call("my_function")),
      class = "vctrs_error_subscript_oob"
    ))

    "With tibble columns"
    (expect_error(
      with_tibble_cols(vec_slice(set_names(letters), "foo")),
      class = "vctrs_error_subscript_oob"
    ))
    (expect_error(
      with_tibble_cols(vec_slice(set_names(letters), 30)),
      class = "vctrs_error_subscript_oob"
    ))
    (expect_error(
      with_tibble_cols(vec_slice(set_names(letters), -30)),
      class = "vctrs_error_subscript_oob"
    ))

    "With tibble rows"
    (expect_error(
      with_tibble_rows(vec_slice(set_names(letters), c("foo", "bar"))),
      class = "vctrs_error_subscript_oob"
    ))
    (expect_error(
      with_tibble_rows(vec_slice(set_names(letters), 1:30)),
      class = "vctrs_error_subscript_oob"
    ))
    (expect_error(
      with_tibble_rows(vec_slice(set_names(letters), -(1:30))),
      class = "vctrs_error_subscript_oob"
    ))

    "With tidyselect select"
    (expect_error(
      with_tidyselect_select(vec_slice(set_names(letters), c("foo", "bar"))),
      class = "vctrs_error_subscript_oob"
    ))
    (expect_error(
      with_tidyselect_select(vec_slice(set_names(letters), 30)),
      class = "vctrs_error_subscript_oob"
    ))
    (expect_error(
      with_tidyselect_select(vec_slice(set_names(letters), -(1:30))),
      class = "vctrs_error_subscript_oob"
    ))

    "With tidyselect relocate"
    (expect_error(
      with_tidyselect_relocate(vec_slice(set_names(letters), c("foo", "bar"))),
      class = "vctrs_error_subscript_oob"
    ))
    (expect_error(
      with_tidyselect_relocate(vec_slice(set_names(letters), 30)),
      class = "vctrs_error_subscript_oob"
    ))
    (expect_error(
      with_tidyselect_relocate(vec_slice(set_names(letters), -(1:30))),
      class = "vctrs_error_subscript_oob"
    ))
  })
})

test_that("num_as_location() requires non-S3 inputs", {
  expect_error(num_as_location(factor("foo"), 2), "must be a numeric vector")
})

test_that("vec_as_location() checks dimensionality", {
  expect_snapshot({
    (expect_error(vec_as_location(matrix(TRUE, nrow = 1), 3L), class = "vctrs_error_subscript_type"))
    (expect_error(vec_as_location(array(TRUE, dim = c(1, 1, 1)), 3L), class = "vctrs_error_subscript_type"))
    (expect_error(with_tibble_rows(vec_as_location(matrix(TRUE, nrow = 1), 3L)), class = "vctrs_error_subscript_type"))
  })
})

test_that("vec_as_location() works with vectors of dimensionality 1", {
  expect_identical(vec_as_location(array(TRUE, dim = 1), 3L), 1:3)
})

test_that("vec_as_location() UI", {
  expect_snapshot(error = TRUE, vec_as_location(1, 1L, missing = "bogus"))
})

test_that("num_as_location() UI", {
  expect_snapshot(error = TRUE, num_as_location(1, 1L, missing = "bogus"))
  expect_snapshot(error = TRUE, num_as_location(1, 1L, negative = "bogus"))
  expect_snapshot(error = TRUE, num_as_location(1, 1L, oob = "bogus"))
  expect_snapshot(error = TRUE, num_as_location(1, 1L, zero = "bogus"))
})

test_that("vec_as_location2() UI", {
  expect_snapshot(error = TRUE, vec_as_location2(1, 1L, missing = "bogus"))
})

test_that("vec_as_location() evaluates arg lazily", {
  expect_silent(vec_as_location(1L, 1L, arg = print("oof")))
})

test_that("vec_as_location2() evaluates arg lazily", {
  expect_silent(vec_as_location2(1L, 1L, arg = print("oof")))
  expect_silent(vec_as_location2_result(1L, 1L, names = NULL, arg = print("oof"), missing = "error", negative = "error", call = NULL))
})
