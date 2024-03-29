% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/proxy.R
\name{vec_proxy}
\alias{vec_proxy}
\alias{vec_restore}
\title{Proxy and restore}
\usage{
vec_proxy(x, ...)

vec_restore(x, to, ...)
}
\arguments{
\item{x}{A vector.}

\item{...}{These dots are for future extensions and must be empty.}

\item{to}{The original vector to restore to.}
}
\description{
\ifelse{html}{\href{https://lifecycle.r-lib.org/articles/stages.html#experimental}{\figure{lifecycle-experimental.svg}{options: alt='[Experimental]'}}}{\strong{[Experimental]}}

\code{vec_proxy()} returns the data structure containing the values of a
vector. This data structure is usually the vector itself. In this
case the proxy is the \link[base:identity]{identity function}, which is
the default \code{vec_proxy()} method.

Only experts should implement special \code{vec_proxy()} methods, for
these cases:
\itemize{
\item A vector has vectorised attributes, i.e. metadata for
each element of the vector. These \emph{record types} are implemented
in vctrs by returning a data frame in the proxy method. If you're
starting your class from scratch, consider deriving from the
\code{\link[=new_rcrd]{rcrd}} class. It implements the appropriate data
frame proxy and is generally the preferred way to create a record
class.
\item When you're implementing a vector on top of a non-vector type,
like an environment or an S4 object. This is currently only
partially supported.
\item S3 lists are considered scalars by default. This is the safe
choice for list objects such as returned by \code{stats::lm()}. To
declare that your S3 list class is a vector, you normally add
\code{"list"} to the right of your class vector. Explicit inheritance
from list is generally the preferred way to declare an S3 list in
R, for instance it makes it possible to dispatch on
\code{generic.list} S3 methods.

If you can't modify your class vector, you can implement an
identity proxy (i.e. a proxy method that just returns its input)
to let vctrs know this is a vector list and not a scalar.
}

\code{vec_restore()} is the inverse operation of \code{vec_proxy()}. It
should only be called on vector proxies.
\itemize{
\item It undoes the transformations of \code{vec_proxy()}.
\item It restores attributes and classes. These may be lost when the
memory values are manipulated. For example slicing a subset of a
vector's proxy causes a new proxy to be allocated.
}

By default vctrs restores all attributes and classes
automatically. You only need to implement a \code{vec_restore()} method
if your class has attributes that depend on the data.
}
\section{Proxying}{


You should only implement \code{vec_proxy()} when your type is designed
around a non-vector class. I.e. anything that is not either:
\itemize{
\item An atomic vector
\item A bare list
\item A data frame
}

In this case, implement \code{vec_proxy()} to return such a vector
class. The vctrs operations such as \code{\link[=vec_slice]{vec_slice()}} are applied on
the proxy and \code{vec_restore()} is called to restore the original
representation of your type.

The most common case where you need to implement \code{vec_proxy()} is
for S3 lists. In vctrs, S3 lists are treated as scalars by
default. This way we don't treat objects like model fits as
vectors. To prevent vctrs from treating your S3 list as a scalar,
unclass it in the \code{vec_proxy()} method. For instance, here is the
definition for \code{list_of}:

\if{html}{\out{<div class="sourceCode">}}\preformatted{vec_proxy.vctrs_list_of <- function(x) \{
  unclass(x)
\}
}\if{html}{\out{</div>}}

Another case where you need to implement a proxy is \link[=new_rcrd]{record types}. Record types should return a data frame, as in
the \code{POSIXlt} method:

\if{html}{\out{<div class="sourceCode">}}\preformatted{vec_proxy.POSIXlt <- function(x) \{
  new_data_frame(unclass(x))
\}
}\if{html}{\out{</div>}}

Note that you don't need to implement \code{vec_proxy()} when your class
inherits from \code{vctrs_vctr} or \code{vctrs_rcrd}.
}

\section{Restoring}{


A restore is a specialised type of cast, primarily used in
conjunction with \code{NextMethod()} or a C-level function that works on
the underlying data structure. A \code{vec_restore()} method can make
the following assumptions about \code{x}:
\itemize{
\item It has the correct type.
\item It has the correct names.
\item It has the correct \code{dim} and \code{dimnames} attributes.
\item It is unclassed. This way you can call vctrs generics with \code{x}
without triggering an infinite loop of restoration.
}

The length may be different (for example after \code{\link[=vec_slice]{vec_slice()}} has
been called), and all other attributes may have been lost. The
method should restore all attributes so that after restoration,
\code{vec_restore(vec_data(x), x)} yields \code{x}.

To understand the difference between \code{vec_cast()} and \code{vec_restore()}
think about factors: it doesn't make sense to cast an integer to a factor,
but if \code{NextMethod()} or another low-level function has stripped attributes,
you still need to be able to restore them.

The default method copies across all attributes so you only need to
provide your own method if your attributes require special care
(i.e. they are dependent on the data in some way). When implementing
your own method, bear in mind that many R users add attributes to track
additional metadata that is important to them, so you should preserve any
attributes that don't require special handling for your class.
}

\section{Dependencies}{

\itemize{
\item \code{x} must be a vector in the vctrs sense (see \code{\link[=vec_is]{vec_is()}})
\item By default the underlying data is returned as is (identity proxy)
}

All vector classes have a proxy, even those who don't implement any
vctrs methods. The exception is S3 lists that don't inherit from
\code{"list"} explicitly. These might have to implement an identity
proxy for compatibility with vctrs (see discussion above).
}

\keyword{internal}
