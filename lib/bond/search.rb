module Bond
  # Contains search methods used to filter possible completions given what the user has typed for that completion.
  module Search
    # Searches completions from the beginning of the string.
    def default_search(input, list)
      list.grep(/^#{input}/)
    end

    # Searches completions anywhere in the string.
    def anywhere_search(input, list)
      list.grep(/#{input}/)
    end

    # Searches completions from the beginning and ignores case.
    def ignore_case_search(input, list)
      list.grep(/^#{input}/i)
    end

    # Searches completions from the beginning but also provides aliasing of underscored words.
    # For example 'some_dang_long_word' can be specified as 's-d-l-w'. Aliases can be any unique string
    # at the beginning of an underscored word. For example, to choose the first completion between 'so_long' and 'so_larger',
    # type 's-lo'.
    def underscore_search(input, list)
      split_input = input.split("-").join("")
      list.select {|c|
        c.split("_").map {|g| g[0,1] }.join("") =~ /^#{split_input}/ || c =~ /^#{input}/
      }
    end
  end
end