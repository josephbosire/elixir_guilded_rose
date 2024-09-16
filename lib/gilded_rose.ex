defmodule GildedRose do
  use Agent
  alias GildedRose.Item

  @max_item_quality 50
  @min_item_quality 0

  def new() do
    {:ok, agent} =
      Agent.start_link(fn ->
        [
          Item.new("+5 Dexterity Vest", 10, 20),
          Item.new("Aged Brie", 2, 0),
          Item.new("Elixir of the Mongoose", 5, 7),
          Item.new("Sulfuras, Hand of Ragnaros", 0, 80),
          Item.new("Backstage passes to a TAFKAL80ETC concert", 15, 20),
          Item.new("Conjured Mana Cake", 3, 6)
        ]
      end)

    agent
  end

  def items(agent), do: Agent.get(agent, & &1)

  def update_quality(agent) do
    for i <- 0..(Agent.get(agent, &length/1) - 1) do
      item = Agent.get(agent, &Enum.at(&1, i))
      item = update_item_quality(item)
      Agent.update(agent, &List.replace_at(&1, i, item))
    end

    :ok
  end

  @spec update_item_quality(%Item{}) :: %Item{}
  def update_item_quality(%Item{name: "Sulfuras, Hand of Ragnaros"} = item), do: item

  def update_item_quality(%Item{name: "Aged Brie"} = item) do
    item
    |> increase_quality()
    |> decrease_sell_in()
  end

  def update_item_quality(
        %Item{
          name: "Backstage passes to a TAFKAL80ETC concert",
          sell_in: sell_in,
          quality: quality
        } = item
      )
      when quality < 50 and sell_in > 0 do
    item |> increase_quality() |> decrease_sell_in()
  end

  def update_item_quality(
        %Item{
          name: "Backstage passes to a TAFKAL80ETC concert"
        } = item
      ) do
    item |> reset_quality_to_zero() |> decrease_sell_in()
  end

  def update_item_quality(%Item{quality: @min_item_quality} = item) do
    decrease_sell_in(item)
  end

  def update_item_quality(%Item{quality: @max_item_quality} = item) do
    decrease_sell_in(item)
  end

  def update_item_quality(%Item{sell_in: sell_in} = item) when sell_in > 0 do
    item |> decrease_quality() |> decrease_sell_in()
  end

  def update_item_quality(%Item{sell_in: sell_in} = item) when sell_in <= 0 do
    item |> decrease_quality(2) |> decrease_sell_in()
  end

  defp decrease_quality(item, decrease_by \\ 1) do
    quality = item.quality
    updated_quality = max(quality - decrease_by, 0)
    %{item | quality: updated_quality}
  end

  defp increase_quality(%Item{quality: quality} = item) when quality < @max_item_quality do
    %{item | quality: quality + 1}
  end

  defp increase_quality(item), do: item

  defp reset_quality_to_zero(%Item{} = item) do
    %{item | quality: 0}
  end

  defp decrease_sell_in(%Item{sell_in: sell_in} = item) do
    %{item | sell_in: sell_in - 1}
  end
end
