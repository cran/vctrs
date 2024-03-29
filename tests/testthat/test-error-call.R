test_that("failing common type reports correct error call", {
  my_function <- function() vec_ptype2(2, chr())
  expect_snapshot((expect_error(my_function())))
})

test_that("failing cast reports correct error call", {
  my_function <- function() vec_cast(2, chr())
  expect_snapshot((expect_error(my_function())))

  df1 <- data_frame(x = TRUE, y = TRUE)
  df2 <- data_frame(y = "1")
  my_function <- function(lhs, rhs) vec_cast(lhs, rhs)
  expect_snapshot((expect_error(my_function(df1, df2))))

  df1 <- data_frame(y = TRUE)
  df2 <- data_frame(y = "1")
  expect_snapshot((expect_error(my_function(df1, df2))))
})

test_that("lossy cast reports correct error call", {
  my_function <- function() vec_cast(2, lgl())
  expect_snapshot((expect_error(my_function())))
})

test_that("failing common size reports correct error call", {
  my_function <- function() vec_recycle(1:2, 10)
  expect_snapshot((expect_error(my_function())))

  # FIXME
  my_function <- function() vec_size_common(1:2, 1:10)
  expect_snapshot((expect_error(my_function())))
})

test_that("unsupported error reports correct error call", {
  x <- new_vctr(1:2)

  my_function <- function() dim(x) <- 1:2
  expect_snapshot((expect_error(my_function())))

  my_function <- function() median(x)
  expect_snapshot((expect_error(my_function())))
})

test_that("scalar error reports correct error call", {
  my_function <- function() obj_check_vector(foobar())
  expect_snapshot((expect_error(my_function())))
})

test_that("size error reports correct error call", {
  my_function <- function() vec_check_size(1:2, size = 1)
  expect_snapshot((expect_error(my_function())))
})

test_that("bare casts report correct error call", {
  my_function <- function() vec_cast(1.5, int())
  expect_snapshot((expect_error(my_function())))

  my_function <- function() vec_cast(1.5, lgl())
  expect_snapshot((expect_error(my_function())))

  my_function <- function() vec_cast(2L, lgl())
  expect_snapshot((expect_error(my_function())))

  # Passing call to `shape_broadcast()`
  my_function <- function() vec_cast(matrix(TRUE), dbl())
  expect_snapshot((expect_error(my_function())))
})

test_that("base S3 casts report correct error call", {
  my_function <- function() vec_cast("a", factor("b"))
  expect_snapshot((expect_error(my_function())))
})

test_that("names validation reports correct error call", {
  my_function <- function() vec_as_names(c("x", "", "y"), repair = "check_unique")
  expect_snapshot((expect_error(my_function())))

  my_function <- function() vec_as_names(c("x", "x"), repair = "check_unique", repair_arg = "repair")
  expect_snapshot((expect_error(my_function())))

  my_function <- function() vec_as_names("...", repair = "check_unique", repair_arg = "repair")
  expect_snapshot((expect_error(my_function())))
})

test_that("subscript validation reports correct error calls", {
  my_function <- function() vctrs::num_as_location(1, 1L, missing = "bogus")
  expect_snapshot((expect_error(my_function())))

  my_function <- function() vctrs::vec_as_location(10, 2)
  expect_snapshot((expect_error(my_function())))

  my_function <- function(my_arg) vec_as_location(my_arg, 2)
  expect_snapshot((expect_error(my_function(1.5))))

  my_function <- function(my_arg) vctrs::vec_as_subscript(my_arg)
  expect_snapshot((expect_error(my_function(1.5))))

  my_function <- function(my_arg) vctrs::vec_as_location(my_arg, 2)
  expect_snapshot((expect_error(my_function(list()))))

  my_function <- function(my_arg) vec_as_location(1, my_arg)
  expect_snapshot((expect_error(my_function(1.5))))

  my_function <- function(my_arg) vec_as_location(my_arg, 1, missing = "error")
  expect_snapshot((expect_error(my_function(NA))))
})

test_that("`vec_ptype()` reports correct error call", {
  my_function <- function(my_arg) vec_ptype(my_arg)
  expect_snapshot({
    (expect_error(my_function(env())))
    (expect_error(my_function(foobar(list()))))
  })
})

test_that("`vec_slice()` uses `error_call`", {
  my_function <- function(x, i) vec_slice(x, i, error_call = current_env())
  expect_snapshot({
    (expect_error(my_function(env(), 1)))
    (expect_error(my_function(1, 2)))
  })
})

test_that("vec_slice() reports self in error context", {
  expect_snapshot({
    (expect_error(vec_slice(foobar(list()), 1)))
    (expect_error(vec_slice(list(), env())))
  })
})

test_that("list_sizes() reports error context", {
  expect_snapshot({
    (expect_error(list_sizes(foobar(list()))))
    (expect_error(list_sizes(list(env()))))
    (expect_error(list_sizes(list(1, 2, env()))))
    (expect_error(list_sizes(list(1, 2, foo = env()))))
  })
})

test_that("vec_size() reports error context", {
  expect_snapshot({
    (expect_error(vec_size(env())))
  })
})

test_that("vec_cast_common() reports error context", {
  my_function <- function(...) vec_cast_common(...)
  expect_snapshot((expect_error(my_function(my_arg = 1.5, .to = int()))))
  expect_snapshot((expect_error(my_function(my_arg = 1.5, .to = int(), .arg = "my_arg"))))
  expect_snapshot((expect_error(my_function(this_arg = 1, that_arg = "foo", .arg = "my_arg"))))
  expect_snapshot((expect_error(my_function(1, "foo", .arg = "my_arg"))))

  x <- data.frame(x = "a")
  y <- data.frame(x = 1, y = 2)
  expect_snapshot((expect_error(my_function(this_arg = x, that_arg = y))))
})

test_that("vec_ptype_common() reports error context", {
  my_function <- function(...) vec_ptype_common(...)
  expect_snapshot((expect_error(my_function(this_arg = 1, that_arg = "foo"))))
  expect_snapshot((expect_error(my_function(this_arg = 1, that_arg = "foo", .arg = "my_arg"))))
  expect_snapshot((expect_error(my_function(1, "foo", .arg = "my_arg"))))
})
