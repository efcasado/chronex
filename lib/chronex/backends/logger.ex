###========================================================================
### File: logger.ex
###
### A Logger backend for Chronex.
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
defmodule Chronex.Backends.Logger do
  ##== Preamble ===========================================================
  @moduledoc """
  A Logger backend for Chronex.
  """

  require Logger


  ##== API ================================================================
  def before(args, context) do
    level = Application.get_env(Chronex.Backends.Logger, :log_level, :debug)
    log(level, :before, "args=#{inspect args}", context)
  end

  def after_return(return, context) do
    level = Application.get_env(Chronex.Backends.Logger, :log_level, :debug)
    log(level, :after_return, "return=#{inspect return}", context)
  end

  def after_throw(ex, context) do
    level = Application.get_env(Chronex.Backends.Logger, :log_level, :debug)
    log(level, :after_throw, "ex=#{inspect ex}", context)
  end

  def after_raise(err, context) do
    level = Application.get_env(Chronex.Backends.Logger, :log_level, :debug)
    err = Exception.message(err)
    log(level, :after_raise, "err=#{inspect err}", context)
  end


  ##== Local functions ====================================================
  defp log(level, hook, msg, ctx) do
    {m, ctx} = Keyword.pop(ctx, :m)
    {f, ctx} = Keyword.pop(ctx, :f)
    {a, ctx} = Keyword.pop(ctx, :a)
    mfa = {m, f, a}
    mfa = format_mfa(mfa)
    ctx = format_context(ctx)
    pre = "chronex | hook=#{inspect hook} mfa=#{inspect mfa}"
    msg = Enum.join([pre, msg, ctx], " ")
    Logger.bare_log(level, msg)
  end

  defp format_mfa({m, f, a}), do: "#{m}.#{f}/#{a}"

  defp format_context(context) do
    context
    |> Enum.map(fn({k, v}) -> "#{k}=#{inspect v}" end)
    |> Enum.join(" ")
  end
end
