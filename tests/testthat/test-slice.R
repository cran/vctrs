
test_that("vec_slice throws error with non-vector inputs", {
  expect_error(vec_slice(environment(), 1L), class = "vctrs_error_scalar_type")
})

test_that("vec_slice throws error with non-vector subscripts", {
  expect_snapshot({
    (expect_error(vec_slice(1:3, Sys.Date()), class = "vctrs_error_subscript_type"))
    (expect_error(vec_slice(1:3, matrix(TRUE, nrow = 1)), class = "vctrs_error_subscript_type"))
  })
})

test_that("can subset base vectors", {
  i <- 2:3
  expect_identical(vec_slice(lgl(1, 0, 1), i), lgl(0, 1))
  expect_identical(vec_slice(int(1, 2, 3), i), int(2, 3))
  expect_identical(vec_slice(dbl(1, 2, 3), i), dbl(2, 3))
  expect_identical(vec_slice(cpl(1, 2, 3), i), cpl(2, 3))
  expect_identical(vec_slice(chr("1", "2", "3"), i), chr("2", "3"))
  expect_identical(vec_slice(raw2(1, 2, 3), i), raw2(2, 3))
  expect_identical(vec_slice(list(1, 2, 3), i), list(2, 3))
})

test_that("can subset shaped base vectors", {
  i <- 2:3
  mat <- as.matrix
  expect_identical(vec_slice(mat(lgl(1, 0, 1)), i), mat(lgl(0, 1)))
  expect_identical(vec_slice(mat(int(1, 2, 3)), i), mat(int(2, 3)))
  expect_identical(vec_slice(mat(dbl(1, 2, 3)), i), mat(dbl(2, 3)))
  expect_identical(vec_slice(mat(cpl(1, 2, 3)), i), mat(cpl(2, 3)))
  expect_identical(vec_slice(mat(chr("1", "2", "3")), i), mat(chr("2", "3")))
  expect_identical(vec_slice(mat(raw2(1, 2, 3)), i), mat(raw2(2, 3)))
  expect_identical(vec_slice(mat(list(1, 2, 3)), i), mat(list(2, 3)))
})

test_that("can subset with missing indices", {
  for (i in list(int(2L, NA), lgl(FALSE, TRUE, NA))) {
    expect_identical(vec_slice(lgl(1, 0, 1), i), lgl(0, NA))
    expect_identical(vec_slice(int(1, 2, 3), i), int(2, NA))
    expect_identical(vec_slice(dbl(1, 2, 3), i), dbl(2, NA))
    expect_identical(vec_slice(cpl2(1, 2, 3), i), cpl2(2, NA))
    expect_identical(vec_slice(chr("1", "2", "3"), i), c("2", NA))
    expect_identical(vec_slice(raw2(1, 2, 3), i), raw2(2, 0))
    expect_identical(vec_slice(list(1, 2, 3), i), list(2, NULL))
  }
})

test_that("can subset with a recycled NA", {
  local_name_repair_quiet()

  expect_identical(vec_slice(1:3, NA), int(NA, NA, NA))
  expect_identical(vec_slice(new_vctr(1:3), NA), new_vctr(int(NA, NA, NA)))

  rownames <- rep_len("", nrow(mtcars))
  rownames <- vec_as_names(rownames, repair = "unique")
  expect_identical(vec_slice(mtcars, NA), structure(mtcars[NA, ], row.names = rownames))
})

test_that("can subset with a recycled TRUE", {
  expect_identical(vec_slice(1:3, TRUE), 1:3)
  expect_identical(vec_slice(mtcars, TRUE), mtcars)
  expect_identical(vec_slice(new_vctr(1:3), TRUE), new_vctr(1:3))
  expect_identical(vec_as_location(TRUE, 2), 1:2)
})

test_that("can subset with a recycled FALSE", {
  expect_identical(vec_slice(1:3, FALSE), int())
  expect_identical(vec_slice(mtcars, FALSE), mtcars[NULL, ])
  expect_identical(vec_slice(new_vctr(1:3), FALSE), new_vctr(integer()))
})

test_that("can't index beyond the end of a vector", {
  expect_snapshot({
    (expect_error(vec_slice(1:2, 3L), class = "vctrs_error_subscript_oob"))
    (expect_error(vec_slice(1:2, -3L), class = "vctrs_error_subscript_oob"))
  })
})

test_that("slicing non existing elements fails", {
  expect_error(vec_as_location("foo", 1L, "f"), class = "vctrs_error_subscript_oob")
  expect_error(vec_slice(c(f = 1), "foo"), class = "vctrs_error_subscript_oob")
})

test_that("can subset object of any dimensionality", {
  x0 <- c(1, 1)
  x1 <- ones(2)
  x2 <- ones(2, 3)
  x3 <- ones(2, 3, 4)
  x4 <- ones(2, 3, 4, 5)

  expect_equal(vec_slice(x0, 1L), 1)
  expect_identical(vec_slice(x1, 1L), ones(1))
  expect_identical(vec_slice(x2, 1L), ones(1, 3))
  expect_identical(vec_slice(x3, 1L), ones(1, 3, 4))
  expect_identical(vec_slice(x4, 1L), ones(1, 3, 4, 5))
})

test_that("can subset using logical subscript", {
  x0 <- c(1, 1)

  expect_identical(vec_slice(x0, TRUE), x0)
  expect_identical(vec_slice(x0, c(TRUE, FALSE)), 1)

  expect_error(
    vec_slice(x0, c(TRUE, FALSE, TRUE)),
    class = "vctrs_error_subscript_size"
  )

  expect_error(
    vec_slice(x0, lgl()),
    class = "vctrs_error_subscript_size"
  )

  expect_error(
    vec_slice(mtcars, c(TRUE, FALSE)),
    class = "vctrs_error_subscript_size"
  )
})

test_that("can subset data frame columns", {
  df <- data.frame(x = 1:2)
  df$y <- data.frame(a = 2:1)

  expect_equal(vec_slice(df, 1L)$y, vec_slice(df$y, 1L))
})

test_that("can subset empty data frames", {
  df <- new_data_frame(n = 3L)
  expect_equal(vec_size(vec_slice(df, integer())), 0)
  expect_equal(vec_size(vec_slice(df, 1L)), 1)
  expect_equal(vec_size(vec_slice(df, 1:3)), 3)

  df$df <- df
  expect_equal(vec_size(vec_slice(df, integer())), 0)
  expect_equal(vec_size(vec_slice(df, 1L)), 1)
  expect_equal(vec_size(vec_slice(df, 1:3)), 3)
})

test_that("ignores NA in logical subsetting", {
  x <- c(NA, 1, 2)
  expect_equal(vec_slice(x, x > 0), c(NA, 1, 2))
})

test_that("ignores NA in integer subsetting", {
  expect_equal(vec_slice(0:2, c(NA, 2:3)), c(NA, 1, 2))
})

test_that("can't slice with missing argument", {
  expect_error(vec_slice(1:3))
  expect_error(vec_slice(mtcars))
  expect_error(vec_slice(new_vctr(1:3)))
})

test_that("can slice with NULL argument", {
  expect_identical(vec_slice(1:3, NULL), integer())
  expect_identical(vec_slice(iris, NULL), iris[0, ])
  expect_identical(vec_slice(new_vctr(1:3), NULL), new_vctr(integer()))
})

test_that("slicing unclassed structures preserves attributes", {
  x <- structure(1:3, foo = "bar")
  expect_identical(vec_slice(x, 1L), structure(1L, foo = "bar"))
})

test_that("can slice with negative indices", {
  expect_identical(vec_slice(1:3, -c(1L, 3L)), 2L)
  expect_identical(vec_slice(mtcars, -(1:30)), vec_slice(mtcars, 31:32))

  expect_error(vec_slice(1:3, -c(1L, NA)), class = "vctrs_error_subscript_type")
  expect_error(vec_slice(1:3, c(-1L, 1L)), class = "vctrs_error_subscript_type")
})

test_that("0 is ignored in negative indices", {
  expect_identical(vec_slice(1:3, c(-2L, 0L)), int(1L, 3L))
  expect_identical(vec_slice(1:3, c(0L, -2L)), int(1L, 3L))
})

test_that("0 is ignored in positive indices", {
  expect_identical(vec_slice(1:3, 0L), int())
  expect_identical(vec_slice(1:3, c(0L, 0L)), int())
  expect_identical(vec_slice(1:3, c(0L, 2L, 0L)), 2L)
})

test_that("can slice with double indices", {
  expect_identical(vec_slice(1:3, dbl(2, 3)), 2:3)
  expect_snapshot((expect_error(vec_as_location(2^31, 3L), class = "vctrs_error_subscript_type")))
})

test_that("can slice with symbols", {
  expect_identical(vec_as_location(quote(b), 26, letters), 2L)
})

test_that("can `vec_slice()` S3 objects without dispatch infloop", {
  expect_identical(new_vctr(1:3)[1], new_vctr(1L))
  expect_identical(new_vctr(as.list(1:3))[1], new_vctr(list(1L)))
})

test_that("can `vec_slice()` records", {
  out <- vec_slice(new_rcrd(list(a = 1L, b = 2L)), rep(1, 3))
  expect_size(out, 3)

  out <- vec_init(new_rcrd(list(a = 1L, b = 2L)), 2)
  expect_size(out, 2)
})

test_that("vec_restore() is called after proxied slicing", {
  local_methods(
    vec_proxy.vctrs_foobar = function(x, ...) x,
    vec_restore.vctrs_foobar = function(x, to, ...) "dispatch"
  )
  expect_identical(vec_slice(foobar(1:3), 2), "dispatch")
})

test_that("vec_slice() is proxied", {
  local_proxy()
  x <- vec_slice(new_proxy(1:3), 2:3)
  expect_identical(proxy_deref(x), 2:3)
})

test_that("dimensions are preserved by vec_slice()", {
  # Fallback case
  x <- foobar(1:4)
  dim(x) <- c(2, 2)
  dimnames(x) <- list(a = c("foo", "bar"), b = c("quux", "hunoz"))

  out <- vec_slice(x, 1)
  exp <- foobar(
    c(1L, 3L),
    dim = c(1, 2),
    dimnames = list(a = "foo", b = c("quux", "hunoz")
  ))
  expect_identical(out, exp)


  # Native case
  attrib <- NULL

  local_methods(
    vec_proxy.vctrs_foobar = function(x, ...) x,
    vec_restore.vctrs_foobar = function(x, to, ...) attrib <<- attributes(x)
  )

  vec_slice(x, 1)

  exp <- list(dim = 1:2, dimnames = list(a = "foo", b = c("quux", "hunoz")))
  expect_identical(attrib, exp)
})

test_that("can slice shaped objects by name", {
  x <- matrix(1:2)

  expect_error(vec_slice(x, "foo"), "unnamed")

  dimnames(x) <- list(c("foo", "bar"))

  expect_equal(vec_slice(x, "foo"), vec_slice(x, 1L))
  expect_error(vec_slice(x, "baz"), class = "vctrs_error_subscript_oob")
})

test_that("vec_slice() unclasses input before calling `vec_restore()`", {
  oo <- NULL
  local_methods(
    vec_proxy.vctrs_foobar = function(x, ...) x,
    vec_restore.vctrs_foobar = function(x, ...) oo <<- is.object(x)
  )

  x <- foobar(1:4)
  dim(x) <- c(2, 2)

  vec_slice(x, 1)
  expect_false(oo)
})

test_that("can call `vec_slice()` from `[` methods with shaped objects without infloop", {
  local_methods(
    `[.vctrs_foobar` = function(x, i, ...) vec_slice(x, i)
  )

  x <- foobar(1:4)
  dim(x) <- c(2, 2)

  exp <- foobar(c(1L, 3L))
  dim(exp) <- c(1, 2)
  expect_identical(x[1], exp)
})

test_that("vec_slice() restores attributes on shaped S3 objects correctly", {
  x <- factor(c("a", "b", "c", "d", "e", "f"))
  dim(x) <- c(3, 2)

  expect <- factor(c("a", "c", "d", "f"), levels = levels(x))
  dim(expect) <- c(2, 2)

  expect_identical(vec_slice(x, c(1, 3)), expect)
})

test_that("vec_slice() falls back to `[` with S3 objects", {
  local_methods(
    `[.vctrs_foobar` = function(x, i, ...) "dispatched"
  )
  expect_identical(vec_slice(foobar(NA), 1), "dispatched")

  expect_error(vec_slice(foobar(list(NA)), 1), class = "vctrs_error_scalar_type")
  local_methods(
    vec_proxy.vctrs_foobar = function(x, ...) x
  )
  expect_identical(vec_slice(foobar(list(NA)), 1), foobar(list(NA)))
})

test_that("vec_slice() doesn't restore when attributes have already been restored", {
  local_methods(
    `[.vctrs_foobar` = function(x, i, ...) structure("dispatched", foo = "bar"),
    vec_restore.vctrs_foobar = function(...) stop("not called")
  )
  expect_error(vec_slice(foobar(NA), 1), NA)
})

test_that("vec_slice() doesn't restore when `[` method intentionally dropped attributes", {
  local_methods(
    `[.vctrs_foobar` = function(x, i, ...) unstructure(NextMethod()),
    vec_restore.vctrs_foobar = function(...) stop("not called")
  )
  expect_identical(vec_slice(foobar(NA), 1), NA)
})

test_that("can vec_slice() without inflooping when restore calls math generics", {
  local_methods(
    new_foobar = function(x) {
      new_vctr(as.double(x), class = "vctrs_foobar")
    },
    vec_restore.vctrs_foobar = function(x, ...) {
      abs(x)
      sum(x)
      mean(x)
      is.finite(x)
      is.infinite(x)
      is.nan(x)
      new_foobar(x)
    }
  )
  expect_identical(new_foobar(1:10)[1:2], new_foobar(1:2))
})

test_that("vec_restore() is called after slicing data frames", {
  local_methods(
    vec_restore.vctrs_tabble = function(...) "dispatched"
  )
  df <- structure(mtcars, class = c("vctrs_tabble", "data.frame"))
  expect_identical(vec_slice(df, 1), "dispatched")
})

test_that("additional subscripts are forwarded to `[`", {
  local_methods(
    `[.vctrs_foobar` = function(x, i, ...) vec_index(x, i, ...)
  )

  x <- foobar(c("foo", "bar", "quux", "hunoz"))
  dim(x) <- c(2, 2)

  exp <- foobar("quux")
  dim(exp) <- c(1, 1)

  expect_identical(x[1, 2], exp)
})

test_that("can use names to vec_slice() a named object", {
  x0 <- c(a = 1, b = 2)
  x1 <- c(a = 1, a = 2)

  expect_identical(vec_slice(x0, letters[1]), c(a = 1))
  expect_identical(vec_slice(x0, letters[2:1]), c(b = 2, a = 1))
  expect_identical(vec_slice(x1, letters[1]), c(a = 1))

  expect_error(vec_slice(x0, letters[3:1]), class = "vctrs_error_subscript_oob")
  expect_error(vec_slice(x1, letters[2]), class = "vctrs_error_subscript_oob")
})

test_that("can't use names to vec_slice() an unnamed object", {
  expect_error(
    vec_slice(1:3, letters[1]),
    "Can't use character names to index an unnamed vector.",
    fixed = TRUE
  )
  expect_error(
    vec_slice(1:3, letters[25:27]),
    "Can't use character names to index an unnamed vector.",
    fixed = TRUE
  )
})

test_that("can slice with missing character indices (#244)", {
  expect_identical(vec_as_location(na_chr, 2L, c("x", "")), na_int)
  expect_identical(vec_slice(c(x = 1), na_chr), set_names(na_dbl, ""))
  expect_identical(vec_slice(c(x = "foo"), na_chr), set_names(na_chr, ""))
})

test_that("can slice with numerics (#577)", {
  expect_identical(vec_as_location(1:2, 3), 1:2)
  expect_error(vec_as_location(1:2, 3.5), class = "vctrs_error_cast_lossy")
})

test_that("missing indices don't create NA names", {
  x <- set_names(letters)
  expect_identical(vec_slice(x, na_int), set_names(na_chr, ""))
  expect_identical(vec_slice(x, int(1, NA, 3, NA)), chr(a = "a", NA, c = "c", NA))

  # Preserves existing NA names
  x <- set_names(1:2, c(NA, "foo"))
  expect_identical(vec_slice(x, 1:2), x)
})

test_that("vec_slice() asserts vectorness (#301)", {
  expect_error(vec_slice(NULL, 1), class = "vctrs_error_scalar_type")
})

test_that("slicing an unspecified logical vector returns a logical vector", {
  expect_identical(vec_slice(NA, integer()), logical())
  expect_identical(vec_slice(NA, c(1, 1)), c(NA, NA))
})

test_that("slicing an unspecified() object returns an unspecified()", {
  expect_identical(vec_slice(unspecified(1), integer()), unspecified())
  expect_identical(vec_slice(unspecified(1), c(1, 1)), unspecified(2))
})


test_that("vec_slice() works with Altrep classes with custom extract methods", {
  skip_if(getRversion() < "3.5")

  x <- .Call(vctrs_altrep_rle_Make, c(foo = 10L, bar = 5L))

  idx <- c(9, 10, 11)
  expect_equal(vec_slice(x, idx), c("foo", "foo", "bar"))
})

test_that("Unnamed vector with character subscript is caught", {
  expect_snapshot(error = TRUE, vec_slice(1:3, letters[1]))
})

test_that("Negative subscripts are checked", {
  expect_snapshot(error = TRUE, vec_slice(1:3, -c(1L, NA)))
  expect_snapshot(error = TRUE, vec_slice(1:3, c(-1L, 1L)))
})

test_that("oob error messages are properly constructed", {
  expect_snapshot(error = TRUE, vec_slice(c(bar = 1), "foo"))

  # Multiple OOB indices
  expect_snapshot(error = TRUE, vec_slice(letters, c(100, 1000)))
  expect_snapshot(error = TRUE, vec_slice(letters, c(1, 100:103, 2, 104:110)))
  expect_snapshot(error = TRUE, vec_slice(set_names(letters), c("foo", "bar")))
  expect_snapshot(error = TRUE, vec_slice(set_names(letters), toupper(letters)))
})

# vec_init ----------------------------------------------------------------

test_that("na of atomic vectors is as expected", {
  expect_equal(vec_init(TRUE), NA)
  expect_equal(vec_init(1L), NA_integer_)
  expect_equal(vec_init(1), NA_real_)
  expect_equal(vec_init("x"), NA_character_)
  expect_equal(vec_init(1i), NA_complex_)
})

test_that("na of factor preserves levels", {
  f1 <- factor("a", levels = c("a", "b"))
  f2 <- vec_init(f1)

  expect_equal(levels(f1), levels(f2))
})

test_that("na of POSIXct preserves tz", {
  dt1 <- as.POSIXct("2010-01-01", tz = "America/New_York")
  dt2 <- vec_init(dt1)
  expect_equal(attr(dt2, "tzone"), "America/New_York")
})

test_that("na of list is list(NULL)", {
  expect_equal(vec_init(list()), list(NULL))
})

test_that("na of array is 1d slice", {
  x1 <- array(1:12, c(2, 3, 4))
  x2 <- vec_init(x1)

  expect_equal(x2, array(NA_integer_, c(1, 3, 4)))
})

test_that("na of list-array is 1d slice", {
  x1 <- array(as.list(1:12), c(2, 3, 4))
  x2 <- vec_init(x1)

  expect_equal(x2, array(list(), c(1, 3, 4)))
})

test_that("vec_init() asserts vectorness (#301)", {
  expect_error(vec_init(NULL, 1L), class = "vctrs_error_scalar_type")
})

test_that("vec_init() works with Altrep classes", {
  skip_if(getRversion() < "3.5")

  x <- .Call(vctrs_altrep_rle_Make, c(foo = 1L, bar = 2L))

  expect_equal(vec_init(x, 2), rep(NA_character_, 2))
})

test_that("vec_init() validates `n`", {
  expect_snapshot({
    (expect_error(vec_init(1L, 1.5)))
    (expect_error(vec_init(1L, c(1, 2))))
    (expect_error(vec_init(1L, -1L)))
    (expect_error(vec_init(1L, NA)))
    (expect_error(vec_init(1L, NA_integer_)))
  })
})


# vec_slice + compact_rep -------------------------------------------------

# `i` is 1-based

test_that("names are repaired correctly with compact reps and `NA_integer_`", {
  x <- list(a = 1L, b = 2L)
  expect <- set_names(list(NULL, NULL), c("", ""))

  expect_equal(vec_slice_rep(x, NA_integer_, 2L), expect)
})

test_that("names are recycled correctly with compact reps", {
  expect_named(vec_slice_rep(c(x = 1L), 1L, 3L), c("x", "x", "x"))
})

test_that("vec_slice() with compact_reps work with Altrep classes", {
  skip_if(getRversion() < "3.5")

  x <- .Call(vctrs_altrep_rle_Make, c(foo = 10L, bar = 5L))

  expect_equal(vec_slice_rep(x, 10L, 3L), rep("foo", 3))
})

# vec_slice + compact_seq -------------------------------------------------

# `start` is 0-based

test_that("can subset base vectors with compact seqs", {
  start <- 1L
  size <- 2L
  increasing <- TRUE
  expect_identical(vec_slice_seq(lgl(1, 0, 1), start, size, increasing), lgl(0, 1))
  expect_identical(vec_slice_seq(int(1, 2, 3), start, size, increasing), int(2, 3))
  expect_identical(vec_slice_seq(dbl(1, 2, 3), start, size, increasing), dbl(2, 3))
  expect_identical(vec_slice_seq(cpl(1, 2, 3), start, size, increasing), cpl(2, 3))
  expect_identical(vec_slice_seq(chr("1", "2", "3"), start, size, increasing), chr("2", "3"))
  expect_identical(vec_slice_seq(raw2(1, 2, 3), start, size, increasing), raw2(2, 3))
  expect_identical(vec_slice_seq(list(1, 2, 3), start, size, increasing), list(2, 3))
})

test_that("can subset base vectors with decreasing compact seqs", {
  start <- 2L
  size <- 2L
  increasing <- FALSE
  expect_identical(vec_slice_seq(lgl(1, 0, 1), start, size, increasing), lgl(1, 0))
  expect_identical(vec_slice_seq(int(1, 2, 3), start, size, increasing), int(3, 2))
  expect_identical(vec_slice_seq(dbl(1, 2, 3), start, size, increasing), dbl(3, 2))
  expect_identical(vec_slice_seq(cpl(1, 2, 3), start, size, increasing), cpl(3, 2))
  expect_identical(vec_slice_seq(chr("1", "2", "3"), start, size, increasing), chr("3", "2"))
  expect_identical(vec_slice_seq(raw2(1, 2, 3), start, size, increasing), raw2(3, 2))
  expect_identical(vec_slice_seq(list(1, 2, 3), start, size, increasing), list(3, 2))
})

test_that("can subset base vectors with size 0 compact seqs", {
  start <- 1L
  size <- 0L
  increasing <- TRUE
  expect_identical(vec_slice_seq(lgl(1, 0, 1), start, size, increasing), lgl())
  expect_identical(vec_slice_seq(int(1, 2, 3), start, size, increasing), int())
  expect_identical(vec_slice_seq(dbl(1, 2, 3), start, size, increasing), dbl())
  expect_identical(vec_slice_seq(cpl(1, 2, 3), start, size, increasing), cpl())
  expect_identical(vec_slice_seq(chr("1", "2", "3"), start, size, increasing), chr())
  expect_identical(vec_slice_seq(raw2(1, 2, 3), start, size, increasing), raw2())
  expect_identical(vec_slice_seq(list(1, 2, 3), start, size, increasing), list())
})

test_that("can subset shaped base vectors with compact seqs", {
  start <- 1L
  size <- 2L
  increasing <- TRUE
  mat <- as.matrix
  expect_identical(vec_slice_seq(mat(lgl(1, 0, 1)), start, size, increasing), mat(lgl(0, 1)))
  expect_identical(vec_slice_seq(mat(int(1, 2, 3)), start, size, increasing), mat(int(2, 3)))
  expect_identical(vec_slice_seq(mat(dbl(1, 2, 3)), start, size, increasing), mat(dbl(2, 3)))
  expect_identical(vec_slice_seq(mat(cpl(1, 2, 3)), start, size, increasing), mat(cpl(2, 3)))
  expect_identical(vec_slice_seq(mat(chr("1", "2", "3")), start, size, increasing), mat(chr("2", "3")))
  expect_identical(vec_slice_seq(mat(raw2(1, 2, 3)), start, size, increasing), mat(raw2(2, 3)))
  expect_identical(vec_slice_seq(mat(list(1, 2, 3)), start, size, increasing), mat(list(2, 3)))
})

test_that("can subset shaped base vectors with decreasing compact seqs", {
  start <- 2L
  size <- 2L
  increasing <- FALSE
  mat <- as.matrix
  expect_identical(vec_slice_seq(mat(lgl(1, 0, 1)), start, size, increasing), mat(lgl(1, 0)))
  expect_identical(vec_slice_seq(mat(int(1, 2, 3)), start, size, increasing), mat(int(3, 2)))
  expect_identical(vec_slice_seq(mat(dbl(1, 2, 3)), start, size, increasing), mat(dbl(3, 2)))
  expect_identical(vec_slice_seq(mat(cpl(1, 2, 3)), start, size, increasing), mat(cpl(3, 2)))
  expect_identical(vec_slice_seq(mat(chr("1", "2", "3")), start, size, increasing), mat(chr("3", "2")))
  expect_identical(vec_slice_seq(mat(raw2(1, 2, 3)), start, size, increasing), mat(raw2(3, 2)))
  expect_identical(vec_slice_seq(mat(list(1, 2, 3)), start, size, increasing), mat(list(3, 2)))
})

test_that("can subset shaped base vectors with size 0 compact seqs", {
  start <- 1L
  size <- 0L
  increasing <- TRUE
  mat <- as.matrix
  expect_identical(vec_slice_seq(mat(lgl(1, 0, 1)), start, size, increasing), mat(lgl()))
  expect_identical(vec_slice_seq(mat(int(1, 2, 3)), start, size, increasing), mat(int()))
  expect_identical(vec_slice_seq(mat(dbl(1, 2, 3)), start, size, increasing), mat(dbl()))
  expect_identical(vec_slice_seq(mat(cpl(1, 2, 3)), start, size, increasing), mat(cpl()))
  expect_identical(vec_slice_seq(mat(chr("1", "2", "3")), start, size, increasing), mat(chr()))
  expect_identical(vec_slice_seq(mat(raw2(1, 2, 3)), start, size, increasing), mat(raw2()))
  expect_identical(vec_slice_seq(mat(list(1, 2, 3)), start, size, increasing), mat(list()))
})

test_that("can subset object of any dimensionality with compact seqs", {
  x0 <- c(1, 1)
  x1 <- ones(2)
  x2 <- ones(2, 3)
  x3 <- ones(2, 3, 4)
  x4 <- ones(2, 3, 4, 5)

  expect_equal(vec_slice_seq(x0, 0L, 1L), 1)
  expect_identical(vec_slice_seq(x1, 0L, 1L), ones(1))
  expect_identical(vec_slice_seq(x2, 0L, 1L), ones(1, 3))
  expect_identical(vec_slice_seq(x3, 0L, 1L), ones(1, 3, 4))
  expect_identical(vec_slice_seq(x4, 0L, 1L), ones(1, 3, 4, 5))
})

test_that("can subset data frames with compact seqs", {
  df <- data_frame(x = 1:5, y = letters[1:5])
  expect_equal(vec_slice_seq(df, 0L, 0L), vec_slice(df, integer()))
  expect_equal(vec_slice_seq(df, 0L, 1L), vec_slice(df, 1L))
  expect_equal(vec_slice_seq(df, 0L, 3L), vec_slice(df, 1:3))
  expect_equal(vec_slice_seq(df, 2L, 3L, FALSE), vec_slice(df, 3:1))

  df$df <- df
  expect_equal(vec_slice_seq(df, 0L, 0L), vec_slice(df, integer()))
  expect_equal(vec_slice_seq(df, 0L, 1L), vec_slice(df, 1L))
  expect_equal(vec_slice_seq(df, 0L, 3L), vec_slice(df, 1:3))
  expect_equal(vec_slice_seq(df, 2L, 3L, FALSE), vec_slice(df, 3:1))
})

test_that("can subset S3 objects using the fallback method with compact seqs", {
  x <- factor(c("a", "b", "c", "d"))
  expect_equal(vec_slice_seq(x, 0L, 0L), vec_slice(x, integer()))
  expect_equal(vec_slice_seq(x, 0L, 1L), vec_slice(x, 1L))
  expect_equal(vec_slice_seq(x, 2L, 2L), vec_slice(x, 3:4))
  expect_equal(vec_slice_seq(x, 3L, 2L, FALSE), vec_slice(x, 4:3))
})

test_that("vec_slice() with compact_seqs work with Altrep classes", {
  skip_if(getRversion() < "3.5")

  x <- .Call(vctrs_altrep_rle_Make, c(foo = 2L, bar = 3L))

  expect_equal(vec_slice_seq(x, 1L, 3L), c("foo", "bar", "bar"))
})

test_that("vec_slice() handles symbols and OO objects", {
  expect_identical(vec_slice(c(a = 1, b = 2), quote(b)), c(b = 2))
  expect_identical(vec_slice(c(a = 1, b = 2), factor("b")), c(b = 2))
  expect_error(vec_slice(c(a = 1, b = 2), foobar("b")), class = "vctrs_error_subscript_type")
})

test_that("vec_init() handles names in columns", {
  expect_identical(
    vec_init(data_frame(x = c(a = 1, b = 2)))$x,
    named(na_dbl)
  )
  expect_identical(
    vec_init(data_frame(x = c(1, 2)))$x,
    na_dbl
  )
})

test_that("vec_slice() restores unrestored but named foreign classes", {
  x <- foobar(c(x = 1))

  expect_identical(vec_slice(x, 1), x)
  expect_identical(vec_chop(x), list(x))
  expect_identical(vec_chop(x, indices = list(1)), list(x))
  expect_identical(vec_ptype(x), foobar(named(dbl())))
  expect_identical(vec_ptype(x), foobar(named(dbl())))
  expect_identical(vec_ptype_common(x, x), foobar(named(dbl())))

  out <- vec_ptype_common_fallback(x, x)
  expect_true(is_common_class_fallback(out))
  expect_identical(fallback_class(out), "vctrs_foobar")
})

test_that("scalar type error is thrown when `vec_slice_unsafe()` is called directly (#1139)", {
  x <- foobar(as.list(1:3))
  expect_error(vec_slice_seq(x, 1L, 1L), class = "vctrs_error_scalar_type")
})

test_that("column sizes are checked before slicing (#552)", {
  x <- structure(list(a = 1, b = 2:3), row.names = 1:2, class = "data.frame")
  expect_error(
    vctrs::vec_slice(x, 2),
    "Column `a` (size 1) must match the data frame (size 2)",
    fixed = TRUE
  )
})

test_that("base_vec_rep() slices data frames with the base::rep() UI", {
  df <- data_frame(x = data_frame(y = 1:2))
  expect_identical(
    base_vec_rep(df, length.out = 4),
    vec_slice(df, c(1:2, 1:2))
  )
})

test_that("vec_size_assign() slices data frames with the base::rep() UI", {
  df <- data_frame(x = data_frame(y = 1:3))

  expect_identical(
    vec_size_assign(df, 2),
    vec_slice(df, 1:2)
  )

  expect_identical(
    vec_size_assign(df, 4),
    vec_slice(df, c(1:3, NA))
  )
})
