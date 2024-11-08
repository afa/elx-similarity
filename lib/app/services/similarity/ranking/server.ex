defmodule Similarity.Ranking.Server do
  @moduledoc """
  api and impl for ranking processes server
  TODO 
  """

  use GenServer
  alias Similarity.Ranking

  def test(who) do
    GenServer.call(who, {:chk, 1}, 10_000)
    GenServer.cast(who, {:tokenize, 1})
    GenServer.call(who, {:chk, 2}, 10_100)
  end

  @doc """
  imports counts to ets db, store cache id to state
  """
  @impl true
  def init(data) do
    ets = :ets.new(:token_counts, [])
    initial_state = %{cache: ets}
    {:ok, initial_state}
  end

  @doc """
  tokenizes document^ updates counts, store tokens & counts to db

  params:
  doc_id: internal document id

  TODO: send signal to queue server when done
  """
  @impl true
  def handle_cast({:tokenize, doc_id}, state) do
    {:noreply, state}
  end

  @doc """
  ranking document, store ranks to db. use counts from :ets

  params:
  doc_id: internal document id
  TODO: send signal to queue server
  """
  @impl true
  def handle_cast({:rank, doc_id}, state) do
    {:noreply, state}
  end
end
