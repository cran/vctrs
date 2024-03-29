# vec_identify_runs ------------------------------------------------------------

test_that("vec_identify_runs() works with size zero input", {
  expect <- structure(integer(), n = 0L)

  expect_identical(vec_identify_runs(integer()), expect)
  expect_identical(vec_identify_runs(data.frame()), expect)
})

test_that("works with atomic input of various types", {
  expect <- structure(c(1L, 1L, 2L, 2L, 3L), n = 3L)

  expect_identical(vec_identify_runs(c(TRUE, TRUE, FALSE, FALSE, TRUE)), expect)
  expect_identical(vec_identify_runs(c(1L, 1L, 2L, 2L, 3L)), expect)
  expect_identical(vec_identify_runs(c(1, 1, 2, 2, 3)), expect)
  expect_identical(vec_identify_runs(complex(real = c(1, 1, 2, 2, 2), imaginary = c(1, 1, 2, 2, 3))), expect)
  expect_identical(vec_identify_runs(c("a", "a", "b", "b", "c")), expect)
  expect_identical(vec_identify_runs(as.raw(c(1, 1, 2, 2, 3))), expect)
  expect_identical(vec_identify_runs(list(1, 1, 2, 2, 3)), expect)
})

test_that("NA values are identical", {
  expect <- structure(c(1L, 1L), n = 1L)

  expect_identical(vec_identify_runs(c(NA, NA)), expect)
  expect_identical(vec_identify_runs(c(NA_integer_, NA_integer_)), expect)
  expect_identical(vec_identify_runs(c(NA_real_, NA_real_)), expect)
  expect_identical(vec_identify_runs(c(NA_complex_, NA_complex_)), expect)
  expect_identical(vec_identify_runs(c(NA_character_, NA_character_)), expect)
  # No NA type for raw
  expect_identical(vec_identify_runs(list(NULL, NULL)), expect)
})

test_that("NA and NaN are different", {
  expect <- structure(c(1L, 2L), n = 2L)
  expect_identical(vec_identify_runs(c(NA_real_, NaN)), expect)
})

test_that("normalizes character encodings", {
  encs <- encodings()
  x <- c(encs$utf8, encs$unknown, encs$latin1)
  expect_identical(vec_identify_runs(x), structure(rep(1L, 3), n = 1L))
})

test_that("errors on scalars", {
  expect_snapshot(error = TRUE, {
    vec_identify_runs(foobar())
  })
})

test_that("works with data frames rowwise", {
  df <- data_frame(x = c(1, 1, 1, 2), y = c(1, 1, 2, 3))
  expect <- structure(c(1L, 1L, 2L, 3L), n = 3L)
  expect_identical(vec_identify_runs(df), expect)

  df <- data_frame(x = c(1, 1, 1), y = c(2, 2, 2), z = c("b", "a", "a"))
  expect <- structure(c(1L, 2L, 2L), n = 2L)
  expect_identical(vec_identify_runs(df), expect)
})

test_that("works with data frames with rows but no columns", {
  expect <- structure(rep(1L, 5), n = 1L)
  expect_identical(vec_identify_runs(new_data_frame(n = 5L)), expect)
})

test_that("works with data frame columns", {
  col <- data_frame(a = c(1, 1, 2, 2), b = c(1, 2, 3, 3))
  df <- data_frame(x = rep(1, 4), y = col)
  expect <- structure(c(1L, 2L, 3L, 3L), n = 3L)
  expect_identical(vec_identify_runs(df), expect)
})

test_that("works with columns of various types", {
  # Use two columns to keep the data frame from being squashed to a vector
  add_col <- function(col) {
    x <- rep(1L, 5)
    data_frame(x = x, y = col)
  }

  expect <- structure(c(1L, 1L, 2L, 2L, 3L), n = 3L)

  expect_identical(vec_identify_runs(add_col(c(TRUE, TRUE, FALSE, FALSE, TRUE))), expect)
  expect_identical(vec_identify_runs(add_col(c(1L, 1L, 2L, 2L, 3L))), expect)
  expect_identical(vec_identify_runs(add_col(c(1, 1, 2, 2, 3))), expect)
  expect_identical(vec_identify_runs(add_col(complex(real = c(1, 1, 2, 2, 2), imaginary = c(1, 1, 2, 2, 3)))), expect)
  expect_identical(vec_identify_runs(add_col(c("a", "a", "b", "b", "c"))), expect)
  expect_identical(vec_identify_runs(add_col(as.raw(c(1, 1, 2, 2, 3)))), expect)
  expect_identical(vec_identify_runs(add_col(list(1, 1, 2, 2, 3))), expect)
})

# vec_run_sizes ----------------------------------------------------------------

test_that("vec_run_sizes() works with size zero input", {
  expect_identical(vec_run_sizes(integer()), integer())
  expect_identical(vec_run_sizes(data.frame()), integer())
})

test_that("works with atomic input of various types", {
  expect <- c(2L, 2L, 1L)

  expect_identical(vec_run_sizes(c(TRUE, TRUE, FALSE, FALSE, TRUE)), expect)
  expect_identical(vec_run_sizes(c(1L, 1L, 2L, 2L, 3L)), expect)
  expect_identical(vec_run_sizes(c(1, 1, 2, 2, 3)), expect)
  expect_identical(vec_run_sizes(complex(real = c(1, 1, 2, 2, 2), imaginary = c(1, 1, 2, 2, 3))), expect)
  expect_identical(vec_run_sizes(c("a", "a", "b", "b", "c")), expect)
  expect_identical(vec_run_sizes(as.raw(c(1, 1, 2, 2, 3))), expect)
  expect_identical(vec_run_sizes(list(1, 1, 2, 2, 3)), expect)
})

test_that("NA values are identical", {
  expect <- 2L

  expect_identical(vec_run_sizes(c(NA, NA)), expect)
  expect_identical(vec_run_sizes(c(NA_integer_, NA_integer_)), expect)
  expect_identical(vec_run_sizes(c(NA_real_, NA_real_)), expect)
  expect_identical(vec_run_sizes(c(NA_complex_, NA_complex_)), expect)
  expect_identical(vec_run_sizes(c(NA_character_, NA_character_)), expect)
  # No NA type for raw
  expect_identical(vec_run_sizes(list(NULL, NULL)), expect)
})

test_that("NA and NaN are different", {
  expect_identical(vec_run_sizes(c(NA_real_, NaN)), c(1L, 1L))
})

test_that("normalizes character encodings", {
  encs <- encodings()
  x <- c(encs$utf8, encs$unknown, encs$latin1)
  expect_identical(vec_run_sizes(x), 3L)
})

test_that("errors on scalars", {
  expect_snapshot(error = TRUE, {
    vec_run_sizes(foobar())
  })
})

test_that("works with data frames rowwise", {
  df <- data_frame(x = c(1, 1, 1, 2), y = c(1, 1, 2, 3))
  expect_identical(vec_run_sizes(df), c(2L, 1L, 1L))

  df <- data_frame(x = c(1, 1, 1), y = c(2, 2, 2), z = c("b", "a", "a"))
  expect_identical(vec_run_sizes(df), c(1L, 2L))
})

test_that("works with data frames with rows but no columns", {
  expect_identical(vec_run_sizes(new_data_frame(n = 5L)), 5L)
})

test_that("works with data frame columns", {
  col <- data_frame(a = c(1, 1, 2, 2), b = c(1, 2, 3, 3))
  df <- data_frame(x = rep(1, 4), y = col)
  expect_identical(vec_run_sizes(df), c(1L, 1L, 2L))
})

test_that("works with columns of various types", {
  # Use two columns to keep the data frame from being squashed to a vector
  add_col <- function(col) {
    x <- rep(1L, 5)
    data_frame(x = x, y = col)
  }

  expect <- c(2L, 2L, 1L)

  expect_identical(vec_run_sizes(add_col(c(TRUE, TRUE, FALSE, FALSE, TRUE))), expect)
  expect_identical(vec_run_sizes(add_col(c(1L, 1L, 2L, 2L, 3L))), expect)
  expect_identical(vec_run_sizes(add_col(c(1, 1, 2, 2, 3))), expect)
  expect_identical(vec_run_sizes(add_col(complex(real = c(1, 1, 2, 2, 2), imaginary = c(1, 1, 2, 2, 3)))), expect)
  expect_identical(vec_run_sizes(add_col(c("a", "a", "b", "b", "c"))), expect)
  expect_identical(vec_run_sizes(add_col(as.raw(c(1, 1, 2, 2, 3)))), expect)
  expect_identical(vec_run_sizes(add_col(list(1, 1, 2, 2, 3))), expect)
})

# vec_locate_run_bounds --------------------------------------------------------

test_that("can locate run starts", {
  expect_identical(
    vec_locate_run_bounds(c(1, 3, 3, 1, 5, 5, 6)),
    c(1L, 2L, 4L, 5L, 7L)
  )
})

test_that("can locate run ends", {
  expect_identical(
    vec_locate_run_bounds(c(1, 3, 3, 1, 5, 5, 6), which = "end"),
    c(1L, 3L, 4L, 6L, 7L)
  )
})

test_that("vec_locate_run_bounds() works with size zero input", {
  expect_identical(vec_locate_run_bounds(integer(), which = "start"), integer())
  expect_identical(vec_locate_run_bounds(integer(), which = "end"), integer())
})

test_that("vec_locate_run_bounds() validates `which`", {
  expect_snapshot(error = TRUE, {
    vec_locate_run_bounds(1, which = "x")
  })
  expect_snapshot(error = TRUE, {
    vec_locate_run_bounds(1, which = 1)
  })
  expect_snapshot(error = TRUE, {
    vec_locate_run_bounds(1, which = c("foo", "bar"))
  })
})

# vec_detect_run_bounds --------------------------------------------------------

test_that("can detect run starts", {
  expect_identical(
    vec_detect_run_bounds(c(1, 3, 3, 1, 5, 5, 6)),
    c(TRUE, TRUE, FALSE, TRUE, TRUE, FALSE, TRUE)
  )
})

test_that("can detect run ends", {
  expect_identical(
    vec_detect_run_bounds(c(1, 3, 3, 1, 5, 5, 6), which = "end"),
    c(TRUE, FALSE, TRUE, TRUE, FALSE, TRUE, TRUE)
  )
})

test_that("vec_detect_run_bounds() works with size zero input", {
  expect_identical(vec_detect_run_bounds(integer(), which = "start"), logical())
  expect_identical(vec_detect_run_bounds(integer(), which = "end"), logical())
})

test_that("vec_detect_run_bounds() validates `which`", {
  expect_snapshot(error = TRUE, {
    vec_detect_run_bounds(1, which = "x")
  })
  expect_snapshot(error = TRUE, {
    vec_detect_run_bounds(1, which = 1)
  })
  expect_snapshot(error = TRUE, {
    vec_detect_run_bounds(1, which = c("foo", "bar"))
  })
})
