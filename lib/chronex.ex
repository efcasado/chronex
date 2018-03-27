###========================================================================
### File: chronex.ex
###
### A small library to seamlessly add instrumentation to your Elixir code.
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
defmodule Chronex do
  ##== Preamble ===========================================================
  @moduledoc """
  # Chronex
  A small library to seamlessly add instrumentation to your Elixir code.


  ## Quick Start

  `Chronex` implements a dead simple API consisting of only one function,
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
  :ok  = Chronex.bind(String, :length, 1)

  String.length(str)
  # STDOUT: 15:53:09.917 [debug] chronex | 'Elixir.String':length/1 returned in 0.006 ms
  # => 13

  # Detach the stopwatch from String.length/1 by means of a code reload
  l(String)

  String.length(str)
  # => 13
  ```


  ## Configuration

  `Chronex` will use a `:debug` log level by default. You can change the log
  level used by `Chronex` by simply setting `Chronex`'s `log_level` to the
  desired value.

  ```elixir
  config :chronex, log_level: :info
  ```
  """

  @prefix "#chronex"


  ##== API ================================================================
  @doc """
  Attach a stopwatch to the given function. The stopwatch is started on
  every function call targetting the given function. It measures how long
  it takes for the given function to run. All measurements are handled
  by the Logger application.
  """
  @spec bind(atom(), atom(), non_neg_integer()) :: :ok
  def bind(m, f0, a) do
    f1    = fname(f0)
    args  = args(a)
    msg   = list_to_cons('chronex | ~p:~p/~p returned in ~p ms\n')

    fun = {:function, 0, f0, a,
           [{:clause, 0, args, [],
             [{:match, 0,
               {:tuple, 0, [{:var, 0, :t0}, {:var, 0, :v}]},
               {:call, 0,
                {:remote, 0, {:atom, 0, :timer}, {:atom, 0, :tc}},
                [{:fun, 0, {:clauses,
                            [{:clause, 0, [], [],
                              [{:call, 0, {:atom, 0, f1}, args}]}]}}]}},
              {:match, 0,
               {:var, 0, :t1},
               {:op, 0, :/, {:var, 0, :t0}, {:integer, 0, 1000}}},
              {:match, 0,
               {:var, 0, :level},
               {:call, 0,
                {:remote, 0, {:atom, 0, Application}, {:atom, 0, :get_env}},
                [{:atom, 0, :chronex},
                 {:atom, 0, :log_evel},
                 {:atom, 0, :debug}]}},
              {:match, 0,
               {:var, 0, :msg},
               {:call, 0,
                {:remote, 0, {:atom, 0, :io_lib}, {:atom, 0, :format}},
                [msg,
                 {:cons, 0, {:atom, 0, m},
                  {:cons, 0, {:atom, 0, f0},
                   {:cons, 0, {:integer, 0, a},
                    {:cons, 0, {:var, 0, :t1},
                     {nil, 0}}}}}]}},
              {:call, 0,
               {:remote, 0, {:atom, 0, Logger}, {:atom, 0, :bare_log}},
               [{:var, 0, :level},
                {:var, 0, :msg}]},
              {:var, 0, :v}]}]}

    forms = :forms.read(m)
    forms = :meta.rename_function(f0, a, f1, false, forms)
    forms = :meta.add_function(fun, false, forms)
    :meta.apply_changes(forms)
    :ok
  end


  ##== Local functions ====================================================
  defp fname(fname) do
    Enum.join([@prefix, Atom.to_string(fname)], "_")
    |> String.to_atom
  end

  defp args(arity) do
    1..arity
    |> Enum.map(
    fn(nth) ->
      var = String.to_atom("$#{nth}")
      {:var, 0, var}
    end)
  end

  defp list_to_cons([]) do
    {:nil, 0}
  end
  defp list_to_cons([h| tail]) do
    {:cons, 0, {:integer, 0, h}, list_to_cons(tail)}
  end
end
