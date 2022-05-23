defmodule HomeworkTest do
  # Import helpers
  use Hound.Helpers
  use ExUnit.Case

  defmacro assert_sof(assertion) do
    quote do
      try do
        assert unquote(assertion)
      rescue
        error ->
          take_screenshot()
          raise error
      end
    end
  end

  def element_visible?(element, retries \\ 5) do
    if retries > 0 do
      case element_displayed?(element) do
        true -> true
        false ->
          :timer.sleep(@retry_time)
          element_visible?(element, retries - 1)
      end
    else
      element_displayed?(element)
    end
  end

  # Start hound session and destroy when tests are run
  hound_session()

  test "Checkboxes" do
    navigate_to("https://the-internet.herokuapp.com/")
    checkbox_page = find_element(:xpath, ~s|//*[@id="content"]/ul/li[6]/a|)
    click(checkbox_page)
    checkbox1 = find_element(:xpath, ~s|//*[@id="checkboxes"]/input[1]|)
    checkbox2 = find_element(:xpath, ~s|//*[@id="checkboxes"]/input[2]|)
    # default selected checkbox 2
    assert_sof selected?(checkbox2) == true
    # check both the checkbox, checkbox1 true and checkbox 2 false as this was default selected
    click(checkbox1)
    assert_sof selected?(checkbox1) == true
    click(checkbox1)
    assert_sof selected?(checkbox1) == false

    click(checkbox2)
    assert_sof selected?(checkbox2) == false
    click(checkbox2)
    assert_sof selected?(checkbox2) == true
  end

  test "Add/Remove Elements" do
    navigate_to("https://the-internet.herokuapp.com/")
    add_remove_ele_page = find_element(:xpath, ~s|//*[@id="content"]/ul/li[2]/a|)
    click(add_remove_ele_page)
    add_ele_button = find_element(:xpath, ~s|//*[@id="content"]/div/button|)
    click(add_ele_button)
    assert_sof element_visible?(find_element(:xpath, ~s|//*[@id="elements"]/button|)) == true
    # element deleted
    click(find_element(:xpath, ~s|//*[@id="elements"]/button|))
    delete_found = match?({:ok, _}, search_element(:xpath, ~s|//*[@id="elements"]/button|))
    assert_sof delete_found == false
  end

  test "redirect link" do
    navigate_to("https://the-internet.herokuapp.com/")
    redirect_page = find_element(:xpath, ~s|//*[@id="content"]/ul/li[36]/a|)
    click(redirect_page)
    assert_sof element_visible?(find_element(:xpath, ~s|//a[@href='redirect']|)) == true
    click(find_element(:xpath, ~s|//a[@href='redirect']|))
    assert_sof current_path() == "/status_codes"
  end

  test "Status Codes" do
    navigate_to("https://the-internet.herokuapp.com/")
    status_codes_page = find_element(:xpath, ~s|//*[@id="content"]/ul/li[42]/a|)
    click(status_codes_page)
    status_codes = [200, 301, 404, 500]
    for each_code <- status_codes do
      click(find_element(:xpath, "//a[@href='status_codes/#{each_code}']") )
      assert_sof current_path() == "/status_codes/#{each_code}"
      click(find_element(:xpath, "//a[@href='/status_codes']"))
    end
  end

  test "Multiple Windows" do
    navigate_to("https://the-internet.herokuapp.com/")
    multiple_windows_page = find_element(:xpath, ~s|//*[@id="content"]/ul/li[33]/a|)
    click(multiple_windows_page)
    find_element(:xpath, ~s|//a[@href='/windows/new']|) |> click()
    assert_sof current_url() == "https://the-internet.herokuapp.com/windows"
    assert_sof current_path() == "/windows"
  end

end
