###========================================================================
### File: chronex_spec.exs
###
### Unit tests.
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
defmodule ChronexSpec do
  ##== Preamble ===========================================================
  use ESpec

  ##== Configuration ======================================================
  before do
    Code.append_path("spec/lib")
    Chronex.unbind(String2, :length, 1)
    Chronex.unbind(String2, :throw_test, 1)

    allow Logger
    |> to(accept :bare_log, fn(_level, _msg) -> :ok end,
    [:non_strict, :passthrough, :unstick])
  end

  ##== Tests ==============================================================
  describe """
  when no stopwatch is attached to String2.length/1
  """ do
    it "no information is logged when String2.length/1 is called" do
      str = "Hello, world!"
      len = String2.length(str)

      expect len |> to(eq 13)
      expect Logger |> to(accepted :bare_log, :any, count: 0)
    end
  end

  describe """
  when a stopwatch is attached to String2.length/1
  """ do
    it """
    information is logged when String2.length/1 is called and it returns
    normally
    """ do
      :ok = Chronex.bind(String2, :length, 1)

      str = "Hello, world!"
      len = String2.length(str)

      expect len |> to(eq 13)
      expect Logger |> to(accepted :bare_log, :any, count: 2)
    end

    it """
    information is logged when String2.length/1 is called and it raises
    an exception
    """ do
      :ok = Chronex.bind(String2, :length, 1)

      str = :hello_world
      expect(fn() -> String2.length(str) end) |> to(raise_exception())
      expect Logger |> to(accepted :bare_log, :any, count: 2)
    end

    it """
    information is logged when String2.length/1 is called and it throws
    a value
    """ do
      :ok = Chronex.bind(String2, :throw_test, 1)

      str = "Hello, world!"
      expect(fn() -> String2.throw_test(str) end) |> to(throw_term str)
      expect Logger |> to(accepted :bare_log, :any, count: 2)
    end

  end

  describe """
  when a stopwatch is first attached and then detached from String2.length/1
  """ do
    it """
    no information is logged when String2.length/1 is called after the stopwatch
    is detached
    """ do
      :ok = Chronex.bind(String2, :length, 1)

      str = "Hello, world!"
      len = String2.length(str)

      expect len |> to(eq 13)
      expect Logger |> to(accepted :bare_log, :any, count: 2)

      :ok = Chronex.unbind(String2, :length, 1)

      len = String2.length(str)

      expect len |> to(eq 13)
      expect Logger |> to(accepted :bare_log, :any, count: 2)
    end
  end
end
