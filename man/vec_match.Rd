% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dictionary.R
\name{vec_match}
\alias{vec_match}
\alias{vec_in}
\title{Find matching observations across vectors}
\usage{
vec_match(
  needles,
  haystack,
  ...,
  na_equal = TRUE,
  needles_arg = "",
  haystack_arg = ""
)

vec_in(
  needles,
  haystack,
  ...,
  na_equal = TRUE,
  needles_arg = "",
  haystack_arg = ""
)
}
\arguments{
\item{needles, haystack}{Vector of \code{needles} to search for in vector haystack.
\code{haystack} should usually be unique; if not \code{vec_match()} will only
return the location of the first match.

\code{needles} and \code{haystack} are coerced to the same type prior to
comparison.}

\item{...}{These dots are for future extensions and must be empty.}

\item{na_equal}{If \code{TRUE}, missing values in \code{needles} can be
matched to missing values in \code{haystack}. If \code{FALSE}, they
propagate, missing values in \code{needles} are represented as \code{NA} in
the return value.}

\item{needles_arg, haystack_arg}{Argument tags for \code{needles} and
\code{haystack} used in error messages.}
}
\value{
A vector the same length as \code{needles}. \code{vec_in()} returns a
logical vector; \code{vec_match()} returns an integer vector.
}
\description{
\code{vec_in()} returns a logical vector based on whether \code{needle} is found in
haystack. \code{vec_match()} returns an integer vector giving location of
\code{needle} in \code{haystack}, or \code{NA} if it's not found.
}
\details{
\code{vec_in()} is equivalent to \link{\%in\%}; \code{vec_match()} is equivalent to \code{match()}.
}
\section{Missing values}{

In most cases places in R, missing values are not considered to be equal,
i.e. \code{NA == NA} is not \code{TRUE}. The exception is in matching functions
like \code{\link[=match]{match()}} and \code{\link[=merge]{merge()}}, where an \code{NA} will match another \code{NA}.
By \code{vec_match()} and \code{vec_in()} will match \code{NA}s; but you can control
this behaviour with the \code{na_equal} argument.
}

\section{Dependencies}{

\itemize{
\item \code{\link[=vec_cast_common]{vec_cast_common()}} with fallback
\item \code{\link[=vec_proxy_equal]{vec_proxy_equal()}}
}
}

\examples{
hadley <- strsplit("hadley", "")[[1]]
vec_match(hadley, letters)

vowels <- c("a", "e", "i", "o", "u")
vec_match(hadley, vowels)
vec_in(hadley, vowels)

# Only the first index of duplicates is returned
vec_match(c("a", "b"), c("a", "b", "a", "b"))
}
