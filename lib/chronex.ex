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
  A small library to seamlessly add code instrumentation to your Elixir
  projects.

  The documentation for this project is available at
  [HexDocs](https://hexdocs.pm/chronex/api-reference.html).


  ## Quick Start

  `Chronex` implements a dead simple API consisting of only three functions,
  `bind/3`, `unbind/3` and `bound?/3`. All three functions take 3 arguments
  as input. A module name, a function name and an arity. These three arguments
  are used to identify the target function.

  `bind/3` is used to attach a stopwatch to the given function. `unbind/3` is
  used to detach a stopwatch from the given function. Last but not least,
  `bound?/3` is used to check if the given function has a stopwatch attach to
  it.

  > Chronex needs write access to the beam files where the target functions
  > are implemented. Thus, you will need to run as root should you want to
  > experiment adding code instrumentation to core functions.

  ```elixir
  str = "Hello, world!"
  String2.length(str)
  # => 13

  # Attach a stopwatch to String2.length/1
  :ok  = Chronex.bind(String2, :length, 1)
  true = Chronex.bound?(String2, :length, 1)

  String2.length(str)
  # STDOUT: 15:53:09.917 [debug] chronex | hook=:before mfa="Elixir.String2.length/1" args=["Hello, world!"] uuid="39c120fa-3264-11e8-afec-600308a32e10"
  # STDOUT: chronex | hook=:after_return mfa="Elixir.String2.length/1" return=13 duration=0.003 uuid="39c120fa-3264-11e8-afec-600308a32e10"
  # => 13

  # Detach the stopwatch from String2.length/1
  :ok   = Chronex.unbind(String2, :length, 1)
  false = Chronex.bound?(String2, :length, 1)

  String2.length(str)
  # => 13
  ```


  ## Backends

  `Chronex` implements four hooks:

  - `before` - Executed before the target function is called.
  - `after_return` - Executed right after the target function returns.
  - `after_throw` - Executed right after the target function throws a value (i.e.
  `catch` clause in a `try` block).
  - `after_raise` - Executed right after the target function raises an error
  (i.e. `rescue` clause in a `try` block).

  `Chronex` ships with a `Logger` backend that can be used to log interesting
  information surrounding the invocation of the instrumented functions. New
  backends can easily be implemented by simply writting a module that implements
  the four hooks listed above.

  To configure the list of backends, just do as follows:

  ```
  config :chronex, backends: [
  Chronex.Backends.Logger
  ]
  ```

  Note that you can have more than one backend enabled at the same time.

  To configure the log level of the Logger backend, just add the following
  line to your config file:

  ```elixir
  config :chronex, Chronex.Backends.Logger,
  log_level: :debug
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
  @spec bind(atom(), atom(), non_neg_integer()) :: :ok | {:error, :bound}
  def bind(m, f0, a) do
    case bound?(m, f0, a) do
      true  -> {:error, :bound}
      false ->
        f1    = fname(f0)
        args  = args(a)

        fun = {:function, 0, f0, a,
               [{:clause, 0, args, [],
                 [{:match, 0,
                   {:var, 0, :c@0},
                   {:call, 0,
                    {:remote, 0, {:atom, 0, Keyword}, {:atom, 0, :put}},
                    [{nil, 0},
                     {:atom, 0, :m},
                     {:atom, 0, m}]}},
                  {:match, 0,
                   {:var, 0, :c@1},
                   {:call, 0,
                    {:remote, 0, {:atom, 0, Keyword}, {:atom, 0, :put}},
                    [{:var, 0, :c@0},
                     {:atom, 0, :f},
                     {:atom, 0, f0}]}},
                  {:match, 0,
                   {:var, 0, :c@2},
                   {:call, 0,
                    {:remote, 0, {:atom, 0, Keyword}, {:atom, 0, :put}},
                    [{:var, 0, :c@1},
                     {:atom, 0, :a},
                     {:integer, 0, a}]}},
                  {:match, 0,
                   {:var, 0, :c@3},
                   {:call, 0,
                    {:remote, 0, {:atom, 0, Keyword}, {:atom, 0, :put}},
                    [{:var, 0, :c@2},
                     {:atom, 0, :uuid},
                     {:call, 0, {:remote, 0, {:atom, 0, UUID}, {:atom, 0, :uuid1}},
                      []}]}},
                  {:call, 0,
                   {:remote, 0, {:atom, 0, Chronex.Backends}, {:atom, 0, :before}},
                   [list_to_cons(args),
                    {:var, 0, :c@3}]},
                  {:match, 0,
                   {:var, 0, :t0},
                   {:call, 0,
                    {:remote, 0, {:atom, 0, System}, {:atom, 0, :monotonic_time}},
                    []}},
                  {:try, 0,
                   [{:match, 0,
                     {:var, 0, :v},
                     {:call, 0, {:atom, 0, f1}, args}},
                    {:match, 0,
                     {:var, 0, :t1},
                     {:call, 0,
                      {:remote, 0, {:atom, 0, System}, {:atom, 0, :monotonic_time}},
                      []}},
                    {:match, 0,
                     {:var, 0, :t},
                     {:call, 0,
                      {:remote, 0, {:atom, 0, Chronex.Utils}, {:atom, 0, :diff}},
                      [{:var, 0, :t0},
                       {:var, 0, :t1}]}},
                    {:match, 0,
                     {:var, 0, :c@4},
                     {:call, 0,
                      {:remote, 0, {:atom, 0, Keyword}, {:atom, 0, :put}},
                      [{:var, 0, :c@3},
                       {:atom, 0, :duration},
                       {:var, 0, :t}]}},
                    {:call, 0,
                     {:remote, 0, {:atom, 0, Chronex.Backends}, {:atom, 0, :after_return}},
                     [{:var, 0, :v},
                      {:var, 0, :c@4}]},
                    {:var, 0, :v}],
                   [],
                   [{:clause, 0, # rescue
                     [{:tuple, 0,
                       [{:atom, 0, :error}, {:var, 0, :_@2}, {:var, 0, :_}]}],
                     [],
                     [{:match, 0, {:var, 0, :e@1},
                       {:call, 0,
                        {:remote, 0, {:atom, 0, Exception}, {:atom, 0, :normalize}},
                        [{:atom, 0, :error}, {:var, 0, :_@2}]}},
                      {:match, 0,
                       {:var, 0, :t1@c},
                       {:call, 0,
                        {:remote, 0, {:atom, 0, System}, {:atom, 0, :monotonic_time}},
                        []}},
                      {:match, 0,
                       {:var, 0, :t@c},
                       {:call, 0,
                        {:remote, 0, {:atom, 0, Chronex.Utils}, {:atom, 0, :diff}},
                        [{:var, 0, :t0},
                         {:var, 0, :t1@c}]}},
                      {:match, 0,
                       {:var, 0, :c@4c},
                       {:call, 0,
                        {:remote, 0, {:atom, 0, Keyword}, {:atom, 0, :put}},
                        [{:var, 0, :c@3},
                         {:atom, 0, :duration},
                         {:var, 0, :t@c}]}},
                      {:call, 0,
                       {:remote, 0, {:atom, 0, Chronex.Backends}, {:atom, 0, :after_raise}},
                       [{:var, 0, :e@1},
                        {:var, 0, :c@4c}]},
                      {:call, 0,
                       {:remote, 0, {:atom, 0, :erlang}, {:atom, 0, :error}},
                       [{:call, 0,
                         {:remote, 0, {:atom, 0, Kernel.Utils}, {:atom, 0, :raise}},
                         [{:var, 0, :e@1}]}]}]},
                    {:clause, 0, # catch
                     [{:tuple, 0,
                       [{:atom, 0, :throw}, {:var, 0, :e@2}, {:var, 0, :_}]}],
                     [],
                     [{:match, 0,
                       {:var, 0, :t1@c},
                       {:call, 0,
                        {:remote, 0, {:atom, 0, System}, {:atom, 0, :monotonic_time}},
                        []}},
                      {:match, 0,
                       {:var, 0, :t@c},
                       {:call, 0,
                        {:remote, 0, {:atom, 0, Chronex.Utils}, {:atom, 0, :diff}},
                        [{:var, 0, :t0},
                         {:var, 0, :t1@c}]}},
                      {:match, 0,
                       {:var, 0, :c@4c},
                       {:call, 0,
                        {:remote, 0, {:atom, 0, Keyword}, {:atom, 0, :put}},
                        [{:var, 0, :c@3},
                         {:atom, 0, :duration},
                         {:var, 0, :t@c}]}},
                      {:call, 0,
                       {:remote, 0, {:atom, 0, Chronex.Backends}, {:atom, 0, :after_throw}},
                       [{:var, 0, :e@2},
                        {:var, 0, :c@4c}]},
                      {:call, 0,
                       {:remote, 0, {:atom, 0, :erlang}, {:atom, 0, :throw}},
                       [{:var, 0, :e@2}]}]}],
                   []}
                 ]}]}

        forms = :forms.read(m)
        forms = :meta.rename_function(f0, a, f1, false, forms)
        forms = :meta.add_function(fun, false, forms)
        :meta.apply_changes(forms, [:force, :permanent])
        :ok
    end
  end

  @doc """
  Check if the given function has a stopwatch attached to it.
  """
  @spec bound?(atom(), atom(), non_neg_integer()) :: boolean()
  def bound?(m, f0, a) do
    f1 = fname(f0)
    :meta.has_function(f1, a, m)
  end

  @doc """
  Detach a stopwatch from the given function.
  """
  @spec unbind(atom(), atom(), non_neg_integer()) :: :ok | {:error, :unbound}
  def unbind(m, f0, a) do
    case bound?(m, f0, a) do
      false -> {:error, :unbound}
      true  ->
        f1    = fname(f0)
        forms = :forms.read(m)
        forms = :meta.rm_function(f0, a, false, forms)
        forms = :meta.rename_function(f1, a, f0, false, forms)
        :meta.apply_changes(forms, [:force, :permanent])
        :ok
    end
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
    {:cons, 0, h, list_to_cons(tail)}
  end
end
