defmodule Barlix.CostOptimizer do
  @moduledoc false

  defmodule Node do
    @moduledoc false

    defstruct parent: nil, cost: 0, state: nil
  end

  def optimize(start, next, max_level) do
    do_optimize([%Node{state: start}], next, 0, max_level)
  end

  defp do_optimize(tree, next, level, max_level) do
    {tree, level} =
      if level == max_level do
        {prune(expand(tree, next), level), level}
      else
        {expand(tree, next), level + 1}
      end

    finished = Enum.all?(tree, &(&1.state.mode == :F))
    (finished && Enum.at(tree, 0).state) || do_optimize(tree, next, level, max_level)
  end

  defp expand(tree, next) do
    Enum.flat_map(tree, fn node ->
      Enum.map(next.(node.state, node.cost), fn {state, cost} ->
        %Node{parent: node, state: state, cost: cost}
      end)
    end)
    |> Enum.sort_by(& &1.cost)
  end

  defp prune(tree, level) do
    min_cost_node = Enum.min_by(tree, & &1.cost)
    min_cost_parent = get_parent(min_cost_node, level)

    Enum.filter(tree, fn node ->
      get_parent(node, level) == min_cost_parent
    end)
  end

  defp get_parent(%Node{parent: nil}, _level), do: raise("node doesn't have enough levels")
  defp get_parent(%Node{parent: parent}, 0), do: parent
  defp get_parent(%Node{parent: parent}, level), do: get_parent(parent, level - 1)
end
