#ifndef VCTRS_COMPARE_H
#define VCTRS_COMPARE_H

#include "vctrs-core.h"
#include "equal.h"
#include "missing.h"
#include <stdlib.h>

// -----------------------------------------------------------------------------

r_obj* vec_compare(r_obj* x, r_obj* y, bool na_equal);

// -----------------------------------------------------------------------------

// https://stackoverflow.com/questions/10996418
static inline
int int_compare_scalar(int x, int y) {
  return (x > y) - (x < y);
}
static inline
int dbl_compare_scalar(double x, double y) {
  return (x > y) - (x < y);
}
static inline
int chr_compare_scalar(r_obj* x, r_obj* y) {
  // Assume translation handled by `vec_normalize_encoding()`
  int cmp = strcmp(r_str_c_string(x), r_str_c_string(y));
  return cmp / abs(cmp);
}

// -----------------------------------------------------------------------------

static inline
int qsort_int_compare_scalar(const void* x, const void* y) {
  return int_compare_scalar(*((int*) x), *((int*) y));
}

// -----------------------------------------------------------------------------

static inline r_no_return
int nil_compare_na_equal(r_obj* x, r_obj* y) {
  r_stop_internal("Can't compare NULL values.");
}
static inline
int lgl_compare_na_equal(int x, int y) {
  return int_compare_scalar(x, y);
}
static inline
int int_compare_na_equal(int x, int y) {
  return int_compare_scalar(x, y);
}
static inline
int dbl_compare_na_equal(double x, double y) {
  enum vctrs_dbl x_class = dbl_classify(x);
  enum vctrs_dbl y_class = dbl_classify(y);

  switch (x_class) {
  case VCTRS_DBL_number: {
    switch (y_class) {
    case VCTRS_DBL_number: return dbl_compare_scalar(x, y);
    case VCTRS_DBL_missing: return 1;
    case VCTRS_DBL_nan: return 1;
    }
  }
  case VCTRS_DBL_missing: {
    switch (y_class) {
    case VCTRS_DBL_number: return -1;
    case VCTRS_DBL_missing: return 0;
    case VCTRS_DBL_nan: return 1;
    }
  }
  case VCTRS_DBL_nan: {
    switch (y_class) {
    case VCTRS_DBL_number: return -1;
    case VCTRS_DBL_missing: return -1;
    case VCTRS_DBL_nan: return 0;
    }
  }
  }

  r_stop_unreachable();
}
static inline r_no_return
int cpl_compare_na_equal(Rcomplex x, Rcomplex y) {
  r_stop_internal("Can't compare complex types.");
}
static inline
int chr_compare_na_equal(r_obj* x, r_obj* y) {
  if (chr_equal_na_equal(x, y)) {
    return 0;
  } else if (chr_is_missing(x)) {
    return -1;
  } else if (chr_is_missing(y)) {
    return 1;
  } else {
    return chr_compare_scalar(x, y);
  }
}
static inline r_no_return
int raw_compare_na_equal(Rbyte x, Rbyte y) {
  r_stop_internal("Can't compare raw types.");
}
static inline r_no_return
int list_compare_na_equal(r_obj* x, r_obj* y) {
  r_stop_internal("Can't compare list types.");
}

// -----------------------------------------------------------------------------

#define P_COMPARE_NA_EQUAL(CTYPE, COMPARE_NA_EQUAL) do {                     \
  return COMPARE_NA_EQUAL(((CTYPE const*) p_x)[i], ((CTYPE const*) p_y)[j]); \
} while (0)

static inline
int p_nil_compare_na_equal(const void* p_x, r_ssize i, const void* p_y, r_ssize j) {
  P_COMPARE_NA_EQUAL(r_obj*, nil_compare_na_equal);
}
static inline
int p_lgl_compare_na_equal(const void* p_x, r_ssize i, const void* p_y, r_ssize j) {
  P_COMPARE_NA_EQUAL(int, lgl_compare_na_equal);
}
static inline
int p_int_compare_na_equal(const void* p_x, r_ssize i, const void* p_y, r_ssize j) {
  P_COMPARE_NA_EQUAL(int, int_compare_na_equal);
}
static inline
int p_dbl_compare_na_equal(const void* p_x, r_ssize i, const void* p_y, r_ssize j) {
  P_COMPARE_NA_EQUAL(double, dbl_compare_na_equal);
}
static inline
int p_cpl_compare_na_equal(const void* p_x, r_ssize i, const void* p_y, r_ssize j) {
  P_COMPARE_NA_EQUAL(Rcomplex, cpl_compare_na_equal);
}
static inline
int p_chr_compare_na_equal(const void* p_x, r_ssize i, const void* p_y, r_ssize j) {
  P_COMPARE_NA_EQUAL(r_obj*, chr_compare_na_equal);
}
static inline
int p_raw_compare_na_equal(const void* p_x, r_ssize i, const void* p_y, r_ssize j) {
  P_COMPARE_NA_EQUAL(Rbyte, raw_compare_na_equal);
}
static inline
int p_list_compare_na_equal(const void* p_x, r_ssize i, const void* p_y, r_ssize j) {
  P_COMPARE_NA_EQUAL(r_obj*, list_compare_na_equal);
}

#undef P_COMPARE_NA_EQUAL

static inline
int p_compare_na_equal(const void* p_x,
                       r_ssize i,
                       const void* p_y,
                       r_ssize j,
                       const enum vctrs_type type) {
  switch (type) {
  case VCTRS_TYPE_null: return p_nil_compare_na_equal(p_x, i, p_y, j);
  case VCTRS_TYPE_logical: return p_lgl_compare_na_equal(p_x, i, p_y, j);
  case VCTRS_TYPE_integer: return p_int_compare_na_equal(p_x, i, p_y, j);
  case VCTRS_TYPE_double: return p_dbl_compare_na_equal(p_x, i, p_y, j);
  case VCTRS_TYPE_complex: return p_cpl_compare_na_equal(p_x, i, p_y, j);
  case VCTRS_TYPE_character: return p_chr_compare_na_equal(p_x, i, p_y, j);
  case VCTRS_TYPE_raw: return p_raw_compare_na_equal(p_x, i, p_y, j);
  case VCTRS_TYPE_list: return p_list_compare_na_equal(p_x, i, p_y, j);
  default: stop_unimplemented_vctrs_type("p_compare_na_equal", type);
  }
}

// -----------------------------------------------------------------------------

static inline r_no_return
int nil_compare_na_propagate(r_obj* x, r_obj* y) {
  r_stop_internal("Can't compare NULL values.");
}
static inline
int lgl_compare_na_propagate(int x, int y) {
  if (lgl_is_missing(x) || lgl_is_missing(y)) {
    return r_globals.na_int;
  } else {
    return int_compare_scalar(x, y);
  }
}
static inline
int int_compare_na_propagate(int x, int y) {
  if (int_is_missing(x) || int_is_missing(y)) {
    return r_globals.na_int;
  } else {
    return int_compare_scalar(x, y);
  }
}
static inline
int dbl_compare_na_propagate(double x, double y) {
  if (dbl_is_missing(x) || dbl_is_missing(y)) {
    return r_globals.na_int;
  } else {
    return dbl_compare_scalar(x, y);
  }
}
static inline r_no_return
int cpl_compare_na_propagate(Rcomplex x, Rcomplex y) {
  r_stop_internal("Can't compare complex types.");
}
static inline
int chr_compare_na_propagate(r_obj* x, r_obj* y) {
  if (chr_is_missing(x) || chr_is_missing(y)) {
    return r_globals.na_int;
  } else if (chr_equal_na_equal(x, y)) {
    return 0;
  } else {
    return chr_compare_scalar(x, y);
  }
}
static inline r_no_return
int raw_compare_na_propagate(Rbyte x, Rbyte y) {
  r_stop_internal("Can't compare raw types.");
}
static inline r_no_return
int list_compare_na_propagate(r_obj* x, r_obj* y) {
  r_stop_internal("Can't compare list types.");
}

// -----------------------------------------------------------------------------

#define P_COMPARE_NA_PROPAGATE(CTYPE, COMPARE_NA_PROPAGATE) do {               \
return COMPARE_NA_PROPAGATE(((CTYPE const*) p_x)[i], ((CTYPE const*) p_y)[j]); \
} while (0)

static inline
int p_nil_compare_na_propagate(const void* p_x, r_ssize i, const void* p_y, r_ssize j) {
  P_COMPARE_NA_PROPAGATE(r_obj*, nil_compare_na_propagate);
}
static inline
int p_lgl_compare_na_propagate(const void* p_x, r_ssize i, const void* p_y, r_ssize j) {
  P_COMPARE_NA_PROPAGATE(int, lgl_compare_na_propagate);
}
static inline
int p_int_compare_na_propagate(const void* p_x, r_ssize i, const void* p_y, r_ssize j) {
  P_COMPARE_NA_PROPAGATE(int, int_compare_na_propagate);
}
static inline
int p_dbl_compare_na_propagate(const void* p_x, r_ssize i, const void* p_y, r_ssize j) {
  P_COMPARE_NA_PROPAGATE(double, dbl_compare_na_propagate);
}
static inline
int p_cpl_compare_na_propagate(const void* p_x, r_ssize i, const void* p_y, r_ssize j) {
  P_COMPARE_NA_PROPAGATE(Rcomplex, cpl_compare_na_propagate);
}
static inline
int p_chr_compare_na_propagate(const void* p_x, r_ssize i, const void* p_y, r_ssize j) {
  P_COMPARE_NA_PROPAGATE(r_obj*, chr_compare_na_propagate);
}
static inline
int p_raw_compare_na_propagate(const void* p_x, r_ssize i, const void* p_y, r_ssize j) {
  P_COMPARE_NA_PROPAGATE(Rbyte, raw_compare_na_propagate);
}
static inline
int p_list_compare_na_propagate(const void* p_x, r_ssize i, const void* p_y, r_ssize j) {
  P_COMPARE_NA_PROPAGATE(r_obj*, list_compare_na_propagate);
}

#undef P_COMPARE_NA_PROPAGATE

static inline
int p_compare_na_propagate(const void* p_x,
                           r_ssize i,
                           const void* p_y,
                           r_ssize j,
                           const enum vctrs_type type) {
  switch (type) {
  case VCTRS_TYPE_null: return p_nil_compare_na_propagate(p_x, i, p_y, j);
  case VCTRS_TYPE_logical: return p_lgl_compare_na_propagate(p_x, i, p_y, j);
  case VCTRS_TYPE_integer: return p_int_compare_na_propagate(p_x, i, p_y, j);
  case VCTRS_TYPE_double: return p_dbl_compare_na_propagate(p_x, i, p_y, j);
  case VCTRS_TYPE_complex: return p_cpl_compare_na_propagate(p_x, i, p_y, j);
  case VCTRS_TYPE_character: return p_chr_compare_na_propagate(p_x, i, p_y, j);
  case VCTRS_TYPE_raw: return p_raw_compare_na_propagate(p_x, i, p_y, j);
  case VCTRS_TYPE_list: return p_list_compare_na_propagate(p_x, i, p_y, j);
  default: stop_unimplemented_vctrs_type("p_compare_na_propagate", type);
  }
}

// -----------------------------------------------------------------------------
#endif // VCTRS_COMPARE_H
