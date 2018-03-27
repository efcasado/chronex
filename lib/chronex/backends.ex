###========================================================================
### File: backends.ex
###
### Route requests to all the configured backends.
###
###
### Author(s):
###  - Enrique Fernandez <efcasado@gmail.com>
###
###-- LICENSE -------------------------------------------------------------
### The MIT License (MIT)
###
### Copyright (c) 2018 Enrique Fernandez
###
### Permission is hereby granted, free of charge, to any person obtaining
### a copy of this software and associated documentation files (the
### "Software"), to deal in the Software without restriction, including
### without limitation the rights to use, copy, modify, merge, publish,
### distribute, sublicense, and/or sell copies of the Software,
### and to permit persons to whom the Software is furnished to do so,
### subject to the following conditions:
###
### The above copyright notice and this permission notice shall be included
### in all copies or substantial portions of the Software.
###
### THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
### EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
### MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
### IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
### CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
### TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
### SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
###========================================================================
defmodule Chronex.Backends do
  ##== Preamble ===========================================================
  @moduledoc """
  Route requests to all the configured backends.
  """


  ##== API ================================================================
  def before(args, context) do
    backends = Application.get_env(:chronex, :backends, [])
    backends
    |> Enum.each(fn(b) -> b.before(args, context) end)
  end

  def after_return(return, context) do
    backends = Application.get_env(:chronex, :backends, [])
    backends
    |> Enum.each(fn(b) -> b.after_return(return, context) end)
  end

  def after_throw(ex, context) do
    backends = Application.get_env(:chronex, :backends, [])
    backends
    |> Enum.each(fn(b) -> b.after_throw(ex, context) end)
  end

  def after_raise(err, context) do
    backends = Application.get_env(:chronex, :backends, [])
    backends
    |> Enum.each(fn(b) -> b.after_raise(err, context) end)
  end
end
