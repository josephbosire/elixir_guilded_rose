defmodule GildedRoseTest do
  use ExUnit.Case
  doctest GildedRose

  test "interface specification" do
    gilded_rose = GildedRose.new()
    [%GildedRose.Item{} | _] = GildedRose.items(gilded_rose)
    assert :ok == GildedRose.update_quality(gilded_rose)
  end

  test "assert item qualtity is never updated to a negative value" do
    agent = get_agent([GildedRose.Item.new("Dummy Item", 10, 0)])
    assert :ok == GildedRose.update_quality(agent)
    assert [%GildedRose.Item{sell_in: 9, quality: 0} | _] = GildedRose.items(agent)
  end

  test "assert item quality and sell in are lowered by 1 at the end of each day" do
    agent = get_agent([GildedRose.Item.new("Dummy Item", 10, 10)])
    assert :ok == GildedRose.update_quality(agent)
    assert [%GildedRose.Item{sell_in: 9, quality: 9} | _] = GildedRose.items(agent)
    assert :ok == GildedRose.update_quality(agent)
    assert [%GildedRose.Item{sell_in: 8, quality: 8} | _] = GildedRose.items(agent)
  end

  test "assert item quality degrades twice as fast if sell in < 0" do
    agent = get_agent([GildedRose.Item.new("Dummy Item", 0, 10)])
    assert :ok == GildedRose.update_quality(agent)
    assert [%GildedRose.Item{sell_in: -1, quality: 8} | _] = GildedRose.items(agent)
  end

  # Maybe add description to skip tag
  test "assert item quality never never degrades to less than 0 if sell in < 0" do
    agent = get_agent([GildedRose.Item.new("Dummy Item", 0, 1)])
    assert :ok == GildedRose.update_quality(agent)
    assert [%GildedRose.Item{sell_in: -1, quality: 0} | _] = GildedRose.items(agent)
  end

  test "assert aged brie increases in quality over time" do
    agent = get_agent([GildedRose.Item.new("Aged Brie", 10, 1)])
    assert :ok == GildedRose.update_quality(agent)
    assert [%GildedRose.Item{sell_in: 9, quality: 2} | _] = GildedRose.items(agent)
  end

  test "assert item qualtity is never more than 50" do
    agent = get_agent([GildedRose.Item.new("Aged Brie", 10, 50)])
    assert :ok == GildedRose.update_quality(agent)
    assert [%GildedRose.Item{sell_in: 9, quality: 50} | _] = GildedRose.items(agent)
  end

  test "assert sulfuras items sell in and quality never decreases" do
    agent = get_agent([GildedRose.Item.new("Sulfuras, Hand of Ragnaros", 10, 80)])
    assert :ok == GildedRose.update_quality(agent)
    assert [%GildedRose.Item{sell_in: 10, quality: 80} | _] = GildedRose.items(agent)
  end

  @tag :skip
  test "assert back stage passes increase in quality while sell in > 0" do
    agent = get_agent([GildedRose.Item.new("Backstage passes to a TAFKAL80ETC concert", 3, 40)])
    assert :ok == GildedRose.update_quality(agent)
    assert [%GildedRose.Item{sell_in: 2, quality: 41} | _] = GildedRose.items(agent)
  end

  @tag :skip
  test "assert back stage passes quality is set to 0 when sell in date passes" do
    agent = get_agent([GildedRose.Item.new("Backstage passes to a TAFKAL80ETC concert", 0, 40)])
    assert :ok == GildedRose.update_quality(agent)
    assert [%GildedRose.Item{sell_in: -1, quality: 0} | _] = GildedRose.items(agent)
  end

  @tag :skip
  test "assert conjured items degrade in quality twice as fast over time" do
    agent = get_agent([GildedRose.Item.new("Conjured Mana Cake", 10, 10)])
    assert :ok == GildedRose.update_quality(agent)
    assert [%GildedRose.Item{sell_in: 9, quality: 8} | _] = GildedRose.items(agent)
  end

  @tag :skip
  test "assert conjured items never degrade below 0 if sell in < 0" do
    agent = get_agent([GildedRose.Item.new("Conjured Mana Cake", 0, 1)])
    assert :ok == GildedRose.update_quality(agent)
    assert [%GildedRose.Item{sell_in: -1, quality: 0} | _] = GildedRose.items(agent)
  end

  defp get_agent(items) do
    {:ok, agent} = Agent.start_link(fn -> items end)
    agent
  end
end
