# Stopwatch
[![Build Status](https://travis-ci.org/efcasado/stopwatch.svg?branch=master)](https://travis-ci.org/efcasado/stopwatch)

![Stopwatch](stopwatch.png)

A small library to seamlessly add instrumentation to your Elixir code.


## Quick Start

`Stopwatch` implements a dead simple API consisting of only one function,
`bind/3`.

`bind/3` is used to attach a stopwatch to the given function. Calling this
function several times does not attach multiple stopwatches to the same
function.

Note that the changes are not persisted. Thus, any attached stopwatches
will be detached should their target modules be reloaded.

```elixir
str = "Hello, world!"
String.length(str)
# => 13

# Attach a stopwatch to String.length/1
:ok  = Stopwatch.bind(String, :length, 1)

String.length(str)
# STDOUT: stopwatch | 'Elixir.String':length/1 returned in 0.004 ms
# => 13

# Detach the stopwatch from String.length/1 by means of a code reload
l(String)

String.length(str)
# => 13
```


## Author(s)

- Enrique Fernandez `<efcasado@gmail.com>`


## License

> The MIT License (MIT)
>
> Copyright (c) 2018, Enrique Fernandez
>
> Permission is hereby granted, free of charge, to any person obtaining a copy
> of this software and associated documentation files (the "Software"), to deal
> in the Software without restriction, including without limitation the rights
> to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
> copies of the Software, and to permit persons to whom the Software is
> furnished to do so, subject to the following conditions:
>
> The above copyright notice and this permission notice shall be included in
> all copies or substantial portions of the Software.
>
> THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
> IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
> FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
> AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
> LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
> OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
> THE SOFTWARE.
