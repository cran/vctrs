
# constructor and accessors -----------------------------------------------

test_that("can construct and access components", {
  r <- new_rcrd(list(x = 1, y = 2))

  expect_equal(length(r), 1)
  expect_equal(n_fields(r), 2)

  expect_equal(names(r), NULL)
  expect_equal(fields(r), c("x", "y"))

  expect_error(r$x, class = "vctrs_error_unsupported")
  expect_equal(field(r, "x"), 1)
})

test_that("requires format method", {
  x <- new_rcrd(list(x = 1))
  expect_error(format(x), class = "vctrs_error_unimplemented")
})

test_that("vec_proxy() transforms records to data frames", {
  expect_identical(
    vec_proxy(new_rcrd(list(a = "1"))),
    new_data_frame(list(a = "1"))
  )
})

test_that("equality, comparison, and order proxies are recursive and fall through (#1503, #1664)", {
  base <- new_rcrd(list(a = 1), class = "custom")
  x <- new_rcrd(list(x = base))

  expect_identical(vec_proxy_equal(x), 1)
  expect_identical(vec_proxy_compare(x), 1)
  expect_identical(vec_proxy_order(x), 1)

  local_methods(vec_proxy_equal.custom = function(x, ...) rep("equal", length(x)))

  expect_identical(vec_proxy_equal(x), "equal")
  expect_identical(vec_proxy_compare(x), "equal")
  expect_identical(vec_proxy_order(x), "equal")

  local_methods(vec_proxy_compare.custom = function(x, ...) rep("compare", length(x)))

  expect_identical(vec_proxy_equal(x), "equal")
  expect_identical(vec_proxy_compare(x), "compare")
  expect_identical(vec_proxy_order(x), "compare")

  local_methods(vec_proxy_order.custom = function(x, ...) rep("order", length(x)))

  expect_identical(vec_proxy_equal(x), "equal")
  expect_identical(vec_proxy_compare(x), "compare")
  expect_identical(vec_proxy_order(x), "order")

  y <- new_rcrd(list(a = 1), class = "custom2")
  local_methods(vec_proxy_compare.custom2 = function(x, ...) rep("compare2", length(x)))

  z <- data_frame(x = x, y = y)

  # Each column falls back independently
  expect_identical(vec_proxy_equal(z), data_frame(x = "equal", y = 1))
  expect_identical(vec_proxy_compare(z), data_frame(x = "compare", y = "compare2"))
  expect_identical(vec_proxy_order(z), data_frame(x = "order", y = "compare2"))
})

# base methods ------------------------------------------------------------

test_that("has no names", {
  x <- new_rcrd(list(a = 1, b = 2L))

  expect_null(names(x))
  expect_null(vec_names(x))
})

test_that("removing names with `NULL` is a no-op (#1419)", {
  x <- new_rcrd(list(a = 1, b = 2L))

  expect_identical(`names<-`(x, NULL), x)
  expect_identical(vec_set_names(x, NULL), x)
})

test_that("setting character names is an error (#1419)", {
  x <- new_rcrd(list(a = 1, b = 2L))

  expect_error(`names<-`(x, "x"), "Can't assign names")
  expect_error(vec_set_names(x, "x"), "Can't assign names")
})

test_that("na.omit() works and retains metadata (#1413)", {
  x <- new_rcrd(list(a = c(1, 1, NA, NA), b = c(1, NA, 1, NA)))
  result <- na.omit(x)

  expect <- vec_slice(x, 1:3)
  attr(expect, "na.action") <- structure(4L, class = "omit")

  expect_identical(result, expect)
})

test_that("na.fail() works", {
  # Only considered missing if all fields are missing
  x <- new_rcrd(list(a = c(1, 1, NA), b = c(1, NA, 1)))
  expect_identical(na.fail(x), x)

  x <- new_rcrd(list(a = c(1, 1, NA, NA), b = c(1, NA, 1, NA)))
  expect_snapshot(error = TRUE, na.fail(x))
})

# coercion ----------------------------------------------------------------

test_that("can't cast list to rcrd", {
  l <- list(
    new_rcrd(list(a = "1", b = 3L)),
    new_rcrd(list(b = "4", a = 2))
  )
  expect_error(
    vec_cast(l, new_rcrd(list(a = 1L, b = 2L))),
    class = "vctrs_error_incompatible_type"
  )
})

test_that("can recast rcrd from list", {
  r <- new_rcrd(list(x = integer(), y = numeric()))

  expect_equal(
    vec_restore(list(x = 1L, y = 1), r),
    new_rcrd(list(x = 1L, y = 1))
  )
})

test_that("can't cast rcrd to list", {
  r <- new_rcrd(list(x = 1:2, y = 2:3))
  expect_error(vec_cast(r, list()), class = "vctrs_error_incompatible_type")
  expect_error(vec_cast(r, list()), class = "vctrs_error_incompatible_type")
})

test_that("default casts are implemented correctly", {
  r <- new_rcrd(list(x = 1, y = 1))

  expect_error(vec_cast(1, r), class = "vctrs_error_incompatible_type")
  expect_equal(vec_cast(NULL, r), NULL)
})

test_that("can't cast incompatible rcrd", {
  expect_error(
    vec_cast(
      new_rcrd(list(a = "1", b = 3L)),
      new_rcrd(list(a = "1"))
    ),
    class = "vctrs_error_cast_lossy"
  )
  expect_error(
    vec_cast(
      new_rcrd(list(a = "1", b = 3L)),
      new_rcrd(list(a = "1", c = 3L))
    ),
    class = "vctrs_error_cast_lossy"
  )
  expect_error(
    vec_cast(
      new_rcrd(list(a = "a", b = 3L)),
      new_rcrd(list(a = 1, b = 3L))
    ),
    class = "vctrs_error_incompatible_type"
  )
})

# input validation --------------------------------------------------------

test_that("must be list of equal length vectors", {
  expect_error(new_rcrd(list()), "list of length 1")
  expect_error(new_rcrd(list(x = environment())), class = "vctrs_error_scalar_type")
  expect_error(new_rcrd(list(x = 1:2, y = 1:3)), "same size")
})

test_that("names must be unique", {
  expect_error(new_rcrd(list(1, 2)), class = "vctrs_error_names_cannot_be_empty")
  expect_error(new_rcrd(list(x = 1, 2)), class = "vctrs_error_names_cannot_be_empty")
  expect_error(new_rcrd(list(x = 1, x = 2)), class = "vctrs_error_names_must_be_unique")
  expect_error(new_rcrd(setNames(list(1, 2), "x")), "can't return `NA`")
})

test_that("subset assignment throws error", {
  x <- new_rcrd(list(x = 1))
  expect_error(
    x$y <- 2,
    class = "vctrs_error_unsupported"
  )
})

test_that("can supply data frame as fields", {
  expect_identical(
    new_rcrd(list(x = 1)),
    new_rcrd(tibble(x = 1))
  )
})

test_that("fields are not recycled", {
  expect_error(
    new_rcrd(list(x = 1, y = 1:2)),
    "must be the same size"
  )
})


# tuple class ----------------------------------------------------------
# use simple class to test essential features of rcrds

test_that("print and str use format", {
  local_tuple_methods()
  r <- tuple(1, 1:100)

  expect_snapshot(r)
  expect_snapshot(str(r[1:10]))
  expect_snapshot(str(list(list(list(r, 1:100)))))
})

test_that("subsetting methods applied to each field", {
  local_tuple_methods()
  x <- tuple(1:2, 1)

  expect_equal(x[1], tuple(1, 1))
  expect_equal(x[[1]], tuple(1, 1))

  expect_equal(rep(tuple(1, 1), 2), tuple(c(1, 1), 1))

  length(x) <- 1
  expect_equal(x, tuple(1, 1))
})

test_that("subset assignment modifies each field", {
  local_tuple_methods()
  x <- tuple(c(1, 1), c(2, 2))

  expect_error(x[[]] <- tuple(), "missing")

  x[[1]] <- tuple(3, 3)
  expect_equal(x, tuple(c(3, 1), c(3, 2)))

  x[1] <- tuple(4, 4)
  expect_equal(x, tuple(c(4, 1), c(4, 2)))
})

test_that("subset assignment recycles", {
  local_tuple_methods()

  x <- tuple(c(1, 1), c(2, 2))
  x[1:2] <- tuple(1, 1)
  expect_equal(x, tuple(c(1, 1), c(1, 1)))

  x[] <- tuple(2, 2)
  expect_equal(x, tuple(c(2, 2), c(2, 2)))
})

test_that("can sort rcrd", {
  local_tuple_methods()
  x <- tuple(c(1, 2, 1), c(3, 1, 2))
  expect_equal(xtfrm(x), c(2, 3, 1))
  expect_equal(order(x), c(3, 1, 2))
  expect_equal(sort(x), tuple(c(1, 1, 2), c(2, 3, 1)))
})

test_that("can use dictionary methods on a rcrd", {
  local_tuple_methods()
  x <- tuple(c(1, 2, 1), c(3, 1, 3))
  expect_equal(unique(x), x[1:2])
  expect_equal(duplicated(x), c(FALSE, FALSE, TRUE))
  expect_equal(anyDuplicated(x), TRUE)
})

test_that("cannot round trip through list", {
  local_tuple_methods()
  t <- tuple(1:2, 3:4)

  # Used to be allowed
  expect_error(vec_cast(t, list()), class = "vctrs_error_incompatible_type")
})

test_that("can convert to list using as.list() or vec_chop() (#1113)", {
  local_tuple_methods()
  t <- tuple(1:2, 3:4)

  expect <- list(tuple(1L, 3L), tuple(2L, 4L))

  expect_identical(as.list(t), expect)
  expect_identical(vec_chop(t), expect)
})

test_that("dangerous methods marked as unimplemented", {
  local_tuple_methods()
  t <- tuple()

  expect_error(mean(t), class = "vctrs_error_unsupported")
  expect_error(abs(t), class = "vctrs_error_unsupported")
  expect_error(is.finite(t), class = "vctrs_error_unsupported")
  expect_error(is.nan(t), class = "vctrs_error_unsupported")
})


# slicing -----------------------------------------------------------------

test_that("dots are an error (#1295)", {
  foo <- new_rcrd(list(foo = "foo"))
  expect_snapshot(error = TRUE, foo[1, 2])
})

test_that("records are restored after slicing the proxy", {
  expect_identical(new_rcrd(list(x = 1:2))[1], new_rcrd(list(x = 1L)))
})

test_that("can slice with df-cols fields", {
  x <- new_rcrd(data_frame(x = data_frame(y = 1:2)))

  out <- vec_slice(x, 2)
  expect_identical(
    out,
    new_rcrd(data_frame(x = data_frame(y = 2L)))
  )
  expect_identical(
    x[2],
    out
  )
  expect_identical(
    x[[2]],
    out
  )
})

test_that("can rep with df-cols fields", {
  x <- new_rcrd(data_frame(x = data_frame(y = 1:2)))

  expect_identical(
    rep(x, length.out = 4),
    vec_slice(x, c(1:2, 1:2))
  )
})

test_that("can assign with df-cols fields", {
  x <- new_rcrd(data_frame(x = data_frame(y = 1:3)))
  y <- new_rcrd(data_frame(x = data_frame(y = FALSE)))
  exp <- new_rcrd(data_frame(x = data_frame(y = c(1L, 2L, 0L))))

  expect_identical(vec_assign(x, 3, y), exp)

  out <- x
  out[[3]] <- y
  expect_identical(out, exp)
})

test_that("can resize with df-cols fields", {
  x <- new_rcrd(data_frame(x = data_frame(y = 1:3)))

  length(x) <- 2
  expect_identical(x, new_rcrd(data_frame(x = data_frame(y = 1:2))))

  length(x) <- 4
  expect_identical(x, new_rcrd(data_frame(x = data_frame(y = c(1:2, NA, NA)))))
})

test_that("`[[` preserves type of record fields (#1205)", {
  x <- new_rcrd(list(x = 1:3, a = list(1, 2:3, 4:6)))
  expect_identical(field(x[3], "a"), list(4:6))
  expect_identical(field(x[[3]], "a"), list(4:6))
})
